project("gpolkit" C)

cmake_minimum_required(VERSION 2.6)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake/vala
)

find_package(Vala REQUIRED)
include(UseVala)
include(GNUInstallDirs)

set(GPOLKIT_DATADIR ${CMAKE_INSTALL_DATADIR}/gpolkit)
set(GPOLKIT_FULL_DATADIR ${CMAKE_INSTALL_FULL_DATADIR}/gpolkit)
set(POLKIT_ACTIONDIR ${CMAKE_INSTALL_FULL_DATADIR}/polkit-1/actions)
set(POLKIT_EXPLICIT_VAR_DIR /${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1/localauthority)
set(POLKIT_EXPLICIT_ETC_DIR /${CMAKE_INSTALL_SYSCONFDIR}/polkit-1/localauthority)
set(GPOLKIT_COMMON_INCLUDE_DIR ${CMAKE_BINARY_DIR}/common)

add_subdirectory(common)
add_subdirectory(gpolkit)
add_subdirectory(gpolkithelper)

