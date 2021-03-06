#!/bin/bash

# db_query_typetoken_bedeutung.sh
#
# Query typetoken between timestamps to the sqlite3 database
# Write the results to a csv file.
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

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ ! -d $4 ] ; then
	echo "usage $0 daymin daymax bedeutung outputdir"
	exit
fi

DAYMIN=$1
DAYMAX=$2
BEDEUTUNG="$3"
OUTPUTDIR=$4

#echo "--------------------------- $BEDEUTUNG ----------------------------"
echo -n 'SELECT textpostags.lemma ' > query.sql
echo -n 'FROM sprecher,aufnahme,textpostags ' >> query.sql
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

#cat query.sql | sqlite3 $DB | wc -l
cat query.sql | sqlite3 $DB | sort | uniq > \
		$OUTPUTDIR/output_wortlist_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.txt
WORTLIST=`cat $OUTPUTDIR/output_wortlist_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.txt`
CNT=0
WORDCNTSUM=0

rm -f $OUTPUTDIR/output_typetoken_bedeutung_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
for j in $WORTLIST ; do
	#echo "........................... $j ............................"
	echo -n 'SELECT textpostags.bedeutung ' > query2.sql
	echo -n 'FROM sprecher,aufnahme,textpostags ' >> query2.sql
	echo -n 'WHERE julianday(aufnahme.datum) ' >> query2.sql
	echo -n '- julianday(sprecher.geburtsdatum) > ' >> query2.sql
	echo -n $DAYMIN >> query2.sql
	echo -n ' AND julianday(aufnahme.datum) ' >> query2.sql
	echo -n '- julianday(sprecher.geburtsdatum) < ' >> query2.sql
	echo -n $DAYMAX >> query2.sql
	echo -n ' AND textpostags.bedeutung = "' >> query2.sql
	echo -n $BEDEUTUNG >> query2.sql
	echo -n '" AND textpostags.lemma = '\' >> query2.sql
	echo -n $j\' >> query2.sql
	echo -n ' AND aufnahme.sprecher_id = sprecher.id ' >> query2.sql
	echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query2.sql
	#cat query2.sql | sqlite3 $DB
	echo -n "$j|" \
	>> $OUTPUTDIR/output_typetoken_bedeutung_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
	WORDCNT=`cat query2.sql | sqlite3 $DB | wc -l`
	WORDCNTSUM=$((WORDCNTSUM + WORDCNT))
	CNT=$((CNT + 1))
	echo $WORDCNT >> $OUTPUTDIR/output_typetoken_bedeutung_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
done
echo "----|----" >> $OUTPUTDIR/output_typetoken_bedeutung_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
echo "$CNT|$WORDCNTSUM" >> $OUTPUTDIR/output_typetoken_bedeutung_${BEDEUTUNG}_${DAYMIN}_${DAYMAX}.csv
echo "${BEDEUTUNG}|${DAYMIN}|${DAYMAX}||$CNT|$WORDCNTSUM" >> $OUTPUTDIR/../output_typetoken_bedeutung_summary.csv

rm -f query.sql
rm -f query2.sql
