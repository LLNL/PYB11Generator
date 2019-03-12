class Vector {
public:
  double x, y, z;
  Vector(double x = 0.0,
         double y = 0.0,
         double z = 0.0):
    x(x),
    y(y),
    z(z) {}
};

class my_array {
private:
  std::vector<Vector> mdata;
public:
  std::vector<Vector>& data() { return mdata; }
};

  
