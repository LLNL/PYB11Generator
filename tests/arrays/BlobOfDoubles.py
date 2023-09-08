from PYB11Generator import *

class BlobOfDoubles:

    def pyinit(self):
        return

    @PYB11implementation("[](const BlobOfDoubles&) { return BlobOfDoubles::numElements; }")
    def __len__(self):
        "The size (number of elements) of the ThirdRankTensor."

    @PYB11cppname("operator[]")
    @PYB11returnpolicy("reference_internal")
    def __getitem__(self, i = "const size_t"):
        return "double&"

    @PYB11implementation("[](BlobOfDoubles &s, const size_t i, const double v) { s[i] = v; }")
    def __setitem__(self,
                    i = "const size_t",
                    v = "const double"):
        "Python indexing to set an element."
        return "void"

    @PYB11implementation("[](const BlobOfDoubles &s) { return py::make_iterator(s.begin(), s.end()); }, py::keep_alive<0,1>()")
    def __iter__(self):
        "Python iteration through a BlobOfDoubles."
        return

    # String representation
    @PYB11implementation("""
[](const BlobOfDoubles& self) {
  std::string result = "BlobOfDoubles(";
  for (auto val: self) result += (" " + std::to_string(val) + " ");
  result += ")";
  return result;
}""")
    def __repr__(self):
        return

    numElements = PYB11property("size_t", constexpr=True, static=True)

