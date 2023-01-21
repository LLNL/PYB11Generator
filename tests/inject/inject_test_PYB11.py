from PYB11Generator import *

PYB11preamble = """
#include <cstdio>

class A {
public:
  A()                       { printf("A::A()\\n"); }    
  virtual ~A()              { printf("A::~A()\\n"); }   
  virtual void Apure() = 0;
  void blago() const        { printf("A::blago()\\n"); }
};

"""

class A:
    def pyinit(self):
        "A()"

    @PYB11const
    def blago(self):
        "blago"
        return

@PYB11ignore
class bogus_for_injection:

    def Apure(self):
        "injected A virtual method"
        return "void"

PYB11inject(bogus_for_injection, A, pure_virtual=True)
