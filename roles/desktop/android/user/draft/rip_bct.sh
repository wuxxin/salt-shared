#!/bin/sh

if [ -z "$1" ]; then
	echo "Usage: $0 sbk_iv"
	echo "where sbk_iv is SBK as a long number"
	echo "So, 0x09A81E00 0xD4531301 0x3B1AF703 0x9A052103 becomes"
	echo "09A81E00D45313013B1AF7039A052103"
	exit 1
fi

SBK=$1
FIN="mmcblk0_start"
FTMP="bct_tmp"
FOUT="iconia_bct.bin"
TMPSIZE=4096
BCTSIZE=4080

if [ ! -f $FIN ]; then
	echo "Input file $FIN not found"
	exit 1
fi

dd if=$FIN of=$FTMP bs=$TMPSIZE count=1

if [ ! -f $FTMP ]; then
	echo "Failed to create temporary file $FTMP"
	exit 1
fi

openssl aes-128-cbc -K $SBK -iv 0 -d -in $FTMP -out $FOUT

if [ -f $FOUT ]; then
	echo "The decrtypted BCT is in $FOUT"
else
	echo "Failed to decrypt BCT"
	exit 1
fi

echo "moving $FOUT to $FTMP"
mv $FOUT $FTMP

echo "cutting BCT from temporary file $FTMP"
dd if=$FTMP bs=$BCTSIZE count=1 of=$FOUT

if [ -f $FOUT ]; then
	echo "Done, the BCT is ready in $FOUT"
else
	echo "Failed to cut BCT"
	exit 1
fi
