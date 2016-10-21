#!/usr/bin/env bash

# turn on verbose debugging output for parabuild logs.
exec 4>&1; export BASH_XTRACEFD=4; set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

if [ -z "$AUTOBUILD" ] ; then 
    exit 1
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    autobuild="$(cygpath -u $AUTOBUILD)"
else
    autobuild="$AUTOBUILD"
fi

STAGING_DIR="$(pwd)"
TOP_DIR="$(dirname "$0")"
SRC_DIR="${TOP_DIR}/src"

# load autobuild provided shell functions and variables
source_environment_tempfile="$STAGING_DIR/source_environment.sh"
"$autobuild" source_environment > "$source_environment_tempfile"
. "$source_environment_tempfile"

LICENSE_DIR="${STAGING_DIR}/LICENSES"
test -d ${LICENSE_DIR} || mkdir ${LICENSE_DIR}
echo "See *-dictionary-license.txt" > "${LICENSE_DIR}/dictionaries.txt"

dictionaries_version=1
build=${AUTOBUILD_BUILD_ID:=0}
echo "${dictionaries_version}.${build}" > "${STAGING_DIR}/VERSION.txt"

DICT_DIR="${STAGING_DIR}/dictionaries"
test -d ${DICT_DIR} || mkdir ${DICT_DIR}

# Dictionary meta-data
cp -v "${SRC_DIR}/dictionaries.xml" "${DICT_DIR}/"

# Second Life
cp -v "${SRC_DIR}/sl.dic" "${DICT_DIR}/sl.dic"

## For each dictionary:
##   1) Put the package itself in the DICT_DIR 
##      with the name <lang>_<variant>.<suffix> 
##      where <suffix> is .oxt, .zip, or .dic
##   2) Extract the license for the dictionary 
##      into LICENSE_DIR with the name
##      <lang>_<variant>-dictionary-license.txt
function extract {
    # e.g. "$SRC_DIR/en_US.oxt"
    local file="$1"
    # e.g. "en_US.oxt"
    local base="$(basename "$1")"
    # lang (e.g. "en_US") can be explicitly passed as second param,
    # but if omitted, strip off directory and extension from filename.
    # Within $file we expect to find $lang.dic and $lang.aff.
    local lang="${2:-${base%.*}}"
    # Even though region within $lang tends to be capitalized (e.g. en_US),
    # the files in $DICT_DIR should have uniform lowercase names.
    local lowlang="$(echo "$lang" | tr '[[:upper:]]' '[[:lower:]]')"
    # also, we want dest files to uniformly use underscore, not hyphen
    lowlang="${lowlang/-/_}"
    # Optionally pass name of license file; if omitted, copy whatever we find
    # that looks like README*.txt. We really expect README_$lang.txt, and in
    # most cases that's what we should find. However, en-GB.zip contains
    # en-GB.dic, en-GB.aff and README_en_GB.txt (note inconsistent
    # underscore). Finess that by copying whatever README_*.txt we find there:
    # we're going to make its name uniform anyway.
    local licfile="${3:-README*.txt}"

    # extract from zipfile into directory named for language
    mkdir -p "$lang"
    # Note: we use Python to extract files from zip - can't rely on unzip on Windows
    python -c "import zipfile; zipfile.ZipFile(r'$file').extractall(r'$lang')"
    for ext in dic aff
    do # within $lang directory, expect to find $lang.$ext
       # lowercase language name when we copy
       cp -v "$lang/$lang.$ext" "${DICT_DIR}/$lowlang.$ext"
    done
    cp -v "$lang"/$licfile "${LICENSE_DIR}/$lowlang-dictionary-license.txt"
}

# American English
extract "$SRC_DIR/en_US.oxt"

# British English
extract "$SRC_DIR/en-GB.zip"

# Spanish Spanish
extract "$SRC_DIR/es_ES.oxt"

# Brazilian Portugese
extract "$SRC_DIR/Vero_pt_BR_V208AOC.oxt" "pt_BR" "README_en.TXT"
