from keepalive import *

wombat_a = Wombat()
wombat_b = Wombat()
wombat_c = Wombat()

a = A()
a.add_wombats(wombat_a, wombat_b, wombat_c)

# Try to delete the wombats -- the C++ objects should persist
del wombat_a, wombat_b, wombat_c

print("a")
