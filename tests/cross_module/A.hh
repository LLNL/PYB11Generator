struct A {
   A()                          { printf("A::A()\n"); }
  ~A()                          { printf("A::~A()\n"); }
  virtual int func(const int x) { printf("A::func(%d)\n", x); return x; }
};
