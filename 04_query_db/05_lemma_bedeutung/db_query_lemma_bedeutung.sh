#!/bin/bash

# db_query_lemma_bedeutung.sh
#
# Query lemma bedeutung between timestamps to the sqlite3 database
# Write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2015 Alexander Mack
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

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ ! -d $4 ] ; then
	echo "usage $0 daymin daymax bedeutung outputdir"
	exit
fi

DAYMIN=$1
DAYMAX=$2
BEDEUTUNG="$3"
OUTPUTDIR=$4

#echo "--------------------------- $BEDEUTUNG ----------------------------"

echo -n 'SELECT textpostags.id ' > query.sql
echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
echo -n 'WHERE julianday(aufnahme.datum) ' >> query.sql
echo -n '- julianday(sprecher.geburtsdatum) > ' >> query.sql
echo -n $DAYMIN >> query.sql
echo -n ' AND julianday(aufnahme.datum) ' >> query.sql
echo -n '- julianday(sprecher.geburtsdatum) < ' >> query.sql
echo -n $DAYMAX >> query.sql
echo -n ' AND textpostags.bedeutung = "' >> query.sql
echo -n $BEDEUTUNG >> query.sql
echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql

rm -f $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv

IDs=`cat query.sql | sqlite3 $DB`
for ID in $IDs ; do
	RESULT[11]=$ID
	#echo "--vorgaenger--$ID--"
	if [ -n "$ID" ] && [ $ID -ne 0 ] ; then
		for i in 11 10 9 8 7 6 5 4 3 2 1; do
			#echo $i ${RESULT[$i]}
			j=${RESULT[$i]}
			if [ -n "$j" ] && [ $j -ne 0 ] ; then
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
		for i in 11 12 13 14 15 16 17 18 19 20 21; do
			#echo $i ${RESULT[$i]}
			j=${RESULT[$i]}
			if [ -n "$j" ] && [ $j -ne 0 ] ; then
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

	echo -n 'SELECT sprecher.name, sprecher.geburtsdatum, ' > query.sql
	echo -n 'aufnahme.datum, julianday(aufnahme.datum) ' >> query.sql
	echo -n '-julianday(sprecher.geburtsdatum),' >> query.sql
	echo -n ' aufnahme.esb_name, textpostags.wort, ' >> query.sql
	echo -n 'textpostags.lemma, textpostags.postag, ' >> query.sql
	echo -n 'textpostags.bedeutung, textpostags.id ' >> query.sql
	echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
	echo -n 'WHERE ' >> query.sql
	echo -n ' textpostags.id = "' >> query.sql
	echo -n $ID >> query.sql
	echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
	echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql
	RESULT=`cat query.sql | sqlite3 $DB`
	echo -n \|${RESULT} >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv

	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21; do
		#echo -n " $i: ${RESULT[$i]}"
		j=${RESULT[$i]}
		if [ -n "$j" ] && [ $j -ne 0 ] ; then
			echo -n 'SELECT textpostags.wort ' > query.sql
			echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
			echo -n 'WHERE ' >> query.sql
			echo -n ' textpostags.id = "' >> query.sql
			echo -n $j >> query.sql
			echo -n '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
			echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql
			#cat query.sql | sqlite3 $DB
			#echo "create file $OUTPUTDIR/output_${LEMMA}.csv"
			if [ $i -eq 11 ] ; then
				echo -n "|{" >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
			else
				echo -n "|" >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
			fi
			RESULT=`cat query.sql | sqlite3 $DB`
			echo -n ${RESULT} >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
			if [ $i -eq 11 ] ; then echo -n "}" >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv ; fi
		fi
	done
	echo "" >> $OUTPUTDIR/output_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
	#echo ""
done

rm query.sql
