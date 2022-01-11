#--------------------------------------------------------------------------------
# This is the main PYB11Generator CMake file.  PYB11Generator is pure python, and
# therefore does not really need to be built.  This example does show how to use
# the provided CMake functions (like PYB11Generator_add_module) in order to build
# pybind11 projects bound using PYB11Generator.  In this case we're just building
# some example/test modules.
#
# In order to install PYB11Generator it is simplest to use pip, as described at
#   https://pyb11generator.readthedocs.io/
#--------------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.10)
project(PYB11Generator LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)

set(PYB11GENERATOR_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_MODULE_PATH ${PYB11GENERATOR_ROOT_DIR}/cmake)
include(${PYB11GENERATOR_ROOT_DIR}/cmake/PYB11Generator.cmake)

# Documentation
set(ENABLE_DOCS OFF CACHE BOOL "enable sphinx PYB11Generator documentation")
if (ENABLE_DOCS)
  if (NOT DEFINED SPHINX_EXECUTABLE)
    find_package(Sphinx)
  else()
    message("-- forcing SPHINX_EXECUTABLE: ${SPHINX_EXECUTABLE}")
  endif()
  add_subdirectory(docs)
endif()

# Tests
add_subdirectory(tests/cross_module)
add_subdirectory(tests/inheritance)
add_subdirectory(tests/protected)
add_subdirectory(tests/inject)
# add_subdirectory(tests/numpy)    # Not ready yet -- need to augment PYB11 to support the buffer protocol to do correctly

