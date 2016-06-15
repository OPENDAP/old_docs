#!/usr/local/bin/perl

# A faster DODS image generator.  Uses rpc and IDL.  Much help from Rich.
# --Sven Olsen, Summer 2000

use MD5;
use Time::localtime;

open(IPADRS,">>ip.logs");

warn "$ENV{'QUERY_STRING'}\n";
#$client_dir='/usr/local/apache/htdocs/dodsview/';
$client_dir='/usr/local/apache/htdocs/idl/';


#$thisday = (Sun,Mon,Tue,Wed,Thu,Fri,Sat)[(locatltime)[6]];
#$time = timelocal($sec, $min, $hours, $mday, $mon, $year);

 
#The landmasks hash.  Any url containing one of the keys in this hash will
#use the value of that key as a landmask.  Yes, their are obvious long term
#problems with the keys that I have choosen for glk and avhrr, but I have
#yet to figure out how to use '/' in a hash key, so they will have to do
#untill someone better educated in the ways of perl comes along and fixes them.

#Now that we have learned how to use idl's mapping functions, I don't think
#that the landmasks are needed any more.  However, I failed to make a
#good idl script that replicates the effect of these landmasks, so the
#landmasking will stay... for now.
#
#	the avhrr prevu.landmask is missing. until it is reconstructed
#	a copy of glk.landmask will be used.

%landmasks = (
glk => 'http://dods.gso.uri.edu/cgi-bin/nph-dsp/dods/glk.landmask',
avhrr => 'http://dods.gso.uri.edu/cgi-bin/nph-dsp/dods/prevu.landmask'
	     );

$lmask="none";

%req=&getCGIinput();

warn "\n$req{'parentURL'}\n";

foreach (keys(%landmasks)) {
  $lmask=$landmasks{"$_"} if $req{'url'}=~/$_/;
}

#warn "\n\nlmask=$lmask\n\n";
$req{'FillValue'}='\!VALUES.F_NAN' if !$req{'FillValue'};
#Undo the substitution Kashan did to get around netscape's "+"=" " definition. 
$req{'FillValue'} =~  s/e\^/e\+/;

#Show the error gif if I get a request without a url, for some reason this
#happens if you double click on a date.
#warn"\nurl::$req{'url'}\n";
if( ($req{'url'} eq "undefined") || ($req{'url'} eq "3D") ) { warn "hi\n\n"; &display_gif("error.gif"); 
exit; }



#Get rid of bothersome x= y= parts of request.  Kashan says he didn't
#put them there.  They seem to change randomly, so they need to 
#die if caching is gona work.
$ENV{'QUERY_STRING'}=~s/x=\d*//;
$ENV{'QUERY_STRING'}=~s/y=\d*//;
$ENV{'QUERY_STRING'}=~s/&&//;
@dims;
%arrays;
#warn "\n$ENV{'QUERY_STRING'}\n";


# Get the array sizes.
# Kashan will give me something like "TIME=12 COADSY=90 COADSX=180".
# This stuff turns it into the implied hash table.
#warn "$\n$req{'arraysizes'}\n";
$req{'arraysizes'}=~s/\s=\s/=/g;
#warn "$\n$req{'arraysizes'}\n";
foreach (split(' ',$req{'arraysizes'})) {
  (my $key,my $value) = split('=',$_,2);
  push(@dims,$key);
  $arrays{$key}=$value;
}
$size=$#dims+1;

$req{'xsize'}=$arrays{@dims[$size-1]};
$req{'ysize'}=$arrays{@dims[$size-2]};
@extra;
for(my $i=0;$i<$size-2;$i++) {
  push(@extra,' ');
  push(@extra,$req{@dims[$i]});
}

# Kashan will give me something like "-180 180", for a
# lat or long range.  The following regexpersions would turn
# that into "-180" and "180".
$req{'xrange'}=~/(.*)\s(.*)/;
$req{'xhi'}=$2;
$req{'xlo'}=$1;

$req{'yrange'}=~/(.*)\s(.*)/;
$req{'yhi'}=$2;
$req{'ylo'}=$1;

