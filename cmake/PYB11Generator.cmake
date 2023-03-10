#-----------------------------------------------------------------------------------
# PYB11Generator_add_module
#
# Front-end CMake function for use building PYB11Generator Python modules.  Takes a
# single argument (package_name), which is the name of the Python module to be
# generated.  The associated PYB11Generator code should be in the file
#   <package_name>_PYB11.py
# That file may in turn import as many other Python sources for PYB11Generator as
# desired, so it is not necessary to cram all the PYB11Generator bindings into
# <package_name>_PYB11.py.
#
# Important CMake variables:
#   PYB11GENERATOR_ROOT_DIR : (required)
#       - Top-level director for PYB11Generator installation
#   PYBIND11_ROOT_DIR : (optional)
#       - Location of the pybind11 install
#       - defaults to ${PYB11GENERATOR_ROOT_DIR}/extern/pybind11
#   PYTHON_EXE : (optional)
#       - Python executable
#       - if not set, we use CMake's find_package to search for Python3
#
# Usage:
#   PYB11Generator_add_module(<target_name>
#                             MODULE           ...
#                             SOURCE           ...
#                             INSTALL          ...
#                             INCLUDES         ...
#                             LINKS            ...
#                             DEPENDS          ...
#                             PYBIND11_OPTIONS ...
#                             COMPILE_OPTIONS  ...
#                             USE_BLT          ON/OFF)
#   where arguments are:
#       <package_name> (required)
#           The base name of the Python module being generated.  Results in a module
#           which can be imported in Python as "import <package_name>".
#       MODULE ... (optional)
#           default: <target_name>
#           Specify the name of the Python module to be imported and bound
#       SOURCE ... (optional)
#           default: <package_name>_PYB11.py
#           Specify the name of the Python file holding the PYB11Generator description
#           of the bindings.
#       EXTRA_SOURCE ... (optional)
#           Any additional source files we want to compile into the library
#       INSTALL ... (optional)
#           default: ${Python3_SITEARCH}/${package_name}
#           Path to install the final Python module to
#       INCLUDES ... (optional)
#           Any necessary C++ include paths for the compilation of the generated C++ code
#       LINKS ... (optional)
#           Any link flags or libraries necessary to link the compiled Python module
#       DEPENDS ... (optional)
#           Any CMake targets that need to be built/satisfied before this module is
#           built.
#       PYBIND11_OPTIONS ... (optional)
#           Any flags that should be bassed to the pybind11 CMake function
#           pybind11_add_module.  See documentation at
#           https://pybind11.readthedocs.io/en/stable/compiling.html#pybind11-add-module
#       COMPILE_OPTIONS ... (optional)
#           Any additional flags that should be passed during the compile stage.  See
#           CMake documentation for TARGET_COMPILE_OPTIONS.
#       USE_BLT ON/OFF (optional, default OFF)
#           For those using the BLT Cmake extension (https://llnl-blt.readthedocs.io/),
#           which does not play well with standard CMake add_library options.
#           Note, using this option skips using pybind11's own add_module CMake logic,
#           and therefore may make some pybind11 options no-ops.
#
# This is the function users should call directly.  The macro PYB11_GENERATE_BINDINGS
# defined next is primarily for internal use.
#
# Based on Mike Davis' original Cmake scripts for handling PYB11Generator extensions
# in Spheral.  Also uses the pybind11 add_pybind11_module function for most of the
# compilation work.
#-----------------------------------------------------------------------------------

# Need Python components and pybind11
if (NOT DEFINED PYTHON_EXE)
  find_package(Python3 COMPONENTS Interpreter Development)
  set(PYTHON_EXE ${Python3_EXECUTABLE})
endif()
if (DEFINED PYBIND11_ROOT_DIR)
  add_subdirectory(${PYBIND11_ROOT_DIR} ${CMAKE_CURRENT_BINARY_DIR}/external)
else()
  add_subdirectory(${PYB11GENERATOR_ROOT_DIR}/extern/pybind11 ${CMAKE_CURRENT_BINARY_DIR}/external)
endif()

