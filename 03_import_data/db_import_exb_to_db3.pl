#!/usr/bin/perl

# db_import_exb_to_db3.pl
# Read the intresting content from the Exmaralda (exb) file and
# write it to the sqlite3 database
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# This script reads Exmaralda files as exported XML and gets the interesting
# data. Then it writes the values to the sqlite3 database. If the entry
# already exists in the db, then the new one will be ignored.
# For a fresh database you should reinitialize the db with the script
# create_database.sh. You can also use the script db_import_all.sh
# for import many Exmaralda files to db.
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


use Data::Dumper;
use XML::Simple;
use File::Basename;
use Class::Struct;
use DBI;
use feature qw/say switch/;
use utf8

$|++; # auto flush on - for continious print out

my $DEBUG=0; # if you need more infos, then increase the value

# connect to db (command line parameter 2), and switch foreign keys on
$dbh = DBI->connect( "dbi:SQLite:$ARGV[1]" ) || die
					"Cannot connect: $DBI::errstr";

# enable foreign keys
$dbh->do( "PRAGMA foreign_keys = ON" );

my $xmlref = XMLin($ARGV[0]);

##############################################################################
#
# remove the spaces at the beginning / end of string, also remove all '
#
sub stringRemSpc {
	$_[0] =~ s/^\s+|\s+$//g;
	# remove also all ' because problems occur when inserting ' into database
	$_[0] =~ s/'//g;
	return $_[0];
}

##############################################################################
#
# remove the spaces at the beginning / end of string, also remove all '
# and return the result in lower case
#
sub stringCorr {
	return lc(stringRemSpc($_[0]));
}

##############################################################################
#
# define the structures of tables, see also db_table_structure.sqlite3.
#
struct( Aufnahme => [
		id => '$',
		datum => '$',
		esb_name => '$',
		kommentar => '$',
	]);
my $a = Aufnahme->new();

struct( Sprecher => [
		id => '$',
		kuerzel => '$',
		name => '$',
		geburtsdatum => '$',
		geschlecht => '$',
		sprache => '$',
		erstsprache => '$',
	]);
my $s = Sprecher->new();

struct( Textpostags => [
		id => '$',
		wort => '$',
		lemma => '$',
		postag => '$',
		bedeutung => '$',
		tli_start => '$',
		tli_start_intp => '$',
		tli_end => '$',
		tli_end_intp => '$',
		unverstaendlich => '$',
		vorgaenger_id => '$',
		nachfolger_id => '$',
	]);
my $t = Textpostags->new();

struct( Wavdatei => [
		id => '$',
		name => '$',
	]);
my $w = Wavdatei->new();



if ($DEBUG == 0) { print "$ARGV[0]\n"};

$headref = $xmlref->{head};
$bodyref = $xmlref->{"basic-body"};
$tierformat = $xmlref->{"tierformat-table"};

# get filename from the command line parameter 1
if ($DEBUG >= 2) { print "----------------------------------------------------".
			"--------------------------------------------\n"; }
$a->esb_name(basename($ARGV[0]));
if ($DEBUG >= 2) { print "aufnahme.esb_name = ".$a->esb_name."\n"};


##############################################################################
##############################################################################
#
#
# part 1: load entries from the esb-file to the internal structures
#
#
##############################################################################
##############################################################################


# header of esb-xml-data

#sprecher.kuerzel
if ($DEBUG >= 3) {
	print Data::Dumper->Dump([ $headref->{speakertable}->{speaker}->{id} ])
}
$s->kuerzel(stringCorr($headref->{speakertable}->{speaker}->{id}));
if ($DEBUG >= 2) { print "sprecher.kuerzel = ".$s->kuerzel."\n"};

#sprecher.geschlecht
if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{speakertable}->{speaker}->{sex}->{value} ]
	)
};
$s->geschlecht(stringCorr($headref->{speakertable}->{speaker}->{sex}->{value}));
if ($DEBUG >= 2) { print "sprecher.geschlecht = ".$s->geschlecht."\n"};

