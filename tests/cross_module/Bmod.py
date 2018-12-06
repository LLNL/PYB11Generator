from PYB11Generator import *

import Amod

PYB11includes = ['"B.hh"']

class B(Amod.A):

    def pyinit(self):
        "Default constructor"

    @PYB11virtual
    def func(self, x="int"):
        "B::func"
        return "int"
