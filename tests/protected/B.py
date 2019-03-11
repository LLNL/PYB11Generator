from PYB11Generator import *
from A import *

@PYB11template("T1", "T2")
class B(A):

    def pyinit(self):
        "B default constructor"
        return

    @PYB11virtual
    @PYB11protected
    def func(self,
             val1 = "const %(T1)s",
             val2 = "const %(T2)s"):
        return "void"

    x = PYB11readwrite()
    y = PYB11readwrite()

B_int_double = PYB11TemplateClass(B, template_parameters=("int", "double"))
