#!/bin/bash

# -*- shell-script -*-
# taken from /usr/share/initramfs-tools/hook-functions

# $1 = file to copy to ramdisk
# $2 (optional) Name for the file on the ramdisk
# Location of the image dir is assumed to be $DESTDIR
# We never overwrite the target if it exists.
copy_exec() {
	local src target x nonoptlib
	local libname dirname

	src="${1}"
	target="${2:-$1}"

	[ -f "${src}" ] || return 1

	if [ -d "${DESTDIR}/${target}" ]; then
		# check if already copied
		[ -e "${DESTDIR}/$target/${src##*/}" ] && return 0
	else
		[ -e "${DESTDIR}/$target" ] && return 0
		#FIXME: inst_dir
		mkdir -p "${DESTDIR}/${target%/*}"
	fi

	[ "${verbose}" = "y" ] && echo "Adding binary ${src}"
	cp -pL "${src}" "${DESTDIR}/${target}"

	# Copy the dependant libraries
	for x in $(ldd ${src} 2>/dev/null | sed -e '
		/\//!d;
		/linux-gate/d;
		/=>/ {s/.*=>[[:blank:]]*\([^[:blank:]]*\).*/\1/};
		s/[[:blank:]]*\([^[:blank:]]*\) (.*)/\1/' 2>/dev/null); do

		# Try to use non-optimised libraries where possible.
		# We assume that all HWCAP libraries will be in tls,
		# sse2, vfp or neon.
		nonoptlib=$(echo "${x}" | sed -e 's#/lib/\(tls\|i686\|sse2\|neon\|vfp\).*/\(lib.*\)#/lib/\2#')

		if [ -e "${nonoptlib}" ]; then
			x="${nonoptlib}"
		fi

		libname=$(basename "${x}")
		dirname=$(dirname "${x}")

		# FIXME inst_lib
		mkdir -p "${DESTDIR}/${dirname}"
		if [ ! -e "${DESTDIR}/${dirname}/${libname}" ]; then
			cp -pL "${x}" "${DESTDIR}/${dirname}"
			[ "${verbose}" = "y" ] && echo "Adding library ${x}" || true
		fi
	done
}


echo "this needs to be run from a machine with ubuntu 14.04 amd64"

overlay="./overlay"
DESTDIR=$overlay
debs="./debs"

mkdir $overlay
mkdir $debs

copy_list=`for a in haveged tmux pwgen; do echo $(which $a); done`

for d in $copy_list; do
    copy_exec $d 
done


cd $overlay
tar czf ../files/overlay.tar.gz .

cd ..
rm -r $overlay
rm -r $debs

