from PYB11Generator import *

PYB11preamble = """
#include <cstdio>

template<typename Value1, typename Value2>
class A {
public:
  A()                                                       { printf("A::A()\\n"); }
  virtual ~A()                                              { printf("A::~A()\\n"); }
  virtual void func(const Value1& x, const Value2& y) const { printf("A::func(...)\\n"); }
};

template<typename Value3, typename Value4>
class B: public A<double, int> {
public:
  B(): A<double, int>()                                               { printf("B::B()\\n"); }
  virtual ~B()                                                        { printf("B::~B()\\n"); }
  virtual void yetAnotherFunc(const Value3& x, const Value4& y) const { printf("B::yetAnotherFunc(...)\\n"); }
};
"""

@PYB11template("Value1", "Value2")
class A:

    def pyinit(self):
        "Default A()"

    @PYB11virtual
    @PYB11const
    def func(self, x="const %(Value1)s&", y="const %(Value2)s&"):
        "Default A::func"
        return "void"

@PYB11template("Value3", "Value4")
@PYB11template_dict({"Value1" : "double", "Value2" : "int"})
class B(A):

    def pyinit(self):
        "Default B()"

    @PYB11virtual
    @PYB11const
    def yetAnotherFunc(self, x="const %(Value3)s&", y="const %(Value4)s&"):
        "Default B::yetAnotherFunc"
        return "void"

# We still need to instantiate any versions of A that we need/use.
A_double_int = PYB11TemplateClass(A, template_parameters=("double", "int"))
B_ADI_uint   = PYB11TemplateClass(B, template_parameters= {"Value3" : "A<int, double>", 
                                                           "Value4" : "unsigned"})
