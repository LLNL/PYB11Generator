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
if not os.path.exists("current"):
    os.makedirs("current")
if os.path.exists("new"):
    shutil.rmtree("new")
os.makedirs("new")

# Paths to the main module pybind11 source files
current_src = os.path.join("current", mod_name + ".cc")
new_src     = os.path.join("new",     mod_name + ".cc")

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
diff = filecmp.dircmp("current", "new")
if diff.left_only or diff.right_only or diff.diff_files:
    shutil.rmtree("current")
    shutil.move("new", "current")
else:
    shutil.rmtree("new")

assert os.path.isfile(current_src)
assert not os.path.exists("new")
