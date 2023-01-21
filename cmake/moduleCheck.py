# Find all the non-system python dependencies of a given python file
# Based on the original version developed in Spheral.
from modulefinder import ModuleFinder
import sys, os
import filecmp

mod_name = sys.argv[1]
mod_file = sys.argv[2]

finder = ModuleFinder()
finder.run_script(mod_file)
#print("Warning failed imports: ", finder.badmodules.keys())

current_stamp_name = mod_name + "_stamp.cmake"
tmp_stamp_name = current_stamp_name + ".tmp"

with open(tmp_stamp_name, "w") as newF:
    newF.write("set("+mod_name+"_DEPENDS \n")

    for name, mod in finder.modules.items():
      if (mod.__file__):
        if not ("lib/python3" in mod.__file__):
          newF.write(mod.__file__)
          newF.write('\n')

    newF.write(")\n")

if (os.path.isfile(current_stamp_name)):
  if (not filecmp.cmp(current_stamp_name, tmp_stamp_name)):
    os.rename(tmp_stamp_name, current_stamp_name)
  else:
    os.remove(tmp_stamp_name)
else:
  os.rename(tmp_stamp_name, current_stamp_name)
