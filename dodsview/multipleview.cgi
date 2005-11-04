#!/usr/local/bin/perl
# FileServer DODS Dataset Image View
# -----------------
# Kashan A. Shaikh
# 8-11-2000
# -----------------
use MD5;
use LWP::Simple;


%input = &getCGIinput();

#The purpose of these next lines is to calculate the area of the request.
$input{'xrange'}=~/(.*)\s(.*)/;
$dx=$1-$2;
$input{'yrange'}=~/(.*)\s(.*)/;
$dy=$1-$2;
$area=$dx*$dy;

# Sven is playing with multi-resolution switching,  If you can think of a better way to do it, do it.
# At the moment it is set up to only use the high res version if the area is <= 180.  180 a very small area, but in my experiments with Peter's dataset, even something of this small size takes quite a bit of time to load.
#if($input{'url'} eq 'http://dods.gso.uri.edu/cgi-bin/nph-ff/catalog2/path.catalog' && $area>180) {
if($input{'url'} eq 'http://dods.gso.uri.edu/cgi-bin/nph-ff/catalog/path.catalog' && $area>180) {
  
  #Do the url switch.  I am using avhrr instead of pathlr because as of the writing of this program, the pathlr catalog was having problems.
  #$input{'url'}= 'http://maewest.gso.uri.edu/cgi-bin/nph-ff/catalog2/pathlr2.catalog';
  $input{'url'}= 'http://maewest.gso.uri.edu/cgi-bin/nph-ff/catalog/pathlr2.catalog';

  #The two resolutions have diffrent arraysizes, data storage styles, and variable names.  The next three regexps deal with all that.
#  $ENV{'QUERY_STRING'}=~s/Binary%7E%7E%7E20Data/dsp_band_1/;
#  $ENV{'QUERY_STRING'}=~s/not_grid/grid/;
  $ENV{'QUERY_STRING'}=~s/6144/1024/g;
}

#print "Content-type: text/html\n\n<html><head><title>Multiple Datasets</title></head><body bgcolor=\"White\"><b>Sven was here<br>$area</b></body></html>";
#exit;

open (LEFTHTML, ">kash\/left.html");
print LEFTHTML "<html><body bgcolor=\"White\"><br><div align=\"center\"><b>Please wait while the image loads...</b></div></body></html>\n";
close (LEFTHTML);

#create the code
$md5 = new MD5;
$md5->reset;
$ENV{'QUERY_STRING'}=~s/x=\d*//;
$ENV{'QUERY_STRING'}=~s/y=\d*//;
$md5->add($ENV{'QUERY_STRING'});
$id = $md5->digest;
$id = unpack("H*", $id);

if (! defined $input{'date_low'} ) {
    $date_low = "$input{'date_year_low'}\/$input{'date_month_low'}\/$input{'date_day_low'}";
    $date_high = "$input{'date_year_high'}\/$input{'date_month_high'}\/$input{'date_day_high'}";
}
else {
    $date_low = $input{'date_low'};
    $date_high = $input{'date_high'};
    #Get the date_year, month, day for error checking
    $input{'date_low'}=~/(.*)\/(.*)\/(.*)/;
    $input{'date_year_low'}=$1;
    $input{'date_month_low'}=$2;
    $input{'date_day_low'}=$3;
    $input{'date_high'}=~/(.*)\/(.*)\/(.*)/;
    $input{'date_year_high'}=$1;
    $input{'date_month_high'}=$2;
    $input{'date_day_high'}=$3;
}

print "Content-type: text/html\n\n";

&date_check();

