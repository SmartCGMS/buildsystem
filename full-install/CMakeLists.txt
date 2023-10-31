# SmartCGMS - continuous glucose monitoring and controlling framework
# https://diabetes.zcu.cz/
#
# Copyright (c) since 2018 University of West Bohemia.
#
# Contact:
# diabetes@mail.kiv.zcu.cz
# Medical Informatics, Department of Computer Science and Engineering
# Faculty of Applied Sciences, University of West Bohemia
# Univerzitni 8, 301 00 Pilsen
# Czech Republic
# 
# 
# Purpose of this software:
# This software is intended to demonstrate work of the diabetes.zcu.cz research
# group to other scientists, to complement our published papers. It is strictly
# prohibited to use this software for diagnosis or treatment of any medical condition,
# without obtaining all required approvals from respective regulatory bodies.
#
# Especially, a diabetic patient is warned that unauthorized use of this software
# may result into severe injure, including death.
#
#
# Licensing terms:
# Unless required by applicable law or agreed to in writing, software
# distributed under these license terms is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# a) This file is available under the Apache License, Version 2.0.
# b) When publishing any derivative work or results obtained using this software, you agree to cite the following paper:
#    Tomas Koutny and Martin Ubl, "SmartCGMS as a Testbed for a Blood-Glucose Level Prediction and/or 
#    Control Challenge with (an FDA-Accepted) Diabetic Patient Simulation", Procedia Computer Science,  
#    Volume 177, pp. 354-362, 2020

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

PROJECT("smartcgms")

INCLUDE(FetchContent)

SET(CMAKE_CXX_STANDARD 20)

# The script will fetch xlnt, ExcelFormat and Eigen3 if instructed to do so
SET(BUILDOPT_FETCH_ALL_DEPS TRUE CACHE BOOL "Should the script fetch all external dependencies (except Qt)?")

IF(BUILDOPT_FETCH_ALL_DEPS)
	FetchContent_Declare(
		Eigen3
		GIT_REPOSITORY https://github.com/SmartCGMS/Eigen3.git
	)
	FetchContent_MakeAvailable(Eigen3)
	SET(EIGEN3_INCLUDE "${Eigen3_SOURCE_DIR}" CACHE PATH "Eigen3 library location" FORCE)
	
	IF(COMPONENT_EXCEL_LOADERS)
		FetchContent_Declare(
			xlnt
			GIT_REPOSITORY https://github.com/SmartCGMS/xlnt.git
		)
		FetchContent_MakeAvailable(xlnt)
		SET(XLNT_INCLUDE "${xlnt_SOURCE_DIR}/include" CACHE PATH "xlnt include directory location" FORCE)
		
		FetchContent_Declare(
			ExcelFormat
			GIT_REPOSITORY https://github.com/SmartCGMS/ExcelFormat.git
		)
		FetchContent_MakeAvailable(ExcelFormat)
		SET(EXCELFORMAT_INCLUDE "${ExcelFormat_SOURCE_DIR}/include" CACHE PATH "ExcelFormat include directory location" FORCE)
	ENDIF()
ENDIF()

# this overrides the SMARTCGMS_COMMON_DIR in all sub-projects
SET(SMARTCGMS_COMMON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/common" CACHE PATH "SmartCGMS 'common' directory location" FORCE)

ADD_SUBDIRECTORY(common)
ADD_SUBDIRECTORY(console)
ADD_SUBDIRECTORY(core)
ADD_SUBDIRECTORY(desktop)
