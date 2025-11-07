#-------------------------------------------------------------------------------
# PYB11Generator
#-------------------------------------------------------------------------------
import inspect, sys, os
from .PYB11utils import *
from .PYB11Decorators import *
from .PYB11STLmethods import *
from .PYB11function import *
from .PYB11class import *
from .PYB11Publicist import *
from .PYB11enum import *
from .PYB11attr import *

#-------------------------------------------------------------------------------
# PYB11generateModule
#-------------------------------------------------------------------------------
def PYB11generateModule(modobj,
                        modname = None,
                        filename = None,
                        multiple_files = False,  # Optionally generate multiple pybind11 source files
                        generatedfiles = None):  # file name to create list of generated pybind11 source files if multiple_files = True
    if modname is None:
        modname = modobj.__name__
    modobj.PYB11modulename = modname
    modobj.multiple_files = multiple_files
    if filename is None:
        filename = modname + ".cc"
    basedir, tmp_filename = os.path.split(filename)
    basename, ext = os.path.splitext(tmp_filename)
    if not basedir:
        raise RuntimeError("ERROR determining base directory from " + filename)
    if not basename:
        raise RuntimeError("ERROR determining base file name from " + filename)
    if generatedfiles is None:
        generatedfiles = modname + "_PYB11_generated_files"
    modobj.filename = filename
    modobj.basedir = basedir
    modobj.basename = basename
    modobj.generatedfiles = generatedfiles
    modobj.master_include_file = "PYB11_module_" + basename + ".hh"
    modobj.generatedfiles_list = [tmp_filename]

    # Main module source
    PYB11generateModuleStart(modobj)

    # enums
    PYB11generateModuleEnums(modobj)

    # STL types
    PYB11generateModuleSTL(modobj)

    # Generate the class binding calls
    PYB11generateModuleClassBindingCalls(modobj)

    # methods
    PYB11generateModuleFunctions(modobj)

    # Attributes
    PYB11generateModuleAttrs(modobj)

    # Close the module source
    PYB11generateModuleClose(modobj)

    # Generate the class binding functions
    PYB11generateModuleClassFuncs(modobj)

    # Write out our list of generated files
    with open(generatedfiles, "w") as f:
        ss = f.write
        #ss(f"#  PYB11Generator generated files for module {modname}\n")
        for x in modobj.generatedfiles_list:
            ss(x + "\n")

    return

#-------------------------------------------------------------------------------
# PYB11generateModuleStart
#
# All the stuff up to the methods.
#-------------------------------------------------------------------------------
def PYB11generateModuleStart(modobj):

    name = modobj.PYB11modulename

    # Generate module starting comments and include master header
    faccess = "w" if modobj.multiple_files else "a"
    with open(modobj.filename, faccess) as f:
        ss = f.write
        incfile = modobj.master_include_file
        ss(f'''//------------------------------------------------------------------------------
// Module {name}
//------------------------------------------------------------------------------
#include "{incfile}"

''')

    # Make master include file
    with open(os.path.join(modobj.basedir, modobj.master_include_file), "w") as f:
        ss = f.write

        ss(f"""//------------------------------------------------------------------------------
// Module {name}
//------------------------------------------------------------------------------
#ifndef PYB11_{name}_master_include
#define PYB11_{name}_master_include

// Put Python includes first to avoid compile warnings about redefining _POSIX_C_SOURCE
#include "pybind11/pybind11.h"
#include "pybind11/stl_bind.h"
#include "pybind11/stl.h"
#include "pybind11/functional.h"
#include "pybind11/operators.h"

namespace py = pybind11;
using namespace pybind11::literals;
""")

        # Includes
        allincs = PYB11findAllIncludes(modobj)
        if allincs:
            for inc in allincs:
                ss('#include %s\n' % inc)
            ss("\n")

        # Use namespaces
        if hasattr(modobj, "PYB11namespaces"):
            for ns in modobj.PYB11namespaces:
                ss("using namespace " + ns + ";\n")
            ss("\n")

        # Use objects from scopes
        if hasattr(modobj, "PYB11scopenames"):
            for scopename in modobj.PYB11scopenames:
                ss("using " + scopename + "\n")
            ss("\n")

        # Preamble
        if hasattr(modobj, "PYB11preamble"):
            ss("""//------------------------------------------------------------------------------
// User defined preamble
//------------------------------------------------------------------------------
""")
            ss(modobj.PYB11preamble + "\n")
            ss("\n")
        for objname, obj in PYB11objsWithMethod(modobj, "PYB11preamble"):
            obj.PYB11preamble(modobj, ss, objname)

        # Does anyone have any opaque types?
        if hasattr(modobj, "PYB11opaque"):
            ss("""//------------------------------------------------------------------------------
// Opaque type definitions
//------------------------------------------------------------------------------
""")
            for x in modobj.PYB11opaque:
                ss(f"PYBIND11_MAKE_OPAQUE(PYBIND11_TYPE({x}))\n")
            ss("\n")
        for objname, obj in PYB11objsWithMethod(modobj, "PYB11opaqueTypes"):
            obj.PYB11opaqueTypes(modobj, ss, objname)
        ss("\n")

        # Forward declare functions we use for multiple file bindings
        ss("""//------------------------------------------------------------------------------
// Forward decalare methods for providing bindings
//------------------------------------------------------------------------------
""")
        if PYB11STLobjs(modobj):
            ss("void bindModuleSTLtypes(py::module_& mod);\n")

        PYB11generateClassBindingFunctionDecls(modobj, ss)
        ss("\n#endif\n")

    # On to the module coding
    with open(modobj.filename, "a") as f:
        ss = f.write

        # Trampolines
        PYB11generateModuleTrampolines(modobj)

        # Publicists
        PYB11generateModulePublicists(modobj)

        # Declare the module
        ss("""//------------------------------------------------------------------------------
// Make the module
//------------------------------------------------------------------------------
PYBIND11_MODULE(%(name)s, m) {
""" % {"name"     : name,
})

        doc = inspect.getdoc(modobj)
        if doc:
            ss("  m.doc() = ")
            PYB11docstring(doc, ss)
            ss("  ;\n")
        ss("\n")

        # Any module preamble?
        if hasattr(modobj, "PYB11modulepreamble"):
            ss(modobj.PYB11modulepreamble + "\n\n")

        # Are there any objects to import from other modules
        othermods = PYB11othermods(modobj)
        for (kname, klass) in PYB11classes(modobj):
            klassattrs = PYB11attrs(klass)
            mods = klassattrs["module"]
            for otherklass in mods:
                othermod = mods[otherklass]
                if othermod not in othermods:
                    othermods.append(othermod)
        if othermods:
            ss("  // Import external modules\n")
            for othermod in othermods:
                if othermod != name:
                    ss('  py::module::import("%s");\n' % othermod)
            ss("\n")

    return

#-------------------------------------------------------------------------------
# PYB11generateModuleClose
#-------------------------------------------------------------------------------
def PYB11generateModuleClose(modobj):
    with open(modobj.filename, "a") as f:
        f.write("}\n")
    return
