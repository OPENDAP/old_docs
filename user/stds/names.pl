#!/usr/bin/perl
#
# Reads the name.dat file, and prints a LaTeX-sort of table for it in
# a file called "appa.tex".  This is to be part of the stds.tex book,
# so it can be simply included in that file.  The function is meant to
# be invoked from the Makefile when making the stds book.
#
# $Id$
#
open(NAMES, "@ARGV[0]") or die "Can't open @ARGV[0]: $!";
open(APPA, ">@ARGV[1]") or die "Can't open @ARGV[1] for writing: $!";

&print_head(APPA);
while (<NAMES>) {
    s/\#.*//g;             # delete comments
    chop;                  # removes \n
    if ($_) {
	/,[ ]*/;           # find first comma
	$name = $`;        # name is what precedes first comma
	s/$name$&//;       # remove name and comma
	/,[ ]*/;           # find second comma
	$description = $`; # description precedes comma
	s/$description$&//;# remove description and comma
	/,[ ]*/;           # find third comma
	$units = $`;       # units precedes that
	$gcmd = $';        # gcmd is everything after, if anything
	$, = "";
	$name = &fix_string($name);
	$description = &fix_string($description);
	print APPA "\\lit{", $name, "}\\indc{", $name;
	print APPA "\@\\lit{", $name, "}} & ", $description;
	print APPA "\\indc{", $description;
	print APPA "} & ", &fix_string($units);
	if ($gcmd) {
	    print APPA " \\\\ \n";
	    print APPA " & \\multicolumn{2}{p{3.75in}|}{{\\footnotesize ";
	    print APPA &fix_string($gcmd), "}}";
	}
        print APPA "\\\\ \\hline \n";
    }
}
&print_tail(APPA);
close(APPA);

sub fix_string {
    my($str) = @_;
    $str =~ s/_/\\_/g;             # protect underscores
    $str =~ s/>/\$>\$/g;
    return $str;
}

sub print_head {
    local($fp)=@_;
    print $fp <<'END';
\chapter{DODS Names}
\label{std-names}

Here is a list of the currently used DODS variable names.   The most
up-to-date list is available at
\xlink{\lit{http://unidata.ucar.edu/packages/dods/names.dat}}
{http://unidata.ucar.edu/packages/dods/names.dat} 
Where one exists, the GCMD parameter name follows the DODS variable
name. 

\begin{longtable}{|p{1.25in}p{2in}p{1.75in}|}
\caption{Supported DODS Names\label{stds,name-table}} 
\\ \hline
\textbf{Name} & \textbf{Description} & \textbf{Units} \\ 
 & \multicolumn{2}{p{3.75in}|}{GCMD Parameter Name (if any)} \\ \hline
\endfirsthead
\caption[]{Supported DODS Names} 
\\ \hline
\textbf{Name} & \textbf{Description} & \textbf{Units} \\ 
 & \multicolumn{2}{p{3.75in}|}{GCMD Parameter Name (if any)} \\ \hline
\endhead
\hline
\endfoot
END
}

sub print_tail {
    local($fp)=@_;
    print $fp <<'END';
\end{longtable}
END
}


