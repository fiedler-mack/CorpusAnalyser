#!/bin/bash

# remove_non_used_area_in_wav_all.sh
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# This is a helperscript (call remove_non_used_in_wav.pl) to convert all wav
# files from source folder INPUT_WAV_DIR to OUTPUT_WAV_DIR. Also use the
# folker files from INPUT_FLK_DIR.
# Please change folders as you need - see below.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# change folder as you need
INPUT_WAV_DIR="../../01_input_files/wav"
INPUT_FLK_DIR="../../01_input_files/folker"
OUTPUT_WAV_DIR="../../02_generated_files/wav"

# get filelist from inputdir
FILES=`ls $INPUT_WAV_DIR`

echo
echo "ATTENTION: this script will overwrite files in directory $OUTPUT_WAV_DIR !"
echo "press enter to continue or ctrl-c to abort."
read

#convert all files
for i in $FILES; do
	NAME=`basename $i .wav`
	PARAM="$INPUT_WAV_DIR/$i $OUTPUT_WAV_DIR/$i $INPUT_FLK_DIR/$NAME.flk"
	echo "----------------------------------------------------------------"
	echo "remove_non_used_area_in_wav.pl $PARAM"
	echo "----------------------------------------------------------------"
	./remove_non_used_area_in_wav.pl $PARAM
done
