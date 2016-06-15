#!/usr/local/bin/perl
#
# ----------------------------------------------
# Prints out all Variables and attributes
# ----------------------------------------------
# Kashan A. Shaikh
# 8-2-2000
# -------------------------------------
# usage: perl getDatasetInfo.pl url
# -------------------------------------

use LWP::Simple;


@possible_lat = ("y", "lat");
@possible_lon = ("x", "lon");

$url = shift || die "usage: perl $0 url\n";
$cat2=shift;

&determineConvention();
&getDDS() ;
&getDDS() if $cat2!=2;
&pete_array_case() if $cat2==2;

exit;

sub pete_array_case {
  $dds = get("$url.dds");
  if($dds=~/.*\[(.*?)\]\[(.*?)\]/) {
    print "\tdimensions: 2\tdimension_info: $1 $2";
  }
}


# -----------------------------------------------------
# Determine if this dataset follows a named convention
# -----------------------------------------------------
sub determineConvention {
	$das = get("$url.das");
	lc($das) =~ /conventions "(.*?)"/;
	$convention = $1;
}
# -----------------------------------------------------


# -----------------------------------------------------------------
# Get the variables, array sizes, and lat/lon ranges from the .dds
# -----------------------------------------------------------------
sub getDDS {
$dds = get("$url.dds");
my $grid_found = 0;
my $array_found = 0;
foreach ( split('\n', $dds) ) {
	$line = $_;
	if ($grid_found) {
		$is_gridded=1;
		if ($array_found) {
			/\w+\s+(\w+)\[/;
			print "varname: $1";
			&getDASInfo($1);
			$temp = $1;
			my @dimensions;
			my $num_dimensions = 0;
			while ( $line =~ /($temp\[(\w+)\s*=\s*(\w+)\])/ ) {
				$temp = $1;
				my $name = $2;
				my $size = $3;
			my $lastindex = $size - 1;
			push (@dimensions, "$name=$size");
			$num_dimensions ++;
			foreach (@possible_lat) {
				if ( lc($name) =~ /$_/ ) {	
		 	 		my $array = get("$url.asc?$name");
			 		$array =~ s/^.*\n//;
			 		$array =~ /^([^,]+,)([^,]+),([^,]+)(, ([^,]+),)?/;
			 		my $lat_first = $2;
			 		my $step = 0;
			 		if ($3) { $step = abs($3 - $2); }
			 		$array =~ /.+, (.+)/;
			 		my $lat_last = $1;
			 		# orientation of the data
			 		#    machine = axes cross at the top left corner of the screen
			 		#    human = axes cross at the bottom left corner
			 		if ($lat_first < $lat_last) { print "\torientation: human"; }
			 		else { print "\torientation: machine"; }
			 		
			 		#my $lat_low = $lat_last - $step / 2;
			 		my $lat_low = &getMin($lat_first, $lat_last) - $step / 2;
			 		#my $lat_high = $lat_first + $step / 2;
			 		my $lat_high = &getMax($lat_first, $lat_last) + $step / 2;
			 		print "\tlat_low: $lat_low\tlat_high: $lat_high";
				 	}
			} #end poss_lat
				foreach (@possible_lon) {
					if ( lc($name) =~ /$_/ ) {	
				 	my $array = get("$url.asc?$name");
				 	$array =~ s/^.*\n//;
				 	$array =~ /^([^,]+,)([^,]+),([^,]+)(, ([^,]+),)?/;
				 	my $lon_first = $2;
			 		my $step = 0;
			 		if ($3) { $step = abs($3 - $2); }
			 		$array =~ /.+, (.+)/;
			 		my $lon_last = $1;

			 		#my $lon_low = $lon_first - $step / 2;
			 		my $lon_low = &getMin($lon_first, $lon_last) - $step / 2;
			 		#my $lon_high = $lon_last + $step / 2;
			 		my $lon_high = &getMax($lon_first, $lon_last) + $step / 2;
			 		print "\tlon_low: $lon_low\tlon_high: $lon_high";
					}
				}
				$temp =~ s/\[/\\\[/g;
				$temp =~ s/\]/\\\]/g;
			}
			print "\tdimensions: $num_dimensions";
			print "\tdimension_info: @dimensions\ttype: grid";
			print "\n";
			$grid_found = 0;
			$array_found = 0;
		}
		if (lc($_) =~ /array/) { $array_found = 1; }
	}
	
	if (lc($_) =~ /grid/) { $grid_found = 1; }
}
}
# -----------------------------------------------------------------


# -----------------------------------------
# Return the least of two specified values
# -----------------------------------------
sub getMinLon {
# this is a misnomer
# this should be returning the minimum lon 

# we need to check for the case where the
# start and end are on opposite sides
# of the dateline/prime meridian
# when on opposite sides the muliplication
# of the two will be positive
# if one of the two is exactly zero either
# ??????
	my $start = shift;
	my $end = shift;
	my $sign = $start*$end;
	if ( $sign > 0 ) {
	# test  $start &  $end
	if ( $start < $end ) { return $start;}
	}
	else {
	if ( $end < $start ) { return $start; }
	else {return $end;}
	}
	
}
# -----------------------------------------


sub getMin{
        my $start = shift;
	my $end = shift;
	if ( $start < $end ) { return $start;}
        else { return $end;}


}

# -------------------------------------------
# Return the greater of two specified values
# -------------------------------------------
sub getMaxLon {
# we need to check for the case where the
# start and end are on opposite sides
# of the dateline/prime meridian
# when on opposite sides the muliplication
# of the two will be positive
# if one of the two is exactly zero either
# ??????
# 
# this assumes that we're living in a +180 to -180 world
# where PM to DL is +ve and DL to PM is  -ve



	my $start = shift;
	my $end = shift;
	my $sign = $start*$end;
	if ( $sign > 0 ) {
	# test	$start &  $end
	if ( $start < $end ) { return $end;}
	}
        else {
	if ( $end < $start ) { return $end; }
	else {return $end;}
	}

	return $end;

}
# ---------------------------------------------

# -------------------------------------------
# Return the greater of two specified values
# -------------------------------------------
sub getMax {

	 my $start = shift;
	 my $end = shift;
	 if ( $start < $end ) { return $end;}
         else { return $start; }


}
# ---------------------------------------------




# -------------------------------
# Get info from the .das
# -------------------------------
sub getDASInfo {
my $varname = shift;
my $fillvalue = 0;
my $longname = 0;
my $found = 0;
foreach ( split('\n', $das) ) {
	if ($fillvalue && $longname) { return; }
	if ($found) {
		if ( $_ =~ /FillValue/ ) {
			/FillValue (.*?);/;
			print "\tFillValue: $1";
			$fillvalue = 1;
		}
		if ($convention eq "coards") {
			if ( $_ =~ /var_desc/ ) {
				/var_desc *"(.*)"*/;
				print "\tlong_name: $1";
			}
			$longname = 1;
		}
		elsif ( lc($_) =~ /long_name|name/ ) {
			/"(.*?)"/;
			print "\tlong_name: $1";
			$longname = 1;
		}
	}
	if (/$varname/) { $found = 1; }
}
}
# --------------------------------
