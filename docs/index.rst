.. PYB11Generator documentation master file, created by
   sphinx-quickstart on Sun Nov 25 11:21:07 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

PYB11Generator's documentation
==============================

PYB11Generator is a python based code generator that creates `pybind11 <https://github.com/pybind/pybind11>`_ code for binding C++ libraries as extensions in Python. PYB11Generator parses input that is very close to writing the desired interface in native python, turning this into the corresponding pybind11 C++ code.

.. Note::

   Since PYB11Generator blindly generates C++ pybind11 code, it is essential to understand the pybind11 package itself as well!  In other words, be sure to read and understand the `pybind11 documentation <https://pybind11.readthedocs.io/en/stable/>`_ before trying to go too far with PYB11Generator.  The purpose of PYB11Generator is to reduce the burden of writing and maintaining redundant code when working with pybind11 (such as the trampoline classes required by :ref:`pybind11:overriding_virtuals`), and provide a natural syntax for those already familiar with writing interfaces in Python.  However, since the generated pybind11 code produced by PYB11Generator is what is actually compiled by a C++ compiler to create the corresponding python package, any errors reported by the compiler will refer to this generated code, and require understanding pybind11 itself to properly interpret.

.. Note::
   PYB11Generator is now Python 3 only -- for users of Python 2 the last version of PYB11Generator supporting Python 2 is 1.0.12 (available from PyPI and Github).

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   intro
   functions
   classes
   enums
   memory
   stl
   complications
   cmake
   PYB11variables
   PYB11decorators
   PYB11functions

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
