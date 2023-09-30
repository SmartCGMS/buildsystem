#!/bin/bash

CONFIG_LOCATION="$(pwd)/config.sh"
if [ -f "config.sh" ]; then
	source $CONFIG_LOCATION
else
	echo "No config.sh file found, falling back to defaults."
fi

### Defaulting section

C_COMPILER=${C_COMPILER:-$(which gcc)}
CXX_COMPILER=${CXX_COMPILER:-$(which g++)}
BUILD_TYPE=${BUILD_TYPE:-"Release"}

COMPONENT_CONSOLE=${COMPONENT_CONSOLE:-1}
COMPONENT_DESKTOP=${COMPONENT_DESKTOP:-1}
COMPONENT_EXCEL_SUPPORT=${COMPONENT_EXCEL_SUPPORT:-1}
REPO_URL_SCHEME=${REPO_URL_SCHEME:-"https://"}
REPO_URL_BASE=${REPO_URL_BASE:-"diabetes.zcu.cz:3443/"}
REPO_COMMON=${REPO_COMMON:-"common3.git"}
REPO_CORE=${REPO_CORE:-"core3.git"}
REPO_CONSOLE=${REPO_CONSOLE:-"console3.git"}
REPO_DESKTOP=${REPO_DESKTOP:-"desktop3.git"}
REPO_TOOLS=${REPO_TOOLS:-"Tools.git"}
REPO_EXAMPLES=${REPO_EXAMPLES:-"examples3.git"}
LOCAL_COMMON=${LOCAL_COMMON:-"common"}
LOCAL_CORE=${LOCAL_CORE:-"core"}
LOCAL_CONSOLE=${LOCAL_CONSOLE:-"console"}
LOCAL_DESKTOP=${LOCAL_DESKTOP:-"desktop"}
LOCAL_TOOLS=${LOCAL_TOOLS:-"tools"}
LOCAL_EXAMPLES=${LOCAL_TOOLS:-"examples"}
ASK_CREDENTIALS_ONCE=${ASK_CREDENTIALS_ONCE:-1}
QT5_DIR=${QT5_DIR:-""}

### Main script

echo "SmartCGMS, Glucose prediction 3"
echo "Automated installer"
echo ""
echo "University of West Bohemia, Faculty of Applied Sciences"
echo "Department of Computer Science and Engineering"
echo "https://diabetes.zcu.cz"
echo ""

# helper function for probing command availability; prints result to stdout
echo_bin_status() {
	if which $1 >/dev/null; then
		echo "OK (" $(which $1) ")"
	else
		echo "NOT FOUND"
	fi
}

echo "This is an automated installer script. The following tools and libraries has to be"
echo "installed before running this script:"
echo -n "  * C++ compiler with C++17 support (gcc-8, clang-6, ..) ... "
echo_bin_status $CXX_COMPILER
echo -n "  * CMake (3.0+) ... "
echo_bin_status cmake
echo -n "  * git ... "
echo_bin_status git
echo "When a desktop/console build is requested, additional components are required:"
echo "  * Qt5 - Core and Sql components (libqt5core5a, libqt5sql5, qtbase5-dev)"
echo ""

echo "Also make sure, that your compiler is properly set up in system, either using"
echo "default installation procedure, update-alternatives or setting C_COMPILER and"
echo "CXX_COMPILER config variables."

echo ""

