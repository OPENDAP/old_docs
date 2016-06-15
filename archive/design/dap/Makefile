#
# New standard DODS documentation Makefile (5/2001) ts.

# $Id$

# $Log: Makefile,v $
# Revision 1.9  2003/07/18 16:15:15  tom
# fixed html file names
#
# Revision 1.8  2003/06/10 16:13:53  tom
# incorporated suggestions from March meeting
#
# Revision 1.7  2003/05/23 22:08:30  tom
# makefile repairs, bibliography
#
# Revision 1.6  2003/05/23 21:50:52  tom
# progress made
#
# Revision 1.5  2003/05/23 19:27:42  tom
# new files, rearranging DAP spec into separate documents
#
# Revision 1.4  2003/01/14 19:53:05  jimg
# Added stuff for the dap_overview. This may or may not actually work...
#
# Revision 1.3  2001/10/10 16:52:15  jimg
# *** empty log message ***
#
# Revision 1.5  2001/05/14 14:51:08  tom
# added redirect to .html processing
#
# Revision 1.4  2001/05/11 21:18:42  tom
# oops.  forgot a couple of entries to the .PRECIOUS directive
#
# Revision 1.3  2001/05/11 21:04:12  tom
# fixed what errors I found
#
# Revision 1.2  2001/05/10 16:19:54  tom
# fixed a few things
#

HOME_DIR=.
TEX_AUX_FILES=*.aux *.blg *.ent *.ilg *.log *.bbl *.ind \
              *.lot *.blg *.idx *.lof *.toc *.all *.cb
DODS_DOC=~/DODS-doc
# Customize the following for each new document.
RFC_DEPENDS=dap_rfc.tex

COMMON_DEPENDS=dap_boiler.tex
OVR_DEPENDS=dap_overview.tex $(COMMON_DEPENDS)
OBJ_DEPENDS=dap_objects.tex $(COMMON_DEPENDS)
SERV_DEPENDS=dap_services.tex $(COMMON_DEPENDS)
HTTP_DEPENDS=dap_http.tex $(COMMON_DEPENDS)
ASC_DEPENDS=dap_ascii.tex $(COMMON_DEPENDS)
HTML_DEPENDS=dap_html.tex $(COMMON_DEPENDS)

# Edit the following to point to the directory where the hyperlatex
# output will go.  Do *NOT* use this file if the hyperlatex output
# doesn't get put in a subdirectory. (see "realclean" and ".html" for why).
HTML_DIR=html
HTML_RFC_DIR=htmlrfc

#.PHONY: %.all dap_objects.all dap_services.all dap_http.all \
#        dap_html.all dap_ascii.all

all: dap_overview.all dap_objects.all dap_services.all dap_http.all dap_html.all dap_ascii.all

dap_overview.all: dap_overview.ps dap_overview.pdf dap_overview.html

dap_objects.all: dap_objects.ps dap_objects.pdf dap_objects.html

dap_services.all: dap_services.ps dap_services.pdf dap_services.html

dap_http.all: dap_http.ps dap_http.pdf dap_http.html

dap_ascii.all: dap_ascii.ps dap_ascii.pdf dap_ascii.html

dap_html.all: dap_html.ps dap_html.pdf dap_html.html

# %.all: %.ps %.html %.pdf 
#	echo "All dependent files are generated." > $@

# The dvi file is in the following dependency list because some
# hyperlatex steps occasionally read the LaTeX byproduct files, like
# for the bibliography.  Also, LaTeX catches errors that hyperlatex
# does not.  If there's no bibliography, you can delete that
# dependency.  The html file in the current directory will contain a
# redirect to the sub-directory page.  Note that this will have the
# same name as the product of the hyperlatex run.  This file will not
# be included in the tar file products.
dap_rfc.html: $(RFC_DEPENDS) dap_rfc.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_RFC_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_RFC_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

dap_overview.html: $(OVR_DEPENDS) dap_overview.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/dap.html"></head><body>wrong page.</body></html>' >$@

dap_objects.html: $(OBJ_DEPENDS) dap_objects.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/dapo.html"></head><body>wrong page.</body></html>' >$@

dap_services.html: $(SERV_DEPENDS) dap_services.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/daps.html"></head><body>wrong page.</body></html>' >$@

dap_http.html: $(HTTP_DEPENDS) dap_http.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/daph.html"></head><body>wrong page.</body></html>' >$@

dap_ascii.html: $(ASC_DEPENDS) dap_ascii.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/dapa.html"></head><body>wrong page.</body></html>' >$@

dap_html.html: $(HTML_DEPENDS) dap_html.dvi
	hyperlatex $<
	@echo '$@ will contain a redirect to $(HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(HTML_DIR)/dapm.html"></head><body>wrong page.</body></html>' >$@

# For a simple directory, containing a single document with no index
# or bibliography, you won't have to change anything else.  Otherwise,
# edit where noted.

# Stop GNU make from overzealous deletion of intermediate files.  We
# take care of these explicitly, with the clean-up rules.
.PRECIOUS: %.ps %.dvi %.pdf %.aux %.bbl %.ind %.tar \
	%.all %.ps.gz %.tar.gz

dap_overview.aux: $(OVR_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

dap_objects.aux: $(OBJ_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

dap_services.aux: $(SERV_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

dap_http.aux: $(HTTP_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

dap_html.aux: $(HTML_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

dap_ascii.aux: $(ASC_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

%.aux: %.tex
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

# If there is a bibliography, add %.bbl to the following dependency
# list.  If there is an index, add %.ind.  If there is neither, 
# use this short version instead:
# %.dvi: %.aux
# 	@echo 'no need to run LaTeX again'

%.dvi: %.aux %.bbl
	latex $*.tex
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

%.ind: %.aux
	makeindex -s $(DODS_DOC)/latex/dods-book.ist $*.idx

%.bbl:  %.aux
	bibtex $*

%.ps: %.dvi
	dvips -o $@ $<

%.ps.gz: %.ps
	gzip -f $*.ps

%.pdf: %.ps
	ps2pdf $< $@

dap.tar:  $(HTML_DAP_DEPENDS)
	cp html/dap.html html/index.html
	tar cf $@ $(HTML_DIR)

%.tar.gz: %.tar %.ps.gz %.pdf
	gzip -f $*.tar

%.eps:%.dia
	dia --output=$@ @<

#
# Cleaning up the joint.
#
clean:
	-rm -f *.dvi *~
	-rm -f $(TEX_AUX_FILES)

# If there's more than one HTML directory, this needs to be changed.
realclean: clean
	-rm *.html
	-rm -rf $(HTML_DIR)

distclean: realclean
	-rm *.gz
	-rm *.pdf
	-rm *.ps
