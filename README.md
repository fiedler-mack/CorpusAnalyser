CorpusAnalyser
==============

Software tool suite to help analysing a linguistic corpus.



This is a software tool suite help analysing a linguistic corpus. It takes
xml format files as input from folker and/or exmaralda and write parts of the
content to a sqlite3 database. The database will be a file on the disc.
After you have created and imported the data in the sqlite3 database, you can
query the database with specific database selects. The output will be written
to csc-files in the output dirs.
There are also scripts to modify audio (wav) files, it mutes unused space in
file by taking the information from a folker xml file.

Author: Alexander Mack <amack@fiedler-mack.de>



License:
========

Copyright (C) 2012 Alexander Mack

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.



Project folder structure:
=========================

This is the recommened folder structure for using. You can change this when
you call scripts manually or edit the path entries in the helper-scripts
xxx_all.sh


	project (your project root folder - here named project)
	|
	+- CorpusAnalyser (this should be this project from github)
	|	|
	|	+- 01_wav_convert
	|	|
	|	+- 02_create_db
	|	|
	|	+- 03_import_data
	|	|
	|	+- 04_query_db
	|	|
	|	LICENSE
	|	README.md (this file)
	|
	+- 01_input_files (folder for input files - wav, folker,
	|	|	   exmaralda xml exports)
	|	|
	|	+- wav (this folder is for your original wav records)
	|	|
	|	+- folker (this folder is for your folker (*.flk) files
	|	|	   in xml format)
	|	|
	|	+- exmaralda (this folder is for your exmaralda (*.exb) files
	|		      in xml format)
	|
	+- 02_generated_files (folder for generated files - wav, sqlite3
	|	|	       database)
	|	|
	|	+- wav (here will be stored the output wav's from
	|		01_wav_convert/remove_non_used_in_wav_all.sh
	|		this script use wav files and folker files from
	|		01_input_files)
	|
	+- 03_db_query_results (folder for query results from database)
	|


1. Installation / Preparation:
==============================

	1.1 create above folder structure

	1.2 move this project folder "CorpusAnalyser" in the root of your project, see above.



2. Copy / save your files to the right place:
=============================================

	These steps are needed for 3.:

	2.1 put your wav-files to the folder:
		01_input_files/wav

	2.2 create folker files in the program Folker and save it in xml format
	    as name.flk - the name should be without spaces and have the same
	    name as the corresponding wav file.
	    put the folker-files in the folder:
	  	01_input_files/folker

	This step is needed for 5.:

	2.3 create the exmaralda file with the program Exmaralda and put it in the exmaralda folder:
	  	01_input_files/exmaralda



3. Convert wav-files:
=====================

	This step depends on steps 1., 2.1 and 2.2. 

	3.1 to remove unused areas in your wav files (overwrite with silence)
	    call the script 01_wav_convert/remove_non_used_area_in_wav_all.sh:

	    open terminal/console and change directory to your project folder

	    $ cd project
	    $ cd CorpusAnalyser/01_wav_convert
	    $ ./remove_non_used_area_in_wav_all.sh

	    after success you will find the created files in:
	  	02_generated_files/wav



4. Create the SQLite3 Database:
===============================

	4.1 open terminal/console and change directory to your project folder

	    $ cd project
	    $ cd CorpusAnalyser/02_create_db
	    $ ./create_database.sh

	    after success you will find an empty sqlite 3 database under:
	  	02_generated_files/corpus.db



5. Import exmaralda files to sqlite db:
=======================================

	This step depends on step 2.3 and 4.

	5.1 open terminal/console and change directory to your project folder
	    You can do step 5.2 alternatively - step 5.2 may be faster but
	    have same results.

	    $ cd project
	    $ cd CorpusAnalyser/03_import_data
	    $ ./db_import_all.sh ../../01_input_files/exmaralda/ ../../02_generated_files/corpus.db

	    after success you will find an updated sqlite 3 database under:
	  	02_generated_files/corpus.db

	   now you can open the corpus.db file, which you can find in folder
	   02_generated_files, with a sqlite3 browser and browse / check the
	   imported data.

	5.2 faster way to create the db

	  You need root access to work over a tmpfs - you can do that also by
	  step 5.1 - it does the same but slower.

	    $ cd project
	    $ cd CorpusAnalyser/03_import_data

	  create the tmp filesystem

	    $ su
	    # mount -t tmpfs tmpfs /mnt/
	    # exit

	  copy the sqlite3 db to the tmp fs

	    $ cp ../../02_generated_files/corpus.db /mnt/
	    $ ./db_import_all.sh ../../01_input_files/exmaralda/ /mnt/corpus.db

	  copy back the sqlite db

	    $ cp /mnt/corpus.db ../../02_generated_files/

	  umount tmpfs

	    $ su
	    # umount /mnt
	    # exit



6. Generate all results (step 7-12) from db:
============================================

	This step depends on step 5.

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db
	    $ ./query_all.sh

	This script will call step 7 to 12 automaticially, it's not necessary
	to do this manually. All results should be written now - you can stop
	here.
	The results are written to subfolder under 03_db_query_results.



7. Generate Tag count results from db:
======================================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/01_tag_count

	  count of all names

	    $ ./db_query_all_tag_count.sh

	  and separated by name in separate folders

	    $ ./db_query_all_tag_count_name.sh



8. Typetoken results from db:
=============================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/02_typetoken
	    $ ./db_query_all_typetoken.sh



9. Typetoken Lemma results from db:
===================================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/03_typetoken_lemma
	    $ ./db_query_all_typetoken_lemma.sh

	and separated by name in separate folders

	    $ ./db_query_all_typetoken_lemma_name.sh



10. Lemma Tags results from db:
===============================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/04_lemma_tag
	    $ ./db_query_all_lemma_tag.sh

	and separated by name in separate folders

	    $ ./db_query_all_lemma_tag_name.sh



11. Lemma Bedeutung Tags results from db:
=========================================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/05_lemma_bedeutung
	    $ ./db_query_all_lemma_bedeutung.sh



12. Typetoken Bedeutung Tags results from db:
=============================================

	This step depends on step 5.
	This is a substep of db_query_all.sh (step 6).

	    $ cd project
	    $ cd CorpusAnalyser/04_query_db/06_typetoken_bedeutung
	    $ ./db_query_all_typetoken_bedeutung.sh


