#!/bin/bash

if [ ! $1 ]; then
        echo "Usage: $0 <target_directory> <compiled binaries dir>"
        exit;
fi;

PKGDIR=${1}
[ -e "${PKGDIR}" ] || mkdir -p ${PKGDIR}

CURDIR=`pwd`
for _directory_ in "$@"
do

if [ "${_directory_}" == "${PKGDIR}" ]; then
	continue;
fi;

cd ${CURDIR}

SRCDIR=`readlink -f ${_directory_}`
PKGNAME=`basename ${_directory_}`
PKGFULL=`readlink -f ${PKGDIR}/${PKGNAME}`

if [ -d ${PKGFULL} ]; then
	rm -r ${PKGFULL}
fi;

mkdir -p ${PKGDIR}/${PKGNAME}/package

cd ${PKGDIR}/${PKGNAME}
cp -pur ${SRCDIR}/* package/
cd package

if [ -e "post.install.sh" ]; then
	mv post.install.sh ../
	chmod 777 ../post.install.sh
fi;

if [ -e "pre.install.sh" ]; then
	mv pre.install.sh ../
	chmod 777 ../pre.install.sh
fi;
if [ -e "post.remove.sh" ]; then
	mv post.remove.sh ../
	chmod 777 ../post.remove.sh
fi;

if [ -e "pre.remove.sh" ]; then
	mv pre.remove.sh ../
	chmod 777 ../pre.remove.sh
fi;

find . -print >../file.list
cd ..
sed -i -e 's/\.\///g' file.list
tail -n +2 file.list > .tmp && mv .tmp file.list

cd ..
if [ -e ${PKGNAME}.tar.gz ]; then
	rm ${PKGNAME}.tar.gz
fi;
tar cf - ${PKGNAME} | gzip -9 - > ${PKGDIR}/${PKGNAME}.tar.gz
echo "${PKGDIR}/${PKGNAME}.tar.gz done"
done;
