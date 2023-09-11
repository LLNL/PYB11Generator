from PYB11Generator import *

PYB11includes = ['"MyArray.hh"', '"GeomThirdRankTensor.hh"', '"BlobOfDoubles.hh"']

PYB11namespaces = ["Spheral"]

PYB11preamble = """
void setChaiStuff() {
  auto* rm = chai::ArrayManager::getInstance();
  std::cerr << "Starting CHAI execution space: " << rm->getExecutionSpace() << std::endl;
  std::cerr << "Starting CHAI allocation space: " << rm->getDefaultAllocationSpace() << std::endl;
  rm->setExecutionSpace(chai::CPU);
  rm->setDefaultAllocationSpace(chai::CPU);
  std::cerr << "New CHAI execution space: " << rm->getExecutionSpace() << std::endl;
  std::cerr << "New CHAI allocation space: " << rm->getDefaultAllocationSpace() << std::endl;
}
"""

from RankNTensor import *
from ThirdRankTensor import *
from BlobOfDoubles import *

@PYB11template("Value")
class MyArray:
    "Thin wrapper around a native C++ array type"

    PYB11typedefs = """
  using MyArrayType = MyArray<%(Value)s>;
"""

    def pyinit(self):
        "Default MyArray constructor"
        return

    def pyinit1(self,
                size = "const size_t"):
        "Construct with given size"
        return 

    def pyinit2(self,
                size = "const size_t",
                x = "const %(Value)s&"):
        "Construct with a give size and initial value for all elements"
        return

    @PYB11const
    def size(self):
        "Return size of array"
        return "size_t"

    @PYB11cppname("size")
    @PYB11const
    def __len__(self):
        return "size_t"

    @PYB11cppname("operator[]")
    @PYB11returnpolicy("reference_internal")
    @PYB11implementation('[](MyArrayType& self, const size_t i) -> %(Value)s& { const int n = self.size(); if (i >= n) throw py::index_error(); return self[(i %% n + n) %% n]; }')
    def __getitem__(self, i = "const size_t"):
        return "%(Value)s&"

    # @PYB11cppname("operator[]")
    # @PYB11returnpolicy("reference_internal")
    # def __getitem__(self,
    #                index = "const size_t"):
    #    return "%(Value)s&"

    @PYB11implementation("[](MyArrayType& self, int i, const %(Value)s v) { const int n = self.size(); if (i >= n) throw py::index_error(); self[(i %% n + n) %% n] = v; }")
    def __setitem__(self):
        "Set a value"

    #@PYB11implementation("[](MyArrayType& self, size_t i, const %(Value)s x) { const auto n = self.size(); if (i >= n) throw py::index_error(); self[(i %% n + n) %% n] = x; }")
    #def __setitem__(self,
    #                index = "const size_t",
    #                x = "const %(Value)s&"):
    #    "Set a value"
    #    return

    @PYB11implementation("[](const MyArrayType& self) { return py::make_iterator(self.begin(), self.end()); }, py::keep_alive<0,1>()")
    def __iter__(self):
        "Python iteration through MyArray."

MyArray_double = PYB11TemplateClass(MyArray, template_parameters="double")
MyArray_BlobOfDoubles = PYB11TemplateClass(MyArray, template_parameters="BlobOfDoubles")

# MyArray_TRT = PYB11TemplateClass(MyArray, template_parameters="Spheral::GeomThirdRankTensor<1>")
# #MyArray_of_vec_double = PYB11TemplateClass(MyArray, template_parameters="std::vector<double>")
# #MyArray_of_MyArray_double = PYB11TemplateClass(MyArray, template_parameters="MyArray<double>")

def setChaiStuff():
    "A bunch of chai initialization"
    return "void"