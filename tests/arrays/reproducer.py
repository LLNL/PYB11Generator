#from arrays import *
#
#v0 = MyArray_double(100, -4.8)
#vv = MyArray_of_vec_double(100, v0)
#print("len(vv) : ", len(vv))
#print("vv[15][10] : ", vv[15][10])
#vv[15][10] = 4729.3
#print("vv[15][10] : ", vv[15][10])

from tensor import *
from arrays import *
t = ThirdRankTensor1d()
print(t)
m = MyArray_TRT(10)
#print(m[0].nDimensions)
#print(t.nDimensions)
print(ThirdRankTensor3d())
#for i in range(ThirdRankTensor3d.nDimensions):
#    print(i)
print(m[0])
print(m[1])
print("----")
for i in range(10):
    print(m[i])
