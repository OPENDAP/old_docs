#!/usr/local/bin/perl
#
# -----------------------
# DODS Dataset Image View
# -----------------------
# Kashan A. Shaikh
# 8-11-2000
# -----------------------


use MD5;
use LWP::Simple;

%input = &getCGIinput();



#Force the url to start with http://
$input{'url'}=~s/http:\/\///;
$input{'url'}="http:\/\/".$input{'url'};
if($input{'url'} eq "http:\/\/") { $input{'url'}=""; }

warn "\nrunning devolopment version of view.cgi\n";
warn "\nstart warns\n";


@oldURL;
open(HIST,"kash\/hist");

$i=0;
foreach(<HIST>) {
  if (/http/) {
  @oldURL[$i]=$_;
  $i++;
  if($i>20) {last;}
  }
}
close(HIST);

#Get the name of the idl program to be used in generating the image.
open(DATA,"<configdata") or die "\nNo configdata!!!\n";


$flag1="on";
$k=0;
@stdURL_name;
@stdURL_loc;

$config_url;
$script_name;
$script="";
$banner_name;
$banner="";
warn "\nnext\n";
foreach (<DATA>) {

  if( $_ =~ /END/ ) { $flag1=""; next;}
  if($flag1) {
  	$_=~/(.+?)::(.+)/;
  	@stdURL_loc[$k]=$1;
  	@stdURL_name[$k]=$2;
     	$k=$k+1;
  	next;
  }

  $_.=" ";
  $_=~/(.+?):\s/;
  $script_url=$1;
  $_=~/.*PRO:\s()(.+?)\s/;
  $script_name=$2;
  $_=~/.*HTML:\s()()(.+?)\s/;
  $banner_name=$3;
  
  if( $script_url eq "default") {
    $script=$script_name if $script eq "";
    $banner=$banner_name if $banner eq "";
  }
  if($script_url eq $input{'url'}) {
    $script=$script_name if $script_name;   
    $banner=$banner_name if $banner_name;
  }
} #end foreach configdata line

$ENV{'QUERY_STRING'}.="&script=$script";
$ENV{'QUERY_STRING'}.="&banner=$banner";
#die ":$script:, :$banner:";
close(DATA);

$type;
print "Content-type: text/html\n\n";

$dtype = "";
if(! defined $input{'url'} ) { $dtype = "nodataset"; }
elsif ( $input{'url'} eq "") { $dtype = "nodataset"; }
elsif ( get("$input{'url'}.ver") ) { $dtype = "normal"; }
elsif ( get("$input{'url'}.dds") ) { $dtype = "strange"; }
else {
    print "<html><body bgcolor=\"White\">";
    print "Unable to find a DODS Dataset at <font color=\"Red\">$input{'url'}</font>\n<br>";
    print "Please check the URL";
    print "</body></html>";
}


if ( $dtype ne "" ) {
    %dataset_variable;
    @dataset_variable_names;

    $iscatalog = 0;
    $dataset_volume = "Single Dataset";

    if ($dtype ne "nodataset") {
	
	#create the 'kashed' code
	$md5 = new MD5;
	$md5->reset;
	$md5->add($input{'url'});
	$urlid = $md5->digest;
	$urlid = unpack("H*", $urlid);


	$kashed = 0;
	if (! (open(NOTTHERE, "kash\/$urlid.kashed")) ) { &getCatalogInfo(); }
	else { close(NOTTHERE); $kashed = 1; &getKashed("catalog");}
        if (! $iscatalog) {
	    if (! $kashed) { &getDatasetInfo();	}
	    else { close(NOTTHERE); &getKashed("single"); }
	}
	else {
	    $dataset_volume = "Catalog";
	}
    }
    if ( ($numlines > 1) || ($dtype eq "nodataset") ) {
	$dataset_lat_low = $dataset_variable{$dataset_variable_names[0]}{'lat_low'};
	$dataset_lat_high = $dataset_variable{$dataset_variable_names[0]}{'lat_high'};
	$dataset_lon_low = $dataset_variable{$dataset_variable_names[0]}{'lon_low'};
	$dataset_lon_high = $dataset_variable{$dataset_variable_names[0]}{'lon_high'};
	if ($dtype eq "nodataset") {
	    $dataset_lat_low = -90;
	    $dataset_lat_high = 90;
	    $dataset_lon_low = -180;
	    $dataset_lon_high = 180;
	    $dataset_volume = "Enter a URL";
	}

	&writeInitialPage();
    }
    else {
	print "<html><body bgcolor=\"White\">";
	print "The dataset at <font color=\"Red\">$input{'url'}</font> is either non-gridded, or cannot be found.\n<br>";
	print "Unfortunately, non-gridded datasets are not supported at this time.";
	print "</body></html>";
    }
}
else {
    print "<html><body bgcolor=\"White\">";
    print "Unable to find a DODS Dataset at <font color=\"Red\">$input{'url'}</font>\n<br>";
    print "Please check the URL";
    print "</body></html>";
}
exit;


 # ===========================================================
