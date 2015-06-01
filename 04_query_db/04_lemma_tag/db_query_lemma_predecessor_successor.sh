#!/bin/bash

# db_query_lemma_predecessor_successor.sh
#
# Query all lemma tags with 5 predecessor/successor to the
# sqlite3 database and write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
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

DB=../../../02_generated_files/corpus.db

if [ -z $1 ] || [ -z $2 ] || [ ! -d $2 ] ; then
	echo "usage $0 lemma outputdir"
	exit
fi

LEMMA="$1"
OUTPUTDIR=$2

for i in 0 1 2 3 4 5 6 7 8 9 10 11; do
	RESULT[$i]=0
done

#echo "--------------------------- $LEMMA ----------------------------"

rm -f $OUTPUTDIR/output_${LEMMA}.csv

echo -n 'SELECT textpostags.id ' > query.sql
echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
echo -n 'WHERE ' >> query.sql
echo -n ' textpostags.lemma = "' >> query.sql
echo -n $LEMMA >> query.sql
echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql

IDs=`cat query.sql | sqlite3 $DB`
for ID in $IDs ; do
	RESULT[6]=$ID
	#echo "--vorgaenger--$ID--"
	if [ $ID -ne 0 ] ; then
		for i in 6 5 4 3 2 1; do
			#echo $i ${RESULT[$i]}
			j=${RESULT[$i]}
			if [ $j -ne 0 ] ; then
				echo -n 'SELECT textpostags.vorgaenger_id ' > query.sql
				echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
				echo -n 'WHERE ' >> query.sql
				echo -n ' textpostags.id = "' >> query.sql
				echo -n $j >> query.sql
				echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
				echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql
				RESULT[$i-1]=`cat query.sql | sqlite3 $DB`
			fi
		done
	fi

	#echo "--nachfolger--$ID--"
	if [ $ID -ne 0 ] ; then
		for i in 6 7 8 9 10 11; do
			#echo $i ${RESULT[$i]}
			j=${RESULT[$i]}
			if [ $j -ne 0 ] ; then
				echo -n 'SELECT textpostags.nachfolger_id ' > query.sql
				echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
				echo -n 'WHERE ' >> query.sql
				echo -n ' textpostags.id = "' >> query.sql
				echo -n $j >> query.sql
				echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
				echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql
				RESULT[$i+1]=`cat query.sql | sqlite3 $DB`
			fi
		done
	fi
	for i in 1 2 3 4 5 6 7 8 9 10 11; do
		#echo -n " $i: ${RESULT[$i]}"
		j=${RESULT[$i]}
		if [ $j -ne 0 ] ; then
			echo -n 'SELECT sprecher.name, sprecher.geburtsdatum, ' > query.sql
			echo -n 'aufnahme.datum, julianday(aufnahme.datum) ' >> query.sql
			echo -n '-julianday(sprecher.geburtsdatum),' >> query.sql
			echo -n ' aufnahme.esb_name, textpostags.wort, ' >> query.sql
			echo -n 'textpostags.lemma, textpostags.postag, textpostags.id ' >> query.sql
			echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
			echo -n 'WHERE ' >> query.sql
			echo -n ' textpostags.id = "' >> query.sql
			echo -n $j >> query.sql
			echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
			echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql
			#cat query.sql | sqlite3 $DB
			#echo "create file $OUTPUTDIR/output_${LEMMA}.csv"
			cat query.sql | sqlite3 $DB \
				>> $OUTPUTDIR/output_${LEMMA}.csv
		fi
	done
	echo "" >> $OUTPUTDIR/output_${LEMMA}.csv
	#echo ""
done

rm query.sql

