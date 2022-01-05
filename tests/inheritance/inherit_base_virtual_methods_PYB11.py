from PYB11Generator import *

PYB11preamble = """
#include <cstdio>

class A {
public:
  A()                   { printf("A::A()\\n"); }    
  virtual ~A()          { printf("A::~A()\\n"); }   
  virtual void Afunc()  { printf("A::Afunc()\\n"); }
};

class B: public A {
public:
  B()                   { printf("B::B()\\n"); }
  virtual ~B()          { printf("B::~B()\\n"); }
  virtual void Bfunc()  { printf("B::Bfunc()\\n"); }
};
"""

#...............................................................................
class A:

    def pyinit(self):
        "Default A()"

    @PYB11virtual
    def Afunc(self):
        "Default A::Afunc"
        return "void"

#...............................................................................
class B(A):

    def pyinit(self):
        "Default B()"

    @PYB11virtual
    def Bfunc(self):
        "Default B::Bfunc"
        return "void"
