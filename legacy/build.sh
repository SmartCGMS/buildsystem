#!/bin/bash

BUILD_BASE=$(pwd)

cd build

# this script is modified by install.sh; if you want to enable parallel build, run install.sh with "parallel" argument
cmake --build . {{IS_PARALLEL_BUILD}}

# copy compiled binaries to top level
cp -r compiled/* ../../compiled/

cd $BUILD_BASE

if [ -d "Tools/sentiero/build" ]; then
	cd Tools/sentiero/build
	
	cmake --build . {{IS_PARALLEL_BUILD}}

	# force .so extension (even on macOS), as the Python VM requires it
	if [ -f "libsentiero.so" ]; then
		cp libsentiero.so $BUILD_BASE/../compiled/libsentiero.so
	elif [ -f "libsentiero.dylib" ]; then
		cp libsentiero.dylib $BUILD_BASE/../compiled/libsentiero.so
	fi
	
	cd $BUILD_BASE
fi
