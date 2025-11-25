from PYB11Generator import *

PYB11preamble = """

constexpr unsigned square_of_two = 2u*2u;
static constexpr unsigned cube_of_three = 3u*3u*3u;
constexpr double a_constexpr_function() { return square_of_two * cube_of_three; }

class A {
public:
  A()                                       { printf("A::A()\\n"); } 
  ~A()                                      { printf("A::~A()\\n"); }
  static constexpr double square_of_pi = M_PI*M_PI;
  static constexpr size_t size_of_something = 24u;

  static constexpr double some_static_constexpr_method()      { return square_of_pi * square_of_two; }
  constexpr double some_constexpr_method(double x, double y)  { return x*y * some_static_constexpr_method(); }
};
"""

#...............................................................................
square_of_two = PYB11attr()
cube_of_three = PYB11attr()

def a_constexpr_function():
    return

#...............................................................................
class A:

    def pyinit(self):
        "Default A()"

    # Methods
    @PYB11static
    def some_static_constexpr_method(self):
        return "double"

    def some_constexpr_method(self,
                              x = "double",
                              y = "double"):
        return "double"

    # Attributes
    square_of_pi = PYB11readonly(static=True)
    size_of_something = PYB11readonly(static=True)