#sprecher.sprache
if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{speakertable}->{speaker}->
			{"languages-used"}->{language}->{lang} ]
	)
};
$s->sprache(stringCorr($headref->{speakertable}->{speaker}->
	{"languages-used"}->{language}->{lang}));
if ($DEBUG >= 2) { print "sprecher.sprache = ".$s->sprache."\n"};

#sprecher.erstsprache
if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{speakertable}->{speaker}->{"l1"}->
			{language}->{lang} ]
	)
};
$s->erstsprache(
	stringCorr(
		$headref->{speakertable}->{speaker}->{"l1"}->{language}->{lang}
	)
);
if ($DEBUG >= 2) { print "sprecher.erstsprache = ".$s->erstsprache."\n"};

#aufnahme.kommentar
if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{speakertable}->{speaker}->{comment} ]
	)
};
if (ref($headref->{speakertable}->{speaker}->{comment}) eq "HASH") {
	$a->kommentar('');
} else {
	$a->kommentar(
		stringRemSpc($headref->{speakertable}->{speaker}->{comment})
	);
}
if ($DEBUG >= 2) { print "aufnahme.kommentar = ".$a->kommentar."\n"};


# userdata of esb-xml-data

if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{speakertable}->{speaker}->
			{"ud-speaker-information"}->{"ud-information"}
		]
	)
};
@ud_information = @{$headref->{speakertable}->{speaker}->
			{"ud-speaker-information"}->{"ud-information"}};
foreach (@ud_information) {
	$ud_information_href->{$_->{'attribute-name'}} = $_->{'content'};
}

#sprecher.name
$s->name(stringCorr($ud_information_href->{'Name'}));
if ($DEBUG >= 2) { print "sprecher.name = ".$s->name."\n"};

#aufnahme.datum
$a->datum(stringCorr($ud_information_href->{'Datum'}));
# TODO better space handling
if ($a->datum eq '') {
	$a->datum(stringCorr($ud_information_href->{'Datum '}));
}
# change format of date from german style (dd.mm.yyyy) to
# sql style (yyyy-mm-dd)
($d, $m, $y) = split(/\./, $a->datum);
$a->datum($y."-".$m."-".$d);
if ($DEBUG >= 2) { print "aufnahme.datum = ".$a->datum."\n"};

#sprecher.geburtsdatum
$s->geburtsdatum(stringCorr($ud_information_href->{'Geburtstag'}));
# TODO better space handling
if ($s->geburtsdatum eq '') {
	$s->geburtsdatum(stringCorr($ud_information_href->{'Geburtstag '}));
}
# change format of date from german style (dd.mm.yyyy) to
# sql style (yyyy-mm-dd)
($d, $m, $y) = split(/\./, $s->geburtsdatum);
$s->geburtsdatum($y."-".$m."-".$d);
if ($DEBUG >= 2) { print "sprecher.geburtsdatum = ".$s->geburtsdatum."\n"};


#wavdatei.name (from header of esb-xml-data)
if ($DEBUG >= 3) {
	print Data::Dumper->Dump(
		[ $headref->{"meta-information"}->{"referenced-file"}->{url} ]
	)
};
$w->name(stringRemSpc(
	basename($headref->{"meta-information"}->{"referenced-file"}->{url}))
);
if ($DEBUG >= 2) { print "wavdatei.name = ".$w->name."\n"};


##############################################################################
##############################################################################
#
#
# part 2: write entries to the sqlite3 db
#
#
##############################################################################
##############################################################################


##############################################################################
#
# WAVDATEI
#
if ($DEBUG >= 3) { print "---------------------------------------------------".
			"---------------------------------------------\n"};

