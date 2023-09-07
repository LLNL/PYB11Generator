from PYB11Generator import *

PYB11includes = ['"GeomThirdRankTensor.hh"']
PYB11namespaces = ["Spheral"]
#-------------------------------------------------------------------------------
# ThirdRankTensor template
#-------------------------------------------------------------------------------
@PYB11template("ndim")
class ThirdRankTensor:
    "Spheral third rank tensor (%(ndim)sx%(ndim)sx%(ndim)s) class"

    # Static attributes
    zero = PYB11readonly(static=True, doc="The zero value equivalent", returnpolicy="copy")

    numElements = PYB11readonly(static=True, cppname = "numElements")
    nDimensions = PYB11property(returnType= "int", static = True, getterraw = "[](const GeomThirdRankTensor<2>& self) -> int { return self.nDimensions; }")
    #nDimensions = PYB11property(constexpr = True)
    #nDimensions = PYB11readonly(static = True, cppname = "nDimensions")
    nrank = PYB11readonly(static=True, cppname = "nrank")

    # Constructors
    def pyinit0(self):
        "Default constructor"

    def pyinit1(self,
                rhs = "const GeomThirdRankTensor<%(ndim)s>"):
        "Copy constructor"

    def pyinit2(self,
                rhs="double"):
        "Construct setting the element values to a constant value."

    # Sequence methods
    @PYB11implementation("[](const GeomThirdRankTensor<%(ndim)s>&) { return GeomThirdRankTensor<%(ndim)s>::numElements; }")
    def __len__(self):
        "The size (number of elements) of the ThirdRankTensor."

    @PYB11implementation("[](const GeomThirdRankTensor<%(ndim)s> &s, size_t i) { if (i >= GeomThirdRankTensor<%(ndim)s>::numElements) throw py::index_error(); return s[i]; }") 
    @PYB11returnpolicy("reference_internal")
    def __getitem__(self):
        "Python indexing to get an element."

    @PYB11implementation("[](GeomThirdRankTensor<%(ndim)s> &s, size_t i, double v) { if (i >= GeomThirdRankTensor<%(ndim)s>::numElements) throw py::index_error(); s[i] = v; }") 
    def __setitem__(self):
        "Python indexing to set an element."

    @PYB11implementation("[](const GeomThirdRankTensor<%(ndim)s> &s) { return py::make_iterator(s.begin(), s.end()); }, py::keep_alive<0,1>()")
    def __iter__(self):
        "Python iteration through a ThirdRankTensor."

    @PYB11const
    @PYB11returnpolicy("reference_internal")
    def __call__(self,
                 i="GeomThirdRankTensor<%(ndim)s>::size_type", 
                 j="GeomThirdRankTensor<%(ndim)s>::size_type",
                 k="GeomThirdRankTensor<%(ndim)s>::size_type"):
        "Extract the (i,j,k) element."
        return "double"

    @PYB11pycppname("__call__")
    @PYB11implementation("""[](GeomThirdRankTensor<%(ndim)s>& self, 
                               GeomThirdRankTensor<%(ndim)s>::size_type i,
                               GeomThirdRankTensor<%(ndim)s>::size_type j,
                               GeomThirdRankTensor<%(ndim)s>::size_type k,
                               double val) { self(i,j,k) = val; }""")
    def assignCall(self,
                   i="GeomThirdRankTensor<%(ndim)s>::size_type", 
                   j="GeomThirdRankTensor<%(ndim)s>::size_type",
                   k="GeomThirdRankTensor<%(ndim)s>::size_type",
                   val="double"):
        return "void"

    # Methods
    def Zero(self):
        "Zero out the elements"
        return "void"

    @PYB11const
    def doubledot(self, rhs="const RankNTensor<%(ndim)s, 3, GeomThirdRankTensor<%(ndim)s>>& rhs"):
        return "double"

    @PYB11const
    def squareElements(self):
        return "const GeomThirdRankTensor<%(ndim)s>"

    @PYB11const
    def maxAbsElement(self):
        return "double"

    # Operators
    def __neg__(self):
        return
    def __iadd__(self):
        return
    def __isub__(self):
        return
    def __add__(self):
        return
    def __sub__(self):
        return
    def __imul__(self, rhs="double()"):
        return
    def __itruediv__(self, rhs="double()"):
        return
    def __mul__(self, rhs="double()"):
        return
    def __truediv__(self, rhs="double()"):
        return
                 
    # Comparisons
    def __eq__(self):
        return
    def __ne__(self):
        return
    def __lt__(self):
        return
    def __gt__(self):
        return
    def __le__(self):
        return
    def __ge__(self):
        return

    # String representation
    @PYB11implementation("""
[](const GeomThirdRankTensor<%(ndim)s>& self) {
  std::string result = "ThirdRankTensor" + std::to_string(%(ndim)s) + "d(";
  for (auto val: self) result += (" " + std::to_string(val) + " ");
  result += ")";
  return result;
}""")
    def __repr__(self):
        return

#-------------------------------------------------------------------------------
# ThirdRankTensor instantiations.
#-------------------------------------------------------------------------------
ThirdRankTensor1d = PYB11TemplateClass(ThirdRankTensor,
                                       template_parameters = ("1"),
                                       cppname = "GeomThirdRankTensor<1>",
                                       pyname = "ThirdRankTensor1d")
ThirdRankTensor2d = PYB11TemplateClass(ThirdRankTensor,
                                       template_parameters = ("2"),
                                       cppname = "GeomThirdRankTensor<2>",
                                       pyname = "ThirdRankTensor2d")
ThirdRankTensor3d = PYB11TemplateClass(ThirdRankTensor,
                                       template_parameters = ("3"),
                                       cppname = "GeomThirdRankTensor<3>",
                                       pyname = "ThirdRankTensor3d")
