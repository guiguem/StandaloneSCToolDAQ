# CMakeLists for Jarvis
# Author: N. Oblath

# Minimum cmake verison 3.1 required for the variable CMAKE_CXX_STANDARD
cmake_minimum_required (VERSION 3.1)

#########
# Setup #
#########

set(PROJECT_NAME Jarvis)
set(PROJECT_VERSION 0.0.1)

cmake_policy( SET CMP0048 NEW ) # version in project()
cmake_policy(SET CMP0024 NEW)
cmake_policy(SET CMP0057 NEW)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION})

list( APPEND CMAKE_MODULE_PATH
        ${PROJECT_SOURCE_DIR}/cmake )
include( PackageBuilder )

pbuilder_prepare_project()

set( PUBLIC_EXT_LIBS )

# Jarvis CMake files
# list( APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake )
# include( Jarvis )


#################
# Jarvis options #
#################

# require C++14
#set_option( USE_CPP11 FALSE )
#set_option( USE_CPP14 TRUE )
set(CMAKE_CXX_STANDARD 14)

# Build the Jarvis executable (also requires Jarvis_ENABLE_EXECUTABLES)
option( Jarvis_BUILD_MAIN_EXE "Flag to build the Jarvis main executable; also requires Jarvis_ENABLE_EXECUTABLES" ON )

# Build python bindings (requires boost::python)
option( Jarvis_BUILD_PYTHON "Build python bindings (JarvisPy)" ON )

# Add a "Standard" build type
#set (CMAKE_BUILD_TYPE standard)
set (CMAKE_CXX_FLAGS_STANDARD "-O1 -DNDEBUG -DSTANDARD" CACHE STRING "Flags used by the compiler during standard builds.")
set (CMAKE_C_FLAGS_STANDARD "-O1 -DNDEBUG -DSTANDARD" CACHE STRING "Flags used by the compiler during standard builds.")
set (CMAKE_EXE_LINKER_FLAGS_STANDARD "" CACHE STRING "Flags used by the linker during standard builds.")
set (CMAKE_MODULE_LINKER_FLAGS_STANDARD "" CACHE STRING "Flags used by the linker during standard builds.")
set (CMAKE_SHARED_LINKER_FLAGS_STANDARD "" CACHE STRING "Flags used by the linker during standard builds.")
mark_as_advanced(CMAKE_CXX_FLAGS_STANDARD CMAKE_C_FLAGS_STANDARD CMAKE_EXE_LINKER_FLAGS_STANDARD CMAKE_MODULE_LINKER_FLAGS_STANDARD CMAKE_SHARED_LINKER_FLAGS_STANDARD)


# Single-threading option
option (Jarvis_SINGLETHREADED "Flag for running in single-threaded mode" OFF)

# Optional compiler flags
set (FLAG_WARNINGS "" CACHE STRING "Extra warning and error related flags")
set (FLAG_WARNING_LEVEL "NORMAL" CACHE STRING "Valid values are NONE(-w), NORMAL(), MORE(-Wall), MOST(-Wall -Wextra)")
set (FLAG_WARN_AS_ERROR FALSE CACHE BOOL "Treat all warnings as errors")
mark_as_advanced(FLAG_WARNINGS)

# Jarvis_process_options()

if( UNIX AND NOT APPLE )
    pbuilder_add_ext_libraries (rt)
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-as-needed")
endif( UNIX AND NOT APPLE )

set (CMAKE_CXX_FLAGS_STANDARD "${CMAKE_CXX_FLAGS_STANDARD} -Winconsistent-missing-override ")


######################
# Jarvis dependencies #
######################

#set (Jarvis_BUILD_PYTHON FALSE)

if( Jarvis_BUILD_PYTHON )
    set_option( Scarab_BUILD_PYTHON TRUE )
else( Jarvis_BUILD_PYTHON )
    set_option( Scarab_BUILD_PYTHON FALSE )
endif( Jarvis_BUILD_PYTHON )

set (Scarab_ENABLE_EXECUTABLES FALSE)

########
# ZeroMQ
########

