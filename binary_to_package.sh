#!/bin/bash


if [ $# -lt 3 ]; then
	echo "Usage: ${0} package_name binary_directories target_dir";
	exit;
fi;

TDIR=${3}
_pkg_name=${1}
__my_dir="$(dirname "$0")"
_source_dir=`readlink -f ${2}`

if [ ! -e "${_source_dir}" ]; then
	exit;
fi;

#create a wokring copy... 
_tmp=`mktemp -d`;

cp -prf ${_source_dir}/* ${_tmp}/

_orig_source=${_source_dir}
_source_dir=${_tmp}

FTD="${TDIR}/${_pkg_name}"
#binary package
BINDIR="${FTD}"
#lib package
LIBDIR="${FTD}_lib"
#dev package
DEVDIR="${FTD}_dev"
#docs package
DOCDIR="${FTD}_doc"




[ -e ${DOCDIR} ] && { rm -r ${DOCDIR}; mkdir ${DOCDIR}; } || mkdir ${DOCDIR}
[ -e ${BINDIR} ] && { rm -r ${BINDIR}; mkdir ${BINDIR}; } || mkdir ${BINDIR}
[ -e ${LIBDIR} ] && { rm -r ${LIBDIR}; mkdir ${LIBDIR}; } || mkdir ${LIBDIR}
[ -e ${DEVDIR} ] && { rm -r ${DEVDIR}; mkdir ${DEVDIR}; } || mkdir ${DEVDIR}





list=`find ${_source_dir} -type d -print | sort`


for path in ${list}; do
	name=$(basename "${path}")
	parentdir="$(dirname "$path")"
	shortname=`echo "${path}" | sed "s#${_source_dir}##g"`


if [ "${parent}" == "." ] || [ "${shortname}" == "" ]; then
	continue
fi;

if [ -d "${path}" ]; then

	[ ! -e ${BINDIR}${shortname} ] && mkdir "${BINDIR}${shortname}"; chmod --reference=${path} ${BINDIR}${shortname}
	[ ! -e ${DEVDIR}${shortname} ] && mkdir "${DEVDIR}${shortname}"; chmod --reference=${path} ${DEVDIR}${shortname}
	[ ! -e ${DOCDIR}${shortname} ] && mkdir "${DOCDIR}${shortname}"; chmod --reference=${path} ${DOCDIR}${shortname}
	[ ! -e ${LIBDIR}${shortname} ] && mkdir "${LIBDIR}${shortname}"; chmod --reference=${path} ${LIBDIR}${shortname}


	if [ "${shortname}" == "/usr/include" ]; then
		mv ${path}/* ${DEVDIR}${shortname}/
		rmdir ${path}
	fi;

	if [ "${shortname}" == "/usr/share/man" ] || [ "${shortname}" == "/usr/share/doc" ]; then
		 mv ${path}/* ${DOCDIR}${shortname}/
		 rmdir ${path}
	fi;

	if [ "${shortname}" == "/lib" ] || [ "${shortname}" == "/usr/lib" ]; then
		mv ${path}/* ${LIBDIR}${shortname}/
		rmdir ${path}
	fi;

	if [ "${shortname}" == "/usr/bin" ] || [ "${shortname}" == "/bin" ]; then
		mv ${path}/* ${BINDIR}${shortname}/
		rmdir ${path}
	fi;

	if [ "${shortname}" == "/usr/sbin" ] || [ "${shortname}" == "/sbin" ]; then
                mv ${path}/* ${BINDIR}${shortname}/
		rmdir ${path}
        fi;

	if [[ ${shortname} == */etc* ]]; then
		mv ${path}/* ${BINDIR}${shortname}/
		rmdir ${path}
	fi;

	if [[ "${shortname}" == *libexec* ]]; then
		mv ${path}/* ${BINDIR}${shortname}/ &>/dev/null
		rmdir ${path} &>/dev/null
	fi;



fi;

done;


list=`find ${_source_dir} -type d -print | sort -r`

for path in ${list}; do
        name=$(basename "${path}")
        parentdir="$(dirname "$path")"
        shortname=`echo "${path}" | sed "s#${_source_dir}##g"`
	if [ -d ${path} ]; then 
 		mv ${path}/* ${BINDIR}${shortname}/ &>/dev/null
		rmdir ${path}
	fi;
done;

rmdir ${_source_dir} &>/dev/null

find ${BINDIR} -type d -empty -delete
find ${LIBDIR} -type d -empty -delete
find ${DEVDIR} -type d -empty -delete
find ${DOCDIR} -type d -empty -delete

rmdir ${DOCDIR} &>/dev/null
rmdir ${LIBDIR} &>/dev/null
rmdir ${BINDIR} &>/dev/null
rmdir ${DEVDIR} &>/dev/null

if [ -e "${DEVDIR}" ]; then
	echo ${DEVDIR}
fi;

if [ -e "${BINDIR}" ]; then
	echo ${BINDIR}
fi;

if [ -e "${LIBDIR}" ]; then
	echo ${LIBDIR}
fi;

if [ -e "${DOCDIR}" ]; then
	echo ${DOCDIR}
fi;



