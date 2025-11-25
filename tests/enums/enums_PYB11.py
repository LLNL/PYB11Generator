from PYB11Generator import *

PYB11preamble = """

// A collection of adorable rodents
enum Rodents {
  mouse = 0,
  rat = 1,
  squirrel = 2,
  hamster = 3,
  gerbil = 4,
  capybara = 10
};

class Homestararmy {
  public:

  enum members {
    HomestarRunner = 0,
    StrongSad = 1,
    Homsar = 2,
    PaintingOfGuyWithBigKnife = 3,
    FrankBennedetto = 4,
  };
};

"""

Rodents = PYB11enum(("mouse", "rat", "squirrel", "hamster", "gerbil", "capybara"),
                    export_values = True,
                    doc="A collection of adorable rodents")

class Homestararmy:
    members = PYB11enum(("HomestarRunner", "StrongSad", "Homsar", "PaintingOfGuyWithBigKnife", "FrankBennedetto"))
