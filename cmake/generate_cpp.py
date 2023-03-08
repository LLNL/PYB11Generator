import sys
import os
import shutil
import filecmp

pyb11_mod_name = sys.argv[1]
mod_name = sys.argv[2]

tmp_dir = "tmp_dir"
current_src = mod_name + ".cc"
stashed_src = os.path.join(tmp_dir, current_src)

# Stash away the existing module code (if any)
if os.path.isfile(current_src):
    if os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)
    os.mkdir(tmp_dir)
    os.rename(current_src, stashed_src)
assert not os.path.isfile(current_src)

# Generate the source anew 
code = """
from PYB11Generator import *
import {pyb11_module}
PYB11generateModule({pyb11_module}, \"{mod_name}\")
""".format(pyb11_module = pyb11_mod_name,
           mod_name     = mod_name)
exec(code)
assert os.path.isfile(current_src)

# If the module source is unchanged, put it back
if os.path.isfile(stashed_src):
    if filecmp.cmp(current_src, stashed_src):
        os.remove(current_src)
        os.rename(stashed_src, current_src)

# Clean up
if os.path.exists(tmp_dir):
    shutil.rmtree(tmp_dir)
