include(${CMAKE_MODULE_PATH}/add_sphinx_target.cmake)

if(NOT DEFINED SPHINX_THEME)
  set(SPHINX_THEME sphinx_rtd_theme)
endif()

if(NOT DEFINED SPHINX_THEME_DIR)
  set(SPHINX_THEME_DIR)
endif()

add_sphinx_target(docs)

# # configured documentation tools and intermediate build results
# set(BINARY_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/_build")

# # Sphinx cache with pickled ReST documents
# set(SPHINX_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_doctrees")

# # HTML output directory
# set(SPHINX_HTML_DIR "${CMAKE_CURRENT_BINARY_DIR}/html")

# add_custom_target(docs ALL
#   ${PYTHON_EXE} ${SPHINX_EXECUTABLE}
#   -q -b html
#   -c "${BINARY_BUILD_DIR}"
#   -d "${SPHINX_CACHE_DIR}"
#   "${CMAKE_CURRENT_SOURCE_DIR}"
#   "${SPHINX_HTML_DIR}"
#   DEPENDS ${DOC_DEPENDS}
#   COMMENT "Building HTML documentation with Sphinx")
