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
#                             MULTIPLE_FILES   ON/OFF
#                             GENERATED_FILES  ...
#                             USE_BLT          ON/OFF
#                             PYTHONPATH       ...
#                             ALLOW_SKIPS      ON/OFF)
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
#       MULTIPLE_FILES  ON/OFF (optional, default OFF)
#           Breakup the output pybind11 code across different source files to allow parallel
#           compilation
#       GENERATED_FILES ... (optional)
#           Name for output file containing the list of C++ pybind11 output files
#       USE_BLT ON/OFF (optional, default OFF)
#           For those using the BLT Cmake extension (https://llnl-blt.readthedocs.io/),
#           which does not play well with standard CMake add_library options.
#           Note, using this option skips using pybind11's own add_module CMake logic,
#           and therefore may make some pybind11 options no-ops.
#       PYTHONPATH ... (optional)
#           Additions needed for the environment PYTHONPATH
#       ALLOW_SKIPS  ON/OFF (optional, default OFF)
#           Developer option (and dangerous).  If ON any generated C++ pybind11 files
#           that start with the line "// PYB11skip" will not be regenerated and replaced
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
  set(oneValueArgs   MODULE SOURCE INSTALL MULTIPLE_FILES GENERATED_FILES USE_BLT ALLOW_SKIPS)
  set(multiValueArgs INCLUDES LINKS DEPENDS PYBIND11_OPTIONS COMPILE_OPTIONS EXTRA_SOURCE PYTHONPATH)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("-- package_name : ${package_name}")
  # message("-- MODULE: ${${package_name}_MODULE}")
  # message("-- SOURCE: ${${package_name}_SOURCE}")
  # message("-- INSTALL: ${${package_name}_INSTALL}")
  # message("-- INCLUDES: ${${package_name}_INCLUDES}")
  # message("-- LINKS: ${${package_name}_LINKS}")
  # message("-- DEPENDS: ${${package_name}_DEPENDS}")
  # message("-- PYBIND11_OPTIONS: ${${package_name}_PYBIND11_OPTIONS}")
  # message("-- COMPILE_OPTIONS: ${${package_name}_COMPILE_OPTIONS}")
  # message("-- MULTIPLE_FILES: ${${package_name}_MULTIPLE_FILES}")
  # message("-- GENERATED_FILES: ${${package_name}_GENERATED_FILES}")
  # message("-- USE_BLT: ${package_name}_USE_BLT")
  # message("-- EXTRA_SOURCE: ${package_name}_EXTRA_SOURCE")
  # message("-- PYTHONPATH: ${${package_name}_PYTHONPATH}")
  # message("-- ALLOW_SKIPS: ${${package_name}_ALLOW_SKIPS}")

  # Set our names and paths
  if (NOT DEFINED ${package_name}_MODULE)
    set(${package_name}_MODULE ${package_name})
  endif()
  if (NOT DEFINED ${package_name}_SOURCE)
    set(${package_name}_SOURCE "${${package_name}_MODULE}_PYB11.py")
  endif()
  if (NOT DEFINED ${package_name}_MULTIPLE_FILES)
    set(${package_name}_MULTIPLE_FILES "OFF")
  endif()
  if (NOT DEFINED ${package_name}_GENERATED_FILES)
    set(${package_name}_GENERATED_FILES "${package_name}_PYB11_generated_files")
  endif()
  if (NOT DEFINED ${package_name}_ALLOW_SKIPS)
    set(${package_name}_ALLOW_SKIPS "OFF")
  endif()
  # message("-- ${package_name}_MODULE: ${${package_name}_MODULE}")
  # message("-- ${package_name}_SOURCE: ${${package_name}_SOURCE}")
  # message("-- ${package_name}_MULTIPLE_FILES: ${${package_name}_MULTIPLE_FILES}")
  # message("-- ${package_name}_GENERATED_FILES: ${${package_name}_GENERATED_FILES}")
  # message("-- ${pacakge_name}_ALLOW_SKIPS: ${${package_name}_ALLOW_SKIPS}")
  
  # Generate the pybind11 C++ source file
  # The macro returns the list of pybind11 C++ source files in GENERATED_FILES_LIST
  PYB11_GENERATE_BINDINGS(${package_name} ${${package_name}_MODULE} ${${package_name}_SOURCE} GENERATED_FILES_LIST
                          MULTIPLE_FILES ${${package_name}_MULTIPLE_FILES} 
                          DEPENDS ${${package_name}_DEPENDS}
                          PYTHONPATH ${${package_name}_PYTHONPATH}
                          ALLOW_SKIPS ${${package_name}_ALLOW_SKIPS})

  # The library build rule
  if (${${package_name}_USE_BLT}) 
    # Build using BLT macros -- assumes you've already included BLT CMake rules
    blt_add_library(NAME         ${${package_name}_MODULE}
                    SOURCES      ${GENERATED_FILES_LIST} ${${package_name}_EXTRA_SOURCE}
                    DEPENDS_ON   ${${package_name}_DEPENDS} ${${package_name}_FILE_DEPENDS}
                    INCLUDES     ${${package_name}_INCLUDES} ${CMAKE_CURRENT_BINARY_DIR}/current_${${package_name}_MODULE}
                    OUTPUT_NAME  ${${package_name}_MODULE}
                    CLEAR_PREFIX TRUE
                    SHARED       TRUE)
    target_link_libraries(${${package_name}_MODULE} PRIVATE pybind11::module pybind11::lto pybind11::windows_extras)
    #pybind11_extension(${${package_name}_MODULE})
    if(NOT MSVC AND NOT ${CMAKE_BUILD_TYPE} MATCHES Debug|RelWithDebInfo)
      # Strip unnecessary sections of the binary on Linux/macOS
      pybind11_strip(${${package_name}_MODULE})
    endif()
    set_target_properties(${${package_name}_MODULE} PROPERTIES CXX_VISIBILITY_PRESET "hidden"
                                                    CUDA_VISIBILITY_PRESET "hidden")

  else()
    # Build using the normal pybind11 rules
    include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${${package_name}_INCLUDES} ${CMAKE_CURRENT_BINARY_DIR}/current_${${package_name}_MODULE})
    pybind11_add_module(${${package_name}_MODULE} ${${package_name}_PYBIND11_OPTIONS} ${GENERATED_FILES_LIST} ${${package_name}_EXTRA_SOURCE})
    if (${package_name}_DEPENDS OR ${package_name}_FILE_DEPENDS)
      add_dependencies(${${package_name}_MODULE} ${${package_name}_DEPENDS} ${${package_name}_FILE_DEPENDS})
    endif()
    set_target_properties(${${package_name}_MODULE} PROPERTIES SUFFIX ".so" LIBRARY_OUTPUT_NAME ${${package_name}_MODULE})
    target_link_libraries(${${package_name}_MODULE} PRIVATE ${${package_name}_LINKS})

  endif()    

  target_compile_options(${${package_name}_MODULE} PRIVATE ${${package_name}_COMPILE_OPTIONS})

  # Installation
  if (NOT ${${package_name}_INSTALL} STREQUAL "OFF")
    if ("${${package_name}_INSTALL} " STREQUAL " ")
      set(${package_name}_INSTALL ${Python3_SITEARCH}/${package_name})
    endif()
    install(TARGETS ${${package_name}_MODULE} DESTINATION ${${package_name}_INSTALL})
  endif()

  if (${package_name}_MULTIPLE_FILES)
    # We need to regenerate at configuration time for multiple file output
    # Read the generated CMake dependencies for PYB11 imported files (sets ${package_name}_FILE_DEPENDS)
    include(${CMAKE_CURRENT_BINARY_DIR}/${${package_name}_MODULE}_stamp.cmake)
    foreach(item IN LISTS ${${package_name}_MODULE}_FILE_DEPENDS)
      set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${item})
    endforeach()

  else()
    # For monolithic pybind11 output we add a source dependency on the PYB11 Python file
    #add_dependencies(${${package_name}_MODULE} ${${package_name}_MODULE}_src)
    set_property(SOURCE ${GENERATED_FILES_LIST} APPEND PROPERTY OBJECT_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${${package_name}_SOURCE})

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
#                           MULTIPLE_FILES ON/OFF
#                           GENERATED_FILES ...
#                           DEPENDS    ...
#                           PYTHONPATH ...
#                           ALLOW_SKIPS    ON/OFF)
#   where the arguments are:
#       <package_name> (required)
#           The CMake target name
#       <module_name> (required)
#           The base name for the Python module
#       <PYB11_SOURCE> (required)
#           Source file containing the PYB11Generator bindings description
#       MULTIPLE_FILES  ON/OFF (optional, default OFF)
#           Breakup the output pybind11 code across different source files to allow parallel
#           compilation
#       GENERATED_FILES ... (optional)
#           Name for output file containing the list of C++ pybind11 output files
#       DEPENDS ... (optional)
#           Any CMake targets this package should depend on being built first
#       PYTHONPATH ... (optional)
#           Additions needed for the environment PYTHONPATH
#       ALLOW_SKIPS  ON/OFF (optional, default OFF)
#           Developer option (and dangerous).  If ON any generated C++ pybind11 files
#           that start with the line "// PYB11skip" will not be regenerated and replaced
#
# To get the names of the generated source
# use: ${PYB11_GENERATED_SOURCE}
#-----------------------------------------------------------------------------------

