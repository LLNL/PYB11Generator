.. _cmake

===========================================
Using CMake to build PYB11Generator modules
===========================================

pybind11 provides excellent support for building python modules using `CMake <https://cmake.org/>`_, as is documented `here <https://pybind11.readthedocs.io/en/stable/compiling.html#building-with-cmake>`_.  PYB11Generator provides a thin wrapper around this capability to simplify generating PYB11Generator Python extensions as well, such that PYB11Generator modules can be compiled with just a few lines of CMake code.  Suppose we have a simple function in a file ``example_functions.hh``::

  int add(int i, int j) {
    return i + j;
  }

  int subtract(int i, int j) {
    return i - j;
  }

and we write PYB11Generator bindings for these functions in the file ``example_PYB11.py``::

  """
  Simple example function performing sums in C++
  """

  PYB11includes = ['"example_functions.hh"']

  def add(i = "int", j = "int"):
      "Add two integers"
      return "int"

  def subtract(i = "int", j = "int"):
      "Subtract two integers"
      return "int"

If we have added PYB11Generator as a submodule of our project (say in the directory ``extern/PYB11Generator``), we can write a CMake ``CMakeLists.txt`` file to compile this example in just a few lines of code::

  cmake_minimum_required(VERSION 3.4...3.18)
  project(example LANGUAGES CXX)

  set(PYB11GENERATOR_ROOT_DIR ${CMAKE_SOURCE_DIR}/extern/PYB11Generator)  # <-- Required to set PYB11GENERATOR_ROOT_DIR
  include(${PYB11GENERATOR_ROOT_DIR}/cmake/PYB11Generator.cmake)          # <-- include the PYB11Generator CMake functions
  PYB11Generator_add_module(example)

This will generate the build necessary to compile a Python extension ``example`` from the PYB11Generator source ``example_PYB11.py``.  The CMake function ``PYB11Generator_add_module`` is the new CMake function which automatically calls PYB11Generator on the Python code stored in ``example_PYB11.py`` to generate the C++ pybind11 code, and then compiles and links that code to a functioning Python module.

.. Note::

   ``PYB11Generator_add_module(<name>)`` takes the single argument ``<name>``, and assumes the PYB11Generator code is stored in a file ``<name>_PYB11.py``.  That file may in turn import any number of other Python files containing PYB11Generator coding to bind classes, functions, etc., to be bound in the same module, but ``<name>_PYB11.py`` should be the top-level file for generating the module.

Some CMake variables that may be set to influence ``PYB11Generator_add_module``:

PYB11GENERATOR_ROOT_DIR : (required)
  Top-level director for PYB11Generator installation

PYBDIND11_ROOT_DIR : (optional)
  Location of the pybind11 install
  defaults to ${PYB11GENERATOR_ROOT_DIR}/extern/pybind11

PYTHON_EXE : (optional)
  Python executable
  if not set, we use CMake's find_package to search for Python3

<package_name>_ADDITIONAL_INCLUDES : (optional)
  List of addition includes needed

<package_name>_ADDITIONAL_LINKS : (optional)
  List of addition linking libraries, targets, or flags needed

<package_name>_DEPENDS : (optional)
  List of targets the library depends on

<package_name>_INSTALL_PATH : (optional)
  Path to install extension module 
  defaults to ${Python3_SITEARCH}/${package_name}
