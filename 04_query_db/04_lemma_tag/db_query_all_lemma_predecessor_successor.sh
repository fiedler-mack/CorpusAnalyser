#!/bin/bash

# db_query_all_lemma_predecessor_successor.sh
#
# Query lemma tags tags with 5 predecessor/successor to the
# sqlite3 database Write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# The query of the database will doing by the subscript
# db_query_lemma_predecessor_successor.sh.
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

LEMMA="dass werden"
LEMMA="$LEMMA haben viel"

OUTPUT_DIR=../../../03_db_query_results/lemma_tag


for i in $LEMMA ; do
	#echo -n "============================================="
	#echo "==============================="
	if [ ! -e $OUTPUT_DIR/predecessor_successor ] ; then
		mkdir -p $OUTPUT_DIR/predecessor_successor
	fi
	echo $i $OUTPUT_DIR/predecessor_successor
	./db_query_lemma_predecessor_successor.sh $i \
				$OUTPUT_DIR/predecessor_successor
done