if ( ! (open(NOTTHERE, "kash\/right$id.html")) ) {
    # get the ascii data

    $lnk = get("$input{'url'}.asc?DODS_Date($input{'sequencevar'}),?DODS_Time($input{'sequencevar'}),DODS_URL&date(\"$date_low\",\"$date_high\")");

#    open(MD,">kash\/mdebug");
#    print(MD "$input{'url'}.asc?DODS_Date($input{'sequencevar'}),DODS_URL&date(\"$date_low\",\"$date_high\")");
#    print(MD "\n\n");
#    print(MD $lnk);
#    close(MD);

#Now that date_check is implemented, these next lines shouldn't be needed...
    # This should at least catch the date bugs for all of peter's datasets.
 #   if(!($lnk=~/[123456789]/)) {
  #  	print "<html><body bgcolor=\"White\"><br><div align=\"center\"><b>You have entered an invalid date range.<br>Check to make sure that all entries in your request are valid dates.</b></div></body></html>"; exit;
   # }

    $query = $ENV{'QUERY_STRING'};
    $query =~ s/url=(.*?&)/parentURL=$1/;
    #warn "\n::$1\n\n";
    #warn "\n::$query\n\n";
    $query =~ s/%(..)/chr(hex($1))/ge;
    #warn "\n::$query\n\n";

    @links;
    $found = 0;
    (my $junk, my $dateinfo) = split('\n', $lnk, 2);
    if (! /^0/ ) { $found = 1; }
    foreach (split('\n', $dateinfo)) {

	$_ =~ /"(http.*?)",\s*?"(.*?)",\s*?"(.*?:.*?):.*/;
	if($3 ne "00:00") { $lname = "$2 $3 GMT"; }
        else { $lname = $2; }
	$link = $1;
	#$temp = $_;
	#$temp =~ /"(http.*?)"/;
	#$link = $1;
	#$temp =~ /^(\d+?), (\d+?), (\d+?), ((\d+?), )?((\d+?), )?/;
	#$time = "";
	#if (defined $5) { $time = "$5:"; }
	#if (defined $7) {
	#    if ($7 < 10) { $time .= "0"; }
	#    $time .= "$7";
	#}
	#$lname = "$1\/$2\/$3  $time";

(my $testgmt, my $testinfo ) = split(':',$1,2);
if ($testgmt != "http") {&getGMTinfo($testgmt);
}else{

	push(@links, $lname);
	push(@links, $link);
}
    }
    if ($found) {
	&writeRightFrame();
    }
}
else { close(NOTTHERE); $found = 1; }

if ($found) {    
    &writeFrames();
}
else {
    print "<html><head><title>Multiple Datasets</title></head><body bgcolor=\"White\"><b>Date Range returned NO DATA<br>Please Enter a new Date Range</b></body></html>";
}
exit;
# ===========================================================
# get info to debug GMT

sub getGMTinfo{
    open(GMTINFO,">>gmtinfo.log");
    $line=shift;
    print GMTINFO "\n gmtinfo: $line\n";
    close(GMTINFO);

}
# ===========================================================
# Get the input from the user (using GET)
sub getCGIinput {
	local(%in);	
	local($name, $value);
	# Resolve and unencode name/value pairs into %in
	foreach (split('&', $ENV{'QUERY_STRING'})) {
		s/\+/ /g;
		($name, $value)= split('=', $_, 2);
		$name=~ s/%(..)/chr(hex($1))/ge;
		$value=~ s/%(..)/chr(hex($1))/ge;
		$in{$name}.= ", " if defined($in{$name});	# concatenate multiple vars
		$in{$name}.= $value;
	}
    return %in;
}
# ===========================================================

# ---------------------------
# Write the FRAMES HTML page
# ---------------------------
sub writeFrames {

#Changed cols from 160 to 100 on 8/29/00 S.O.
print <<FRAMES;
<html>
<head>
	<title>Multiple Datasets</title>

</head>

<frameset cols="*,160"  border=0>
        <frame name="multileft" src="kash/left.html">
	<frame name="multiright" src="kash/right$id.html" scrolling="no">
</frameset>

</html>
FRAMES
}
# ---------------------------


# --------------------------------
# Write the RIGHT frame HTML page
# --------------------------------
sub writeRightFrame {

    #warn "\n>>$query\n\n";

open (RIGHT, ">kash/right$id.html");
print RIGHT <<RIGHTFRAME_1;
<html>
<head>
	<title>Dataset Selection Frame</title>

<script language="Javascript">
function init() {
    document.forms["selectform"].elements["linkselect"].selectedIndex = 0;
    submitRequest('$links[1]');
}
function submitRequest(link) {
       	parent.frames.multileft.document.writeln('<html><body bgcolor="White"><br><div align="center"><b>Please wait while the image loads...</b></div></body></html>');
	parent.frames.multileft.location =  "../IDL.cgi?$query&url=" + link;
}
</script>

</head>

<body bgcolor="White" onLoad="init();">

<div align="center">
<form id="selectform" name="selectform">
<table bgcolor="DarkBlue" cellpadding="2"><tr><td align="center"><font color="White"><b>Select a date<br> to view the image</b></font></td></tr></table>
<select id="linkselect" name="linkselect" size="30" onchange="javascript: submitRequest(this.options[this.selectedIndex].value);">
RIGHTFRAME_1
	

   #warn "\n>>>>$query\n\n";

    my $num = 0;
    my $len = $#links;
    for (my $i = 0; $i < $len; $i += 2) {
	    print RIGHT "<option id=\"$num\" name=\"$num\" value=\"", $links[$i+1], "\" >$links[$i]</option>\n";
            $num++;
    }
	
print RIGHT <<RIGHTFRAME_2;
</select>
</form>
</div>

</body>
</html>
RIGHTFRAME_2
close (RIGHT);
}
# -----------------------------


