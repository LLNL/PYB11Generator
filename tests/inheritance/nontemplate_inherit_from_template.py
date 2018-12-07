from PYB11Generator import *

@PYB11template("Value1", "Value2")
class A:

    def pyinit(self):
        "Default A()"

    @PYB11virtual
    @PYB11const
    def func(self, x="const %(Value1)s&", y="const %(Value2)s&"):
        "Default A::func"
        return "std::string"

@PYB11template()                                             # <--- force not to inherit template parameters from A
@PYB11template_dict({"Value1" : "double", "Value2" : "int"}) # <--- specify the template parameter substitutions
class B(A):

    def pyinit(self):
        "Default B()"

    @PYB11virtual
    @PYB11const
    def func(self, x="const double&", y="const int&"):
        "B::func override"
        return "std::string"

# We still need to instantiate any versions of A that we need/use.
A_double_int = PYB11TemplateClass(A, template_parameters=("double", "int"))
