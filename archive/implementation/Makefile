#
# Make postscript and html documentation from the latex sources
#
# $Id$

TEX=latex

# These don't work because the WWW and ftp archive are now on hollywood
FTPARCHIVE=/usr/local/spool/ftp/pub/DODS
HTMLARCHIVE=/usr/local/spool/http/DODS/doc/design

PSDOCS=toolkits.ps

# .html targets are phony (but don't need to be declared .PHONY). latex2html
# puts each hyperized doc in its own directory.

HTMLDOCS=toolkits.html
HTMLDIRS=toolkits

ps: $(PSDOCS)

html: $(HTMLDOCS)

%.ps : %.dvi
	dvips -o $@ $?
	-rm *.log *.dvi

%.html : %.tex
	latex2html $? 

clean:
	-rm -f *.log *.dvi *.aux *.bbl *.blg *.toc *~ core
	-rm -f `find . -name '*~'`

htmlclean:
	-rm -rf $(HTMLDIRS)

psclean:
	-rm *.ps

tar: ps html
	tar --create --gzip --file implementation-html.tar.gz $(HTMLDIRS)
	tar --create --gzip --file implementation-ps.tar.gz $(PSDOCS)

# Bogus; archives are now on hollywood. Use symbolic links for the local
# httpd. 
install:
	cp $(PSDOCS) $(FTPARCHIVE)
	cp -r $(HTMLDIRS) $(HTMLARCHIVE)

$(HTMLDIRS): html