# Get the input from the user (using GET)
sub getCGIinput {
	local(%in);	
	local($name, $value);
	# Resolve and unencode name/value pairs into %in
	foreach (split('&', $ENV{'QUERY_STRING'})) {
	$mqstring=~s/\+/ /g;
		($name, $value)= split('=', $_, 2);
		$name=~ s/%(..)/chr(hex($1))/ge;
		$value=~ s/%(..)/chr(hex($1))/ge;
		$in{$name}.= ", " if defined($in{$name});	# concatenate multiple vars
		$in{$name}.= $value;
	}
    return %in;
}
# ===========================================================


# -----------------------------
# Create the initial HTML page
# -----------------------------
sub writeInitialPage {
  #Sudo-rounds the bounds to 2 decimal places.
  my $map_lat_low = int($dataset_lat_low*100)/100;
  my $map_lat_high = int($dataset_lat_high*100)/100;
  my $map_lon_low = int($dataset_lon_low*100)/100;
  my $map_lon_high = int($dataset_lon_high*100)/100;


  #Get the html to use for the header and trailer from their files.
  $header_file="";
  open(HEADER, "<header.html") or die "\nno header\n";
  foreach (<HEADER>) {
    $header_file.=$_;
  }
  close(HEADER);

  $trailer_file="";
  open(TRAILER, "<trailer.html") or die "\nno trailer\n";
  foreach (<TRAILER>) {
    $trailer_file.=$_;
  }
  close(TRAILER);


print <<HTML_1;
<html>
<head>
      	<title>DODS Image View</title>

<style type="text/css">
.topbar {
    background-color: Black;
    color: White;
    font-weight: bold;
    font-size: 14pt;
}
.backbar {
    background-color: Black;
    color: White;
}
</style>

<script language="JavaScript">
function init() {
    origURL = "$input{'url'}";
    iscatalog = $iscatalog;
    document.forms["urlform"].elements["url"].value = origURL;
HTML_1

    if ($dtype ne "nodataset") {
	print "\tdocument.map.restrictToolRange(0, $map_lon_low, $map_lon_high, $map_lat_low, $map_lat_high);\n";
	print "\tselectFullRegion();\n";
    }

    print <<HTML_2;
}
function getImage() {
        var windowname = "topview";
	var appearance = "menubar=yes,toolbar=yes,resizable=yes,scrollbars=yes,width=850,height=600";
	document.forms["giform"].target = windowname;
	imageWindow = window.open("", windowname, appearance);
	imageWindow.document.open();
	imageWindow.document.writeln('<html><body bgcolor="White"><center><b>Please Wait...</b></center></body></html>');
	imageWindow.document.close();
	document.forms["giform"].elements["url"].value = document.forms["urlform"].elements["url"].value;
	document.forms["giform"].elements["xrange"].value = document.map.get_x_range();
	document.forms["giform"].elements["yrange"].value = document.map.get_y_range();
	if (iscatalog)
	    document.forms["giform"].action = "multipleview.cgi";
	return true;	
}
function gatherDatasetInfo() {
    if (document.forms["urlform"].elements["url"].value != origURL) {
	document.forms["urlform"].action = "view.cgi?url=" + document.forms["urlform"].elements["url"].value;
        return true;
    }
    else
        return false;
}
function selectFullRegion() {
    document.map.positionTool(0, $map_lon_low, $map_lon_high, $map_lat_low, $map_lat_high);
    return false;
}
function mapZoomIn() {
    document.map.zoom_in();
}

function maybeRefresh() {
    url= document.forms["urlform"].elements["url"].value;
    if(url != origURL) {
      window.location="view.cgi?url="+url;
    }
}

function stdURL() {
   window.location="view.cgi?url=" + document.forms["urlform"].elements["std_URL"].options[document.forms["urlform"].elements["std_URL"].selectedIndex].value;
}

function oldURL() {
  window.location="view.cgi?url=" + document.forms["urlform"].elements["old_URL"].options[document.forms["urlform"].elements["old_URL"].selectedIndex].value;
}

function updateHighDate(id) {
    document.forms["giform"].elements[id + "_high"].selectedIndex = document.forms["giform"].elements[id + "_low"].selectedIndex;
}
</script>

</head>

<body bgcolor="White" leftmargin="0" topmargin="0" rightmargin="0" marginwidth="0" marginheight="0" onLoad="javascript: init();">
<table align="center" width="100%" cellpadding="8" cellspacing="0" border="0">
<tr>
   $header_file
</tr>
<tr>
    <td class="topbar" align="center">
    <table bgcolor="White" align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
        <td align="left" valign="top"><img src="images/topleft_corner.gif" border="0"></td>
        <td align="right" valign="top"><img src="images/topright_corner.gif" border="0"></td>
    </tr>
    <tr>
        <td colspan="2" align="center">

    <br>

	<form id="urlform" name="urlform" action="view.cgi" onSubmit="javascript: return gatherDatasetInfo();">
	        <table cellpadding="4" cellspacing="0" border="0" color='white'>
	        <tr>	
HTML_2


#       this is where 'none selected' can be modified...	print "\t\t<td class=\"backbar\" color = \'white\' align=\"center\"><b>Known DataSets</b><br><select name=\"std_URL\" onChange=\"std_URL\">\n";
	print "\t\t<td class=\"backbar\" color = \'white\' align=\"center\"><b>Known DataSets</b><br><select name=\"std_URL\" onChange=\"javascript: stdURL();\">\n";
	$k=0;
	$i=1;
#       this is where 'none selected' can also be modified...	print "\t\t\t<option name=\"0\" value=\"\" selected>none selected</option>\n";
	print "\t\t\t<option name=\"0\" value=\"\" selected>none selected</option>\n";
	
	foreach(@stdURL_loc) {	
	    print "\t\t\t<option name=\"$i\" value=\"$_\">@stdURL_name[$k]</option>\n";
	    $k=$k+1;
	    $i=$k+1;
	}
	$i=0;

      print "</select></td>\n";

      print "\t\t\t<td class=\"backbar\" align=\"center\"><b>URL History</b><br><select name=\"old_URL\" onChange=\"javascript: oldURL();\"> \n";
      print "\t\t\t\t<option name=\"0\" value=\"\" selected>Select URL</option>\n";
      $i=1;
      foreach(@oldURL) {
          print "\t\t\t\t<option name=\"$i\" value=\"$_\">$_</option>\n";
	  $i++;
	}
	$i=0;
  		
      print "</select></td></tr></table><br><br>";		
	
print <<HTML_2a;

        <b>$dataset_volume</b>
        <table cellpadding="4" cellspacing="0" border="0">
        <tr>
HTML_2a


print <<HTML_2b;
            <td class="backbar">Dataset URL:</td>
            <td class="backbar"><input type="text" name="url" onblur="javascript: maybeRefresh();" value="$input{'url'}" size="75">
                <input type="submit" value="Gather Dataset Information">
            </td>
      	</tr>
        </table>
    </form>
HTML_2b

if ($dtype ne "nodataset") {

#check the dataset lat lon bounds to see if we want to use the altantic or global map


  if(-160 < $map_lon_low &&
     24 > $map_lon_high && 
     0 < $map_lat_low && 
     75 > $map_lat_high)
  {
#atlantic case
print <<HTML_3;
	<form onSubmit="javascript: return selectFullRegion();">
	    <input type="image" name="fullregion" src="images/full_region.gif" border="0">
	</form>

	<form id="giform" name="giform" action=IDL.cgi onSubmit="javascript: return getImage();">
	<applet CODEBASE="LiveMap/classes/"
        ARCHIVE="LiveMap_30.jar"
        CODE="LiveMap_30.class"
        NAME="map" MAPSCRIPT WIDTH=525 HEIGHT=160>
        <PARAM NAME=base_image VALUE="gifs/bathy.jpeg">
        <PARAM NAME=toolType VALUE="XY">
        <PARAM NAME=img_x_domain VALUE="-160 24"> 
        <PARAM NAME=img_y_domain VALUE="0 75">
        <PARAM NAME=tool_x_range VALUE="-160 24">
        <PARAM NAME=tool_y_range VALUE="0 75">       
        <PARAM NAME=debug VALUE="false">
	</applet>
	<br><br>

        <table cellpadding="4" cellspacing="0" border="0">
        <tr>
HTML_3
  }


  else {

#global case
print <<HTML_3;
	<form onSubmit="javascript: return selectFullRegion();">
	    <input type="image" name="fullregion" src="images/full_region.gif" border="0">
	</form>

	<form id="giform" name="giform" action=IDL.cgi onSubmit="javascript: return getImage();">
	<applet CODEBASE="LiveMap/classes/"
        ARCHIVE="LiveMap_30.jar"
        CODE="LiveMap_30.class"
        NAME="map" MAPSCRIPT WIDTH=525 HEIGHT=160>
         <PARAM NAME=base_image VALUE="gifs/java_0_world_20k.jpg">
         <PARAM NAME=toolType VALUE="XY">
         <PARAM NAME=img_x_domain VALUE="-180 180">
         <PARAM NAME=img_y_domain VALUE="-90 90">
         <PARAM NAME=tool_x_range VALUE="-180 180">
         <PARAM NAME=tool_y_range VALUE="-90 90">
         <PARAM NAME=debug VALUE="false">
	</applet>
	<br><br>

        <table cellpadding="4" cellspacing="0" border="0">
        <tr>
HTML_3
}

#This is were Peter and I started hacking stuff up.  Everything seems like it still works...

if ( @dataset_variable_names > 1) { 

print <<HTML_4a1;
            <td class="backbar"><font color="yellow">Variable:</font></td>
            <td class="backbar">
                <select id="variable" name="variable">
HTML_4a1
    
    for ( my $i = 0; $i < @dataset_variable_names; $i++ ) {
        print "\t\t\t<option id=\"$i\" name=\"$i\" value=\"$dataset_variable_names[$i]\">$dataset_variable{$dataset_variable_names[$i]}{'long_name'}</option>\n";
    }

print <<HTML_4a2;
                </select>
            </td>
HTML_4a2
}

else {
print <<HTML_4b;
            <td class="backbar"> <font color="yellow"> Variable: </font> $dataset_variable{$dataset_variable_names[$i]}{'long_name'} </td>
        <input type="hidden" name="variable" value="$dataset_variable_names[$i]">
                      
HTML_4b
    
}

print <<HTML_5;
            <td></td>
            <td class="backbar">
HTML_5

#This marks the end of the Peter-Sven excursion into Kashan's code

    if ($iscatalog) {
      if ($dataset_date{'date_year_low'}) {
        &findPastDate();

	print "\t\t<td class=\"backbar\"><font color=\"yellow\">Date Range:</font></td>\n";
	
	print "\t\t<td class=\"backbar\" align=\"center\">Year<br><select name=\"date_year_low\" onChange=\"javascript: updateHighDate('date_year');\">\n";
	for ( my $i = $dataset_date{'date_year_low'}; $i <= $dataset_date{'date_year_high'}; $i++ ) {
	    print "\t\t\t<option name=\"lowyear$i\" value=\"$i\"";
	    if ($i == $pastyear) { print " selected"; }
	    print ">$i</option>\n";
	}
	print "\t\t</select></td>\n";
	print "\t\t<td class=\"backbar\" align=\"center\">Month<br><select name=\"date_month_low\" onChange=\"javascript: updateHighDate('date_month');\">\n";
	for ( my $i = 1; $i <= 12; $i++ ) {
	    print "\t\t\t<option name=\"lowmonth$i\" value=\"$i\"";
            if ($i == $pastmonth) { print " selected"; }
            print ">$i</option>\n";
	}
	print "\t\t</select></td>\n";
	print "\t\t<td class=\"backbar\" align=\"center\">Day<br><select name=\"date_day_low\" onChange=\"javascript: updateHighDate('date_day');\">\n";
	for ( my $i = 1; $i <= 31; $i++ ) {
	    print "\t\t\t<option name=\"lowday$i\" value=\"$i\"";
	    if ($i == $pastday) { print " selected"; }
	    print ">$i</option>\n";
	}
	print "\t\t</select></td>\n";

	print "\t\t<td class=\"backbar\">to</td>\n";
    
	print "\t\t<td class=\"backbar\" align=\"center\">Year<br><select name=\"date_year_high\">\n";
	for ( my $i = $dataset_date{'date_year_low'}; $i <= $dataset_date{'date_year_high'}; $i++ ) {
            print "\t\t\t<option name=\"highyear$i\" value=\"$i\"";
            if ($i == $dataset_date{'date_year_high'}) { print " selected"; }
            print ">$i</option>\n";
        }
	print "\t\t</select></td>\n";
        print "\t\t<td class=\"backbar\" align=\"center\">Month<br><select name=\"date_month_high\">\n";
	for ( my $i = 1; $i <= 12; $i++ ) {
            print "\t\t\t<option name=\"highmonth$i\" value=\"$i\"";
	    if ($i == $dataset_date{'date_month_high'}) { print " selected"; }
	    print ">$i</option>\n";
	}
	print "\t\t</select></td>\n";
	print "\t\t<td class=\"backbar\" align=\"center\">Day<br><select name=\"date_day_high\">\n";
	for ( my $i = 1; $i <= 31; $i++) {
            print "\t\t\t<option name=\"highday$i\" value=\"$i\"";
            if ($i == $dataset_date{'date_day_high'}) { print " selected"; }
            print ">$i</option>\n";
        }
	print "\t\t</select></td>\n";
      }

      else {
	  print "\t\t<td class=\"backbar\">Date Range:</td>";
	  print "\t\t<td class=\"backbar\"><input type=\"text\" name=\"date_low\" value=\"year/month/day\"></td>";
	  print "\t\t<td class=\"backbar\">to</td>";
	  print "\t\t<td class=\"backbar\"><input type=\"text\" name=\"date_high\" value=\"year/month/day\"></td>";
      }
    }
    
# for dimensions greater than 2 (more than just lat/lon)
    for ( my $i = 0; $i < $dimensions - 2; $i++ ) {
	print "\t\t<td class=\"backbar\">$dimension_names[$i]:</td>\n";
	print "\t\t<td class=\"backbar\"><select name=\"$dimension_names[$i]\">\n";
	for ( my $z = 0; $z < $dimension{$dimension_names[$i]}; $z++ ) {
	    print "\t\t\t<option id=\"$z\"  name=\"$z\" value=\"$z\">", $z+1, "</option>\n";
	}
	print "\t\t</select></td>\n";
    }

print <<HTML_4;
        </tr>
        </table>
        <br>
HTML_4

#xxxxxxxxxxxxx
    
    if ($iscatalog) {
        print "\t\t<input type=\"image\" src=\"images/get_image.gif\" border=\"0\" value=\"View Images\">\n";
    }
    else {
	print "\t\t<input type=\"image\" src=\"images/get_image.gif\" border=\"0\" value=\"View Image\">\n";
    }

print <<HTML_6;
        <input type="hidden" name="url" value="">
        <input type="hidden" name="xrange" value="">
        <input type="hidden" name="yrange" value="">
        <input type="hidden" name="lonlow" value="$dataset_lon_low">
        <input type="hidden" name="lonhigh" value="$dataset_lon_high">
        <input type="hidden" name="latlow" value="$dataset_lat_low">
        <input type="hidden" name="lathigh" value="$dataset_lat_high">
HTML_6
print <<HTML_6a;
        <input type="hidden" name="arraysizes" value="$arraysizes">
      	<input type="hidden" name="FillValue" value="$FillValue">
	<input type="hidden" name="orientation" value="$orientation">
	<input type="hidden" name="dodstype" value="$dodstype">
	<input type="hidden" name="script" value="$script">
	<input type="hidden" name="banner" value="$banner">
	<input type="hidden" name="sequencevar" value="$Sequence_Var">
    </form>

	</td>
    </tr>
    
HTML_6a

}

print <<HTML_7;
    <tr>
        <td align="left" valign="bottom"><img src="images/bottomleft_corner.gif" border="0"></td>
        <td align="right" valign="bottom"><img src="images/bottomright_corner.gif" border="0"></td>
    </tr>
    </table>
      $trailer_file
    </td>
</tr>
</table>

</body>
</html>
HTML_7

}
# -----------------------------