# Here I borrow a trick from LAS and use the MD5 modual to
# make a unique tag for the request.  This tag is used in
# all the filenames that will be created by this script.
$md5 = new MD5;
$md5->reset;
$md5->add($ENV{'QUERY_STRING'});
$digest = $md5->digest;
$digest = unpack("H*", $digest);

#$req{'output_file'}="kash/$digest.png";
$req{'output_file'}="kash/$digest.gif";

# Calculate the array bounds.
&convert_ranges();


#Try to figure out the url.  This code is not as clean as it could be, feel free to neaten it up.
if($req{'dodstype'} eq "grid") { 
  $c_url="$req{'url'}?$req{'variable'}.$req{'variable'}\[$req{'ylo'}:$req{'yhi'}\]\[$req{'xlo'}:$req{'xhi'}\]"; 
}
else { $c_url="$req{'url'}?$req{'variable'}\[$req{'ylo'}:$req{'yhi'}\]\[$req{'xlo'}:$req{'xhi'}\]"; }
$d_three=@extra[0];
$d_four=@extra[1];
$c_url.="[$d_three]" if $d_three=~/\d/;
$c_url.="[$d_four]" if $d_four=~/\d/;
&dumpSysData("\n b4 callto display_gif : curl= $c_url \n");

# A simple conditional that makes sure that the gif hasn't
# already been generated.
#if(-e "kash/$digest.png") {
if(-e "kash/$digest.gif") {
#  &display_gif("kash/$digest.png", $c_url);
 &display_gif("kash/$digest.gif", $c_url);
 #exit;
}

#warn "\n$req{'variable'}\n";
#warn "\nFillValue::$req{'FillValue'}\n";
#Debuging

warn "\n\n:$req{'script'}:\n\n";

warn "\n/usr/local/apache/htdocs/dodsview/idlgif $req{'url'} $req{'variable'} $req{'xlo'} $req{'xhi'} $req{'ylo'} $req{'yhi'} $req{'req_lon_low'} $req{'req_lon_high'} $req{'req_lat_low'} $req{'req_lat_high'} $req{'xsize'} $req{'output_file'} $req{'orientation'} $req{'FillValue'} $req{'dodstype'} $lmask $req{'script'} \"$client_dir\"@extra\n";



#Wait untill the program gets excusive control of the lock file.  Once this happens, run idlgif, then give up control of lock.
#If I have done this right, this should fix a bug in which comes up when diffrent user requests are made at the same time.
open(LOCK, ">lock");
while(!(flock LOCK, 2) ) {}


# Generate the gif.  For some reason, it only works if the export and 
# executable are called at the same time.  
# The source for idlgif is in idlgif.cc
system("LD_LIBRARY_PATH=\"/usr/local/rsi/idl/bin/bin.alpha:/usr/local/apache/htdocs/idl\";export LD_LIBRARY_PATH;/usr/local/apache/htdocs/dodsview/idlgif $req{'url'} $req{'variable'} $req{'xlo'} $req{'xhi'} $req{'ylo'} $req{'yhi'} $req{'req_lon_low'} $req{'req_lon_high'} $req{'req_lat_low'} $req{'req_lat_high'} $req{'xsize'} $req{'output_file'} $req{'orientation'} $req{'FillValue'} $req{'dodstype'} $lmask $req{'script'} $client_dir@extra");
close(LOCK);

&addLogEntry();
 
#Display the html.
&display_gif($req{'output_file'},$c_url);

#if(-e "kash/$digest.png") {
if(-e "kash/$digest.gif") {
  if($req{'parentURL'}) { warn "parents\n\n"; &recordURL($req{'parentURL'}); }
  else { &recordURL($req{'url'}); }

close(IPADRS);
}
sub dumpSysData {
open(SYSDATA, ">>sysData.log");
my $line = shift;
print SYSDATA "\n system call data: $line \t";
print SYSDATA "\n";

close(SYSDATA);

}

sub recordURL {
  my ($url)=@_;
  open(HIST,"kash\/hist");
  @urls;
  $i=0;
  foreach(<HIST>) {
    chomp($_);
    @urls[$i]=$_;
    $i=$i+1;
  }
  close(HIST);

  foreach(@urls) {
    exit if $url eq  $_;
  }

  @urls=($url,@urls);

  open(HIST,">kash\/hist");

  foreach(@urls) {
#    warn ">>$_\n";
     print(HIST "$_\n");
  }

  close(HIST);
}

