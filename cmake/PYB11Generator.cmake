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
# Other important CMake variables:
#   PYB11GENERATOR_ROOT_DIR : (required)
#       - Top-level director for PYB11Generator installation
#   PYBDIND11_ROOT_DIR : (optional)
#       - Location of the pybind11 install
#       - defaults to ${PYB11GENERATOR_ROOT_DIR}/extern/pybind11
#   PYTHON_EXE : (optional)
#       - Python executable
#       - if not set, we use CMake's find_package to search for Python3
#   <package_name>_ADDITIONAL_INCLUDES : (optional)
#       - List of addition includes needed
#   <package_name>_ADDITIONAL_LINKS : (optional)
#       - List of addition linking libraries, targets, or flags needed
#   <package_name>_DEPENDS : (optional)
#       - List of targets the library depends on
#   <package_name>_INSTALL_PATH : (optional)
#       - Path to install extension module 
#       - defaults to ${Python3_SITEARCH}/${package_name}
#
# This is the function users should call directly.  The macro PYB11_GENERATE_BINDINGS
# defined next is primarily for internal use.
#
# Based on Mike Davis' original Cmake scripts for handling PYB11Generator extensions
# in Spheral.  Also uses the pybind11 add_pybind11_module function for most of the
# compilation work.
#-----------------------------------------------------------------------------------

# Need Python components and pybind11
if (NOT PYTHON_EXE)
  find_package(Python3 COMPONENTS Interpreter Development)
  set(PYTHON_EXE ${Python3_EXECUTABLE})
endif()
if (PYBIND11_ROOT_DIR)
  add_subdirectory(${PYBIND11_ROOT_DIR})
else()
  add_subdirectory(${PYB11GENERATOR_ROOT_DIR}/extern/pybind11)
endif()

function(PYB11Generator_add_module package_name)

  # Generate the pybind11 C++ source file
  PYB11_GENERATE_BINDINGS(${package_name})

  # Now the normal pybind11 build can proceed
  include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${${package_name}_ADDITIONAL_INCLUDES})
  pybind11_add_module(${package_name} ${package_name}.cc)
  set_target_properties(${package_name} PROPERTIES SUFFIX ".so")
  target_link_libraries(${package_name} ${${package_name}_ADDITIONAL_LINKS})

  # Installation
  if (NOT ${package_name}_INSTALL_PATH)
    set(${package_name}_INSTALL_PATH ${Python3_SITEARCH}/${package_name})
  endif()
  install(TARGETS ${package_name} DESTINATION ${${package_name}_INSTALL_PATH})

endfunction()

#-----------------------------------------------------------------------------------
# PYB11_GENERATE_BINDINGS
#     - Generates the Python bindings for each module in the list
#     - Generates python stamp files for listing python dependency file to help
#       detecting changes in the pyb11 python files at build time
#
# Variables that must be set before calling PYB11_GENERATE_BINDINGS:
#   
#   PYB11_MODULE_NAME
#     - Pyb11 module to be generated
#   <PYB11_MODULE_NAME>_DEPENDS
#     - Any target dependencies that must be built before generating the module
#
# To get the names of the generated source
# use: ${PYB11_GENERATED_SOURCE}
#-----------------------------------------------------------------------------------

macro(PYB11_GENERATE_BINDINGS PYB11_MODULE_NAME)
  set(PYB11_SOURCE "${PYB11_MODULE_NAME}_PYB11.py")
  set(PYB11_GENERATED_SOURCE "${PYB11_MODULE_NAME}.cc")

  # Place we need in the Python path
  set(PYTHON_ENV 
      ${PYB11GENERATOR_ROOT_DIR}
      ${EXTRA_PYB11_ENV_VARS})

  # Format list into a one line shell friendly format
  STRING(REPLACE ";" "<->" PYTHON_ENV_STR ${PYTHON_ENV})
  string(APPEND PYTHON_ENV_STR ":${CMAKE_CURRENT_SOURCE_DIR}")

  # Generating python stamp files to detect changes in PYB11_SOURCE and
  # its included modules
  if(EXISTS ${PYTHON_EXE})
    # Python must exist to generate at config time
    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${PYB11_MODULE_NAME}_stamp.cmake")
      # Generate stamp files at config time
      execute_process(COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                      ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/moduleCheck.py 
                      ${PYB11_MODULE_NAME}
                      ${CMAKE_CURRENT_SOURCE_DIR}/${PYB11_SOURCE}
                      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                      )
    endif()

    # Include list of dependent python files
    include(${CMAKE_CURRENT_BINARY_DIR}/${PYB11_MODULE_NAME}_stamp.cmake)
  endif()

  # Always regenerate the stamp files at build time. Any change in the stamp file
  # will trigger a rebuild of the target pyb11 module
  add_custom_target(${PYB11_MODULE_NAME}_stamp ALL
                    COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                    ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/moduleCheck.py
                    ${PYB11_MODULE_NAME}
                    ${CMAKE_CURRENT_SOURCE_DIR}/${PYB11_SOURCE}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    )

  # Generate the actual pyb11 module cpp source file
  add_custom_command(OUTPUT ${PYB11_GENERATED_SOURCE}
                     COMMAND env PYTHONPATH=\"${PYTHON_ENV_STR}\"
                     ${PYTHON_EXE} -c
                     'from PYB11Generator import * \; 
                     import ${PYB11_MODULE_NAME}_PYB11 \;
                     PYB11generateModule(${PYB11_MODULE_NAME}_PYB11, \"${PYB11_MODULE_NAME}\") '
                     DEPENDS ${PYB11_MODULE_NAME}_stamp ${${PYB11_MODULE_NAME}_DEPENDS} ${PYB11_SOURCE}
                     )

endmacro()