macro(PYB11_GENERATE_BINDINGS package_name module_name PYB11_SOURCE GENERATED_FILES_LIST)
  set(PYB11_GENERATED_SOURCE "${module_name}.cc")

  # Define our arguments
  set(options )
  set(oneValueArgs MULTIPLE_FILES GENERATED_FILES ALLOW_SKIPS)
  set(multiValueArgs DEPENDS PYTHONPATH)
  cmake_parse_arguments(${package_name} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # message("** package_name: ${package_name}")
  # message("** module_name: ${module_name}")
  # message("** PYB11_SOURCE: ${PYB11_SOURCE}")
  # message("** DEPENDS: ${${package_name}_DEPENDS}")
  # message("** PYTHONPATH: ${${package_name}_PYTHONPATH}")
  # message("** MULTIPLE_FILES: ${${package_name}_MULTIPLE_FILES}")
  # message("** ALLOW_SKIPS: ${${package_name}_ALLOW_SKIPS}")

  # Multiple file output options
  if(NOT DEFINED ${package_name}_MULTIPLE_FILES)
    set(${package_name}_MULTIPLE_FILES OFF)
  endif()
  if(${${package_name}_MULTIPLE_FILES})
    set(${package_name}_MULTIPLE_FILES "True")
  else()
    set(${package_name}_MULTIPLE_FILES "False")
  endif()
  if (NOT DEFINED ${package_name}_GENERATED_FILES)
    set(${package_name}_GENERATED_FILES "${package_name}_PYB11_generated_files")
  endif()
  if(${${package_name}_ALLOW_SKIPS})
    set(${package_name}_ALLOW_SKIPS "True")
  else()
    set(${package_name}_ALLOW_SKIPS "False")
  endif()

  # Places we need in the Python path
  set(PYTHON_ENV ".:${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_SOURCE_DIR}:${PYB11GENERATOR_ROOT_DIR}:${${package_name}_PYTHONPATH}")
  if (DEFINED ENV{PYTHONPATH})
    set(PYTHONPATH_BAK "$ENV{PYTHONPATH}")
    string(CONCAT PYTHON_ENV ${PYTHON_ENV} ":" ${PYTHONPATH_BAK})
  endif()

  # Extract the name of PYB11 generating source code without the .py extension
  string(REGEX REPLACE "\\.[^.]*$" "" pyb11_module ${PYB11_SOURCE})

  # Now for a big branch.  If we're generating multiple output files we need to do all
  # generation and dependency checking at configure time, since we don't have a fixed
  # set of resulting targets.  However, if we're only generating one monolithic pybind11
  # output we can instead make a custom target and do dependency rebuild checking at
  # compile time.
  if (${package_name}_MULTIPLE_FILES)
    message("-- Generating PYB11 code for ${package_name}")

    # Generate the pybind11 C++ files files and the list of those files
    set(ENV{PYTHONPATH} "${PYTHON_ENV}")
    execute_process(
      COMMAND ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/generate_cpp.py ${pyb11_module} ${module_name} ${${package_name}_MULTIPLE_FILES} ${${package_name}_GENERATED_FILES} ${${package_name}_ALLOW_SKIPS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    # Generate the dependencies list
    if (EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${PYB11_SOURCE})
      set(FULL_PYB11_SOURCE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${PYB11_SOURCE})
    else()
      set(FULL_PYB11_SOURCE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${PYB11_SOURCE})
    endif()
    execute_process(
      COMMAND ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/moduleCheck.py ${FULL_PYB11_SOURCE_PATH} ${module_name}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    # Restore the starting environment PYTHONPATH
    if (DEFINED PYTHONPATH_BAK)
      set(ENV{PYTHONPATH} "${PYTHONPATH_BAK}")
    else()
      unset(ENV{PYTHONPATH})
    endif()

  else()

    add_custom_target(
      ${module_name}_src ALL
      COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH="${PYTHON_ENV}" ${PYTHON_EXE} ${PYB11GENERATOR_ROOT_DIR}/cmake/generate_cpp.py ${pyb11_module} ${module_name} ${${package_name}_MULTIPLE_FILES} ${${package_name}_GENERATED_FILES} ${${package_name}_ALLOW_SKIPS}
      BYPRODUCTS current_${module_name}/${PYB11_GENERATED_SOURCE}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

  endif()
    
  # Get the list of generated pybind11 C++ source files
  if (${package_name}_MULTIPLE_FILES)
    file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/${${package_name}_GENERATED_FILES}" GENERATED_FILES)
    list(TRANSFORM GENERATED_FILES PREPEND "current_${module_name}/")
  else()
    set(GENERATED_FILES "current_${module_name}/${PYB11_GENERATED_SOURCE}")
  endif()

  set(${GENERATED_FILES_LIST} "${GENERATED_FILES}")# PARENT_SCOPE)

endmacro()
