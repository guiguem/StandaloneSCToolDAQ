# - Find CPPZMQ
# Find CPPZMQ library.
# Once done this will define
#
#  CPPZMQ_INCLUDE_DIR    - where to find CPPZMQ header files, etc.
#  CPPZMQ_FOUND          - True if CPPZMQ found.
#

message( STATUS "CPPZMQ_ROOT_DIR: ${CPPZMQ_ROOT_DIR}")

find_path(CPPZMQ_INCLUDE_DIR NAMES zmq.hpp HINTS ${CPPZMQ_ROOT_DIR} ${CMAKE_SOURCE_DIR}/external/cppzmq)

message( STATUS "CPPZMQ_INCLUDE_DIR: ${CPPZMQ_INCLUDE_DIR}")

# handle the QUIETLY and REQUIRED arguments and set CPPZMQ_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CPPZMQ REQUIRED_VARS CPPZMQ_INCLUDE_DIR)

mark_as_advanced(CPPZMQ_INCLUDE_DIR)