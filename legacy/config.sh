#!/bin/bash

# C Compiler path
# Leave empty for default
#C_COMPILER="/usr/local/bin/gcc"

# C++ Compiler path
# Leave empty for default
#CXX_COMPILER="/usr/local/bin/g++"

# Build type
# "Release" and "Debug" are valid types
BUILD_TYPE="Release"

# Build console project?
COMPONENT_CONSOLE=1
# Build desktop project?
COMPONENT_DESKTOP=1
# Build support for .xls and .xlsx files?
COMPONENT_EXCEL_SUPPORT=1

# Repository URL scheme with :// part
REPO_URL_SCHEME="https://"
# base URL with trailing forward slash
REPO_URL_BASE="diabetes.zcu.cz:3443/"

# repository of "common" files
REPO_COMMON="common3.git"
# repository of "core" files
REPO_CORE="core3.git"
# repository of "console" files
REPO_CONSOLE="console3.git"
# repository of "desktop" files
REPO_DESKTOP="desktop3.git"
# repository of "tools"
REPO_TOOLS="Tools.git"
# repository of "examples"

# local directories to clone into
LOCAL_COMMON="common"
LOCAL_CORE="core"
LOCAL_CONSOLE="console"
LOCAL_DESKTOP="desktop"
LOCAL_TOOLS="Tools"
LOCAL_EXAMPLES="examples"

# Ask for credentials only on beginning
# For public access, this should be set to 0
# Any other value is considered "true"
ASK_CREDENTIALS_ONCE=1

# NOTE: these are considered temporary and will be replaced with proper Find* script (cmake)
# Where to find Qt5Config.cmake
QT5_DIR="/Users/martinubl/Qt/5.11.1/clang_64/lib/cmake/Qt5/"
