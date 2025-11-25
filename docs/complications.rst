.. _complications:

==============================
Complications and corner cases
==============================

.. _cross-module-inheritance:

------------------------
Cross-module inheritance
------------------------

For the most part having C++ types exposed in different modules is transparent: so long as you import all the necessary modules once they are all compiled and bound, everything just works.  However, the exception to this rule is if you want to bind a class in one module that inherits from a class bound in another.   Suppose for instance we have two C++ classes (``A`` and ``B``), defined in two different headers ``A.hh`` and ``B.hh``, as follows.

A.hh:

.. code-block:: cpp

  struct A {
    A()                           { printf("A::A()\n"); }
    virtual ~A()                  { printf("A::~A()\n"); }
    virtual int func(const int x) { printf("A::func(%d)\n", x); return x; }
  };

B.hh:

.. code-block:: cpp

  #include "A.hh"

  struct B: public A {
    B(): A()                               { printf("B::B()\n"); }
    virtual ~B()                           { printf("B::~B()\n"); }
    virtual int func(const int x) override { printf("B::func(%d)\n", x); return x*x; }
  };


We want to expose these two class in two different modules, ``Amodule`` and ``Bmodule``.  We will now need to annotate the bindings for the ``A`` class with one piece of new information -- the module it will be bound in.  This is accomplished with a new decorator: ``PYB11module``, and the bindings for ``Amodule`` might look like::

  from PYB11Generator import *

  PYB11includes = ['"A.hh"']

  @PYB11module("Amodule")       # <--- This is our new annotation
  class A:

      def pyinit(self):
          "Default constructor"

      @PYB11virtual
      def func(self, x="int"):
          "A::func"
          return "int"

Let's suppose the above binding source is stored in file ``Amodule_bindings.py``.  We can now write our binding source for ``Bmodule`` as normal, but we need to import ``Amodule_bindings`` so we can express the inheritance relation between ``B`` and ``A``::

  from PYB11Generator import *

  import Amodule_bindings

  PYB11includes = ['"B.hh"']

  class B(Amodule_bindings.A):

      def pyinit(self):
          "Default constructor"

      @PYB11virtual
      def func(self, x="int"):
          "B::func"
          return "int"

The ``@PYB11module`` decoration on ``A`` tells PYB11Generator how to generate the pybind11 code to correctly import ``A`` rather than generate ``A`` locally, as described in the `pybind11 documentation <https://pybind11.readthedocs.io/en/stable/advanced/misc.html#partitioning-code-over-multiple-extension-modules>`_.

.. Note::

   It is critical here in the bindings for ``Bmodule`` that we use ``import Amodule_bindings``, and do *not* import ``A`` into the local scope using ``from Amodule_bindings import A``!  If we put ``A`` in the top-level scope of our bindings for ``B``, the binding code for ``A`` will be generated redundantly in the new bindings, and cause a conflict when we try to import the two modules together.

.. _non-template-to-template-inheritance:

-----------------------------------------------------
Non-templated class inheriting from a templated class
-----------------------------------------------------

PYB11Generator needs to know template parameters for templated classes in order to create concrete instantiations, but since Python does not have the concept of templates we have adopted a two-stage process for creating template class instantiations in PYB11 as described in :ref:`class-templates`.  However, if we have a non-templated class which inherits from a templated base, there is no longer the second-stage of this procedure using :func:`PYB11TemplateClass` to instantiate the base with the proper template parameters.

It is possible to handle this situation, but it requires two decorations be applied to the non-templated descendant:

#. Because the descendant will inherit the template decoration of the base class, we must explicitly state that the descendant has no template parameters with ``@PYB11template()``.

#. We still need to specify what template parameters should be used for the base class.  Template parameters in PYB11Generator are specified using python dictionary matching, so we can directly insert the proper template parameter choices in the appropriate dictionary for our non-templated descendant using ``@PYB11template_dict``.

These two steps are best demonstrated by an example -- consider the following C++ class hierarchy:

.. code-block:: cpp

  template<typename Value1, typename Value2>
  class A {
  public:
    A();
    virtual ~A();
    virtual std::string func(const Value1& x, const Value2& y) const;
  };

  class B: public A<double, int> {
  public:
    B();
    virtual ~B();
    virtual std::string func(const double& x, const int& y) const;
  };

PYB11Generator can represent this hierarchy with::

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

.. _template_class_inheritance_changes:

-----------------------------------------------------------
Templated class inheritance with template parameter changes
-----------------------------------------------------------

Another variation on the above is the templated class inheritance where the template parameters are changed between the base and descendant types.  For example, consider the following class hierarchy:

.. code-block:: cpp

  template<typename Value1, typename Value2>
  class A {
  ...
  };

  template<typename Value2, typename Value3>
  class B: public A<unsigned, Value2> {
  ...
  };

