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

dictionaries_version=1
build=${AUTOBUILD_BUILD_ID:=0}
echo "${dictionaries_version}.${build}" > "${STAGING_DIR}/VERSION.txt"

DICT_DIR="${STAGING_DIR}/dictionaries"
test -d ${DICT_DIR} || mkdir ${DICT_DIR}

## For each dictionary:
##   1) Put the package itself in the DICT_DIR 
##      with the name <lang>_<variant>.<suffix> 
##      where <suffix> is .oxt, .zip, or .dic
##   2) Extract the license for the dictionary 
##      into LICENSE_DIR with the name
##      <lang>_<variant>-dictionary-license.txt

# Dictionary meta-data
cp -v "${SRC_DIR}/dictionaries.xml" "${DICT_DIR}/"

# Second Life
cp -v "${SRC_DIR}/sl.dic" "${DICT_DIR}/sl.dic"

# American English
mkdir en_US
unzip -j -aa -d en_US        "${SRC_DIR}/en_US.oxt" 
cp -v en_US/en_US.dic        "${DICT_DIR}/en_us.dic"
cp -v en_US/en_US.aff        "${DICT_DIR}/en_us.aff"
cp -v en_US/README_en_US.txt "${LICENSE_DIR}/en_us-dictionary-license.txt"

# British English
mkdir en_UK
unzip -j -aa -d en_UK        "${SRC_DIR}/en-GB.zip"
cp -v en_UK/en-GB.dic        "${DICT_DIR}/en_gb.dic"
cp -v en_UK/en-GB.aff        "${DICT_DIR}/en_gb.aff"
cp -v en_UK/README_en_GB.txt "${LICENSE_DIR}/en_gb-dictionary-license.txt"

# Spanish Spanish
mkdir es_ES
unzip -j -aa -d es_ES  "${SRC_DIR}/es_ES.oxt" 
cp -v es_ES/es_ES.dic  "${DICT_DIR}/es_es.dic"
cp -v es_ES/es_ES.aff  "${DICT_DIR}/es_es.aff"
cp -v es_ES/README.txt "${LICENSE_DIR}/es_es-dictionary-license.txt"

# Brazillian Portugese
mkdir pt_BR
unzip -j -aa -d pt_BR     "${SRC_DIR}/Vero_pt_BR_V208AOC.oxt"
cp -v pt_BR/pt_BR.dic     "${DICT_DIR}/pt_br.dic"
cp -v pt_BR/pt_BR.aff     "${DICT_DIR}/pt_br.aff"
cp -v pt_BR/README_en.TXT "${LICENSE_DIR}/pt_br-dictionary-license.txt"

pass