# ------------------------
# Get Catalog Information
# ------------------------
sub getCatalogInfo {
    open(TIMESTAMP, ">kash\/$urlid.kashed");
    print TIMESTAMP time;
    print TIMESTAMP "\n";
    close(TIMESTAMP);
    system("/usr/local/bin/perl getCatalogInfo.pl $input{'url'} >> kash\/$urlid.kashed");
    open(INFO, "kash\/$urlid.kashed");
    &getInfo(INFO, "catalog");
    close(INFO);
}
# ------------------------


# ------------------------
# Get Dataset Information
# ------------------------
sub getDatasetInfo {
    open(TIMESTAMP, ">kash\/$urlid.kashed");
    print TIMESTAMP time;
    print TIMESTAMP "\n";
    close(TIMESTAMP);
    system("/usr/local/bin/perl getDatasetInfo.pl $input{'url'} >> kash\/$urlid.kashed");
    open(INFO, "kash\/$urlid.kashed");
    &getInfo(INFO, "single");
    close(INFO);
}
# ------------------------


# ---------------------------------
# Get 'kashed' (sorry) Dataset Info
# ---------------------------------
sub getKashed {
    my $type = shift;
    open(INFO, "kash\/$urlid.kashed");
    my $old_time = <INFO>;
    $old_time =~ s/\n//g;
    my $current_time = time;
    if ( ($current_time - $old_time) > (12*60*60) ) {      # re-kash every 12 hours
	close(INFO);
       	if ($type = "catalog") { &getCatalogInfo; }
	else { &getDatasetInfo; }
	$kashed = 0;
    }
    else {
	&getInfo(INFO, $type);
	close(INFO);
    }
}
#


