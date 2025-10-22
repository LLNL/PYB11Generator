#ifndef cross_module_B
#define cross_module_B

#include "A.hh"

struct B: public A {
  B(): A()                               { printf("B::B()\n"); }
  ~B()                                   { printf("B::~B()\n"); }
  virtual int func(const int x) override { printf("B::func(%d)\n", x); return x*x; }
};

#endif
