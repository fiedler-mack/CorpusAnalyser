#!/bin/bash

# create results for tag count
cd 01_tag_count
./db_query_all_tag_count.sh
./db_query_all_tag_count_name.sh
cd ..

# create results for typetoken
cd 02_typetoken
./db_query_all_typetoken.sh
cd ..

# create results for typetoken lemma
cd 03_typetoken_lemma
./db_query_all_typetoken_lemma.sh
./db_query_all_typetoken_lemma_name.sh
cd ..

# create results for lemma tag
cd 04_lemma_tag
./db_query_all_lemma_tag.sh
./db_query_all_lemma_tag_name.sh
cd ..

# create results for lemma bedeutung
cd 05_lemma_bedeutung
./db_query_all_lemma_bedeutung.sh
cd ..

# create results for typetoken bedeutung
cd 06_typetoken_bedeutung
./db_query_all_typetoken_bedeutung.sh
cd ..

