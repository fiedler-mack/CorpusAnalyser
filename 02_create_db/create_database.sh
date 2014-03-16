#!/bin/bash

# create_database.sh
# Create and initialisize a sqlite3 Database
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# This script creates a sqlite3 Database "DB" and initializes the tables
# which are described in the file "TABLESTRUCTURE". If the database already
# exists it will be removed and a new database is created.
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


# change following parameters, if your files are in different locations
DB=../../02_generated_files/corpus.db
TABLESTRUCTURE=db_table_structure.sqlite3


# echo warning message and wait for enter-key
if [ -f $DB ] ; then
	echo
	echo "ATTENTION: This script will remove your existing database"
	echo "           $DB"
	echo "           and create a new empty database !"
	echo
	echo "Press enter to continue or CTRL-c to abort."
	read
	# remove database
	rm -f $DB
fi

# create and initialisize new sqlite3 database
sqlite3 $DB < $TABLESTRUCTURE

