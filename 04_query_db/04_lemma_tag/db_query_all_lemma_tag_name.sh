#!/bin/bash

# db_query_all_lemma_tag_name.sh
#
# Query lemma tags by name between timestamps to the sqlite3 database
# Write the results to a csv file.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# The query of the database will doing by the subscript
# db_query_lemma_tag_name.sh.
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

NAMES="av mm js rd mk leo lar so lua jk ll ma"

OUTPUT_DIR=../../../03_db_query_results/lemma_tag

for n in $NAMES ; do
for d in $DAYMINMAX ; do
	if [[ $d =~ ^(.*):(.*)$ ]]; then
		DAYMIN=`echo ${BASH_REMATCH[1]}`
		DAYMAX=`echo ${BASH_REMATCH[2]}`

		for i in $POSTAGS ; do
			#echo -n "============================================="
			#echo "==============================="
			if [ ! -e $OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n ] ; then
				#echo -n "directory "
				#echo -n "$OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n "
				#echo "not exist."
				#echo -n "Press enter to create directory or "
				#echo "ctrl-c to abort"
				#read
				mkdir -p $OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n
			fi
			echo $DAYMIN \
				$DAYMAX $i $OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n
			./db_query_lemma_tag_name.sh $DAYMIN $DAYMAX $i \
					$OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n $n
		done
		rmdir --ignore-fail-on-non-empty $OUTPUT_DIR/${DAYMIN}_${DAYMAX}/$n
	fi
done
done
