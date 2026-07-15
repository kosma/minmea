cmake_minimum_required(VERSION 3.10)

project(minmea
    VERSION 1.0.0
    LANGUAGES C
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# -------------------------------------------------
# Options
# -------------------------------------------------
option(MINMEA_BUILD_EXAMPLES "Build example program" ON)
option(MINMEA_ENABLE_TESTING "Build and run tests" ON)
option(MINMEA_INSTALL "Enable installation rules" ON)

# -------------------------------------------------
# Library
# -------------------------------------------------
add_library(minmea minmea.c minmea.h)

add_library(minmea::minmea ALIAS minmea)

target_compile_features(minmea PRIVATE c_std_99)

if(MSVC)
    target_compile_options(minmea PRIVATE /W4)
    target_compile_definitions(minmea PRIVATE MINMEA_INCLUDE_COMPAT)
else()
    target_compile_options(minmea PRIVATE -Wall -Wextra)
endif()

if(NOT WIN32)
    target_compile_definitions(minmea PRIVATE
        _POSIX_C_SOURCE=199309L
        _BSD_SOURCE
        _DEFAULT_SOURCE
        _DARWIN_C_SOURCE
    )
endif()

target_include_directories(minmea
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# -------------------------------------------------
# Example
# -------------------------------------------------
if(MINMEA_BUILD_EXAMPLES)
    add_executable(example example.c)
    target_link_libraries(example PRIVATE minmea)
endif()

# -------------------------------------------------
# Tests
# -------------------------------------------------
if(MINMEA_ENABLE_TESTING AND PROJECT_IS_TOP_LEVEL)
    enable_testing()

    find_package(Threads REQUIRED)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(CHECK REQUIRED check)

    add_executable(tests tests.c)

    target_link_libraries(tests PRIVATE
        minmea
        Threads::Threads
        ${CHECK_LIBRARIES}
    )

    target_include_directories(tests PRIVATE
        ${CHECK_INCLUDE_DIRS}
    )

    target_compile_options(tests PRIVATE
        ${CHECK_CFLAGS_OTHER}
    )

    add_test(NAME tests COMMAND tests)

    # Optional static analysis hook (kept simple)
    add_test(
        NAME clang_static_analysis
        COMMAND scan-build --status-bugs ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR}
    )
endif()

# -------------------------------------------------
# Installation + Export
# -------------------------------------------------
if(MINMEA_INSTALL)
    install(TARGETS minmea
        EXPORT minmeaTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    install(FILES minmea.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    if(MSVC)
        install(FILES
            compat/minmea_compat_windows.h
            DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/compat"
        )
    endif()

    install(EXPORT minmeaTargets
        FILE minmeaTargets.cmake
        NAMESPACE minmea::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/minmea
    )

    # Package config
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/minmeaConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    configure_package_config_file(
        "${CMAKE_CURRENT_LIST_DIR}/cmake/minmeaConfig.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/minmeaConfig.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/minmea
    )

    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/minmeaConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/minmeaConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/minmea
    )
endif()
