##------------------------------------------------------------------------------
## add_sphinx_target(sphinx_target_name)
##
## Creates a build target for invoking sphinx to generate docs
##
## Lifted from the BLT implementation
##------------------------------------------------------------------------------
macro(add_sphinx_target sphinx_target_name )

    # configured documentation tools and intermediate build results
    set(SPHINX_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/_build")

    # Sphinx cache with pickled ReST documents
    set(SPHINX_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_doctrees")

    # HTML output directory
    set(SPHINX_HTML_DIR "${CMAKE_CURRENT_BINARY_DIR}/html")

    # support both direct use of a conf.py file and a cmake-configured
    # sphinx input file (conf.py.in). The cmake-configured input file is
    # preferred when both exist.
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in")
        configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in"
                       "${SPHINX_BUILD_DIR}/conf.py"
                       @ONLY)

        add_custom_target(${sphinx_target_name}
                          ${SPHINX_EXECUTABLE}
                          -q -b html
                          #-W disable warn on error for now, while our sphinx env is still in flux
                          -c "${SPHINX_BUILD_DIR}"
                          -d "${SPHINX_CACHE_DIR}"
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          "${SPHINX_HTML_DIR}"
                          COMMENT "Building HTML documentation with Sphinx for ${sphinx_target_name} target"
                          DEPENDS ${deps})
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/conf.py")
        add_custom_target(${sphinx_target_name}
                          ${SPHINX_EXECUTABLE}
                          -q -b html
                          #-W disable warn on error for now, while our sphinx env is still in flux
                          -d "${SPHINX_CACHE_DIR}"
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          "${SPHINX_HTML_DIR}"
                          COMMENT "Building HTML documentation with Sphinx for ${sphinx_target_name} target"
                          DEPENDS ${deps})
    else()
        message(FATAL_ERROR "Failed to find sphinx 'conf.py' or 'conf.py.in' in ${CMAKE_CURRENT_SOURCE_DIR}")
    endif()
        
    # # hook our new target into the docs dependency chain
    # add_dependencies(sphinx_docs ${sphinx_target_name})

    ######
    # This snippet makes sure if we do a make install w/o the optional "docs"
    # target built, it will be built during the install process.
    ######

    install(CODE "execute_process(COMMAND ${CMAKE_BUILD_TOOL} ${sphinx_target_name} WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}\")")

    install(DIRECTORY "${SPHINX_HTML_DIR}" 
            DESTINATION "docs/sphinx/${sphinx_target_name}" OPTIONAL)

endmacro(add_sphinx_target)
