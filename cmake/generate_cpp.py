import sys
import os
import filecmp

pyb11_mod_name = sys.argv[1]
mod_name = sys.argv[2]
tmp_name = mod_name + "_tmp"

code = """
from PYB11Generator import *
import ${pyb11_module}
PYB11generateModule(${pyb11_module}, \"${tmp_name}\")
"""
code = code.replace("${pyb11_module}", pyb11_mod_name)
code = code.replace("${tmp_name}", tmp_name)

exec(code)

current_src = mod_name + ".cc"
tmp_src = mod_name + "_tmp.cc"

if (os.path.isfile(current_src)):
  if (not filecmp.cmp(current_src, tmp_src)):
    os.rename(tmp_src, current_src)
  else:
    os.remove(tmp_src)
else:
  os.rename(tmp_src, current_src)


