set(chai_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral-spack-tpls/spack/opt/spack/__spack_path_placeholder__/__spack_path_placeholder/linux-rhel7-ppc64le/gcc-8.3.1/chai-2022.03.0-if33a7qge6lecy2om7mvtja2fkzbvway")
set(umpire_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral-spack-tpls/spack/opt/spack/__spack_path_placeholder__/__spack_path_placeholder/linux-rhel7-ppc64le/gcc-8.3.1/umpire-2022.03.0-ohbhodhj7k5nnxl5up7qnojcdrnbskgh")
set(raja_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral-spack-tpls/spack/opt/spack/__spack_path_placeholder__/__spack_path_placeholder/linux-rhel7-ppc64le/gcc-8.3.1/raja-2022.10.4-bnec6qgj7baxyivofosz5jmaagqp3qvc")
set(camp_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral-spack-tpls/spack/opt/spack/__spack_path_placeholder__/__spack_path_placeholder/linux-rhel7-ppc64le/gcc-8.3.1/camp-2022.10.0-k5lkomxt5a6ei4pk67dwfe47q7t64byr")
set(lvarray_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral-spack-tpls/spack/opt/spack/__spack_path_placeholder__/__spack_path_placeholder/linux-rhel7-ppc64le/gcc-8.3.1/lvarray-develop-qphvahymkzsf6ytbykz3hbnwggibyaja")
set(spharray_DIR "/usr/WS2/davis291/LLNLSPHERAL/LLNLSpheral/spheral/src/Field/")

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
