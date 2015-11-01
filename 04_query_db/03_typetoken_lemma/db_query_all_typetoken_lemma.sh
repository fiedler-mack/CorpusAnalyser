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
# single queries
POSTAGS="ADJA ADJD ADV APPR APPRART ART CARD FM ITJ KOKOM KON KOUS NE NN PAV"
POSTAGS="$POSTAGS PDAT PDS PIAT PIDAT PIS PPER PPOSAT PPOSS PRELAT PRELS PRF"
POSTAGS="$POSTAGS PTKA PTKANT PTKNEG PTKVZ PTKZU PWAT PWAV PWS VAFIN VAIMP"
POSTAGS="$POSTAGS VAINF VAPP VMFIN VMINF VMPP VVFIN VVIMP VVINF VVIZU VVPP XY"
# multi queries
POSTAGS="$POSTAGS ADJA+ADJD ADV+PAV APPR+APPRART ART+ART CARD+CARD FM+FM ITJ+ITJ KOKOM+KON+KOUS NE+NN"
POSTAGS="$POSTAGS PDAT+PDS+PIAT+PIDAT+PIS PPER+PPER PPOSAT+PPOSS PRELS+PRF"
POSTAGS="$POSTAGS PTKA+PTKANT+PTKNEG+PTKVZ+PTKZU PWAT+PWAV+PWS VAFIN+VAIMP+VAINF+VAPP"
POSTAGS="$POSTAGS VMFIN+VMINF+VMPP VVFIN+VVIMP+VVINF+VVIZU+VVPP XY+XY"
#PDAT ? PRELAT ?

OUTPUT_DIR=../../../03_db_query_results/typetoken_lemma

for d in $DAYMINMAX ; do
	if [[ $d =~ ^(.*):(.*)$ ]]; then
		DAYMIN=`echo ${BASH_REMATCH[1]}`
		DAYMAX=`echo ${BASH_REMATCH[2]}`

		rm -f $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv

		for i in $POSTAGS ; do
			#echo -n "============================================="
			#echo "==============================="
			if [ ! -e $OUTPUT_DIR/${DAYMIN}_${DAYMAX} ] ; then
				mkdir -p $OUTPUT_DIR/${DAYMIN}_${DAYMAX}
			fi
			echo -n $DAYMIN $DAYMAX $i $OUTPUT_DIR/${DAYMIN}_${DAYMAX}
			./db_query_typetoken_lemma.sh $DAYMIN $DAYMAX $i \
						$OUTPUT_DIR/${DAYMIN}_${DAYMAX}
		done

		# calculate counts / percentage
		CNTSUM=0
		WORDCNTSUM=0
		if [ -f $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv ] ; then
			FILE=`cat $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv`
			for i in $FILE ; do
				if [[ $i =~ ^(.*)\|.*\|.*\|.*\|(.*)\|(.*)$ ]]; then
					TAG=`echo ${BASH_REMATCH[1]}`
					CNT=`echo ${BASH_REMATCH[2]}`
					WORDCNT=`echo ${BASH_REMATCH[3]}`
					if [[ $TAG =~ .*\+.* ]] ; then
						# count only multi quieries
						CNTSUM=$((CNTSUM + CNT))
						WORDCNTSUM=$((WORDCNTSUM + WORDCNT))
					fi
				fi
			done
			if [ $CNTSUM -gt 0 ] && [ $WORDCNTSUM -gt 0 ] ; then
				FILE=`cat $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv`
				rm -f $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv.tmp
				for i in $FILE ; do
					if [[ $i =~ ^.*\|.*\|.*\|.*\|(.*)\|(.*)$ ]]; then
						CNT=`echo ${BASH_REMATCH[1]}`
						WORDCNT=`echo ${BASH_REMATCH[2]}`
						WORDPERCENT=`echo "scale=5; $WORDCNT*100/$WORDCNTSUM" | bc | sed -e "s/\./,/g"`
						CNTPERCENT=`echo "scale=5; $CNT*100/$CNTSUM" | bc | sed -e "s/\./,/g"`
						echo "${i}|${CNTPERCENT}|${WORDPERCENT}" >> $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv.tmp
					fi
				done
				echo "----|----|----|----|----|----|----|----" >> $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv.tmp
				echo "||||${CNTSUM}|${WORDCNTSUM}|100,00000|100,00000" >> $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv.tmp
				mv $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv.tmp $OUTPUT_DIR/output_typetoken_lemma_summary_${DAYMIN}_${DAYMAX}.csv
			fi
		fi
	fi
done
