from arrays import *

# setChaiStuff()

x0 = BlobOfDoubles()
for i in range(len(x0)):
    x0[i] = 10*i
v = MyArray_BlobOfDoubles(2, x0)
print("v: ", v)
print("len(v): ", len(v))
print("v[1]: ", v[1])
print("list(v): ", list(v))
v[1][0] = -4982.5
print("v[1]: ", v[1])
