find_package(PkgConfig)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(XML REQUIRED libxml-2.0)
pkg_check_modules(POLBACK REQUIRED polkit-backend-1)

vala_precompile(VALA_C

SOURCES
GPolkitHelper.vala

PACKAGES
gee-1.0
gio-2.0
libxml-2.0

CUSTOM_VAPIS
${CMAKE_SOURCE_DIR}/gpolkithelper/polkit-1.0.vapi
${CMAKE_BINARY_DIR}/common/gpolkitcommon.vapi
)

set(CMAKE_INSTALL_DBUS_SERVICESDIR ${CMAKE_INSTALL_DATADIR}/dbus-1/services)
set(CMAKE_INSTALL_DBUS_INTERFACESDIR ${CMAKE_INSTALL_DATADIR}/dbus-1/interfaces)

# Borrowed from the kcm polkit module
function(dbus_add_activation_system_service _sources)
    pkg_search_module( DBUS dbus-1 )
    foreach (_i ${_sources})
        get_filename_component(_service_file ${_i} ABSOLUTE)
        string(REGEX REPLACE "\\.service.*$" ".service" _output_file ${_i})
        set(_target ${CMAKE_CURRENT_BINARY_DIR}/${_output_file})
        configure_file(${_service_file} ${_target})
        install(FILES ${_target} DESTINATION ${CMAKE_INSTALL_DBUS_SERVICESDIR} )
    endforeach (_i ${ARGN})
endfunction(dbus_add_activation_system_service _sources)

include_directories(${GPOLKIT_COMMON_INCLUDE_DIR})
add_definitions(${GEE_CFLAGS} ${GEE_CFLAGS_OTHER} ${DBUS_CFLAGS} ${DBUS_CFLAGS_OTHER} ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER} ${DBUS-GLIB_CFLAGS} ${DBUS-GLIB_CFLAGS_OTHER} ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER} ${XML_CFLAGS} ${XML_CFLAGS_OTHER} ${POLBACK_CFLAGS} ${POLBACK_CFLAGS_OTHER})
link_directories(${GEE_LIBRARY_DIRS}${DBUS_LIBRARY_DIRS} ${DBUS-GLIB_LIBRARY_DIRS} ${GLIB_LIBRARY_DIRS} ${GIO_LIBRARY_DIRS} ${XML_LIBRARY_DIRS} ${POLBACK_LIBRARY_DIRS})
add_executable(gpolkithelper ${VALA_C})
target_link_libraries(gpolkithelper gpolkitcommon ${GEE_LIBRARIES} ${DBUS_LIBRARIES} ${DBUS-GLIB_LIBRARIES} ${GLIB_LIBRARIES} ${GIO_LIBRARIES} ${XML_LIBRARIES} ${POLBACK_LIBRARIES})

install(TARGETS gpolkithelper DESTINATION ${CMAKE_INSTALL_LIBEXECDIR})
install(FILES org.gnome.gpolkit.helper.conf DESTINATION /${CMAKE_INSTALL_SYSCONFDIR}/dbus-1/system.d)
install(FILES org.gnome.gpolkit.helper.xml DESTINATION ${CMAKE_INSTALL_DBUS_INTERFACESDIR} )
dbus_add_activation_system_service(org.gnome.gpolkit.helper.service.in)

