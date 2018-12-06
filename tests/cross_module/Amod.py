from PYB11Generator import *

PYB11includes = ['"A.hh"']

@PYB11module("Amodule")
class A:

    def pyinit(self):
        "Default constructor"

    @PYB11virtual
    def func(self, x="int"):
        "A::func"
        return "int"
