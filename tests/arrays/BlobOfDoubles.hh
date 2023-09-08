#include <iostream>
#include "pybind11/pybind11.h"

class BlobOfDoubles {
public:
  using iterator = double*;
  using const_iterator = const double*;
  static constexpr size_t numElements = 1u;

  BlobOfDoubles()                    { std::cerr << "BlobOfDoubles() : " << this << "\n"; for (auto i = 0u; i < numElements; ++i) mData[i] = 0.0; }
  BlobOfDoubles(const double x)      { std::cerr << "BlobOfDoubles(double) : " << this << "\n"; for (auto i = 0u; i < numElements; ++i) mData[i] = x; }
  virtual ~BlobOfDoubles()           { std::cerr << "~BlobOfDoubles() : " << this << "\n"; }
  double& operator[](const size_t i) { std::cerr << "BlobOfDoubles[" << i << "]\n"; if (i >= numElements) throw pybind11::index_error(); return mData[i]; }
  const_iterator begin() const       { std::cerr << "BlobOfDoubles::begin()\n"; return &mData[0]; }
  const_iterator end() const         { std::cerr << "BlobOfDoubles::end()\n"; return &mData[numElements]; }

private:
  double mData[numElements];
};

// namespace PYBIND11_NAMESPACE {
//   template<> struct polymorphic_type_hook<BlobOfDoubles> {
//     static const void *get(const BlobOfDoubles *src, const std::type_info*& type) {
//       // note that src may be nullptr
//       if (src) {
//         type = &typeid(BlobOfDoubles);
//         //type = &typeid(*src);
//         return static_cast<const BlobOfDoubles*>(src);
//       }
//       return src;
//     }
//   };
// } // namespace PYBIND11_NAMESPACE
