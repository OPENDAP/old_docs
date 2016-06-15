#
# Make postscript and html documentation from the latex sources
#
# $Id$

TEX=latex

# These don't work because the WWW and ftp archive are now on hollywood
FTPARCHIVE=/usr/local/spool/ftp/pub/DODS
HTMLARCHIVE=/usr/local/spool/http/DODS/doc/design

PSDOCS=urls.ps data-delivery-design.ps data-delivery-arch.ps api.ps

# .html targets are phony (but don't need to be declared .PHONY). latex2html
# puts each hyperized doc in its own directory.

HTMLDOCS=urls.html data-delivery-design.html data-delivery-arch.html api.html
HTMLDIRS=urls data-delivery-design data-delivery-arch api

HTML_OPTIONS=-show_section_numbers

ps: $(PSDOCS)

html: $(HTMLDOCS)

api.dvi: api.tex
	cd api-figs ; $(MAKE)
	latex $?
	latex $?
	bibtex $*
	latex $?
	latex $?

data-delivery.dvi: data-delivery.tex
	latex $?
	latex $?

data-delivery-arch.dvi: data-delivery-arch.tex
	cd arch-figs ; $(MAKE)
	latex $?
	latex $?

data-delivery-design.dvi: data-delivery-design.tex
	cd ddd-figs ; $(MAKE)
	latex $?
	latex $?

urls.dvi: urls.tex
	latex $?
	latex $?

%.dvi : %.tex
	latex $?
	latex $?
	bibtex $*
	latex $?
	latex $?

%.ps : %.dvi
	dvips -o $@ $?

%.html : %.tex %.dvi
	if [ ! -f $*.aux ]; then latex $?; latex $?; fi
	latex2html $(HTML_OPTIONS) $*.tex

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

