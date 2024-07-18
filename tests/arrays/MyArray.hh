#include <vector>
#include <iostream>

template<typename Value>
class MyArray {

public:
  using ContainerType = std::vector<Value>;
  using iterator = typename ContainerType::iterator;
  using const_iterator = typename ContainerType::const_iterator;

  MyArray(): mContainer()                      { std::cerr << "MyArray()\n"; }
  MyArray(const size_t size): mContainer(size) { std::cerr << "MyArray(" << size << ")\n"; }
  MyArray(const size_t size,
          const Value& x): mContainer(size, x) { std::cerr << "MyArray(" << size << ", x)\n"; }
  ~MyArray()                                   { std::cerr << "~MyArray()\n"; }
  size_t size() const                          { std::cerr << "MyArray::size\n"; return mContainer.size(); }
  Value& operator[](const size_t index)        { std::cerr << "MyArray[" << index << "]\n"; return mContainer[index]; }
  iterator begin()                             { std::cerr << "MyArray::begin()\n"; return mContainer.begin(); }
  iterator end()                               { std::cerr << "MyArray::end()\n"; return mContainer.end(); }
  const_iterator begin() const                 { std::cerr << "MyArray::begin() (const)\n"; return mContainer.begin(); }
  const_iterator end()  const                  { std::cerr << "MyArray::end() (const)\n"; return mContainer.end(); }

private:
  ContainerType mContainer;
};
