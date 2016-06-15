#
# Makefile for various DODS guides. The books described here are as
# follows: 
#
#    pguide.tex - The DODS Programmer's Guide
#    refman.tex  -  The DODS C++ API Reference (no more 04/21/04 jhrg)
#    writing_server.tex - A tutorial on writing a DODS server.
#    writing_client.tex - A tutorial on writing a DODS client.

# I've changed this somewhat for the opendap pages. I stopped making hte tar
# files and the pdf files (we should probably use pdflatex and drop the ps
# files, but that's for later...). I changed the way the reference manual is
# built, although it will likely only work for me... You'll need to have
# DODS-doc, DODS-3.4 (or similar) and Java-DODS all checked out in the same
# directory (like your home directory).

# $Id$

JAVA_DODS=../../Java-DODS
DODS_ROOT=../../DODS-3.4
DODS_DOC=$../DODS-doc
API_DIR=.
TEX_AUX_FILES=*.aux *.blg *.ent *.ilg *.log *.bbl *.ind \
              *.lot *.blg *.idx *.lof *.toc *.all

# PGUIDE definitions
PGUIDE_DIR=$(API_DIR)/pguide
FIGS_DIR=$(PGUIDE_DIR)/figs
PGUIDE_DEPENDS=pguide.tex $(PGUIDE_DIR)/preface.tex  $(PGUIDE_DIR)/ch01.tex \
	$(PGUIDE_DIR)/ch02.tex $(PGUIDE_DIR)/ch03.tex \
	$(PGUIDE_DIR)/ch04.tex  $(PGUIDE_DIR)/ch05.tex \
	$(PGUIDE_DIR)/ch06.tex  $(PGUIDE_DIR)/ch07.tex \
	$(PGUIDE_DIR)/pguide-def.tex
PGUIDE_HTML_DIR=pguide-html

# REFMAN definitions
#
# Trunk or branch, et cetera. I'll set this up for my DODS-3.4 code, but it
# will have to be hacked for each person who builds the docs.
PREF_HTML=pref-html
DOXYCFG=doxy.conf

# Writing_server definitions
SERVER_HTML_DIR=ws-html
SERVER_DEPENDS= writing_server.tex

# Writing_client definitions
CLIENT_HTML_DIR=wc-html
CLIENT_DIR=wc-html
CLIENT_AUX_FILES=$(CLIENT_DIR)/Geturl.java.html $(CLIENT_DIR)/MatlabFactory.java.html $(CLIENT_DIR)/geturl.cc.html   
CLIENT_DEPENDS= writing_client.tex $(CLIENT_AUX_FILES)

.PHONY: all ps pdf tar

all: ps html # pdf tar 
ps: pguide.ps.gz writing_server.ps.gz writing_client.ps.gz

pdf: pguide.pdf writing_server.pdf writing_client.pdf

html: writing_server.html writing_client.html pguide.html pref.html \
	javaDocs.html

# tar: pref.tar.gz pguide.tar.gz writing_server.tar.gz writing_client.tar.gz