# looking for the entry in db
$res = $dbh->selectall_arrayref
	("	SELECT	*
		FROM	wavdatei
		WHERE	name = '".$w->name."'
	");

if (scalar(@$res) == 0) {
	# entry not in DB, create new one
	$dbh->do("INSERT INTO
			wavdatei(
				name
				)
			VALUES (
				'".$w->name."'
				)"
		);
	# refresh result - we need the id
	$res = $dbh->selectall_arrayref
		("	SELECT	*
			FROM	wavdatei
			WHERE	name = '".$w->name."'
		");
	if ($DEBUG >= 1) { print "Wavdatei ".$w->name.", created in DB\n"; }
} else {
	if ($DEBUG >= 1) {
		print "ignore Wavdatei ".$w->name.", already exist in DB\n";
	}
}
$w->id((@$res)[0][0]);
if ($DEBUG >= 1) { print "Wavdatei ID=".$w->id."\n"; }

##############################################################################
#
# SPRECHER
#

# looking for the entry in db
$res = $dbh->selectall_arrayref
	("	SELECT	*
		FROM	sprecher
		WHERE	name = '".$s->name."'
	");

if (scalar(@$res) == 0) {
	# entry not in db, create new one
	$dbh->do("INSERT INTO
			sprecher(
				name,
				kuerzel,
				geschlecht,
				sprache,
				erstsprache,
				geburtsdatum
				)
			VALUES (
				'".$s->name."',
				'".$s->kuerzel."',
				'".$s->geschlecht."',
				'".$s->sprache."',
				'".$s->erstsprache."',
				'".$s->geburtsdatum."'
				)"
		);
	# refresh result - we need the id
	$res = $dbh->selectall_arrayref
		("	SELECT	*
			FROM	sprecher
			WHERE	name = '".$s->name."'
		");
	if ($DEBUG >= 1) { print "Sprecher ".$s->name.", created in DB\n"; }
} else {
	if ($DEBUG >= 1) {
		print "ignore Sprecher ".$s->name.", already exist in DB\n";
	}
}
$s->id((@$res)[0][0]);
if ($DEBUG >= 1) { print "Sprecher ID=".$s->id."\n"; }


##############################################################################
#
# AUFNAHME
#

# looking for the entry in db
$res = $dbh->selectall_arrayref
	("	SELECT	*
		FROM	aufnahme
		WHERE	esb_name = '".$a->esb_name."'
	");

if (scalar(@$res) == 0) {
	# entry not in db, create new one
	$dbh->do("INSERT INTO
			aufnahme(
				sprecher_id,
				wavdatei_id,
				esb_name,
				datum,
				kommentar
				)
			VALUES (
				'".$s->id."',
				'".$w->id."',
				'".$a->esb_name."',
				'".$a->datum."',
				'".$a->kommentar."'
				)"
		);
	# refresh result - we need the id
	$res = $dbh->selectall_arrayref
		("	SELECT	*
			FROM	aufnahme
			WHERE	esb_name = '".$a->esb_name."'
		");
	if ($DEBUG >= 1) { print "Aufnahme ".$a->esb_name.", created in DB\n"; }
} else {
	if ($DEBUG >= 1) {
		print "ignore Aufnahme ".$a->esb_name.", already exist in DB\n";
	}
}
$a->id((@$res)[0][0]);
if ($DEBUG >= 1) { print "Aufnahme ID=".$a->id."\n"; }




##############################################################################
#
# read the postags and the text-elements in two arrays
#
my @postag_events;
my @text_events;
my @lemma_events;
my @bedeutung_events;

if ($DEBUG >= 3) { print Data::Dumper->Dump([ $tierformat->{"tier-format"} ])};
if ($DEBUG >= 3) { print Data::Dumper->Dump([ $bodyref->{tier} ])};
@tier = @{$tierformat->{"tier-format"}};
if (@tier == undef) {
	print "ERROR: No tier-format entry in XML-file ! Press enter to exit.";
	#<STDIN>;
	exit -1;
}

foreach (@tier) {
	$tier_href->{$_->{'attribute-name'}} = $_->{'content'};
	if ($DEBUG >= 3) { print Data::Dumper->Dump([ $_->{tierref} ])};
	if ($_->{tierref} ne "TIE_NOSP") {
		if (lc($bodyref->{tier}->{$_->{tierref}}->{type}) eq 'a'
		    && lc($bodyref->{tier}->{$_->{tierref}}->{category})
		       eq 'pos'
		    ||
		    lc($bodyref->{tier}->{$_->{tierref}}->{type}) eq 'a'
		    && lc($bodyref->{tier}->{$_->{tierref}}->{category})
		       eq 'v'
		    && $bodyref->{tier}->{$_->{tierref}}->{event} != undef)
		{
			# annotation / postag
			if ($DEBUG >= 3) {
				print Data::Dumper->Dump(
					[ $bodyref->{tier}->{$_->{tierref}} ]
				)
			};
			$tmp = $bodyref->{tier}->{$_->{tierref}}->{event};
			#print "--->a v   = $tmp\n";
			if (ref($tmp) eq "ARRAY") {
				@postag_events = @{$bodyref->{tier}->
						{$_->{tierref}}->{event}};
			} else {
				@postag_events[0] = $tmp;
			}
		} elsif(lc($bodyref->{tier}->{$_->{tierref}}->{type}) eq 't'
		    && lc($bodyref->{tier}->{$_->{tierref}}->{category}) eq 'v'
		    && $bodyref->{tier}->{$_->{tierref}}->{event} != undef)
		{
			# text
			if ($DEBUG >= 3) {
				print Data::Dumper->Dump(
					[ $bodyref->{tier}->{$_->{tierref}} ]
				)
			};
			$tmp = $bodyref->{tier}->{$_->{tierref}}->{event};
			#print "--->t v   = $tmp\n";
			if (ref($tmp) eq "ARRAY") {
				@text_events = @{$bodyref->{tier}->
						{$_->{tierref}}->{event}};
			} else {
				@text_events[0] = $tmp;
			}
		} elsif(lc($bodyref->{tier}->{$_->{tierref}}->{type}) eq 'a'
		    && lc($bodyref->{tier}->{$_->{tierref}}->{category})
		       eq 'lem'
		    && $bodyref->{tier}->{$_->{tierref}}->{event} != undef)
		{
			# lemma
			if ($DEBUG >= 3) {
				print Data::Dumper->Dump(
					[ $bodyref->{tier}->{$_->{tierref}} ]
				)
			};
			$tmp = $bodyref->{tier}->{$_->{tierref}}->{event};
			#print "--->a lem = $tmp\n";
			if (ref($tmp) eq "ARRAY") {
				@lemma_events = @{$bodyref->{tier}->
						{$_->{tierref}}->{event}};
			} else {
				@lemma_events[0] = $tmp;
			}
		} elsif (lc($bodyref->{tier}->{$_->{tierref}}->{type}) eq 'a'
		    && lc($bodyref->{tier}->{$_->{tierref}}->{category})
		       eq 'bed'
		    && $bodyref->{tier}->{$_->{tierref}}->{event} != undef)
		{
			# annotation / bedeutung
			if ($DEBUG >= 3) {
				print Data::Dumper->Dump(
					[ $bodyref->{tier}->{$_->{tierref}} ]
				)
			};
			$tmp = $bodyref->{tier}->{$_->{tierref}}->{event};
			#print "--->a bed   = $tmp\n";
			if (ref($tmp) eq "ARRAY") {
				@bedeutung_events = @{$bodyref->{tier}->
						{$_->{tierref}}->{event}};
			} else {
				@bedeutung_events[0] = $tmp;
			}
		}
	}
}


##############################################################################
#
# go through the two arrays and get the connecting postag <-> text element,
# write this to db.
#
if(@postag_events >= @text_events && @postag_events >= @lemma_events && @postag_events >= @bedeutung_events) {
	$cnt = @postag_events;
} elsif(@lemma_events >= @text_events && @lemma_events >= @postag_events && @lemma_events >= @bedeutung_events) {
	$cnt = @lemma_events;
} elsif(@bedeutung_events >= @text_events && @bedeutung_events >= @lemma_events && @bedeutung_events >= @postag_events) {
	$cnt = @bedeutung_events;
} else {
	$cnt = @text_events;
}

$i=0;
$j=0;
$k=0;
$l=0;
while($i<($cnt) && $j<($cnt) && $k<($cnt) && $l<($cnt)) {
	#print "text   [$i] ".$text_events[$i]->{start}."\n";
	#print "postag [$j] ".$postag_events[$j]->{start}."\n";
	#print "lemma  [$k] ".$lemma_events[$k]->{start}."\n";
	#print "bedeutung [$l] ".$bedeutung_events[$l]->{start}."\n";
	if ($text_events[$i]->{start} eq $postag_events[$j]->{start}
	    && $lemma_events[$k]->{start} eq $postag_events[$j]->{start}
	    && $bedeutung_events[$l]->{start} eq $postag_events[$j]->{start}) {

		if ($DEBUG >= 2) { print ". . . . . . . . . . . . . . . . . ".
			". . . . . . . . . . . . . . . . . . . . . . . . . ."."
			. . . . . \n"};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $text_events[$i]->{content} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $postag_events[$j]->{content} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $lemma_events[$k]->{content} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $bedeutung_events[$l]->{content} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $text_events[$i]->{start} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $text_events[$i]->{end} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $bodyref->{"common-timeline"}->{tli}->
					{$text_events[$i]->{start}}->{time} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $bodyref->{"common-timeline"}->{tli}->
					{$text_events[$i]->{start}}->{type} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $bodyref->{"common-timeline"}->{tli}->
					{$text_events[$i]->{end}}->{time} ]
			)
		};
		if ($DEBUG >= 3) {
			print Data::Dumper->Dump(
				[ $bodyref->{"common-timeline"}->{tli}->
					{$text_events[$i]->{end}}->{type} ]
			)};

		$t->wort(stringRemSpc($text_events[$i]->{content}));
		if ($DEBUG >= 2) { print "textpostags.wort = ".$t->wort."\n"};
		if ($t->wort eq "((unverständlich))") {
			$t->unverstaendlich(true);
		} else {
			$t->unverstaendlich(false);
		}

		$t->lemma(stringRemSpc($lemma_events[$k]->{content}));
		if ($DEBUG >= 2) { print "textpostags.lemma = ".$t->lemma."\n"};

		$t->postag(stringRemSpc($postag_events[$j]->{content}));
		if ($DEBUG >= 2) { print "textpostags.postag = ".$t->postag."\n"};

		$t->bedeutung(stringRemSpc($bedeutung_events[$l]->{content}));
		if ($DEBUG >= 2) { print "textpostags.bedeutung = ".$t->bedeutung."\n"};

		$t->tli_start(stringCorr(
			$bodyref->{"common-timeline"}->{tli}->
				{$text_events[$i]->{start}}->{time}));
		if ($DEBUG >= 2) {
			print "textpostags.tli_start = ".$t->tli_start."\n";
		}
		if (lc($bodyref->{"common-timeline"}->{tli}->
			{$text_events[$i]->{start}}->{type}) eq 'intp')
		{
			$t->tli_start_intp(true);
		} else {
			$t->tli_start_intp(false);
		}
		if ($DEBUG >= 2) {
			print "textpostags.tli_start_intp = ".
					$t->tli_start_intp."\n";
		};

		$t->tli_end(stringCorr(
			$bodyref->{"common-timeline"}->{tli}->
				{$text_events[$i]->{end}}->{time}));
		if ($DEBUG >= 2) {
			print "textpostags.tli_end = ".$t->tli_end."\n";
		}
		if (lc($bodyref->{"common-timeline"}->{tli}->
			{$text_events[$i]->{end}}->{type}) eq 'intp')
		{
			$t->tli_end_intp(true);
		} else {
			$t->tli_end_intp(false);
		}
		if ($DEBUG >= 2) {
			print "textpostags.tli_end_intp = ".$t->tli_end_intp."\n";
		}

		# TODO Vorg. / Nachf. init with zero
		$t->vorgaenger_id(0);
		$t->nachfolger_id(0);

		if ($DEBUG == 0) {
			print "($i/".($cnt-1).") ".$t->wort." ".
						$t->postag." ".
						$t->bedeutung."      \r";
		};


		##############################################################
		#
		# TEXTPOSTAGS
		#
		# search vorgaenger
		$res = $dbh->selectall_arrayref
			("	SELECT	id
				FROM	textpostags
				WHERE	aufnahme_id = '".$a->id."'
					AND tli_end = '".$t->tli_start."'
			");
		if (@$res) {
			$t->vorgaenger_id((@$res)[0][0]);
		}

		# looking for the entry in db
		$res = $dbh->selectall_arrayref
			("	SELECT	*
				FROM	textpostags
				WHERE	aufnahme_id = '".$a->id."'
					AND wort = '".$t->wort."'
					AND lemma = '".$t->lemma."'
					AND postag = '".$t->postag."'
					AND bedeutung = '".$t->bedeutung."'
					AND unverstaendlich =
						'".$t->unverstaendlich."'
					AND tli_start = '".$t->tli_start."'
					AND tli_start_intp =
						'".$t->tli_start_intp."'
					AND tli_end = '".$t->tli_end."'
					AND tli_end_intp =
						'".$t->tli_end_intp."'
			");
		if (scalar(@$res) == 0) {
			# entry not in db, create new one
			$dbh->do("INSERT INTO
					textpostags(
						aufnahme_id,
						wort,
						lemma,
						postag,
						bedeutung,
						unverstaendlich,
						tli_start,
						tli_start_intp,
						tli_end,
						tli_end_intp,
						vorgaenger_id,
						nachfolger_id
						)
					VALUES (
						'".$a->id."',
						'".$t->wort."',
						'".$t->lemma."',
						'".$t->postag."',
						'".$t->bedeutung."',
						'".$t->unverstaendlich."',
						'".$t->tli_start."',
						'".$t->tli_start_intp."',
						'".$t->tli_end."',
						'".$t->tli_end_intp."',
						'".$t->vorgaenger_id."',
						'".$t->nachfolger_id."'
						)"
				);
			if ($DEBUG >= 1) {
				print "TextPosTag ".$t->wort." / ".$t->postag." / ".$t->bedeutung.
					" / ".$t->lemma.", created in DB\n";
			}
		} else {
			if ($DEBUG >= 1) {
				print "ignore TextPosTag ".$t->wort." / ".
				$t->postag." / ".$t->bedeutung." / ".$t->lemma.
				", already exist in DB\n";
			}
		}
		if ($t->vorgaenger_id > 0) {
			# refresh result - we need the id
			$res = $dbh->selectall_arrayref
				("	SELECT	*
					FROM	textpostags
					WHERE	aufnahme_id = '".$a->id."'
						AND wort = '".$t->wort."'
						AND lemma = '".$t->lemma."'
						AND postag = '".$t->postag."'
						AND bedeutung = '".$t->bedeutung."'
						AND tli_start =
							'".$t->tli_start."'
						AND tli_end = '".$t->tli_end."'
				");
			$t->id((@$res)[0][0]);
			if ($DEBUG >= 1) { print "TextPosTag ID=".$t->id."\n"; }
			# refresh vorgaenger with nachfolger_id
			$dbh->do("UPDATE
					textpostags
					SET nachfolger_id = '".$t->id."'
					WHERE id = '".$t->vorgaenger_id."'"
				);
		}
		if ($DEBUG >= 1) {
			print "Textpostags ".$t->wort." / ".$t->postag." / ".
					$t->lemma.", in DB angelegt\n"; }

		$i++;
		$j++;
		$k++;
		$l++;

	} else {
		print "ERROR: time-start of postag, wort and lemma differ ".
			"- sourceformat not correct\n";
		print "       text   [$i] ".$text_events[$i]->{start}.
			" - ".stringRemSpc($text_events[$i]->{content})."\n";
		print "       postag [$j] ".$postag_events[$j]->{start}.
			" - ".stringRemSpc($postag_events[$j]->{content})."\n";
		print "       lemma  [$k] ".$lemma_events[$j]->{start}.
			" - ".stringRemSpc($lemma_events[$k]->{content})."\n";
		print "       bedeutung [$l] ".$bedeutung_events[$l]->{start}.
			" - ".stringRemSpc($bedeutung_events[$l]->{content})."\n";
		exit -2;
	}

}

# close database
$dbh->disconnect;

