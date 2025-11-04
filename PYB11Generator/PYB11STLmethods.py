#-------------------------------------------------------------------------------
# PYB11STLmethods
#
# Thin wrappers to generate the pybind11 STL functions.
#-------------------------------------------------------------------------------
import os, inspect
from .PYB11utils import *

#-------------------------------------------------------------------------------
# std::vector
#-------------------------------------------------------------------------------
class PYB11_bind_vector:

    def __init__(self,
                 element,            # template element type for vector
                 opaque = False,     # should we make the type opaque?
                 local = None):      # should the opaque choice be module local?
        self.element = element
        self.opaque = opaque
        self.local = local
        return

    def PYB11opaqueTypes(self, modobj, ss, name):
        if self.opaque:
            ss(f"PYBIND11_MAKE_OPAQUE(PYBIND11_TYPE(std::vector<{self.element}>));\n")
        return

    def __call__(self, modobj, ss, name):
        ss('py::bind_vector<std::vector<' + self.element + '>>(m, "' + name + '"')
        if not self.local is None:
            ss(', py::module_local(')
            if self.local:
                ss('true)')
            else:
                ss('false)')
        ss(');\n')
        return

#-------------------------------------------------------------------------------
# std::map
#-------------------------------------------------------------------------------
class PYB11_bind_map:

    def __init__(self,
                 key,                # template key type
                 value,              # template value type
                 opaque = False,     # should we make the container opaque
                 local = None):      # should the opaque choice be module local?
        self.key = key
        self.value = value
        self.opaque = opaque
        self.local = local
        return

    def PYB11opaqueTypes(self, modobj, ss, name):
        if self.opaque:
            cppname = "std::map<" + self.key + "," + self.value + ">"
            ss(f"PYBIND11_MAKE_OPAQUE(PYBIND11_TYPE({cppname}));\n")
        return

    def __call__(self, modobj, ss, name):
        ss('py::bind_map<std::map<' + self.key + ', ' + self.value + '>>(m, "' + name + '"')
        if not self.local is None:
            ss(', py::module_local(')
            if self.local:
                ss('true)')
            else:
                ss('false)')
        ss(');\n')
        return

#-------------------------------------------------------------------------------
# PYB11STLobjs
#
# Get the STL objects to bind from a module
#-------------------------------------------------------------------------------
def PYB11STLobjs(modobj):
    return [(name, obj) for (name, obj) in inspect.getmembers(modobj)
            if name[:5] != "PYB11" and
            (isinstance(obj, PYB11_bind_vector) or
             isinstance(obj, PYB11_bind_map))]

#-------------------------------------------------------------------------------
# PYB11generateModuleSTLmethod
#
# Generate the method that binds the STL types
#-------------------------------------------------------------------------------
def PYB11generateModuleSTLmethod(modobj, stlobjs):
    filename = modobj.basename + "_STLbindings.cc"
    modobj.generatedfiles_list.append(filename)
    name = modobj.PYB11modulename
    modincludefile = modobj.master_include_file
    with open(os.path.join(modobj.basedir, filename), "w") as f:
        ss = f.write
        ss(f'''//------------------------------------------------------------------------------
// Bind STL for {name} module
//------------------------------------------------------------------------------
#include "{modincludefile}"

void bindModuleSTLtypes(py::module_& m) {{
''')
        for (name, obj) in stlobjs:
            ss("  ")
            obj(modobj, ss, name)
        ss("}\n")
    return

#-------------------------------------------------------------------------------
# PYB11generateModuleSTL
#
# Bind the STL containers in the module
#-------------------------------------------------------------------------------
def PYB11generateModuleSTL(modobj):
    stuff = PYB11STLobjs(modobj)
    if stuff:
        with open(modobj.filename, "a") as f:
            ss = f.write
            ss("  //..............................................................................\n")
            ss("  // STL bindings\n")

        if False: # modobj.multiple_files:
            # Multiple files
            with open(modobj.filename, "a") as f:
                ss = f.write
                ss("  bindModuleSTLtypes(m);\n\n")
            PYB11generateModuleSTLmethod(modobj, stuff)

        else:
            # Monolithic file
            with open(modobj.filename, "a") as f:
                ss = f.write
                for (name, obj) in stuff:
                    ss("  ")
                    obj(modobj, ss, name)
                ss("\n")

    return

