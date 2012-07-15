project("gpolkit" C)

cmake_minimum_required(VERSION 2.6)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake/vala
)

find_package(Vala REQUIRED)
include(UseVala)
include(GNUInstallDirs)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
pkg_check_modules(GEE REQUIRED gee-1.0)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(DBUS-GLIB REQUIRED dbus-glib-1)
pkg_check_modules(DBUS REQUIRED dbus-1)
pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(POLBACK REQUIRED polkit-backend-1)

# Check for the version
#ensure_vala_version("0.16.1" MINIMUM)

set(GPOLKIT_DATADIR ${CMAKE_INSTALL_DATADIR}/gpolkit)
set(GPOLKIT_FULL_DATADIR ${CMAKE_INSTALL_FULL_DATADIR}/gpolkit)
set(POLKIT_ACTIONDIR ${CMAKE_INSTALL_FULL_DATADIR}/polkit-1/actions)

# Configure environment
configure_file(Common/Environment.vala.in ${CMAKE_SOURCE_DIR}/Common/Environment.vala)

# Compile VALA files
vala_precompile(VALA_C
SOURCES
main.vala
Program.vala
Gui/MainWindow.vala
Gui/TreeStoreProxy.vala
Common/GActionDescriptor.vala
Common/Environment.vala
Common/GPolkitHelperInterface.vala

PACKAGES
gtk+-3.0
gmodule-2.0
gee-1.0

CUSTOM_VAPIS
${CMAKE_SOURCE_DIR}/Helper/polkit-1.0.vapi
)

add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER} ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER} ${GMODULE_CFLAGS} ${GMODULE_CFLAGS_OTHER} ${DBUS_CFLAGS} ${DBUS_CFLAGS_OTHER} ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER} ${DBUS-GLIB_CFLAGS} ${DBUS-GLIB_CFLAGS_OTHER} ${POLBACK_CFLAGS} ${POLBACK_CFLAGS_OTHER} -DGPOLKIT_DATADIR="${GPOLKIT_DATADIR}")
link_directories(${GTK_LIBRARY_DIRS} ${GEE_LIBRARY_DIRS} ${GMODUlE_LIBRARY_DIRS} ${DBUS_LIBRARY_DIRS} ${DBUS-GLIB_LIBRARY_DIRS} ${GLIB_LIBRARY_DIRS} ${POLBACK_LIBRARY_DIRS})
add_executable(gpolkit ${VALA_C})
target_link_libraries(gpolkit ${GTK_LIBRARIES} ${GEE_LIBRARIES} ${GMODULE_LIBRARIES} ${DBUS_LIBRARIES} ${DBUS-GLIB_LIBRARIES} ${GLIB_LIBRARIES} ${POLBACK_LIBRARIES})

install(TARGETS gpolkit DESTINATION ${CMAKE_INSTALL_BINDIR})

add_subdirectory(Helper)
add_subdirectory(Gui)