writing_server.aux: $(SERVER_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

writing_client.aux: $(CLIENT_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

pguide.aux: $(PGUIDE_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

pref.html:
	cd $(DODS_ROOT)/src/dap && doxygen $(DOXYCFG)
	cp $(DODS_ROOT)/src/dap/docs/html $(PREF_HTML)
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(PGUIDE_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

javaDocs.html:
	cd $(JAVA_DODS) && make doc
	cp -r $(JAVA_DODS)/doc javaDocs
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=javaDocs/index.html"></head><body>wrong page.</body></html>' >$@

# I don't think we should build the latex, ps and pdf of the reference
# manual. The HTML version is about as good as it gets... 04/21/04 jhrg
# refman.ps refman.pdf: pref.html
# 	$(MAKE) $@ -C $(PREF_LATEX_DIR)
# 	mv $(PREF_LATEX_DIR)/$@ $(API_DIR)

# pref.ps: refman.ps
# 	mv $< $@

# pref.pdf: refman.pdf
# 	mv $< $@

# pref.tar: pref.html
# 	tar cf $@ $(PREF_HTML)

pguide.html: $(PGUIDE_DEPENDS)
	hyperlatex $<
	cp $(PGUIDE_HTML_DIR)/$@ $(PGUIDE_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(PGUIDE_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(PGUIDE_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

writing_server.html: $(SERVER_DEPENDS)
	hyperlatex $<
	cp $(SERVER_HTML_DIR)/$@ $(SERVER_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(SERVER_HTML_DIR)'
	cho '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(SERVER_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

writing_client.html: $(CLIENT_DEPENDS) 
	hyperlatex $<
	cp $(CLIENT_HTML_DIR)/$@ $(CLIENT_HTML_DIR)/index.html
	#for file in $(CLIENT_AUX_FILES); do cp $$file $(CLIENT_HTML_DIR); done
	@echo '$@ will contain a redirect to $(CLIENT_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(CLIENT_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

# writing_server.tar:  writing_server.html 
# 	tar cf $@ $(SERVER_HTML_DIR)

# writing_client.tar: writing_client.html 
# 	tar cf $@ $(CLIENT_HTML_DIR)

# pguide.tar: pguide.html 
# 	tar cf $@ $(PGUIDE_HTML_DIR)

# For a simple directory, containing a single document with no index
# or bibliography, you won't have to change anything else.  Otherwise,
# edit where noted.

# Stop GNU make from overzealous deletion of intermediate files.  We
# take care of these explicitly, with the clean-up rules.
.PRECIOUS: %.ps %.dvi %.pdf %.aux %.bbl %.ind %.tar \
	%.all %.ps.gz %.tar.gz

%.dvi: %.tex

pguide.dvi: pguide.aux pguide.ind

# If there is a bibliography, add %.bbl to the following dependency
# list.  If there is an index, add %.ind.  If there is neither, 
# use this short version instead:
%.dvi: %.aux 
	@echo 'no need to run LaTeX again'

#%.dvi: %.aux %.bbl %.ind
#	latex $*.tex
#	@while ( grep "Rerun to get cross-references" \
#	                $(subst .tex,.log,$<) >/dev/null ); do \
#	      echo '** Re-running LaTeX **'; \
#	      latex $<; \
#	done

%.ind: %.aux
	makeindex -s ../latex/dods-book.ist $*.idx

%.bbl:  %.aux
	bibtex $*

%.ps: %.dvi
	dvips -o $@ $<

%.ps.gz: %.ps
	gzip -f $*.ps

%.pdf: %.ps
	ps2pdf $< $@

%.all: %.ps %.html %.pdf 
	echo "All dependent files are generated." > $@

%.tar:  %.all
	tar cf $@ $*

%.tar.gz: %.tar %.pdf %.ps.gz 
	gzip -f $*.tar

# The %.aux and the %.html rules below are for default simple files.
# You probably need the more precise version, with an explicit list of
# dependencies.  Edit them and put them in above.
%.aux: %.tex
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

# The dvi file is in the following dependency list because some
# hyperlatex steps occasionally read the LaTeX byproduct files, like
# for the bibliography.  Also, LaTeX catches errors that hyperlatex
# does not.  If there's no bibliography, you can delete that
# dependency.  The html file in the current directory will contain a
# redirect to the sub-directory page.  Note that this will have the
# same name as the product of the hyperlatex run.  This file will not
# be included in the tar file products.
#
# This definition assumes that the html directory for `nv.tex' is `nv'. 
# This may not be true, in which case an explicit define is important.
%.html: %.tex %.dvi
	hyperlatex $<
	cp $*/$@ $*/index.html
	@echo '$@ will contain a redirect to $*'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$*/index.html"></head><body>wrong page.</body></html>' >$@

#
# Cleaning up the joint.
#

# Get rid of intermediate files
clean:
	-rm -f *.dvi *~
	-rm -f $(TEX_AUX_FILES)

# The html is in tar files, so they are possibly intermediate files.
realclean: clean
	-rm *.html
	-rm -rf $(PREF_LATEX_DIR)
	-rm -rf $(PREF_HTML_DIR)
	-cd $(PGUIDE_HTML_DIR) ; rm *.html *.gif
	-cd $(SERVER_HTML_DIR) ; rm *.html *.gif 
	-cd $(CLIENT_HTML_DIR) ; rm *.html *.gif

# Get rid of everything except the source.
distclean: realclean
	-rm *.gz
	-rm *.tar
	-rm *.pdf
	-rm *.ps

# $Log: Makefile,v $
# Revision 1.13  2004/04/24 21:37:21  jimg
# I added every directory in preparation for adding everyting. This is
# part of getting the opendap web pages going...
#
# Revision 1.12  2002/07/18 18:39:37  tom
# added writing_server and writing_client, accommodated doxygen instead of
# doc++, re-jiggered extensively, etc
#