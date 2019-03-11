from PYB11Generator import *

@PYB11template("T1", "T2")
class A:

    def pyinit(self):
        "A default constructor"
        return

    @PYB11pure_virtual
    @PYB11protected
    def func(self,
             val1 = "const %(T1)s",
             val2 = "const %(T2)s"):
        return "void"

    x = PYB11readwrite()
    y = PYB11readwrite()

A_int_double = PYB11TemplateClass(A, template_parameters=("int", "double"))
