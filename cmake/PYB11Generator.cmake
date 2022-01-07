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
#   PYBDIND11_ROOT_DIR : (optional)
#       - Location of the pybind11 install
#       - defaults to ${PYB11GENERATOR_ROOT_DIR}/extern/pybind11
#   PYTHON_EXE : (optional)
#       - Python executable
#       - if not set, we use CMake's find_package to search for Python3
#
# Usage:
#   PYB11Generator_add_module(<package_name>
#                             SOURCE           ...
#                             INSTALL          ...
#                             INCLUDES         ...
#                             LINKS            ...
#                             DEPENDS          ...
#                             PYBIND11_OPTIONS ...)
#   where arguments are:
#       <package_name> (required)
#           The base name of the Python module being generated.  Results in a module
#           which can be imported in Python as "import <package_name>".
#       SOURCE ... (optional)
#           default: <package_name>_PYB11.py
#           Specify the name of the Python file holding the PYB11Generator description
#           of the bindings.
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
  add_subdirectory(${PYBIND11_ROOT_DIR})
else()
  add_subdirectory(${PYB11GENERATOR_ROOT_DIR}/extern/pybind11)
endif()

function(PYB11Generator_add_module package_name)

  # Define our arguments
  set(options )
  set(oneValueArgs   SOURCE INSTALL)
  set(multiValueArgs INCLUDES LINKS DEPENDS PYBIND11_OPTIONS)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("-- SOURCE: ${${package_name}_SOURCE}")
  # message("-- INSTALL: ${${package_name}_INSTALL}")
  # message("-- INCLUDES: ${${package_name}_INCLUDES}")
  # message("-- LINKS: ${${package_name}_LINKS}")
  # message("-- DEPENDS: ${${package_name}_DEPENDS}")
  # message("-- PYBIND11_OPTIONS: ${${package_name}_PYBIND11_OPTIONS}")

  # Generate the pybind11 C++ source file
  if ("${${package_name}_SOURCE} " STREQUAL " ")
    set(${package_name}_SOURCE "${package_name}_PYB11.py")
  endif()
  # message("-- ${package_name}_SOURCE: ${${package_name}_SOURCE}")
  PYB11_GENERATE_BINDINGS(${package_name} ${${package_name}_SOURCE}
                          DEPENDS ${${package_name}_DEPENDS})

  # Now the normal pybind11 build can proceed
  include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${${package_name}_INCLUDES})
  pybind11_add_module(${package_name} ${${package_name}_PYBIND11_OPTIONS} ${package_name}.cc)
  set_target_properties(${package_name} PROPERTIES SUFFIX ".so")
  target_link_libraries(${package_name} ${${package_name}_LINKS})

  # Installation
  if ("${${package_name}_INSTALL} " STREQUAL " ")
    set(${package_name}_INSTALL ${Python3_SITEARCH}/${package_name})
  endif()
  install(TARGETS ${package_name} DESTINATION ${${package_name}_INSTALL})

endfunction()

#-----------------------------------------------------------------------------------
# PYB11_GENERATE_BINDINGS
#     - Generates the Python bindings for each module in the list
#     - Generates python stamp files for listing python dependency file to help
#       detecting changes in the pyb11 python files at build time
#
# Usage:
#   PYB11_GENERATE_BINDINGS(<package_name> <PYB11_SOURCE>
#                           DEPENDS    ...
#                           PYTHONPATH ...)
#   where the arguments are:
#       <package_name> (required)
#           The base name for the Python module.
#       <PYB11_SOURCE> (required)
#           Source file containing the PYB11Generator bindings description.
#       DEPENDS ... (optional)
#           Any CMake targets this package should depend on being built first
#       PYTHONPATH ... (optional)
#           Additions needed for the environment PYTHONPATH
#
# To get the names of the generated source
# use: ${PYB11_GENERATED_SOURCE}
#-----------------------------------------------------------------------------------

macro(PYB11_GENERATE_BINDINGS package_name PYB11_SOURCE)
  set(PYB11_GENERATED_SOURCE "${package_name}.cc")

  # Define our arguments
  set(options )
  set(oneValueArgs )
  set(multiValueArgs DEPENDS PYTHONPATH)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("** package_name: ${package_name}")
  # message("** PYB11_SOURCE: ${PYB11_SOURCE}")
  # message("** DEPENDS: ${${package_name}_DEPENDS}")
  # message("** PYTHONPATH: ${${package_name}_PYTHONPATH}")

  # Place we need in the Python path
  set(PYTHON_ENV 
      ${PYB11GENERATOR_ROOT_DIR}
      ${${package_name}_PYTHONPATH})

  # Format list into a one line shell friendly format
  STRING(REPLACE ";" "<->" PYTHON_ENV_STR ${PYTHON_ENV})
  string(APPEND PYTHON_ENV_STR ":${CMAKE_CURRENT_SOURCE_DIR}")

  # Generating python stamp files to detect changes in PYB11_SOURCE and
  # its included modules
  if(EXISTS ${PYTHON_EXE})
    # Python must exist to generate at config time
    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${package_name}_stamp.cmake")
      # Generate stamp files at config time
      execute_process(COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                      ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/moduleCheck.py 
                      ${package_name}
                      ${CMAKE_CURRENT_SOURCE_DIR}/${PYB11_SOURCE}
                      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                      )
    endif()

    # Include list of dependent python files
    include(${CMAKE_CURRENT_BINARY_DIR}/${package_name}_stamp.cmake)
  endif()

  # Always regenerate the stamp files at build time. Any change in the stamp file
  # will trigger a rebuild of the target pyb11 module
  add_custom_target(${package_name}_stamp ALL
                    COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                    ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/moduleCheck.py
                    ${package_name}
                    ${CMAKE_CURRENT_SOURCE_DIR}/${PYB11_SOURCE}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    )

  # Generate the actual pyb11 module cpp source file
  add_custom_command(OUTPUT ${PYB11_GENERATED_SOURCE}
                     COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                     ${PYTHON_EXE} -c
                     'from PYB11Generator import * \; 
                     import ${package_name}_PYB11 \;
                     PYB11generateModule(${package_name}_PYB11, \"${package_name}\") '
                     DEPENDS ${package_name}_stamp ${${package_name}_DEPENDS} ${PYB11_SOURCE}
                     )

endmacro()
