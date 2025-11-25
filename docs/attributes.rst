.. _attributes:

==========
Attributes
==========

Standalone variables defined outside the scope of classes or structs can be exposed in a module with the ``PYB11attr`` method. So if in C++ we have a variable defined such as:

.. code-block:: cpp

   double square_of_two = 4;

This can be exposed in a PYB11Generator module using ``PYB11attr``::

  square_of_two = PYB11attr()
