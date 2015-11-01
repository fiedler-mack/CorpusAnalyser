#!/bin/bash

# db_query_all_typetoken_bedeutung.sh
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
BEDEUTUNG="ad-part ad-qual ad-quant ad-rel"
BEDEUTUNG="$BEDEUTUNG adv-kaus adv-komm adv-lok"
BEDEUTUNG="$BEDEUTUNG adv-mod adv-temp art fm handlung"
BEDEUTUNG="$BEDEUTUNG itj kon-add kon-adv kon-alt kon-ass kon-kaus kon-spez"
BEDEUTUNG="$BEDEUTUNG kon-temp kon-vgl n-abstr-hdlg n-abstr-maß"
BEDEUTUNG="$BEDEUTUNG n-abstr-vorg n-abstr-vorst n-abstr-wiss n-abstr-zeit"
BEDEUTUNG="$BEDEUTUNG n-abstr-zust n-abstr-eig n-belebt ne"
BEDEUTUNG="$BEDEUTUNG n-unbelebt pav pdat pds"
BEDEUTUNG="$BEDEUTUNG piat pidat pis pper ppos"
BEDEUTUNG="$BEDEUTUNG prels prf pr-kaus pr-lok pr-mod pr-neutr pr-temp"
BEDEUTUNG="$BEDEUTUNG ptk-abt ptk-ant ptk-fok ptk-gespr"
BEDEUTUNG="$BEDEUTUNG ptk-grad ptk-neg"
BEDEUTUNG="$BEDEUTUNG ptkvz ptkzu pwat pwav pws sub-fin"
BEDEUTUNG="$BEDEUTUNG sub-kaus sub-kond sub-konz sub-mod-instr sub-neutr sub-temp"
BEDEUTUNG="$BEDEUTUNG v-aux v-kop v-mod"
BEDEUTUNG="$BEDEUTUNG vorgang xy zustand"

OUTPUT_DIR=../../../03_db_query_results/typetoken_bedeutung

for d in $DAYMINMAX ; do
	if [[ $d =~ ^(.*):(.*)$ ]]; then
		DAYMIN=`echo ${BASH_REMATCH[1]}`
		DAYMAX=`echo ${BASH_REMATCH[2]}`

		for i in $BEDEUTUNG ; do
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
			./db_query_typetoken_bedeutung.sh $DAYMIN $DAYMAX $i \
						$OUTPUT_DIR/${DAYMIN}_${DAYMAX}
		done
	fi
done
