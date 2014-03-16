#!/bin/bash

# db_import_all.sh
# Import one or more Exmaralda files from folder to the sqlite3 database
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# This script reads all Exmaralda files (*.exb) from the given folder
# (first parameter) and writes the interesting content to the sqlite3
# database (second parameter).
# The content of the Exmaralda-files will be exported and imported in
# sqlite3 by the subscript db_import_exb_to_db3.pl.
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


# check input parameters, if not ok then print out the usage and exit
if [ ! -d $1 ] || [ -z $1 ] || [ ! -f $2 ] || [ -z $2 ]; then
	echo "usage: $0 dirname_with_exb_files filename_to_sqlite3_database"
	exit -1
fi


# get all filenames with ending exb
FILES=`ls $1/*.exb`


# for progressinfo:
# count of all exb-files
COUNTALL=`echo $FILES | wc -w`
# internal counter
COUNT=0


for i in $FILES ; do
	NAME=`basename $i`
	COUNT=`expr $COUNT + 1`
	echo "================================================================"
	echo "    db_import_exb_to_db3.pl $i $2 ($COUNT/$COUNTALL)"
	echo "================================================================"
	# call the subscript, that is doing the work...
	./db_import_exb_to_db3.pl $i $2
	if [ $? != 0 ] ; then
		echo "Error in subscript db_import_exb_to_db3.pl."
		echo "Importing canceled."
		exit
	fi
done
