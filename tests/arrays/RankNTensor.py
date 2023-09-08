from PYB11Generator import *

@PYB11template("int nDim", "int rank", "typename Descendant")
class RankNTensor:

    PYB11typedefs = """
    using RankNTensorType = Spheral::RankNTensor<%(nDim)s, %(rank)s, %(Descendant)s>;
"""    

    def pyinit(self):
        return

    # @PYB11pure_virtual
    # @PYB11const
    # def blago(self):
    #     return "int"

#-------------------------------------------------------------------------------
# RankNTensor instantiations.
#-------------------------------------------------------------------------------
RankNTensor133 = PYB11TemplateClass(RankNTensor,
                                    template_parameters = ("1", "3", "Spheral::GeomThirdRankTensor<1>"))
