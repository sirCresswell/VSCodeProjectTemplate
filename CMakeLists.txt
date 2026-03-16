# ---------------------------------------------------------
# Automatically derive project/library name from folder
# ---------------------------------------------------------
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" PROJECT_NAME ${PROJECT_NAME})

cmake_minimum_required(VERSION 3.20)
project(${PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---------------------------------------------------------
# Git tag–based versioning
# ---------------------------------------------------------
find_package(Git QUIET)

if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --always
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
else()
    set(GIT_VERSION "0.0.0-unknown")
endif()

message(STATUS "Detected version: ${GIT_VERSION}")

# Allow user to choose static/shared
option(${PROJECT_NAME}_BUILD_SHARED "Build ${PROJECT_NAME} as a shared library" ON)

# ---------------------------------------------------------
# Auto-discover all source files in source/
# ---------------------------------------------------------
file(GLOB_RECURSE ${PROJECT_NAME}_SOURCES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/**/*.cpp"
)

file(GLOB_RECURSE ${PROJECT_NAME}_HEADERS
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/**/*.h"
)

# ---------------------------------------------------------
# Exclude platform folders from auto-discovery
# ---------------------------------------------------------
list(FILTER ${PROJECT_NAME}_SOURCES EXCLUDE REGEX "source/platform/windows")
list(FILTER ${PROJECT_NAME}_SOURCES EXCLUDE REGEX "source/platform/linux")
list(FILTER ${PROJECT_NAME}_SOURCES EXCLUDE REGEX "source/platform/macos")

# ---------------------------------------------------------
# Add platform-specific sources
# ---------------------------------------------------------
if(WIN32)
    file(GLOB_RECURSE PLATFORM_SOURCES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/windows/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/windows/*.h"
    )
elseif(APPLE)
    file(GLOB_RECURSE PLATFORM_SOURCES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/macos/*.mm"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/macos/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/macos/*.h"
    )
elseif(UNIX)
    file(GLOB_RECURSE PLATFORM_SOURCES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/linux/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/linux/*.h"
    )
elseif(ANDROID)
    file(GLOB_RECURSE PLATFORM_SOURCES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/android/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/android/*.h"
    )
elseif(IOS)
    file(GLOB_RECURSE PLATFORM_SOURCES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/ios/*.mm"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/ios/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/ios/*.h"
    )
endif()

# ---------------------------------------------------------
# Build the shared library
# ---------------------------------------------------------
add_library(${PROJECT_NAME} SHARED
    ${${PROJECT_NAME}_SOURCES}
    ${${PROJECT_NAME}_HEADERS}
    ${PLATFORM_SOURCES}
)

target_compile_definitions(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_BUILD_DLL)

# ---------------------------------------------------------
# Install rules
# ---------------------------------------------------------
include(GNUInstallDirs)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# ---------------------------------------------------------
# Version header
# ---------------------------------------------------------
set(GIT_VERSION "${GIT_VERSION}")

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/generated/${PROJECT_NAME}_version.h
    @ONLY
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
)

# ---------------------------------------------------------
# Add example folder
# ---------------------------------------------------------
add_subdirectory(example)
