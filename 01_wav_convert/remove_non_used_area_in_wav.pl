#!/usr/bin/perl

# remove_non_used_area_in_wav.pl
# Remove non used area in wav-files.
#
# Author: Alexander Mack <amack@fiedler-mack.de>
#
# Copyright (C) 2012 Alexander Mack
#
# This script writes silence on not used parts in a wav file.
# The needed timestamps come from a folker file.
# The silence will be written to non tagged (no <w>) areas.
#
# usage: remove_non_used_area_in_wav.pl source.wav target.wav source.flk
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


use Audio::Wav;
use Data::Dumper;
use XML::Simple;
use Math::Round;

my $DEBUG = 0;

my $data;
my $readdatacnt = 0;

my $wav = new Audio::Wav;

# open input wav-file
my $read = $wav -> read( $ARGV[0] );

# get details of wav-file
my $details = $read -> details();

# some extra debug - comment out if needed
#print "input details:\n";
#print Data::Dumper->Dump([ $details ]);
#print "length of samples:", $read -> length_samples(), "\n";

# open input folker-file
my $xmlref = XMLin($ARGV[2]);
@time_arr = @{$xmlref->{timeline}->{timepoint}};
#print Data::Dumper->Dump([ @time_arr ]);

# get all timestamps (absolute time)
my $time_href = {};
foreach (@time_arr) {
	#print $_->{'timepoint-id'}, ", ";
	#print $_->{'absolute-time'}, "\n";
	$time_href->{$_->{'timepoint-id'}} = $_->{'absolute-time'};
}
#print Data::Dumper->Dump([ $time_href ]);


my @contrib_arr = @{$xmlref->{contribution}};
my @contrib_arr_filter;
#print Data::Dumper->Dump([ @contrib_arr ]);
foreach (@contrib_arr) {
	if ($_->{'w'}) {
		# take only entries with words (<w>) in folker file
		push(@contrib_arr_filter, $_);
		if ($DEBUG) { print "Dump:\n", Data::Dumper->Dump([ $_ ]); }
	#} else {
		# ignore all empty fields
	}
}



my $contrib_last_end;
my @contrib_pack_arr;
my @timeline_marks;
my $contrib_href = {};
my $max_last_end;
foreach (@contrib_arr_filter) {

	# some extra debug - comment out if needed
	#print "Dump:\n",Data::Dumper->Dump([ $_ ]);
	#print $_->{'start-reference'};
	#print "...", $_->{'end-reference'}, "\n";

	if (length($contrib_last_end)) {
		if (	$time_href->{$_->{'start-reference'}}
			* $details->{'bytes_sec'}
			>
			$time_href->{$contrib_last_end}
			* $details->{'bytes_sec'})
		{
			if ($DEBUG) { print "...", $contrib_last_end, "\n"; }
			if ($DEBUG) { print $_->{'start-reference'}; }
			push(@contrib_pack_arr, $contrib_last_end);
			push(@contrib_pack_arr, $_->{'start-reference'});
		}
		#print "l=",length($contrib_last_end),"\n";
	} else {
		# take first startentry
		if ($DEBUG) { print $_->{'start-reference'}; }
		push(@contrib_pack_arr, $_->{'start-reference'}); # old
	}
	# we take the last to compare with next start
	if (	length($contrib_last_end) == 0
		||
		$time_href->{$_->{'end-reference'}}
		* $details->{'bytes_sec'}
		>
		$time_href->{$contrib_last_end} * $details->{'bytes_sec'})
	{
		$contrib_last_end=$_->{'end-reference'};
	}
}
if ($DEBUG) { print "...", $contrib_last_end, "\n"; }
push(@contrib_pack_arr, $contrib_last_end);


# create outputfile
my $write = $wav -> write( "$ARGV[1]", $read -> details() );
$write -> set_info( 'software' => 'Audio::Wav' );

my $i = 0;
if (($time_href->{$contrib_pack_arr[0]} * $details->{'bytes_sec'}) < 1) {
	# if first timestamp
	$i = 1;
}

# read input file and write with silence pads to outputfile
while ( defined(
		$data = $read -> read_raw(
			round(	$time_href->{$contrib_pack_arr[$i]}
				* $details->{'bytes_sec'}
			     ) - $readdatacnt)
	     ) )
{
	#print "length=",length($data),"\n";

	if (($i % 2) == 0) {
		# 0, 2, ...
		#overwrite databuf with silence (0)
		$data = chr(0) x ((round(
			$time_href->{$contrib_pack_arr[$i]}
			* $details->{'bytes_sec'}) - $readdatacnt));
		print "$i: silence: $contrib_pack_arr[$i] ->
			time=$time_href->{$contrib_pack_arr[$i]},
			bytes=", round($time_href->{$contrib_pack_arr[$i]}
			* $details->{'bytes_sec'} - $readdatacnt), "\n";
	} else {
		print "$i: wavdata: $contrib_pack_arr[$i] ->
			time=$time_href->{$contrib_pack_arr[$i]}, bytes=",
			round($time_href->{$contrib_pack_arr[$i]}
			* $details->{'bytes_sec'} - $readdatacnt), "\n";
	}
	$readdatacnt += length($data);
	#print $data; # debug
	$write -> write_raw( $data );
	$i++;
}

# write to end of file silence
while ( defined( $data = $read -> read_raw( 512 ) ) ) {
	$data = chr(0) x length($data);
	$write -> write_raw( $data );
}

# close ouputfile
$write -> finish();

