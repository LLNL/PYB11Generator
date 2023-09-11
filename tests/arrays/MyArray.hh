#include "chai/ManagedArray.hpp"
#include "LvArray/Array.hpp"
#include "LvArray/ChaiBuffer.hpp"

#include <vector>
#include <iostream>
#include <memory>
#include <cassert>

template<typename Value>
class MyArray {

public:
  using ContainerType = chai::ManagedArray<Value>;
  using iterator = Value*;
  using const_iterator = const Value*;

  // using ContainerType = LvArray::Array<Value, 1, camp::idx_seq<0>, std::ptrdiff_t, LvArray::ChaiBuffer>;
  // using iterator = Value*;
  // using const_iterator = const Value*;

  // using ContainerType = Spheral::ManagedVector<Value>;
  // using iterator = typename ContainerType::iterator;
  // using const_iterator = typename ContainerType::const_iterator;

  // using ContainerType = std::vector<Value>;
  // using iterator = typename ContainerType::iterator;
  // using const_iterator = typename ContainerType::const_iterator;

  MyArray(): mContainer()                      { std::cerr << "MyArray() : " << this << "\n"; }
  MyArray(const size_t size): mContainer()     { std::cerr << "MyArray(" << size << ") : " << this << "\n"; resize_buffer(size); }
  MyArray(const size_t size,
          const Value& x): mContainer()        { std::cerr << "MyArray(" << size << ", x) : " << this << "\n"; resize_buffer(size); for (auto i = 0u; i < size; ++i) mContainer[i] = x; }
  ~MyArray()                                   { std::cerr << "~MyArray() : " << this << "\n"; destroy(0u); mContainer.free(); }
  size_t size() const                          { std::cerr << "MyArray::size\n"; return mContainer.size(); }
  Value& operator[](const size_t index)        { std::cerr << "MyArray[" << index << "]\n"; return mContainer[index]; }
  iterator begin()                             { std::cerr << "MyArray::begin()\n"; return mContainer.begin(); }
  iterator end()                               { std::cerr << "MyArray::end()\n"; return mContainer.end(); }
  const_iterator begin() const                 { std::cerr << "MyArray::begin() (const)\n"; return mContainer.begin(); }
  const_iterator end()  const                  { std::cerr << "MyArray::end() (const)\n"; return mContainer.end(); }

private:
  ContainerType mContainer;

  // chai::ManagedArray doesn't call C++ destructors on deallocation, so we do it.
  // We assume any elements being removed are on the end of the Array.
  void destroy(std::ptrdiff_t newSize) {
    auto* buf = mContainer.data();
    const auto size = mContainer.size();
    std::cerr << "MyArray::destroy " << size << " --> " << newSize << "\n";
    if (newSize < size and not std::is_trivially_destructible<Value>::value) {
      for (auto i = newSize; i < size; ++i) buf[i].~Value();
    }
    mContainer.reallocate(newSize);
  }

  // When using a chai::ManagedArray we have to initialize all C++ objects explicitly.
  // Based on arrayManipulation::resize from the LvArray code
  void resize_buffer(std::ptrdiff_t newSize) {
    const auto size = mContainer.size();
    std::cerr << "MyArray::resize " << size << " --> " << newSize << "\n";

    if (newSize < size and not std::is_trivially_destructible<Value>::value) {
      // Making array smaller, so just destroy the stuff past our new size
      destroy(newSize);

    } else {
      // Increasing the size of the array, so construct the new objects at the end
      mContainer.reallocate(newSize);
      if (not std::is_trivially_default_constructible<Value>::value) {
        auto* buf = mContainer.data();
        for (size_t i = size; i < size_t(newSize); ++i) new (buf + i) Value();
      }

    }
    assert(mContainer.size() == newSize);
  }

};