if [ $# -lt 1 ]; then
        echo "Not enough parameters, usage:"
        echo "  $0 <git_branch> [<parallel>]"
		echo ""
		echo "	<git_branch> - remote branch, e.g. master or release"
		echo "  <parallel> - indicates whether the installer should fork maximum possible tasks; valid values are 'parallel' without quotes"
        exit 1
fi

BRANCH=$1
PARALLEL_BUILD=""
if [ $# -gt 1 ]; then
	PARALLEL_BUILD=$2
fi

echo "Chosen build type: $BUILD_TYPE"
echo "The installer will create scgms-install directory. You may be asked for credentials to git repository."
echo -n "Proceed? [y/N]: "
read result

if [ $result != "y" ] && [ $result != "Y" ]; then
        echo "Abort."
        exit 0
fi

echo ""

if [ -z "$QT5_DIR" ] || [ ! -f "${QT5_DIR}/Qt5Config.cmake" ]; then
	if (( $COMPONENT_DESKTOP != 0 )); then
		echo "You chose to build a project, that requires Qt5 to be installed (desktop, console), but did not specify a Qt5 directory."
		echo "By not specifying the Qt5Config.cmake directory path, you rely on generic FindQt5 script to find your Qt5 installation"
		echo "in some standard path. Please, enter the directory, where to find the Qt5Config.cmake script or simply skip this step"
		echo "by leaving an empty input."
		echo ""
		echo -n "Qt5Config.cmake directory []: "
		read QT5_DIR
		
		if [ -z "$QT5_DIR" ]; then
			echo "No Qt5 directory specified"
		else
			if [ ! -f "${QT5_DIR}/Qt5Config.cmake" ]; then
				echo "No Qt5Config.cmake found in given location, the configuration may fail."
			else
				echo "Qt5Config.cmake found."
			fi
		fi
	fi
fi

echo ""

# if an old installation was found, ask for deleting it first
if [ -d "build_system" ]; then
        echo "A directory with SmartCGMS installation already found! The installer could not proceed"
        echo "without deleting the old directory prior to new installation."
        echo -n "Delete the old installation? [y/N]: "
        read result
        if [ $result != "y" ] && [ $result != "Y" ]; then
                echo "Abort."
                exit 0
        fi
		echo ""
fi

if [ "$ASK_CREDENTIALS_ONCE" -ne 0 ]; then
	echo "Please, provide credentials to access remote git repository"

	echo -n "Enter username: "
	read USERNAME
	echo -n "Enter password: "
	read -s PASSWORD
	echo ""
	
	# replace @ character for its URL-like substitution
	PASSWORD=${PASSWORD//@/%40}
else
	USERNAME=
	PASSWORD=
fi

AUTH_STR=
if [ ! -z $USERNAME ]; then
	if [ ! -z $PASSWORD ]; then
		AUTH_STR=$USERNAME:$PASSWORD
	else
		AUTH_STR=$USERNAME
	fi
fi

echo ""

# remove any previous installation
rm -rf build_system
rm -rf compiled
rm -rf examples
rm -rf common

PARALLEL_FLAG=""
if [ "$PARALLEL_BUILD" = "parallel" ]; then
	PARALLEL_FLAG="--parallel"
fi

# we will use this directory as a base for any further work
BASE=$(pwd)

# helper function for installing a remote repository library
# args: $1 - name of library (also name of directory to clone into)
#       $2 - repository URL
#       $3 - branch/tag/commit to checkout to
#       $4 - additional build option, "cmake" for cmake and make routine
install_repository() {
	ORIG_PWD=$(pwd)
	echo ">>> Installing $1"
	echo "Cloning repository..."
	git clone --quiet $2 $1
	cd $1
	git checkout --quiet $3
	if [ "$4" = "cmake" ]; then
		echo "Compiling..."
		cmake . \
			-DCMAKE_C_COMPILER="${C_COMPILER}"\
			-DCMAKE_CXX_COMPILER="${CXX_COMPILER}"\
			-DCMAKE_BUILD_TYPE="${BUILD_TYPE}"\
			-DCMAKE_C_FLAGS="-fPIC -Wno-deprecated-declarations -Wno-everything"\
			-DCMAKE_CXX_FLAGS="-fPIC -Wno-deprecated-declarations -Wno-everything" >/dev/null
		cmake --build . ${PARALLEL_FLAG} >/dev/null
	fi
	cd ${ORIG_PWD}
}

# clone examples and common independently
git clone --depth=1 ${REPO_URL_SCHEME}${AUTH_STR}@${REPO_URL_BASE}${REPO_EXAMPLES} -b ${BRANCH} ${LOCAL_EXAMPLES}
git clone --depth=1 ${REPO_URL_SCHEME}${AUTH_STR}@${REPO_URL_BASE}${REPO_COMMON} -b ${BRANCH} ${LOCAL_COMMON}

rm -rf ./${LOCAL_EXAMPLES}/.git
rm -rf ./${LOCAL_COMMON}/.git

mkdir -p compiled/filters/

# create directory for builds
mkdir build_system
cd build_system

# install (and build) dependencies
install_repository "Eigen3" "https://gitlab.com/libeigen/eigen.git" "" ""
if (( $COMPONENT_EXCEL_SUPPORT != 0 )); then
	install_repository "ExcelFormat" "https://github.com/MartinUbl/ExcelFormat.git" "HEAD" "cmake"
	install_repository "xlnt" "https://github.com/MartinUbl/xlnt.git" "HEAD" "cmake"
fi

# retrieve buildscripts
echo ">>> Creating build scripts"
echo "Cloning tools repository..."
git clone ${REPO_URL_SCHEME}${AUTH_STR}@${REPO_URL_BASE}${REPO_TOOLS} -b ${BRANCH} ${LOCAL_TOOLS}
cp -r ${LOCAL_TOOLS}/buildsystem/* .
echo "Configuring variables"

# configure build scripts to this environment
sed -i.bak "s@{{REPO_URL_SCHEME}}@${REPO_URL_SCHEME}@g" clone_and_build.sh
sed -i.bak "s@{{REPO_URL_BASE}}@${REPO_URL_BASE}@g" clone_and_build.sh
sed -i.bak "s@{{REPO_COMMON}}@${REPO_COMMON}@g" clone_and_build.sh
sed -i.bak "s@{{REPO_CORE}}@${REPO_CORE}@g" clone_and_build.sh
sed -i.bak "s@{{REPO_CONSOLE}}@${REPO_CONSOLE}@g" clone_and_build.sh
sed -i.bak "s@{{REPO_DESKTOP}}@${REPO_DESKTOP}@g" clone_and_build.sh
sed -i.bak "s@{{LOCAL_COMMON}}@${LOCAL_COMMON}@g" clone_and_build.sh
sed -i.bak "s@{{LOCAL_CORE}}@${LOCAL_CORE}@g" clone_and_build.sh
sed -i.bak "s@{{LOCAL_CONSOLE}}@${LOCAL_CONSOLE}@g" clone_and_build.sh
sed -i.bak "s@{{LOCAL_DESKTOP}}@${LOCAL_DESKTOP}@g" clone_and_build.sh

sed -i.bak "s@{{IS_PARALLEL_BUILD}}@${PARALLEL_FLAG}@g" build.sh

sed -i.bak "s@{{C_COMPILER}}@${C_COMPILER}@g" rebuild.sh
sed -i.bak "s@{{CXX_COMPILER}}@${CXX_COMPILER}@g" rebuild.sh
sed -i.bak "s@{{QT5_DIR}}@${QT5_DIR}@g" rebuild.sh
sed -i.bak "s@{{CONFIG_LOCATION}}@${CONFIG_LOCATION}@g" rebuild.sh
sed -i.bak "s@{{BUILD_TYPE}}@${BUILD_TYPE}@g" rebuild.sh
sed -i.bak "s@{{XLNT_INCLUDE}}@${BASE}/build_system/xlnt/include/@g" rebuild.sh
sed -i.bak "s@{{XLNT_LIBRARY}}@${BASE}/build_system/xlnt/source/@g" rebuild.sh
sed -i.bak "s@{{EXCELFORMAT_INCLUDE}}@${BASE}/build_system/ExcelFormat/include/@g" rebuild.sh
sed -i.bak "s@{{EXCELFORMAT_LIBRARY}}@${BASE}/build_system/ExcelFormat/@g" rebuild.sh
sed -i.bak "s@{{EIGEN3_INCLUDE}}@${BASE}/build_system/Eigen3/@g" rebuild.sh
sed -i.bak "s@{{SMARTCGMS_COMMON_DIR}}@${BASE}/${LOCAL_COMMON}/@g" rebuild.sh
if (( $COMPONENT_CONSOLE == 0 )); then
	sed -i.bak "s@{{COMPONENT_CONSOLE}}@FALSE@g" rebuild.sh
else
	sed -i.bak "s@{{COMPONENT_CONSOLE}}@TRUE@g" rebuild.sh
fi
if (( $COMPONENT_DESKTOP == 0 )); then
	sed -i.bak "s@{{COMPONENT_DESKTOP}}@FALSE@g" rebuild.sh
else
	sed -i.bak "s@{{COMPONENT_DESKTOP}}@TRUE@g" rebuild.sh
fi
if (( $COMPONENT_EXCEL_SUPPORT == 0 )); then
	sed -i.bak "s@{{COMPONENT_EXCEL_LOADERS}}@FALSE@g" rebuild.sh
else
	sed -i.bak "s@{{COMPONENT_EXCEL_LOADERS}}@TRUE@g" rebuild.sh
fi

echo "Done"

# run clone and build script, which will take care of the rest from now
echo ">>> Retrieving and configuring scgms"
chmod +x top_level_build.sh
chmod +x clone_and_build.sh
chmod +x rebuild.sh
chmod +x build.sh
mv top_level_build.sh ../build.sh
mkdir build
./clone_and_build.sh "$BRANCH" "$USERNAME" "$PASSWORD"

