#!/bin/bash

# db_query_typetoken_lemma_name.sh
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

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ ! -d $4 ] || [ -z $5 ]
then
	echo "usage $0 daymin daymax postag outputdir (hint: postag can also be a list like AAA+BBB...)"
	exit
fi

DAYMIN=$1
DAYMAX=$2
POSTAGLIST="$3"
OUTPUTDIR=$4
NAME=$5

# build the query for postag or postag-list
POSTAG_QUERY="AND ( "
for i in $(echo $POSTAGLIST | tr "+" "\n") ; do
	POSTAG_QUERY=${POSTAG_QUERY}'textpostags.postag = "'
	POSTAG_QUERY=${POSTAG_QUERY}${i}
	POSTAG_QUERY=${POSTAG_QUERY}'" '
	POSTAG_QUERY=${POSTAG_QUERY}"OR "
done
POSTAG_QUERY=${POSTAG_QUERY}'0 ) '

#echo "--------------------------- $POSTAG ----------------------------"
echo -n 'SELECT textpostags.lemma ' > query.sql
echo -n 'FROM sprecher,aufnahme,textpostags ' >> query.sql
echo -n 'WHERE julianday(aufnahme.datum) ' >> query.sql
echo -n '- julianday(sprecher.geburtsdatum) > ' >> query.sql
echo -n $DAYMIN >> query.sql
echo -n ' AND julianday(aufnahme.datum) - ' >> query.sql
echo -n 'julianday(sprecher.geburtsdatum) < ' >> query.sql
echo -n $DAYMAX >> query.sql
echo -n ' ' >> query.sql
echo -n $POSTAG_QUERY >> query.sql
echo -n ' AND sprecher.kuerzel = "' >> query.sql
echo -n $NAME >> query.sql
echo '" AND aufnahme.sprecher_id = sprecher.id ' >> query.sql
echo -n 'AND textpostags.aufnahme_id = aufnahme.id;' >> query.sql

COUNT=`cat query.sql | sqlite3 $DB | wc -l`
echo ", $COUNT entries found"
if [ $COUNT -gt 0 ] ; then
	cat query.sql | sqlite3 $DB | sort | uniq \
	> $OUTPUTDIR/output_wortlist_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.txt
	WORTLIST=`cat $OUTPUTDIR/output_wortlist_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.txt`
	CNT=0
	WORDCNTSUM=0

	rm -f $OUTPUTDIR/output_typetoken_lemma_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.csv
	for j in $WORTLIST ; do
		#echo "....................... $j ........................"
		echo -n 'SELECT textpostags.postag ' > query2.sql
		echo -n 'FROM sprecher,aufnahme,textpostags ' >> query2.sql
		echo -n 'WHERE julianday(aufnahme.datum) ' >> query2.sql
		echo -n '- julianday(sprecher.geburtsdatum) > ' >> query2.sql
		echo -n $DAYMIN >> query2.sql
		echo -n ' AND julianday(aufnahme.datum) ' >> query2.sql
		echo -n '- julianday(sprecher.geburtsdatum) < ' >> query2.sql
		echo -n $DAYMAX >> query2.sql
		echo -n ' ' >> query2.sql
		echo -n $POSTAG_QUERY >> query2.sql
		echo -n ' AND sprecher.kuerzel = "' >> query2.sql
		echo -n $NAME >> query2.sql
		echo -n '" AND textpostags.lemma = '\' >> query2.sql
		echo -n $j\' >> query2.sql
		echo -n ' AND aufnahme.sprecher_id ' >> query2.sql
		echo -n '= sprecher.id AND ' >> query2.sql
		echo -n 'textpostags.aufnahme_id = aufnahme.id;' >> query2.sql
		#cat query2.sql | sqlite3 $DB
		echo -n "$j|" \
		>> $OUTPUTDIR/output_typetoken_lemma_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.csv
		WORDCNT=`cat query2.sql | sqlite3 $DB | wc -l`
		WORDCNTSUM=$((WORDCNTSUM + WORDCNT))
		CNT=$((CNT + 1))
		echo $WORDCNT >> $OUTPUTDIR/output_typetoken_lemma_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.csv
	done
	echo "----|----" >> $OUTPUTDIR/output_typetoken_lemma_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.csv
	echo "$CNT|$WORDCNTSUM" >> $OUTPUTDIR/output_typetoken_lemma_${POSTAGLIST}_${DAYMIN}_${DAYMAX}_${NAME}.csv
	echo "${POSTAGLIST}|${DAYMIN}|${DAYMAX}|${NAME}|$CNT|$WORDCNTSUM" >> $OUTPUTDIR/../../output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}_${NAME}.csv

	rm -f query2.sql
fi
rm -f query.sql

