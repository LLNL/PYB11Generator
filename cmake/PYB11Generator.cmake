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
#   PYB11Generator_add_module(<package_name>
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
#           default: <package_name>
#           Specify the name of the Python module to be imported and bound
#           Also used as the corresponding CMake target name
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
#       VIRTUAL_ENV ... (optional)
#           The name of a python virtual environment target. The target must supply
#           target properties EXECUTABLE and ACTIVATE_VENV to define the python executable
#           and the command to activate the environment respectively.
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
if (NOT TARGET pybind11_headers)
  if (DEFINED PYBIND11_ROOT_DIR)
    add_subdirectory(${PYBIND11_ROOT_DIR} ${CMAKE_CURRENT_BINARY_DIR}/external)
  else()
    add_subdirectory(${PYB11GENERATOR_ROOT_DIR}/extern/pybind11 ${CMAKE_CURRENT_BINARY_DIR}/external)
  endif()
endif()

function(PYB11Generator_add_module package_name)

  # Define our arguments
  set(options )
  set(oneValueArgs   MODULE SOURCE INSTALL USE_BLT VIRTUAL_ENV)
  set(multiValueArgs INCLUDES LINKS DEPENDS PYBIND11_OPTIONS COMPILE_OPTIONS EXTRA_SOURCE)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("-- MODULE: ${${package_name}_MODULE}")
  # message("-- SOURCE: ${${package_name}_SOURCE}")
  # message("-- INSTALL: ${${package_name}_INSTALL}")
  # message("-- INCLUDES: ${${package_name}_INCLUDES}")
  # message("-- LINKS: ${${package_name}_LINKS}")
  # message("-- DEPENDS: ${${package_name}_DEPENDS}")
  # message("-- PYBIND11_OPTIONS: ${${package_name}_PYBIND11_OPTIONS}")
  # message("-- COMPILE_OPTIONS: ${${package_name}_COMPILE_OPTIONS}")
  # message("-- USE_BLT: ${package_name}_USE_BLT")
  # message("-- EXTRA_SOURCE: ${package_name}_EXTRA_SOURCE")
  # message("-- VIRTUAL_ENV: ${${package_name}_VIRTUAL_ENV}")

  # Set our names and paths
  if (NOT DEFINED ${package_name}_MODULE)
    set(${package_name}_MODULE ${package_name})
  endif()
  if (NOT DEFINED ${package_name}_SOURCE)
    set(${package_name}_SOURCE "${${package_name}_MODULE}_PYB11.py")
  endif()
  # message("-- ${package_name}_MODULE: ${${package_name}_MODULE}")
  # message("-- ${package_name}_SOURCE: ${${package_name}_SOURCE}")
  
  # Generate the pybind11 C++ source file
  PYB11_GENERATE_BINDINGS(${package_name} ${${package_name}_MODULE} ${${package_name}_SOURCE}
                          DEPENDS ${${package_name}_DEPENDS}
                          VIRTUAL_ENV ${${package_name}_VIRTUAL_ENV})

  if (${${package_name}_USE_BLT}) 
    # Build using BLT macros -- assumes you've already included BLT CMake rules
    blt_add_library(NAME         ${${package_name}_MODULE}
                    SOURCES      ${${package_name}_MODULE}.cc ${${package_name}_SOURCE} ${${package_name}_EXTRA_SOURCE}
                    DEPENDS_ON   ${${package_name}_DEPENDS}
                    INCLUDES     ${${package_name}_INCLUDES}
                    OUTPUT_NAME  ${${package_name}_MODULE}
                    CLEAR_PREFIX TRUE
                    SHARED       TRUE)
  else()
    # Build using the normal pybind11 rules
    include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${${package_name}_INCLUDES})
    pybind11_add_module(${package_name} ${${package_name}_PYBIND11_OPTIONS} ${${package_name}_MODULE}.cc ${${package_name}_EXTRA_SOURCE})
    set_target_properties(${${package_name}_MODULE} PROPERTIES SUFFIX ".so" LIBRARY_OUTPUT_NAME ${${package_name}_MODULE})
    target_link_libraries(${${package_name}_MODULE} PRIVATE ${${package_name}_LINKS})
  endif()    

  add_dependencies(${${package_name}_MODULE} ${${package_name}_MODULE}_src)
  target_compile_options(${${package_name}_MODULE} PRIVATE ${${package_name}_COMPILE_OPTIONS})

  # Installation
  if (NOT ${${package_name}_INSTALL} STREQUAL "OFF")
    if ("${${package_name}_INSTALL} " STREQUAL " ")
      set(${package_name}_INSTALL ${Python3_SITEARCH}/${package_name})
    endif()
    install(TARGETS ${${package_name}_MODULE} DESTINATION ${${package_name}_INSTALL})
  endif()

endfunction()

#-----------------------------------------------------------------------------------
# PYB11_GENERATE_BINDINGS
#     - Generates the Python bindings for each module in the list
#     - Generates python stamp files for listing python dependency file to help
#       detecting changes in the pyb11 python files at build time
#
# Usage:
#   PYB11_GENERATE_BINDINGS(<package_name> <module_name> <PYB11_SOURCE>
#                           DEPENDS    ...
#                           PYTHONPATH ...)
#   where the arguments are:
#       <package_name> (required)
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

macro(PYB11_GENERATE_BINDINGS package_name module_name PYB11_SOURCE)
  set(PYB11_GENERATED_SOURCE "${module_name}.cc")

  # Define our arguments
  set(options )
  set(oneValueArgs VIRTUAL_ENV)
  set(multiValueArgs DEPENDS PYTHONPATH)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("** package_name: ${package_name}")
  # message("** module_name: ${module_name}")
  # message("** PYB11_SOURCE: ${PYB11_SOURCE}")
  # message("** DEPENDS: ${${package_name}_DEPENDS}")
  # message("** PYTHONPATH: ${${package_name}_PYTHONPATH}")

  # Places we need in the Python path
  set(PYTHON_ENV "${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}:${PYB11GENERATOR_ROOT_DIR}:${${package_name}_PYTHONPATH}")
  if (DEFINED ENV{PYTHONPATH})
    set(PYTHON_ENV "${PYTHON_ENV}:$ENV{PYTHONPATH}")
  endif()

  # Extract the name of PYB11 generating source code without the .py extension
  string(REGEX REPLACE "\\.[^.]*$" "" pyb11_module ${PYB11_SOURCE})

  set(PYTHON_EXE_BAK ${PYTHON_EXE})

  if (DEFINED ${package_name}_VIRTUAL_ENV)
    get_target_property(ACTIVATE_VENV_CMD ${${package_name}_VIRTUAL_ENV} ACTIVATE_VENV)
    list(APPEND ACTIVATE_VENV_CMD &&)
    get_target_property(PYTHON_EXE ${${package_name}_VIRTUAL_ENV} EXECUTABLE)
  endif()

  # Always generate cpp files at build time. Any change in the cpp file
  # will trigger a rebuild of the target pyb11 module
  add_custom_target(
    ${module_name}_src ALL
    COMMAND ${ACTIVATE_VENV_CMD} env PYTHONPATH="${PYTHON_ENV}" ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/generate_cpp.py ${pyb11_module} ${module_name}
    BYPRODUCTS ${PYB11_GENERATED_SOURCE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${${package_name}_VIRTUAL_ENV}
    )

  set(PYTHON_EXE ${PYTHON_EXE_BAK})

endmacro()