find_package(GnuTLS REQUIRED)
if (GNUTLS_FOUND)
    set(LIBS ${LIBS} ${GNUTLS_LIBRARIES})
    include_directories(${GNUTLS_INCLUDE_DIRS})
endif ()
#
#find_package(ZeroMQ REQUIRED)
#
## libzmq autotools install: fallback to pkg-config
#if(NOT ZeroMQ_FOUND)
#    message(STATUS "CMake libzmq package not found, trying again with pkg-config (normal install of zeromq)")
#    list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/libzmq-pkg-config)
#    find_package(ZeroMQ REQUIRED)
#endif()
#
## TODO "REQUIRED" above should already cause a fatal failure if not found, but this doesn't seem to work
#if(NOT ZeroMQ_FOUND)
#    message(FATAL_ERROR "ZeroMQ was not found, neither as a CMake package nor via pkg-config")
#endif()
#
#if (ZeroMQ_FOUND AND (NOT TARGET libzmq OR NOT TARGET libzmq-static))
#    message(FATAL_ERROR "ZeroMQ version not supported!")
#endif()
#
SET (ZMQ_BUILD_TESTS OFF CACHE INTERNAL "" FORCE)
SET (BUILD_TESTS OFF CACHE INTERNAL "" FORCE)
pbuilder_add_submodule( libzmq vendor/libzmq )
list( APPEND PUBLIC_EXT_LIBS libzmq )


########
# CPPZMQ
########

find_package(cppzmq REQUIRED)
SET (CPPZMQ_BUILD_TESTS OFF CACHE INTERNAL "" FORCE)
pbuilder_add_submodule( cppzmq vendor/cppzmq )


# python deps
if (Jarvis_BUILD_PYTHON)
    find_package (Python COMPONENTS Interpreter Development) # Since python3 is now python, we use Pyton instead instead of Python3
    find_package( pybind11 2.3.0 REQUIRED )
    list( APPEND PUBLIC_EXT_LIBS pybind11::module )
    MESSAGE(STATUS "Found pybind11")
endif (Jarvis_BUILD_PYTHON)


#############
# Jarvis
#############



set( PACKAGE_LIBS )  # If there were other libraries in this package on which this library depends, then they would be put in this variable

# subdirectories
include_directories (BEFORE
        ${PROJECT_SOURCE_DIR}/include
        )


set( headers
        include/PGClient.h
        include/DAQInterface.h
        include/DAQUtilities.h
        include/PGClient.h
        include/ServiceDiscovery.h
        include/SlowControlCollection.h
        include/SlowControlElement.h
        include/Store.h
        include/Utilities.h
        )

set( sources
        src/DAQInterface.cpp
        src/DAQUtilities.cpp
        src/PGClient.cpp
        src/ServiceDiscovery.cpp
        src/SlowControlCollection.cpp
        src/SlowControlElement.cpp
        src/Store.cpp
        src/Utilities.cpp
        )

set( exe_sources
        Example.cpp
        #        run_server.cc
        #        run_client.cc
        )

pbuilder_library(
        TARGET Standalone
        SOURCES ${sources}
        PROJECT_LIBRARIES ${PACKAGE_LIBS}
        PUBLIC_EXTERNAL_LIBRARIES ${PUBLIC_EXT_LIBS}
)

set( lib_dependencies
        Standalone)

pbuilder_executables(
        SOURCES ${exe_sources}
        TARGETS_VAR programs
        PROJECT_LIBRARIES ${lib_dependencies}
        PUBLIC_EXTERNAL_LIBRARIES ${PUBLIC_EXT_LIBS}
        PRIVATE_EXTERNAL_LIBRARIES ${PRIVATE_EXT_LIBS}
)

pbuilder_component_install_and_export(
        COMPONENT Executables Libraries
        EXETARGETS ${programs} Standalone
)

pbuilder_install_headers( ${headers} )



#configure_file(${PROJECT_SOURCE_DIR}/JarvisConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/JarvisConfig.cmake @ONLY)
#pbuilder_do_package_config()


add_custom_target(install_${PROJECT_NAME}
        "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target install
        COMMENT "Installing ${PROJECT_NAME}")
