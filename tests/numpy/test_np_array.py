from PYB11Generator import *

PYB11includes = ['"my_array.hh"',
                 '"pybind11/numpy.h"']

PYB11modulepreamble = """
  PYBIND11_NUMPY_DTYPE(Vector, x, y, z);
"""

class Vector:
    def pyinit(self,
               x = ("double", "0.0"),
               y = ("double", "0.0"),
               z = ("double", "0.0")):
        return

    x = PYB11readwrite()
    y = PYB11readwrite()
    z = PYB11readwrite()

class my_array:
    def pyinit(self):
        return

    def data(self):
        return "std::vector<Vector>&"

    @PYB11implementation("[](py::object& obj) -> py::array_t<double> { auto& self = obj.cast<my_array&>(); return py::array_t<double>({self.data().size()}, &(*self.data().begin()), obj); }")
    def array(self):
        return "py::array_t<double>"
