PYB11Generator
==============

PYB11Generator is a python based code generator that creates [pybind11](https://github.com/pybind/pybind11) code for binding C++ libraries as extensions in Python. PYB11Generator parses input that is very close to writing the desired interface in native python, turning this into the corresponding pybind11 C++ code.

Note, since PYB11Generator blindly generates C++ pybind11 code, it is essential to understand the pybind11 package itself as well!  In other words, be sure to read and understand the [pybind11 documentation](https://pybind11.readthedocs.io/en/stable/) before trying to go too far with PYB11Generator.  The purpose of PYB11Generator is to reduce the burden of writing and maintaining redundant code when working with pybind11 (such as the [trampoline classes](https://pybind11.readthedocs.io/en/stable/advanced/classes.html#overriding-virtual-functions-in-python)), and provide a natural syntax for those already familiar with writing interfaces in Python.  However, since the generated pybind11 code produced by PYB11Generator is what is actually compiled by a C++ compiler to create the corresponding python package, any errors reported by the compiler will refer to this generated code, and require understanding pybind11 itself to properly interpret.

Documentation
-------------

PYB11Generator is documented at [readthedocs](https://pyb11generator.readthedocs.io/en/latest/).

Note the source for this documentation is embedded in the PYB11Generator repository under docs/.

Contributions
-------------

Although a great deal of the functionality of pybind11 is available via PYB11Generator, there are certainly missing pieces and improvements that can be made.  Contributions are welcome, and should be provided as pull requests to the main repository.  Note all contributions must be provided under the same license for distribution (in this case the BSD license).

License
-------

PYB11Generator is released under the [BSD license](https://github.com/jmikeowen/PYB11Generator/blob/master/LICENSE).

LLNL-CODE-767799