function(PYB11Generator_add_module target_name)

  # Define our arguments
  set(options )
  set(oneValueArgs   MODULE SOURCE INSTALL USE_BLT)
  set(multiValueArgs INCLUDES LINKS DEPENDS PYBIND11_OPTIONS COMPILE_OPTIONS EXTRA_SOURCE)
  cmake_parse_arguments(${target_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("-- MODULE: ${${taget_name}_MODULE}")
  # message("-- SOURCE: ${${target_name}_SOURCE}")
  # message("-- INSTALL: ${${target_name}_INSTALL}")
  # message("-- INCLUDES: ${${target_name}_INCLUDES}")
  # message("-- LINKS: ${${target_name}_LINKS}")
  # message("-- DEPENDS: ${${target_name}_DEPENDS}")
  # message("-- PYBIND11_OPTIONS: ${${target_name}_PYBIND11_OPTIONS}")
  # message("-- COMPILE_OPTIONS: ${${target_name}_COMPILE_OPTIONS}")
  # message("-- USE_BLT: ${target_name}_USE_BLT")
  # message("-- EXTRA_SOURCE: ${target_name}_EXTRA_SOURCE")

  # Set our names and paths
  if (NOT DEFINED ${target_name}_MODULE)
    set(${target_name}_MODULE ${target_name})
  endif()
  if (NOT DEFINED ${target_name}_SOURCE)
    set(${target_name}_SOURCE "${${target_name}_MODULE}_PYB11.py")
  endif()
  # message("-- ${target_name}_MODULE: ${${target_name}_MODULE}")
  # message("-- ${target_name}_SOURCE: ${${target_name}_SOURCE}")
  
  # Generate the pybind11 C++ source file
  PYB11_GENERATE_BINDINGS(${target_name} ${${target_name}_MODULE} ${${target_name}_SOURCE}
                          DEPENDS ${${target_name}_DEPENDS})

  if (${${target_name}_USE_BLT}) 
    # Build using BLT macros -- assumes you've already included BLT CMake rules
    blt_add_library(NAME         ${target_name}
                    SOURCES      ${${target_name}_MODULE} ${${target_name}_SOURCE} ${${target_name}_EXTRA_SOURCE}
                    DEPENDS_ON   Spheral_CXX ${spheral_blt_depends} ${spheral_blt_py_depends} ${${package_name}_DEPENDS}
                    INCLUDES     ${${package_name}_INCLUDES}
                    OUTPUT_NAME  ${${target_name}_MODULE}
                    CLEAR_PREFIX TRUE
                    SHARED       TRUE)
  else()
    # Build using the normal pybind11 rules
    include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${${target_name}_INCLUDES})
    pybind11_add_module(${target_name} ${${target_name}_PYBIND11_OPTIONS} ${${target_name}_MODULE}.cc ${${target_name}_EXTRA_SOURCE})
    set_target_properties(${target_name} PROPERTIES SUFFIX ".so" LIBRARY_OUTPUT_NAME ${${target_name}_MODULE})
    target_link_libraries(${target_name} PRIVATE ${${target_name}_LINKS})
  endif()    

  add_dependencies(${target_name} ${${target_name}_MODULE}_src)
  target_compile_options(${target_name} PRIVATE ${${target_name}_COMPILE_OPTIONS})

  # Installation
  if ("${${target_name}_INSTALL} " STREQUAL " ")
    set(${target_name}_INSTALL ${Python3_SITEARCH}/${target_name})
  endif()
  install(TARGETS ${target_name} DESTINATION ${${target_name}_INSTALL})

endfunction()

#-----------------------------------------------------------------------------------
# PYB11_GENERATE_BINDINGS
#     - Generates the Python bindings for each module in the list
#     - Generates python stamp files for listing python dependency file to help
#       detecting changes in the pyb11 python files at build time
#
# Usage:
#   PYB11_GENERATE_BINDINGS(<target_name> <module_name> <PYB11_SOURCE>
#                           DEPENDS    ...
#                           PYTHONPATH ...)
#   where the arguments are:
#       <target_name> (required)
#           The CMake target name
#       <module_name> (required)
#           The base name for the Python module
#       <PYB11_SOURCE> (required)
#           Source file containing the PYB11Generator bindings description
#       DEPENDS ... (optional)
#           Any CMake targets this package should depend on being built first
#       PYTHONPATH ... (optional)
#           Additions needed for the environment PYTHONPATH
#
# To get the names of the generated source
# use: ${PYB11_GENERATED_SOURCE}
#-----------------------------------------------------------------------------------

macro(PYB11_GENERATE_BINDINGS target_name module_name PYB11_SOURCE)
  set(PYB11_GENERATED_SOURCE "${module_name}.cc")

  # Define our arguments
  set(options )
  set(oneValueArgs )
  set(multiValueArgs DEPENDS PYTHONPATH)
  cmake_parse_arguments(${target_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("** target_name: ${target_name}")
  # message("** module_name: ${module_name}")
  # message("** PYB11_SOURCE: ${PYB11_SOURCE}")
  # message("** DEPENDS: ${${target_name}_DEPENDS}")
  # message("** PYTHONPATH: ${${target_name}_PYTHONPATH}")

  # Places we need in the Python path
  set(PYTHON_ENV "${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}:${PYB11GENERATOR_ROOT_DIR}:${${target_name}_PYTHONPATH}")
  if (DEFINED ENV{PYTHONPATH})
    set(PYTHON_ENV "${PYTHON_ENV}:$ENV{PYTHONPATH}")
  endif()

  # Extract the name of PYB11 generating source code without the .py extension
  string(REGEX REPLACE "\\.[^.]*$" "" pyb11_module ${PYB11_SOURCE})

  # Always generate cpp files at build time. Any change in the cpp file
  # will trigger a rebuild of the target pyb11 module
  add_custom_target(
    ${module_name}_src ALL
    COMMAND env PYTHONPATH=\"${PYTHON_ENV}\"
    ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/generate_cpp.py
    ${pyb11_module}
    ${module_name}
    BYPRODUCTS ${PYB11_GENERATED_SOURCE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

endmacro()
