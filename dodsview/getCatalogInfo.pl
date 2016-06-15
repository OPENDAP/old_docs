#!/usr/local/bin/perl
#
# -----------------------------------------
# Access a Catalog to get the Dataset Info
# -----------------------------------------
# Kashan A. Shaikh
# 8-10-2000
# -----------------------------------------

use LWP::Simple;


$url = shift || die "usage: perl $0 url\n";


$cat2="";
$getDatasetInfo = "getDatasetInfo.pl";
$das = get("$url.das");

if ( $das =~ /FileServer|Native_file/ ) {	# a catalog (rough find)
	$dds = get("$url.dds");
	if($dds =~ /}\s*(.*?);?\s/) {
		$SequenceVar = $1;
	}	
	
	$date_year_low = 0;
	$date_month_low = 0;
	$date_day_low = 0;
	$date_year_high = 0;
	$date_month_high = 0;
	$date_day_high = 0;
	
	if ($das =~ /DODS_StartDate "(\d+)\/(\d+)\/(\d+)"/) {
		$date_year_low = $1;
		$date_month_low = $2;
		$date_day_low = $3;	
	}
	if ($das =~ /DODS_EndDate "(\d+)\/(\d+)\/(\d+)"/) {
		$date_year_high = $1;
		$date_month_high = $2;
		$date_day_high = $3;
	}

	# get ascii from start and end date
        if ($date_year_low && $date_year_high) {
        	$ascii = get("$url.asc?\&date(\"$date_year_low\/$date_month_low\/$date_day_low\")");
	}
	else {
		$ascii = get("$url.asc?&date(\"1990\/1\/1\")");		# try a random date, last hope
		if ($ascii !~ /http/) { $ascii = get("$url.asc"); }	# all hope is lost, get the entire ascii file
	}
	
	foreach ( split('\n', $ascii) ) {
		if ( (! $done) && (/"(http.*?)"/) ) {
			$dataurl = $1;
			$done = 1;
		}
	}
	print "sequence_var: $SequenceVar\n";
	print "\tdate_year_low: $date_year_low";
	print "\tdate_month_low: $date_month_low";
	print "\tdate_day_low: $date_day_low";
	print "\tdate_year_high: $date_year_high";
	print "\tdate_month_high: $date_month_high";
	print "\tdate_day_high: $date_day_high\n";
	

	&try_das() if !(get("$dataurl.dds") =~ /Grid/);
	
	system("/usr/local/bin/perl $getDatasetInfo $dataurl $cat2");
}


exit;

sub try_das {
   $das = get("$url.das");
   if($das=~/String\sDod_Vars\s\"(.*?)\"/) {
      $cat2=2;
      print "varname: $1";
      $das=~/String\sSel_Vars\s\"(.*?)\"/;
      print "\tlong_name: $1";
      print "\torientation: machine";
      $das=~/String\sDODS_LatRange\s\"(.*?)\",\s\"(.*?)\"/;
      print "\tlat_low: $2\tlat_high: $1";
      $das=~/String\sDODS_LonRange\s\"(.*?)\",\s\"(.*?)\"/;
      print "\tlon_low: $1\tlon_high: $2\ttype: not_grid";
	print "\n";
   }
}