In this case the descendant ``B`` class inherits from ``A``, but specializes one of the template arguments to ``unsigned``.  Binding instantiations of ``A`` is straightforward using the methods described in :ref:`class-templates`, but how should we create instantiations of ``B``?  The solution here is to use ``PYB11template_dict`` as above to specify the ``Value1`` template parameter for ``B``::

  @PYB11template("Value2", "Value3")
  @PYB11template_dict({"Value1" : "unsigned"})
  class B(A):
     ...

  B_double_int = PYB11TemplateClass(B, template_parameters=("double", "int")

----------------------------------------------
Using the Curiously Recurring Template Pattern
----------------------------------------------

The Curiously Recurring Template Pattern (`CRTP <https://en.cppreference.com/w/cpp/language/crtp.html>`_) is a method of implementing static polymorphism in C++.  Binding classes in PYB11Generator using this pattern is another example of the above cases where the template pattern is changed between base and derived classes, but can still be confusing.  An simplified example in C++ might look like:

.. code-block:: cpp

  #include <cstdio>

  template<typename Descendant, typename Value>
  class A {
  public:
    A()                                                   { printf("A::A()\\n"); }
    virtual ~A()                                          { printf("A::~A()\\n"); }
    Value func() const                                    { auto x = asDescendant().func(); printf("A::func() : %f\\n", x); return x; }
    Descendant& asDescendant() const                      { return static_cast<Descendant&>(const_cast<A<Descendant, Value>&>(*this)); }
  };

  template<typename Value>
  class B: public A<B<Value>, Value> {
  public:
    B(const Value x): A<B, Value>(), mval(x)              { printf("B::B(%f)\\n", x); }
    virtual ~B()                                          { printf("B::~B()\\n"); }
    Value func() const                                    { printf("B::func()\\n"); return mval; }
    B() = delete;
  private:
    Value mval;
  };

  template<typename Value>
  class C: public B<Value> {
  public:
    C(const Value x): B<Value>(x)                         { printf("C::C(%f)\\n", x); }
    virtual ~C()                                          { printf("C::~C()\\n"); }
    C() = delete;
  };

This example can be wrapped for Python using PYB11Generator using the ``@PYB11template_dict`` decorator to augment the template parameters of descendant types (class ``B`` in this example) with the needed ``Descendant`` template argument::

  @PYB11template("Descendant", "Value")
  class A:

      def pyinit(self):
          return

      @PYB11const
      def func(self):
          return "%(Value)s"

  @PYB11template("Value")
  @PYB11template_dict({"Descendant" : "B<%(Value)s>"}) # <--- specify the template parameter substitutions
  class B(A):

      def pyinit(self, x = "%(Value)s"):
          return

      @PYB11const
      def func(self):
          return "%(Value)s"

  @PYB11template("Value")
  class C(B):

      def pyinit(self, x = "%(Value)s"):
          return

  ABdouble = PYB11TemplateClass(A, template_parameters=("B<double>", "double"))
  Bdouble = PYB11TemplateClass(B, template_parameters="double")
  Cdouble = PYB11TemplateClass(C, template_parameters="double")

--------------------------------
Binding ``constexpr`` statements
--------------------------------

In C++ ``constexpr`` denotes quantities that are known at compile time and therefore can be entirely optimized away during the compilation phase.  Python does not really have this concept, but nonetheless we can expose ``constexpr`` definitions in our Python modules using methods we have already covered.

* If we have a constexpr variable defined outside the scope of class or struct, we can simply use the :func:`PYB11attr` command to bind it as we would any other :ref:`attributes`.  So for example the following C++ declaration:

  .. code-block:: cpp

     static constexpr unsigned square_of_two = 2u*2u;

  can be bound using the PYB11Generator statement::

    square_of_two = PYB11attr()

* Similarly a constexpr function can be bound using the ordinary methods for binding :ref:`functions`.  So the following combination of C++ variables and functions:

  .. code-block:: cpp

     constexpr unsigned square_of_two = 2u*2u;
     static constexpr unsigned cube_of_three = 3u*3u*3u;
     constexpr double a_constexpr_function() { return square_of_two * cube_of_three; }

  can be bound in a PYB11Generator module as::

    square_of_two = PYB11attr()
    cube_of_three = PYB11attr()

    def a_constexpr_function():
        return

* Similarly constexpr variables and methods of classes can be bound using the statements discussed in :ref:`classes`:

  .. code-block:: cpp

     class A {
     public:
       A()                                       { printf("A::A()\\n"); } 
       ~A()                                      { printf("A::~A()\\n"); }
       static constexpr double square_of_pi = M_PI*M_PI;
       static constexpr size_t size_of_something = 24u;

       static constexpr double some_static_constexpr_method()      { return square_of_pi * square_of_two; }
       constexpr double some_constexpr_method(double x, double y)  { return x*y * some_static_constexpr_method(); }
     };

  becomes in PYB11Generator bindings::

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

------------------------------------------------
Directly editing PYB11Generator generated files
------------------------------------------------

For testing and development occasionally it is useful to directly edit the pybind11 C++ code generated by PYB11Generator.  This is an extremely unusual situation and should probably not be part of anyone's regular work, but if it is desired it is possible to mark a C++ file generated by PYB11Generator such that it is not regenerated and replaced.  To do this simply insert a comment line at the top of the generated C++ file:

  .. code-block:: cpp

    // PYB11skip

And add the option ``ALLOW_SKIPS ON`` to the CMake build configuration::

  PYB11Generator_add_module(...
                            ALLOW_SKIPS ON)

Note that the default for ``ALLOW_SKIPS`` is ``OFF`` so PYB11Generator will not skip generating files.  You must both flip this option on and annotate the generated files with ``// PYB11skip`` for PYB11Generator to not overwrite such generated files.  In these cases PYB11Generator will print a warning for each file that is skipped.
