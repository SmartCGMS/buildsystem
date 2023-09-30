#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "Not enough parameters, usage:"
        echo "  $0 <branch> <username> <password>"
        exit 1
fi

BRANCH=$1
USERNAME=$2
PASSWORD=$3

rm -rf {{LOCAL_COMMON}} {{LOCAL_CORE}} {{LOCAL_CONSOLE}} {{LOCAL_DESKTOP}}

AUTH_STR=
if [ ! -z $USERNAME ]; then
	if [ ! -z $PASSWORD ]; then
		AUTH_STR=$USERNAME:$PASSWORD
	else
		AUTH_STR=$USERNAME
	fi
fi

git clone {{REPO_URL_SCHEME}}${AUTH_STR}@{{REPO_URL_BASE}}{{REPO_COMMON}} -b ${BRANCH} {{LOCAL_COMMON}}
git clone {{REPO_URL_SCHEME}}${AUTH_STR}@{{REPO_URL_BASE}}{{REPO_CORE}} -b ${BRANCH} {{LOCAL_CORE}}
git clone {{REPO_URL_SCHEME}}${AUTH_STR}@{{REPO_URL_BASE}}{{REPO_CONSOLE}} -b ${BRANCH} {{LOCAL_CONSOLE}}
git clone {{REPO_URL_SCHEME}}${AUTH_STR}@{{REPO_URL_BASE}}{{REPO_DESKTOP}} -b ${BRANCH} {{LOCAL_DESKTOP}}

./rebuild.sh
