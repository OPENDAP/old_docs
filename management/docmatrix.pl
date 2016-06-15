#!/usr/local/bin/perl
use strict;

# This program reads documentation planning data from a source file,
# and converts it into an HTML document.

# $Id$

my %doc_records = ("Default" => "");
my $record_in_play;
my $divider = "~~";
my($last_entry); # for dealing with continuation lines
my @notes;

open(INPFILE, @ARGV[0]) or die "can't open file: $!\n";
while (<INPFILE>) {

    if (/^\#/) { # found a comment, discard it.
    } elsif (/^\s*$/) { # found an empty line, discard it.
    } elsif (/^\s*Document:\s*/) {
	s/^\s*Document:\s*//;
	$record_in_play = $_;
	chomp $record_in_play;
	if (not (/Default/)) {
	    $doc_records{$record_in_play} = $doc_records{"Default"};
	}
    } elsif (/^\s+/) {  # continuation
	my %record_hash = split /$divider/, $doc_records{$record_in_play};
	my ($value) = m/^\s+(.*)$/gix;
	if ($value eq "") {$value = " ";}
	$record_hash{lc($last_entry)} = $record_hash{lc($last_entry)} . $value;
	$doc_records{$record_in_play} = join $divider, %record_hash;
    } else {
	my %record_hash = split /$divider/, $doc_records{$record_in_play};
	my ($entry,$value) = m/^\s*([A-z0-9 ]+)\s*:\s*(.*)/gix;
	if ($value eq "") {$value = " ";}
	$last_entry = $entry;
	$record_hash{lc($entry)} = $value;
	$doc_records{$record_in_play} = join $divider, %record_hash;
    } 
}

close(INPFILE);

&print_html_head;

my($doc, $key);
foreach $doc (sort keys %doc_records) {
    if ($doc ne "Default") {
	print '<tr><td align="left"><b>', $doc, "</td>\n";
	my %record_hash = split /$divider/, $doc_records{$doc};
	print '<td align="left">', $record_hash{version}, "</td>\n";
	print '<td align="left">', $record_hash{software}, "</td>\n";
	print '<td align="left">', $record_hash{lead}, "</td>\n";
	&print_progress_cell($record_hash{concept});
	&print_progress_cell($record_hash{design});
	&print_progress_cell($record_hash{implementation});
	&print_progress_cell($record_hash{distribution});
	@notes = &print_note_cell($record_hash{notes}, @notes);
	@notes = &print_note_cell($record_hash{dependencies}, @notes);
	print '<td align="left">', $record_hash{date}, "</td>\n";
	print '<td align="left">', $record_hash{priority}, "</td>\n";
	print "</tr>\n";
    }
}

if ($#notes >= 0) { &print_notes(@notes); }

&print_html_tail;

sub print_notes {
    my(@notes) = @_;
    my($i) = 0;
    my($note);
    
    foreach $note (@notes) {
	print '<tr><td colspan="12" align="left">';
	print '<a name="Note-', ++$i, '">';
	print "Note ", $i, ": ", $note, "</a></td></tr>\n";
    }
}

sub print_note_cell {
    my($cell_string, @notes) = @_;

    print '<td align="left">';
    if (length $cell_string > 35) {
	push @notes, $cell_string;
	print '<a href="#Note-', 1+$#notes, '">Note ', 1+ $#notes, "</a>";
    } else {
	print $cell_string;
    }
    print "</td>\n";
    return @notes;
}


sub print_progress_cell {
    my($cell_string) = @_;

    $cell_string =~ s/\s*$//;
    $cell_string =~ s/^\s*//;

    if ((lc($cell_string) eq "to do") or ($cell_string == 1)) {
	print '<td align="left" bgcolor="#ff0000">', $cell_string, "</td>\n";
    } elsif ((lc($cell_string) eq "in progress") or ($cell_string == 2)) {
	print '<td align="left" bgcolor="#ffff00">', $cell_string, "</td>\n";
    } elsif ((lc($cell_string) eq "done") or ($cell_string == 3)) {
	print '<td align="left" bgcolor="#00ff00">', $cell_string, "</td>\n";
    } elsif ((lc($cell_string) eq "nor") or ($cell_string == 0)) {
	print '<td align="left" bgcolor="#cc88ff">', $cell_string, "</td>\n";
    }
}


sub print_html_head {

    print <<ENDOFHEAD;

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head>
<title>DODS Documentation Status Matrix</title>
</head><body>

<h1>Documentation</h1>
<p><a HREF="http://www.unidata.ucar.edu/packages/dods/home/docs.shtml">Released documentation on the official DODS site</a>
<p><a HREF="http://top.gso.uri.edu/dods.html">Documentation on the unofficial top DODS site</a> 
<p>Stages refer to completion of next revision (i.e. up-to-date as of
DODS core release 3.2). Where marked n/a, there is not a new revision
scheduled.

<p>
<table border="1"><tr>
<th colspan="1" align="LEFT"><b>Document</b></th>
<th colspan="1" align="LEFT"><b>Version</b></th>
<th colspan="1" align="LEFT"><b>Software/Version</b></th>
<th colspan="1" align="LEFT"><b>Lead</b></th>
<th colspan="1" align="LEFT"><b>Concept</b></th>
<th colspan="1" align="LEFT"><b>Design</b></th>
<th colspan="1" align="LEFT"><b>Implement</b></th>
<th colspan="1" align="LEFT"><b>Distribute</b></th>
<th colspan="1" align="LEFT"><b>Notes&nbsp;&nbsp;</b></th>
<th colspan="1" align="LEFT"><b>Dependencies</b></th>
<th colspan="1" align="LEFT" width="400"><b>Entry&nbsp;Date</b></th>
<th colspan="1" align="LEFT"><b>Priority</b></th></tr>

ENDOFHEAD
}

sub print_html_tail {

    print <<ENDOFTAIL;
</table>

<p>STATUS KEY: 
<table><tr><td colspan="1" align="LEFT">
 </td></tr>
<tr><td colspan="1" align="LEFT">
Status key:
</td><td bgcolor="#ff0000" colspan="1" align="LEFT">TO DO
</td><td bgcolor="#ffff00" colspan="1" align="LEFT">IN PROGRESS
</td><td bgcolor="#00ff00" colspan="1" align="LEFT">DONE </td>
</td><td bgcolor="#cc88ff" colspan="1" align="LEFT">NOT ON RADAR </td></tr>
</table>

<HR >
</body></html>
ENDOFTAIL
}
