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
                        multiple_files = False,                     # Optionally generate multiple pybind11 source files
                        generatedfiles = "PYB11_generated_files"):  # file nane to create list of generated pybind11 source files if multiple_files = True
    if modname is None:
        modname = modobj.__name__
    modobj.PYB11modulename = modname
    modobj.multiple_files = multiple_files
    if filename is None:
        filename = modname + ".cc"
    modobj.filename = filename
    if multiple_files:
        basename, ext = os.path.splitext(filename)
        if not ext:
            raise RuntimeError("ERROR determining base file name and extension from " + filename)
        basedir = os.path.dirname(filename)
        if basedir:
            generatedfiles = os.path.join(basedir, generatedfiles)
        modobj.basename = basename
        modobj.basedir = basedir
        modobj.generatedfiles = generatedfiles
        modobj.master_include_file = basename + ".hh"
    else:
        modobj.basedir = None
        modobj.generatedfiles = None
        modobj.master_include_file = filename
    modobj.generatedfiles_list = []

    # Main module source
    PYB11generateModuleStart(modobj)

    # enums
    PYB11generateModuleEnums(modobj)

    # STL types
    PYB11generateModuleSTL(modobj)

        # # classes
        # PYB11generateModuleClasses(modobj, ss)

        # # methods
        # PYB11generateModuleFunctions(modobj, ss)

        # # Attributes
        # PYB11generateModuleAttrs(modobj, ss)

    # Close the module source
    PYB11generateModuleClose(modobj)

    PYB11output("modobj.PYB11modulename")
    PYB11output("modobj.filename")
    PYB11output("modobj.basedir")
    PYB11output("modobj.generatedfiles")
    PYB11output("modobj.generatedfiles_list")
    PYB11output("modobj.master_include_file")

    return

#-------------------------------------------------------------------------------
# PYB11generateModuleStart
#
# All the stuff up to the methods.
#-------------------------------------------------------------------------------
def PYB11generateModuleStart(modobj):

    name = modobj.PYB11modulename

    # Includes
    with open(modobj.master_include_file, "w") as f:
        ss = f.write

        ss(f"""//------------------------------------------------------------------------------
// Module {name}
//------------------------------------------------------------------------------
// Put Python includes first to avoid compile warnings about redefining _POSIX_C_SOURCE
#include "pybind11/pybind11.h"
#include "pybind11/stl_bind.h"
#include "pybind11/stl.h"
#include "pybind11/functional.h"
#include "pybind11/operators.h"

namespace py = pybind11;
using namespace pybind11::literals;

#define PYB11COMMA ,

""")

        # Includes
        allincs = []
        if hasattr(modobj, "PYB11includes"):
            allincs += modobj.PYB11includes
        for objname, obj in PYB11objsWithMethod(modobj, "PYB11includes"):
            allincs += obj.PYB11includes(modobj, objname)
        if allincs:
            for inc in set(allincs):
                ss('#include %s\n' % inc)
            ss("\n")

    # On to the module coding
    faccess = "w" if modobj.multiple_files else "a"
    with open(modobj.filename, faccess) as f:
        ss = f.write

        if modobj.multiple_files:
            incfile = modobj.master_include_file
            ss(f'''//------------------------------------------------------------------------------
// Module {name}
//------------------------------------------------------------------------------
#include "{incfile}"
''')

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
            ss(modobj.PYB11preamble + "\n")
            ss("\n")
        for objname, obj in PYB11objsWithMethod(modobj, "PYB11preamble"):
            obj.PYB11preamble(modobj, ss, objname)
        ss("\n")

        # Does anyone have any opaque types?
        if hasattr(modobj, "PYB11opaque"):
            for x in modobj.PYB11opaque:
                ss("PYBIND11_MAKE_OPAQUE(" + x.replace(",", " PYB11COMMA ") + ")\n")

        # Forward declare functions we use for multiple file bindings
        if modobj.multiple_files:
            ss("// Forward decalare methods for providing bindings\n")
            if PYB11STLobjs(modobj):
                ss("void bindModuleSTLtypes(py::module_& mod);\n")
            ss("\n")

        # Trampolines
        PYB11generateModuleTrampolines(modobj)

        # Publicists
        PYB11generateModulePublicists(modobj, ss)

        # Declare the module
        ss("""
//------------------------------------------------------------------------------
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
