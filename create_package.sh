#!/bin/bash


__my_dir="$(readlink -f "$0")"
__my_dir="$(dirname $__my_dir)"

echo "${__my_dir}" > /tmp/.mydir


if [ -e "conf/defaults.cfg" ]; then
	. conf/defaults.cfg
else

echo "Please define the following variables in the 'conf/defaults.cfg': "
cat <<"EOF"
PACKAGER_MAIL=""
PACKAGER_NAME=""
REPO_URL="http://repo.fsociety.hu/gl-5.0.0/"
WORKDIR="/data/packager"
NUMCPU=
EOF
exit

fi;


if [ ! ${1} ] || [ ! ${2} ]; then
	echo "Usage: ${0} name version (acl 2.2.53)"
	exit;
fi;

name="${1}"
version="${2}"

#if workdir is missing, create it
[ -e ${WORKDIR} ] || mkdir -p ${WORKDIR}


#get recepies from git, if not exists
RECEPIES="${WORKDIR}/gl-recepies"
cd ${RECEPIES}
[ -e ${RECEPIES} ] || { git clone https://github.com/fszontagh/gl-recepies.git ${RECEPIES}; } && { git pull; }
cd $__my_dir
#create a directory for the downloaded source file
SOURCES="${WORKDIR}/downloads"
[ -e ${SOURCES} ] || mkdir ${SOURCES}

#get recepie
RECEPIE="${RECEPIES}/${name}.sh"

if [ ! -e ${RECEPIE} ]; then
	echo "Recepie not found for ${name}-${version} (${RECEPIE})";
	exit;
fi;


. ${RECEPIE}

if [ ! -e "${SOURCES}/${file_name}" ]; then
	echo "Downloading: ${url}"
	wget -q --show-progress -O ${SOURCES}/${file_name} ${url} || { echo "Can not download ${url}"; }
fi;

SOURCE_DIR="${WORKDIR}/${file_name}"

_strip=" "
if [ ! $strip -eq 0 ]; then
	_strip=" --strip-components ${strip} "
fi;


if [ ! -e "${SOURCE_DIR}" ]; then
	mkdir ${SOURCE_DIR}
	echo "extracting ${SOURCES}/${file_name}"
	tar${_strip}--directory=${SOURCE_DIR}/ -xf ${SOURCES}/${file_name} || exit;	
fi;

if [ ! -e "${SOURCE_DIR}/configured.pid" ]; then
	configure ${SOURCE_DIR}/ && touch ${SOURCE_DIR}/configured.pid
fi;

if [ ! -e "${SOURCE_DIR}/configured.pid" ]; then
	exit;
fi;

PKG="${WORKDIR}/${name}_${version}_compiled"

if [ ! -e "${WORKDIR}/${name}_${version}_compiled.pid" ]; then
	
	mkdir -p ${PKG}
	
	pre_make
	build ${PKG}
	find ${PKG} -name "*.a" -delete
	post_make ${PKG}
	touch "${WORKDIR}/${name}_${version}_compiled.pid"
	
fi;


if [ -e ${PKG} ]; then
	
	if [ ! -e "${WORKDIR}/${name}_${version}_packages/" ]; then
		mkdir -p "${WORKDIR}/${name}_${version}_packages/"
	fi;

	__my_dir=`cat /tmp/.mydir`
	cd $__my_dir	
	echo "Preparing compiled source to packaging... "
	CREATED=$($__my_dir/binary_to_package.sh "${name}_${version}_${arch}" ${PKG} "${WORKDIR}")	

	
	if [ ! -z ${libisplugin+x} ]; then 
		CREATED=$(echo "${CREATED}" | sed -e "s/_lib/_plugins/g")
		mv ${WORKDIR}/${name}_${version}_${arch}_lib ${WORKDIR}/${name}_${version}_${arch}_plugins
	fi	
	echo "Created: "
	echo ${CREATED};
	echo "Creating package..."
		
	exec $__my_dir/mkpackage.sh "${WORKDIR}/${name}_${version}_packages/" ${CREATED}	
	
	rm "${WORKDIR}/${name}_${version}_compiled.pid"
	
fi;
	




