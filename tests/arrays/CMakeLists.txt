set(chai_libs libchai.a)
set(umpire_libs libumpire.a)
set(raja_libs -L${raja_DIR}/lib -lRAJA -ldesul_atomics)
set(camp_libs libcamp.a)
set(lvarray_libs liblvarray.so)

configure_file(reproducer.py reproducer.py COPYONLY)

PYB11Generator_add_module(arrays
  INSTALL ${CMAKE_INSTALL_PREFIX}/tests/arrays
  COMPILE_OPTIONS -fopenmp 
  INCLUDES ${chai_DIR}/include ${umpire_DIR}/include ${raja_DIR}/include ${camp_DIR}/include ${lvarray_DIR}/include ${spharray_DIR} 
  LINKS ${chai_DIR}/lib/${chai_libs} ${umpire_DIR}/lib/${umpire_libs} ${raja_libs} ${camp_DIR}/lib/${camp_libs} ${lvarray_DIR}/lib/${lvarray_libs})

PYB11Generator_add_module(tensor
  INSTALL ${CMAKE_INSTALL_PREFIX}/tests/tensor
  COMPILE_OPTIONS -fopenmp 
  INCLUDES ${chai_DIR}/include ${umpire_DIR}/include ${raja_DIR}/include ${camp_DIR}/include ${lvarray_DIR}/include ${spharray_DIR} 
  LINKS ${chai_DIR}/lib/${chai_libs} ${umpire_DIR}/lib/${umpire_libs} ${raja_libs} ${camp_DIR}/lib/${camp_libs} ${lvarray_DIR}/lib/${lvarray_libs})
