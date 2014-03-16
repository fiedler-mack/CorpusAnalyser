#!/bin/bash

cd 01_tag_count
./db_query_all_tag_count.sh
./db_query_all_tag_count_name.sh
cd ..

cd 02_typetoken
./db_query_all_typetoken.sh
cd ..

cd 03_typetoken_lemma
./db_query_all_typetoken_lemma.sh
./db_query_all_typetoken_lemma_name.sh
cd ..

cd 04_lemma_tag
./db_query_all_lemma_tag.sh
./db_query_all_lemma_tag_name.sh
cd ..

