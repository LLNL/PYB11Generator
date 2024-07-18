from PYB11Generator import *

PYB11preamble = """

constexpr unsigned square_of_two = 2u*2u;
static constexpr unsigned cube_of_three = 3u*3u*3u;

class A {
public:
  A()                                       { printf("A::A()\\n"); } 
  ~A()                                      { printf("A::~A()\\n"); }
  static constexpr double square_of_pi = M_PI*M_PI;
  static constexpr size_t size_of_something = 24u;
};
"""

#...............................................................................
square_of_two = PYB11attr()
cube_of_three = PYB11attr()

#...............................................................................
class A:

    def pyinit(self):
        "Default A()"

    square_of_pi = PYB11property("double", constexpr=True, static=True)
    size_of_something = PYB11property("unsigned", constexpr=True, static=True)
