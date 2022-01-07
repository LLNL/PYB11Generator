.. _intro:

==============================
Introduction to PYB11Generator
==============================

Using PYB11Generator to write the interface for a C++ binding is intended to emulate writing that same interface in Python, so if you're familiar with Python it should be easy to get started with PYB11Generator.  As an example, if we have a header for a C++ function that looks like:

.. code-block:: cpp

   // A really important function!
   int func();

We can define the PYB11Generator prescription for binding this method by writing a Python method as::

  def func():
      "A really important function!"
      return "int"

Wherever possible we try to use ordinary Python syntax to correspond to pybind11/C++ constructs: Python functions correspond to and generate binding code for C++ functions as above; a Python class generates binding code for pybind11 to bind a C++ class; arguments for functions and methods in Python generate corresponding argument specifications in C++ function pointer syntax.  Because Python is not a strongly typed language, we specify C++ types using strings (if needed) as above, where we specify the return ``int`` type by returning the string ``"int"`` from ``func``.  We also use Python decorators to annotate Python methods with uniquely C++ concepts such as ``const``, ``virtual``, etc., as will be discussed in succeeding sections.

.. _installation:

Installation
------------

PYB11Generator uses the Python Package Index `PyPI <https://pypi.org/>`_ to simplify installation of PYB11Generator, so installing PYB11Generator is simply a matter of requesting it using `pip <https://packaging.python.org/tutorials/installing-packages/>`_::

  $ pip install PYB11Generator

This command installs PYB11Generator (and pybind11 since it is a dependency of PYB11Generator) as packages in the Python you are using (i.e., the Python associated with the ``pip`` command).

For those curious, the source for PYB11Generator is hosted on `github <https://github.com/jmikeowen/pyb11generator>`_.

Another approach (if you are using git for source code control) is to include PYB11Generator as a submodule of your project, in which case PYB11Generator and pybind11 (which is a submodule of PYB11Generator) will be available for use in your project directly.  See the `Git documentation on submodules <https://git-scm.com/book/en/v2/Git-Tools-Submodules>`_ for more information.  This can also simplify building if you are using `CMake <https://cmake.org/>`_ as your build system, since this makes the PYB11Generator CMake extensions available as well.  Use of CMake to build PYB11Generator generated modules is discussed :ref:`cmake`.

.. _the-basics:

The basics: how to generate pybind11 code using PYB11Generator
--------------------------------------------------------------

PYB11Generator works by starting up a Python process, importing a module containing Python definitions for functions and classes corresponding to the C++ interface to be bound, and invoking the function ``PYB11generateModule`` on the imported Python module, which writes out a C++ file of pybind11 statements binding that interface.  This generated pybind11 C++ file is what is compiled by a C++ compiler to create the final Python shared module allowing the C++ methods and classes to be exercised from Python.  As an example, if we have created a Python file ``mymodule.py`` containing the Python description of the C++ methods we wish to expose in a module to be called ``mymodule``, we can invoke ``PYB11generateModule`` to create the intermediate C++ file as::

  python -c 'from PYB11Generator import *; import mymodule; PYB11generateModule(mymodule)'

resulting in the creation of a C++ source file ``mymodule.cc``.  A full description of the ``PYB11generateModule`` interface is given in :ref:`PYB11-functions`.

.. _first-example:

A first example start to finish
-------------------------------

To explicitly demonstrate the stages of creating bindings using PYB11Generator, here we recreate an early example in the pybind11 documentation: :ref:`pybind11:simple_example`.  Say we want to wrap the following C++ method:

.. code-block:: cpp

  int add(int i, int j) {
    return i + j;
  }

We can use PYB11Generator to create the same pybind11 code used to wrap this method in the pybind11 tutorial by writing a file ``simple_example.py`` containing::

  "pybind11 example plugin"
  
  PYB11preamble = """
  int add(int i, int j) {
    return i + j;
  }
  """
  
  def add():
      "A function which adds two numbers"
      return

Now executing the command::

  $ python -c 'from PYB11Generator import *; import simple_example; PYB11generateModule(simple_example, "example")'

creates a file ``example.cc``, which looks like (omitting the boilerplate preamble code with ``#include``'s):

.. code-block:: cpp

  int add(int i, int j) {
    return i + j;
  }

  //------------------------------------------------------------------------------
  // Make the module
  //------------------------------------------------------------------------------
  PYBIND11_MODULE(example, m) {

    m.doc() = "pybind11 example plugin"  ;

    //...........................................................................
    // Methods
    m.def("add", &add, "A function which adds two numbers");
  }

This is identical to the native pybind11 binding code from the pybind11 tutorial :ref:`pybind11:simple_example`, modulo some comments.  This code can now be compiled to the final Python shared module as described this same pybind11 tutorial::

  $ c++ -O3 -Wall -shared -std=c++11 -fPIC `python -m pybind11 --includes` example.cc -o example.so

A few things worth noting:

* This example uses the fact that if the function being wrapped is unambiguous, allowing us to use a bare C++ function pointer (without the full explicit function prescription).  This is reflected in the PYB11Generator syntax when we write the ``def add()`` function in python without arguments or a return type.
* In order to directly insert the C++ function definition into the resulting C++ file, we have used the special variable ``PYB11preamble`` variable.  A more typical use case will require ``#include``-ing the necessary C++ header files in the generated code, which is accomplished through another special variable, ``PYB11includes``, described in :ref:`variables`.
* In general special variables and commands to PYB11Generator use the prefix ``PYB11`` such as ``PYB11preamble`` in this example.
* Note also that ordinary Python doc strings (both for the module and function) are picked up from ``simple_example.py`` and propagated to the pybind11 bindings.

This example demonstrates the steps necessary to create a usable Python module using PYB11Generator:

#. Create a Python file describing the desired interface using ordinary Python syntax, based on the C++ methods and classes to be bound.
#. Run a Python line like above to generate the pybind11 C++ code from this Python input.
#. Compile the resulting pybind11 C++ code to create the Python shared module.

In the following sections we describe the nuances of creating the PYB11 Python input files in much more detail; we will not show the compilation examples beyond this point since it is no different than using pybind11 directly, and the above example pretty much covers it.
