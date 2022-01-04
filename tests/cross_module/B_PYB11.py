from PYB11Generator import *

import A_PYB11

PYB11includes = ['"B.hh"']

class B(A_PYB11.A):

    def pyinit(self):
        "Default constructor"

    @PYB11virtual
    def func(self, x="int"):
        "B::func"
        return "int"