# -------------------
# Get info from file
# -------------------
sub getInfo {
    my $filehandle = shift;
    my $type = shift;
    $numlines = 0;
    if ($kashed) { ++$numlines; }
    $arraysizes = "";
    undef @dataset_variable_names;
    foreach (<$filehandle>) {
      	my $line = $_;

	#hack to get % sent through netscape's requests.  Possible errors if ~~~ is being used by anything else.
	$line=~s/%/~~~/g;

        # get the date from a catalog
	if ($type eq "catalog") {
	    if ($line =~ /sequence_var/) {
	      (my $key, my $value) = split(': ', $_, 2);
	      chomp($value);
	      $Sequence_Var = $value;
	    } # close if-line

	    elsif ($line =~ /date_year_low/) {
	      foreach ( split('\t', $line) ) {
		(my $key, my $value) = split(': ', $_, 2);
		$value =~ s/\n//;
		$dataset_date{$key} = $value;
		$iscatalog = 1;
	      } # close foreach
	    } # close elseif
	} #close if-catalog

	++$numlines;
	if ($line =~ /varname: (.*?)\t/) {
	    my $keyname = $1;
	    push (@dataset_variable_names, $1);
	    my %atr;
	    foreach ( split('\t', $line) ) {
		(my $key, my $value) = split(': ', $_, 2);
		$value =~ s/\n//;
		$dataset_variable{$keyname}{$key} = $value;
	    } #end foreach 

	    $arraysizes = $dataset_variable{$keyname}{'dimension_info'};

# To keep things simple, we'll disregard variables with no lat/lon ranges
	    if (! defined $dataset_variable{$keyname}{'lat_low'}) {
		pop (@dataset_variable_names);
		undef $dataset_variable{$keyname};
	    } #end defined-dataset
	} #end if-line
    } #end foreach-filehandle

    if ($#dataset_variable_names >= 0) {
	$FillValue = $dataset_variable{$dataset_variable_names[0]}{'FillValue'};
	$FillValue =~ s/e\+/e\^/;
	$orientation = $dataset_variable{$dataset_variable_names[0]}{'orientation'};
	$dodstype = $dataset_variable{$dataset_variable_names[0]}{'type'};
	$arraysizes = $dataset_variable{$dataset_variable_names[0]}{'dimension_info'};
	$dimensions = $dataset_variable{$dataset_variable_names[0]}{'dimensions'};
	%dimension;
	foreach ( split(' ', $arraysizes) ) {
	    (my $key, my $value) = split('=', $_, 2);
	    push (@dimension_names, $key);
	    $dimension{$key} = $value;
	} #end foreach-arraysize
    } # end if-dataset
} #end sub-getInfo
# ------------------------


# -----------------
# Find a past date
# -----------------
sub findPastDate {
    $pastyear = $dataset_date{'date_year_high'};
    $pastmonth = $dataset_date{'date_month_high'};
    $pastday = $dataset_date{'date_day_high'} - 13;     # 2 weeks
    if ($pastday < 1) {
	--$pastmonth;
	if ($pastmonth < 1) {
	    --$pastyear;
	    $pastmonth = 12;
	}
	if ($pastmonth == (9|4|6|11)) {
	    $pastday = 30 + $pastday;
	}
	else {
	    $pastday = 31 + $pastday;
	}
    }
}
# -----------------
