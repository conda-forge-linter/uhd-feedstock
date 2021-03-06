#!/bin/bash

set -ex

cd host  # needed for builds from github tarball
mkdir build
cd build

# enable uhd components explicitly so we get build error when unsatisfied
# the following are disabled:
#   DOXYGEN/MANUAL because we don't need docs in the conda package
#   DPDK needs dpdk
#   E300 build fails on CI
#   LIBERIO needs liberio
cmake_config_args=(
    -DBOOST_ROOT=$PREFIX
    -DBoost_NO_BOOST_CMAKE=ON
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX=$ARCH
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCURSES_NEED_NCURSES=ON
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DUHD_RELEASE_MODE=release
    -DENABLE_B100=ON
    -DENABLE_B200=ON
    -DENABLE_C_API=ON
    -DENABLE_DOXYGEN=OFF
    -DENABLE_DPDK=OFF
    -DENABLE_E300=OFF
    -DENABLE_E320=ON
    -DENABLE_EXAMPLES=ON
    -DENABLE_LIBERIO=OFF
    -DENABLE_LIBUHD=ON
    -DENABLE_MAN_PAGES=ON
    -DENABLE_MANUAL=OFF
    -DENABLE_MPMD=ON
    -DENABLE_OCTOCLOCK=ON
    -DENABLE_N230=ON
    -DENABLE_N300=ON
    -DENABLE_N320=ON
    -DENABLE_PYTHON_API=ON
    -DENABLE_RFNOC=ON
    -DENABLE_TESTS=ON
    -DENABLE_UTILS=ON
    -DENABLE_USB=ON
    -DENABLE_USRP1=ON
    -DENABLE_USRP2=ON
    -DENABLE_X300=ON
)

if [[ $python_impl == "pypy" ]] ; then
    # we need to help cmake find pypy
    cmake_config_args+=(
        -DPYTHON_LIBRARY=$PREFIX/lib/libpypy3-c$SHLIB_EXT
        -DPYTHON_INCLUDE_DIR=$PREFIX/include
    )
fi

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
ctest --output-on-failure
cmake --build . --config Release --target install