# Makes an html page using the specified HTML template.
sub display_gif {
  my ($gif,$url)=@_;
  print "Content-type: text/html\n\n";
dumpSysData("\n inside display_gif: banner is: $req{'banner'} \n");

  open(HTML,$req{'banner'}) or die "\nBad banner file\n";
  my $html="";
  foreach (<HTML>) {
    $html.=$_;
  }
  $html=~s/dods_gif/$gif/g;
  $html=~s/dods_url/$url/g;
  
  $url=~/(.*?)\?/;
  $simp_url=$1;
  $html=~s/simple_url/$simp_url/g;
	print $html;
}


# Loads easy test values for all of the important variables.
sub make_test {
  
  $req{'xhi'}=71;
  $req{'xlo'}=0;
  $req{'yhi'}=35;
  $req{'xsize'}=36;
  $req{'output_file'}="baz.gif";
  $req{'ylo'}=0;
  $req{'var'}="dsp_band_1";
  $req{'url'}="http://maewest.gso.uri.edu/cgi-bin/nph-dsp/dods/sst_clima_gosta/gosta_01.avg";

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
		#Other half of the % hack in view.cgi
		$value=~s/~~~/%/g;
		$in{$name}.= " " if defined($in{$name});	# concatenate multiple vars
		$in{$name}.= $value;
	}
    return %in;
}
# ===========================================================



# ===========================================================
#  Takes all the lat lon and arraysize info and turns it into array bounds.
sub convert_ranges {
  #warn "\n$req{'lonhigh'}::$req{'lonlow'}\n$req{'xsize'}:\n";

  if($req{'lonlow'}>$req{'xlo'}) { $req{'xhi'}+=360; $req{'xlo'}+=360; }

  $req{'req_lon_high'}=$req{'xhi'};
  $req{'req_lon_low'}=$req{'xlo'};
  $req{'req_lat_high'}=$req{'yhi'};
  $req{'req_lat_low'}=$req{'ylo'};

  my $xstep = ($req{'lonhigh'}-$req{'lonlow'}) / $req{'xsize'};
  my $xhi= int ( $req{'xsize'} - 1 -  ( $req{'lonhigh'} - $req{'xhi'} ) / $xstep );
  my $xlo= int ( ( $req{'xlo'} - $req{'lonlow'} ) / $xstep );
	      
  my $ystep = ($req{'lathigh'}-$req{'latlow'}) / $req{'ysize'};

  my $ylo;
  my $yhi;
  if($req{'orientation'} eq 'human') {

    $yhi= int ( $req{'ysize'} - 1 -  ( $req{'lathigh'} - $req{'yhi'} ) / $ystep );
    $ylo= int ( ( $req{'ylo'} - $req{'latlow'} ) / $ystep );

  }
  else {
    $ylo=int ( ( $req{'lathigh'} - $req{'yhi'} ) / $ystep );
    $yhi=$req{'ysize'} - 1 - int ( ( $req{'ylo'} - $req{'latlow'}  ) / $ystep );
  }
  $req{'xhi'}=$xhi;
  $req{'yhi'}=$yhi;
  $req{'xlo'}=$xlo;
  $req{'ylo'}=$ylo;

}
sub addLogEntry{
$requestor =  $ENV{'REMOTE_ADDR'};

# ===========================================================
#  send output of requesting IP and requested URL to log file
#  each time the right-hand item is selected, the file is updated
#  one line for each requestor/url pair.
$year = localtime->year()+1900;
$month = localtime->mon();
$day = localtime->mday();
$hour = localtime->hour();
$minute = localtime->min();
$seconds = localtime->sec();

$date = "time ".$hour.":".$minute.":".$seconds." date ".$month."-".$day."-".$year;
$orient= $req{'orientation'};
print IPADRS "\n$requestor  for $date .. $req{'url'} ..orientation= $orient ... variable= $req{'variable'}\n";


}

#Not used anymore, kept around anyways in case I ever need to steal the code.
sub idlgif_is_running {
  my $foo = `ps -xa | grep idlgif`;
  foreach (split('\n',$foo)) {
    if( !/grep/ ) { return 1; }
  }
  return 0;
}
