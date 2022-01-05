cmake_minimum_required(VERSION 3.10)
project(PYB11Generator LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)

find_package(Python3 COMPONENTS Interpreter Development)
set(PYTHON_EXE ${Python3_EXECUTABLE})

add_subdirectory(extern/pybind11)
#set(pybind11_DIR ${CMAKE_CURRENT_SOURCE_DIR}/extern/pybind11)
#find_package(pybind11 CONFIG)

set(PYB11GENERATOR_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
include(${PYB11GENERATOR_ROOT_DIR}/cmake/PYB11Generator.cmake)

add_subdirectory(tests/cross_module)
