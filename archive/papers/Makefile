#
# Make postscript and html documentation from the latex sources
#
# $Id$

TEX=latex

PSDOCS=

# .html targets are phony (but don't need to be declared .PHONY). latex2html
# puts each hyperized doc in its own directory.

HTMLDOCS=
HTMLDIRS=

ps: $(PSDOCS)

html: $(HTMLDOCS)

%.dvi : %.tex
	latex $?
	latex $?
	bibtex $*.aux
	latex $?

%.ps : %.dvi
	dvips -o $@ $?
	-rm *.log *.dvi

%.html : %.tex
	if [ ! -f $*.aux ]; then latex $?; latex $?; fi
	latex2html $? 

clean:
	-rm -f *.log *.dvi *.aux *.bbl *.blg *.toc *~ core
	-rm -f `find . -name '*~'`

htmlclean:
	-rm -rf $(HTMLDIRS)

psclean:
	-rm *.ps

tar: ps html
	tar --create --gzip --file design-docs-html.tar.gz $(HTMLDIRS)
	tar --create --gzip --file design-docs-ps.tar.gz $(PSDOCS)

# Bogus; archives are now on hollywood. Use symbolic links for the local
# httpd. 
install:
	cp $(PSDOCS) $(FTPARCHIVE)
	cp -r $(HTMLDIRS) $(HTMLARCHIVE)

$(HTMLDIRS): html