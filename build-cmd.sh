#!/bin/bash

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

STAGING_DIR="$(pwd)"
TOP_DIR="$(dirname "$0")"
SRC_DIR="${TOP_DIR}/src"

LICENSE_DIR="${STAGING_DIR}/LICENSES"
test -d ${LICENSE_DIR} || mkdir ${LICENSE_DIR}
echo "See *-dictionary-license.txt" > "${LICENSE_DIR}/dictionaries.txt"

DICT_DIR="${STAGING_DIR}/dictionaries"
test -d ${DICT_DIR} || mkdir ${DICT_DIR}

## For each dictionary:
##   1) Put the package itself in the DICT_DIR 
##      with the name <lang>_<variant>.<suffix> 
##      where <suffix> is either .oxt or .zip
##   2) Extract the license for the dictionary 
##      into LICENSE_DIR with the name
##      <lang>_<variant>-dictionary-license.txt

# American English
cp -v "${SRC_DIR}/en_US.oxt" "${DICT_DIR}/en_US.oxt"
unzip -jaa "${SRC_DIR}/en_US.oxt" README_en_US.txt
mv -v README_en_US.txt "${LICENSE_DIR}/en_US-dictionary-license.txt"

# British English
cp -v "${SRC_DIR}/en-GB.zip" "${DICT_DIR}/en_GB.zip"
unzip -jaa "${SRC_DIR}/en-GB.zip" README_en_GB.txt
mv -v README_en_GB.txt "${LICENSE_DIR}/en_GB-dictionary-license.txt"

# Spanish Spanish
cp -v "${SRC_DIR}/es_ES.oxt" "${DICT_DIR}/es_ES.oxt"
unzip -jaa "${SRC_DIR}/es_ES.oxt" README.txt
mv -v README.txt "${LICENSE_DIR}/es_ES-dictionary-license.txt"

# Brazillian Portugese
cp -v "${SRC_DIR}/Vero_pt_BR_V208AOC.oxt" "${DICT_DIR}/pt_BR.oxt"
unzip -jaa "${SRC_DIR}/Vero_pt_BR_V208AOC.oxt" README_en.TXT
mv -v README_en.TXT "${LICENSE_DIR}/pt_BR-dictionary-license.txt"

pass

