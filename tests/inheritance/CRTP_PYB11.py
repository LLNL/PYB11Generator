from PYB11Generator import *

PYB11preamble = """
#include <cstdio>

template<typename Descendant, typename Value>
class A {
public:
  A()                                                   { printf("A::A()\\n"); }
  virtual ~A()                                          { printf("A::~A()\\n"); }
  Value func() const                                    { auto x = asDescendant().func(); printf("A::func() : %f\\n", x); return x; }
  Descendant& asDescendant() const                      { return static_cast<Descendant&>(const_cast<A<Descendant, Value>&>(*this)); }
};

template<typename Value>
class B: public A<B<Value>, Value> {
public:
  B(const Value x): A<B, Value>(), mval(x)              { printf("B::B(%f)\\n", x); }
  virtual ~B()                                          { printf("B::~B()\\n"); }
  Value func() const                                    { printf("B::func()\\n"); return mval; }
  B() = delete;
private:
  Value mval;
};

template<typename Value>
class C: public B<Value> {
public:
  C(const Value x): B<Value>(x)                         { printf("C::C(%f)\\n", x); }
  virtual ~C()                                          { printf("C::~C()\\n"); }
  C() = delete;
};

"""

@PYB11template("Descendant", "Value")
class A:

    def pyinit(self):
        return

    @PYB11const
    def func(self):
        return "%(Value)s"

@PYB11template("Value")
@PYB11template_dict({"Descendant" : "B<%(Value)s>"}) # <--- specify the template parameter substitutions
class B(A):

    def pyinit(self, x = "%(Value)s"):
        return

    @PYB11const
    def func(self):
        return "%(Value)s"

@PYB11template("Value")
class C(B):

    def pyinit(self, x = "%(Value)s"):
        return

ABdouble = PYB11TemplateClass(A, template_parameters=("B<double>", "double"))
Bdouble = PYB11TemplateClass(B, template_parameters="double")
Cdouble = PYB11TemplateClass(C, template_parameters="double")
