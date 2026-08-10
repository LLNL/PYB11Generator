from PYB11Generator import *

PYB11preamble = """
#include <cstdio>

struct Wombat {
  Wombat()      { printf("Wombat::Wombat()\\n"); }
  ~Wombat()     { printf("Wombat::~Wombat()\\n"); }
};

class A {
public:
  A(): ma(nullptr), mb(nullptr), mc(nullptr)           { printf("A::A()\\n"); }    
  ~A()                                                 { printf("A::~A()\\n"); }   
  void add_wombats(Wombat& a_wombat,
                   Wombat& b_wombat,
                   Wombat& c_wombat) {
    printf("A::add_wombats(%p, %p, %p)\\n", (void*)&a_wombat, (void*)&b_wombat, (void*)&c_wombat);
    ma = &a_wombat;
    mb = &b_wombat;
    mc = &c_wombat;
  }
private:
  Wombat *ma, *mb, *mc;
};
"""

#...............................................................................
class Wombat:

    def pyinit(self):
        "Default Wombat()"

#...............................................................................
class A:

    def pyinit(self):
        "Default A()"

    @PYB11keepalive(1, 2)  # a_wombat tied to this
    @PYB11keepalive(1, 3)  # b_wombat tied to this
    @PYB11keepalive(1, 4)  # c_wombat tied to this
    def add_wombats(self,
                    a_wombat = "Wombat&",
                    b_wombat = "Wombat&",
                    c_wombat = "Wombat&"):
        "Add some Wombats to A"
        return "void"
