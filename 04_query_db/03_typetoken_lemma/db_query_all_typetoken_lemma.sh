#!/bin/bash

# db_query_all_typetoken_lemma.sh
#
# Query typetoken between timestamps to the sqlite3 database
# Write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# The query of the database will doing by the subscript
# db_query_typetoken_lemma.sh.
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

DAYMINMAX="1281:1495 1496:1708 1709:1983"
POSTAGS="ADJA ADJD ADV APPR APPRART ART CARD FM ITJ KOKOM KON KOUS NE NN PAV"
POSTAGS="$POSTAGS PDAT PDS PIAT PIDAT PIS PPER PPOSAT PPOSS PRELAT PRELS PRF"
POSTAGS="$POSTAGS PTKA PTKANT PTKNEG PTKVZ PTKZU PWAT PWAV PWS VAFIN VAIMP"
POSTAGS="$POSTAGS VAINF VAPP VMFIN VMINF VMPP VVFIN VVIMP VVINF VVIZU VVPP XY"

OUTPUT_DIR=../../../03_db_query_results/typetoken

for d in $DAYMINMAX ; do
	if [[ $d =~ ^(.*):(.*)$ ]]; then
		DAYMIN=`echo ${BASH_REMATCH[1]}`
		DAYMAX=`echo ${BASH_REMATCH[2]}`

		for i in $POSTAGS ; do
			#echo -n "============================================="
			#echo "==============================="
			if [ ! -e $OUTPUT_DIR/${DAYMIN}_${DAYMAX} ] ; then
				#echo -n "directory "
				#echo -n "$OUTPUT_DIR/${DAYMIN}_${DAYMAX} "
				#echo "not exist."
				#echo -n "Press enter to create directory or "
				#echo "ctrl-c to abort"
				#read
				mkdir -p $OUTPUT_DIR/${DAYMIN}_${DAYMAX}
			fi
			echo $DAYMIN $DAYMAX $i $OUTPUT_DIR/${DAYMIN}_${DAYMAX}
			./db_query_typetoken_lemma.sh $DAYMIN $DAYMAX $i \
						$OUTPUT_DIR/${DAYMIN}_${DAYMAX}
		done
	fi
done
