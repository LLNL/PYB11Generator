import sys, os, shutil, filecmp

# Arguments
pyb11_mod_name = sys.argv[1]
mod_name = sys.argv[2]
multiple_files = eval(sys.argv[3])
generatedfiles = sys.argv[4]
allow_skips = eval(sys.argv[5])

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

exec(code)
assert os.path.isfile(new_src)

# Look for any files we want to preserve from the existing generated pybind11 source
skips = []
if allow_skips:
    # Scan to see if any of the current files should be preserved
    current_files = os.listdir(current_pth)
    for filename in current_files:
        with open(os.path.join(current_pth, filename), "r") as f:
            line = f.readline().strip()
            if line.startswith("// PYB11skip"):
                skips.append(filename)
                print("PYB11Generator WARNING: skipping regenerating {} as requested".format(filename))

# Compare the old and new generated files
diff = filecmp.dircmp(current_pth, new_pth)

# Copy any new files or changed files
for filename in diff.right_only + diff.diff_files:
    if not filename in skips:
        shutil.copy(os.path.join(new_pth, filename),
                    os.path.join(current_pth, filename))

# Remove any files not in the new set
for filename in diff.left_only:
    if not filename in skips:
        os.remove(os.path.join(current_pth, filename))

# Clean up the temporary new file path
shutil.rmtree(new_pth)

assert os.path.isfile(current_src)
assert not os.path.exists(new_pth)
