#!/usr/local/bin/perl
#
# $Id$
#
# SYNOPSIS
#
#   giftext.pl FILE TEXT
#
# This function creates a little gif image called FILE with text from
# the command line, TEXT.  It is meant for use by the dods-book.hlx
# (hyperlatex) package.  The first part of the script is about
# figuring out the line breaks, so that the lines come out roughly 
# equal in length.  We use the Text::Format package, which actually
# formats the string to the left, but the Annotate function shifts 
# the formatted text back to the center.
#
# Currently, there is no control over the features of the gif image
# produced.  That is, it always comes out in blue bold helvetica, with
# a white background.  This also should eventually change.
#
# Note: ImageMagick uses the X server to render X fonts, such as
#     "-adobe-helvetice-*-*...".  This means that this can only work
#     when the process that executes the program has access to a
#     running X server, i.e. jobs submitted by cron, at, or via
#     telnet, will not work. Changing this to TrueType fonts should
#     allow this kind of access, or diddling with the X configuration,
#     or installing something called vxfd, a virtual X load.
#
# 10/1/2000 Tom Sgouros

use Image::Magick;
use Text::Format;

my $string, $text;

# print "Opening $ARGV[0] with text-$ARGV[1]-\n";

$text = new Text::Format;
$text->rightFill(0);
$text->columns(20);
$text->firstIndent(0);

$string = $text->format($ARGV[1]);
# print "-", $string, "-\n";

my $font='-adobe-helvetica-bold-r-*-*-15-*-*-*-*-*-*-*';

$image=Image::Magick->new(size=>'300x120');
$image->Read('xc:white');
$image->Annotate(font=>$font,
                 pointsize=>15, 
		 fill=> '#0044ff',
                 gravity=>'NorthWest',
                 text=>$string);
my ($cw, $ch, $ca, $cd, $width, $height, $mh) = 
    $image->QueryMultilineFontMetrics(font=>$font,
                 pointsize=>15, 
		 fill=> '#00daff',
                 gravity=>'NorthWest',
                 text=>$string);
$image->Crop(width=>$width, height=>$height);#geometry=>'0x0');
$image->Border(geometry=>'15x15',color=>'white');
$image->Write($ARGV[0]);

# $Log: giftext.pl,v $
# Revision 1.3  2004/12/09 18:49:17  tomfool
# updated to new vsn of perlmagick
#
# Revision 1.2  2001/01/08 15:32:49  tom
# changed to use Text::Format CPAN module
#
# Revision 1.1  2000/10/12 18:13:05  tom
# added to repository
#
