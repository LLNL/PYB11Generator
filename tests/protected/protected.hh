#include <iostream>

template<typename T1, typename T2>
class A {
public:
  T1 x;
  T2 y;
  A()          { printf("A()\n"); }
  virtual ~A() { printf("~A()\n"); }
protected:
  virtual void func(const T1 val1, const T2 val2) = 0;
};

template<typename T1, typename T2>
class B: public A<T1, T2> {
public:
  B() { printf("B()\n"); }
  virtual ~B() {printf("~B()\n"); }
protected:
  virtual void func(const T1 val1, const T2 val2) override {
    std::cout << "B::val(" << val1 << " , " << val2 << ")\n";
    A<T1,T2>::x = val1;
    A<T1,T2>::y = val2;
  }
};
