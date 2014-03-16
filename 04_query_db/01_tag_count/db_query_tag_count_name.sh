#!/bin/bash

# db_query_tag_count_name.sh
#
# Query postags between timestamps with a short name
# to the sqlite3 database
# Write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
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
	echo "usage $0 daymin daymax postag outputdir name"
	exit
fi

DAYMIN=$1
DAYMAX=$2
POSTAG="$3"
OUTPUTDIR=$4
NAME=$5

#echo "--------------------------- $POSTAG ----------------------------"
echo -n 'SELECT sprecher.name, sprecher.geburtsdatum, ' > query.sql
echo -n 'aufnahme.datum, julianday(aufnahme.datum) ' >> query.sql
echo -n '-julianday(sprecher.geburtsdatum),' >> query.sql
echo -n 'aufnahme.esb_name, textpostags.wort, ' >> query.sql
echo -n 'textpostags.postag, textpostags.id ' >> query.sql
echo -n ' FROM sprecher,aufnahme,textpostags ' >> query.sql
echo -n 'WHERE julianday(aufnahme.datum) - ' >> query.sql
echo -n 'julianday(sprecher.geburtsdatum) > ' >> query.sql
echo -n $DAYMIN >> query.sql
echo -n ' AND julianday(aufnahme.datum) ' >> query.sql
echo -n '- julianday(sprecher.geburtsdatum) < ' >> query.sql
echo -n $DAYMAX >> query.sql
echo -n ' AND textpostags.postag = "' >> query.sql
echo -n $POSTAG >> query.sql
echo -n '" AND sprecher.kuerzel = "' >> query.sql
echo -n $NAME >> query.sql
echo -n '" AND aufnahme.sprecher_id = sprecher.id AND' >> query.sql
echo -n ' textpostags.aufnahme_id = aufnahme.id;' >> query.sql

#echo
#cat query.sql | sqlite3 $DB
COUNT=`cat query.sql | sqlite3 $DB | wc -l`
if [ $COUNT -gt 0 ] ; then
	echo -n "$COUNT datarows found: "
	echo "create file $OUTPUTDIR/output_${POSTAG}_${DAYMIN}_${DAYMAX}.csv"
	cat query.sql | sqlite3 $DB > \
			$OUTPUTDIR/output_${POSTAG}_${DAYMIN}_${DAYMAX}.csv
else
	echo "$COUNT datarows found: "
fi
rm query.sql
