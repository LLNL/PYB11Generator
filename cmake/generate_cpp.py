import sys
import os
import filecmp

pyb11_mod_name = sys.argv[1]
mod_name = sys.argv[2]

current_src = mod_name + ".cc"
new_src = mod_name + "_tmp.cc"

# Generate the source anew 
code = """
from PYB11Generator import *
import {pyb11_module}
PYB11generateModule({pyb11_module}, 
                    modname = \"{mod_name}\",
                    filename = \"{new_src}\")
""".format(pyb11_module = pyb11_mod_name,
           mod_name     = mod_name,
           new_src      = new_src)
exec(code)
assert os.path.isfile(new_src)

# If the module source is changed, update it.  Otherwise
# get rid of the temporary file and we're done.
if os.path.isfile(current_src):
    if filecmp.cmp(current_src, new_src):
        os.remove(new_src)
    else:
        os.remove(current_src)
        os.rename(new_src, current_src)
else:
    os.rename(new_src, current_src)
assert os.path.isfile(current_src)
assert not os.path.isfile(new_src)
