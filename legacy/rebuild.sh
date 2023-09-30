#!/bin/bash

REBUILD_BASE=$(pwd)

rm -rf build/*
cd build

cmake ../ \
		-DCMAKE_C_COMPILER="{{C_COMPILER}}"\
		-DCMAKE_CXX_COMPILER="{{CXX_COMPILER}}"\
		-DCMAKE_CXX_FLAGS="-DNOGUI"\
		-DCMAKE_BUILD_TYPE="{{BUILD_TYPE}}"\
		-DQt5_DIR="{{QT5_DIR}}"\
		-DCOMPONENT_CONSOLE={{COMPONENT_CONSOLE}}\
		-DCOMPONENT_DESKTOP={{COMPONENT_DESKTOP}}\
		-DCOMPONENT_EXCEL_LOADERS={{COMPONENT_EXCEL_LOADERS}}\
		-DXLNT_INCLUDE={{XLNT_INCLUDE}} \
		-DXLNT_LIBRARY={{XLNT_LIBRARY}} \
		-DEXCELFORMAT_INCLUDE={{EXCELFORMAT_INCLUDE}} \
		-DEXCELFORMAT_LIBRARY={{EXCELFORMAT_LIBRARY}} \
		-DEIGEN3_INCLUDE={{EIGEN3_INCLUDE}}

cd $REBUILD_BASE

if [ -d "Tools/sentiero" ]; then
	mkdir -p Tools/sentiero/build
	cd Tools/sentiero/build
	cmake ../ \
		-DCMAKE_C_COMPILER="{{C_COMPILER}}"\
		-DCMAKE_CXX_COMPILER="{{CXX_COMPILER}}"\
		-DCMAKE_CXX_FLAGS="-DNOGUI"\
		-DCMAKE_BUILD_TYPE="{{BUILD_TYPE}}"\
		-DQt5_DIR="{{QT5_DIR}}"\
		-DSMARTCGMS_COMMON_DIR="{{SMARTCGMS_COMMON_DIR}}"
	
	cd $REBUILD_BASE
fi

./build.sh