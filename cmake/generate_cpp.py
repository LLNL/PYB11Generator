import sys, os, shutil, filecmp

# Arguments
pyb11_mod_name = sys.argv[1]
mod_name = sys.argv[2]
multiple_files = sys.argv[3]
generatedfiles = sys.argv[4]
# print("--> ", pyb11_mod_name)
# print("--> ", mod_name)
# print("--> ", multiple_files)
# print("--> ", generatedfiles)

# Prepare output directories
current_pth = "current_" + mod_name
new_pth     = "new_"     + mod_name
if not os.path.exists(current_pth):
    os.makedirs(current_pth)
if os.path.exists(new_pth):
    shutil.rmtree(new_pth)
os.makedirs(new_pth)

# Paths to the main module pybind11 source files
current_src = os.path.join(current_pth, mod_name + ".cc")
new_src     = os.path.join(new_pth,    mod_name + ".cc")

# Generate the source anew 
code = """
from PYB11Generator import *
import {pyb11_module}
PYB11generateModule({pyb11_module}, 
                    modname = \"{mod_name}\",
                    filename = \"{new_src}\",
                    multiple_files = {multiple_files},
                    generatedfiles = \"{generatedfiles}\")
""".format(pyb11_module   = pyb11_mod_name,
           mod_name       = mod_name,
           new_src        = new_src,
           multiple_files = multiple_files,
           generatedfiles = generatedfiles)

print("--------------------------------------------------------------------------------")
print(code)
print("--------------------------------------------------------------------------------")

exec(code)
assert os.path.isfile(new_src)

# If the module source is changed, update it.  Otherwise
# get rid of the temporary files and we're done.
diff = filecmp.dircmp(current_pth, new_pth)
if diff.left_only or diff.right_only or diff.diff_files:
    shutil.rmtree(current_pth)
    shutil.move(new_pth, current_pth)
else:
    shutil.rmtree(new_pth)

assert os.path.isfile(current_src)
assert not os.path.exists(new_pth)
