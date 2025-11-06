.. _cmake

===========================================
Using CMake to build PYB11Generator modules
===========================================

pybind11 provides excellent support for building python modules using `CMake <https://cmake.org/>`_, as is documented `on pybind11 readthedocs page <https://pybind11.readthedocs.io/en/stable/compiling.html#building-with-cmake>`_.  PYB11Generator provides a thin wrapper around this capability to simplify generating PYB11Generator Python extensions as well, such that PYB11Generator modules can be compiled with just a few lines of CMake code.  Suppose we have a simple function in a file ``example_functions.hh``::

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

  project(example LANGUAGES CXX)

  set(PYB11GENERATOR_ROOT_DIR ${CMAKE_SOURCE_DIR}/extern/PYB11Generator)  # <-- Required to set PYB11GENERATOR_ROOT_DIR
  include(${PYB11GENERATOR_ROOT_DIR}/cmake/PYB11Generator.cmake)          # <-- include the PYB11Generator CMake functions
  PYB11Generator_add_module(example)

This will generate the build necessary to compile a Python extension ``example`` from the PYB11Generator source ``example_PYB11.py``.  The CMake function ``PYB11Generator_add_module`` is the new CMake function which automatically calls PYB11Generator on the Python code stored in ``example_PYB11.py`` to generate the C++ pybind11 code, and then compiles and links that code to a functioning Python module.

Some CMake variables that influence ``PYB11Generator_add_module`` are:

PYB11GENERATOR_ROOT_DIR (required) :
  Top-level directory for PYB11Generator installation

PYBDIND11_ROOT_DIR (optional) :
  Location of the pybind11 install.  Defaults to ``${PYB11GENERATOR_ROOT_DIR}/extern/pybind11``.

PYTHON_EXE (optional) :
  Python executable
  if not set, we use CMake's find_package to search for Python3

The full function specification for ``PYB11Generator_add_module`` is::

     PYB11Generator_add_module(<package_name>
                               MODULE           ...
                               SOURCE           ...
                               INSTALL          ...
                               INCLUDES         ...
                               LINKS            ...
                               DEPENDS          ...
                               PYBIND11_OPTIONS ...
                               COMPILE_OPTIONS  ...
                               MULTIPLE_FILES   ON/OFF
                               GENERATED_FILES  ...
                               USE_BLT          ON/OFF
                               VIRTUAL_ENV      ...
                               PYTHONPATH       ...)

where the arguments are:

<package_name> (required) : 
  Name of the package to be created.

MODULE <arg> (optional) :
  Name of the Python module and CMake target to be generated.  Defaults to ``<package_name>``.

SOURCE <arg> (optional) :
  Optionally specify the name of the Python source file containing the PYB11Generator bindings.  If not specified, defaults to ``<package_name>_PYB11.py``.

INSTALL <arg> (optional) :
  Path to install extension module -- defaults to ``${Python3_SITEARCH}/${package_name}``.

INCLUDES <arg1> <arg2> ... (optional) :
  List of addition includes needed to compile the extension module.  Note all standard Python include paths are included by default.

LINKS <arg1> <arg2> ... (optional) :
  List of addition linking libraries, targets, or flags necessary to link the extension module.

DEPENDS <arg1> <arg2> ... (optional) :
  List of targets the extension module depends on, i.e., targets that should be satisfied first.

PYBIND11_OPTIONS <arg1> <arg2> ... (optional) :
  Any valid flags that can be passed to the built-in pybind11 ``pybind11_add_module`` CMake function.  See pybind11 CMake `documentation <https://pybind11.readthedocs.io/en/stable/compiling.html#building-with-cmake>`_.

COMPILE_OPTIONS <arg1> <arg2> ... (optional) :
  Any additional flags that should be passed during the compile stage.  See CMake documentation for TARGET_COMPILE_OPTIONS.

MULTIPLE_FILES  ON/OFF (optional, default OFF) :
  Breakup the output pybind11 code across different source files to allow parallel compilation

GENERATED_FILES <arg> (optional) :
  Name for output file containing the list of C++ pybind11 output files

USE_BLT ON/OFF (optional, default OFF) :
  For those using the BLT Cmake extension (https://llnl-blt.readthedocs.io/),
  which does not play well with standard CMake add_library options.
  Note, using this option skips using pybind11's own add_module CMake logic,
  and therefore may make some pybind11 options no-ops.

VIRTUAL_ENV <arg> (optional) :
  The name of a python virtual environment target. The target must supply
  target properties EXECUTABLE and ACTIVATE_VENV to define the python executable
  and the command to activate the environment respectively.

PYTHONPATH <arg> (optional) :
  Additions needed for the environment PYTHONPATH

.. Note::

   ``PYB11Generator_add_module`` only looks at the ``SOURCE`` Python file (default ``<package_name>_PYB11.py``.  However, that file may in turn import as many other Python files as desired to expose more interface as part of the module, so the user should feel free to organize their PYB11Generator bindings as desired for clarity.  A typical pattern would be to have the top-level module ``<package_name>_PYB11.py`` import individual class bindings from separate Python files for each bound class, for instance.  Such dependencies should be noted and cause recompiling as appropriate.

.. Note::

   The state of ``MULTIPLE_FILES`` will cause changes in when PYB11Generator generates the pybind11 output files:

   MULTIPLE_FILES ON : 
     PYB11Generator will run at configure (CMake) time, creating the set of output pybind11 C++ files.  This is necessary in order to tell CMake what source files are being generated for compilation rules.

   MULTIPLE_FILES OFF :
     PYB11Generator runs at compile time, generating a monolithic C++ pybind11 source file and one header per module.