#------------------------------
#  A few functions that try to make sure that the dates sent to dodsview is valid.
#  There is probably a fast and easy way to do this, but I was too lazy to try and find it.
#  If someone is feeling really energetic, they can make this thing handle leap years :)

sub date_check {
  $date_low=~/.*([^\d^\/]+)/;
  if($1) { form_error(); }
  $date_high=~/.*([^\d^\/]+)/;
  if($1) { form_error(); }

  $date_low=~/(.*)\/(.*)\/(.*)/;
  if(!$1 || !$2 || !$3) { form_error(); }
  $date_high=~/(.*)\/(.*)\/(.*)/;
  if(!$1 || !$2 || !$3) { form_error(); }

  if( $input{'date_month_high'} > 12) { month_error("high"); }
  if( $input{'date_month_low'} > 12) { month_error("low"); }
 
  if( $input{'date_day_low'} > 31) { day_error("low"); }
  if( $input{'date_day_high'} > 31) { day_error("high"); }

  if( not31($input{'date_month_low'}) && ($input{'date_day_low'}>30) ) {
    day_error("low"); }
  if( not31($input{'date_month_high'}) && ($input{'date_day_high'}>30) ) { day_error("high"); }

  if( ($input{'date_month_low'}==2) && ($input{'date_day_low'}>29) ) { day_error("low"); }
  if( ($input{'date_month_high'}==2) && ($input{'date_day_high'}>29) ) { day_error("high"); }
  
  my $foo;

  if( $input{'date_year_high'} < $input{'date_year_low'} ) {  $foo=1;}
  if( ( $input{'date_year_high'}==$input{'date_year_low'} ) &&
      ( $input{'date_month_high'} < $input{'date_month_low'} ) ) { $foo=1; }
  if( ( $input{'date_year_high'}==$input{'date_year_low'} ) &&
      ( $input{'date_month_high'} == $input{'date_month_low'} ) &&
      ( $input{'date_day_high'} < $input{'date_day_low'}) ) { $foo=1; }
  if( $foo==1) {
    print "<html><body bgcolor=\"White\"><br><div align=\"left\"><b>You have asked for the date range $date_low to $date_high<br>Yet, $date_high is an earlier date than $date_low.<br>Please change your request and try again.</b></div></body></html>";
    exit;
  }
}

sub form_error {
  print "<html><body bgcolor=\"White\"><br><div align=\"left\"><b>You have asked for the date range $date_low to $date_high<br>One or more of these dates is invalid.<br>Please change your request and try again.</b></div></body></html>";
  exit;
}

sub not31 {
  my $n=shift;
  return 1 if ( ($n==9) || ($n==6) || ($n==4) || ($n==11) );
  return "";
}

sub day_error {
  my $time=shift;
  my $month="date_month_$time";
  my $day="date_day_$time";
  print "<html><body bgcolor=\"White\"><br><div align=\"left\"><b>You have asked for the date range $date_low to $date_high<br>";
  print "However, their are less than $input{$day} days in ";
  my $month_name=make_month($input{$month});
  print $month_name;
  print ".<br>Please change your request and try again.</b></div></body></html>";
  exit;
}

sub month_error {
  my $time=shift;
  my $month="date_month_$time";
  print "<html><body bgcolor=\"White\"><br><div align=\"left\"><b>There is no $input{$month}th month.<br>Please change your request and try again.</b></div></body></html>";
  exit;
}
 
sub make_month {
  my $month=shift;
  if($month==1) { return "January"; }
  if($month==2) { return "February"; }
  if($month==3) { return "March"; }
  if($month==4) { return "April"; }
  if($month==5) { return "May"; }
  if($month==6) { return "June"; }
  if($month==7) { return "July"; }
  if($month==8) { return "August"; }
  if($month==9) { return "September"; }
  if($month==10) { return "October"; }
  if($month==11) { return "November"; }
  if($month==12) { return "December"; }
}

# -------------------------------
