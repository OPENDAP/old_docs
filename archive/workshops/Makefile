#
# New standard DODS documentation Makefile (5/2001) ts.

# $Id$

# $Log: Makefile,v $
# Revision 1.2  2002/05/13 19:34:21  tom
# dumb errors with subdirectories
#
# Revision 1.1  2002/05/13 18:01:35  tom
# added
#
#

HOME_DIR=.
TEX_AUX_FILES=*.aux *.blg *.ent *.ilg *.log *.bbl *.ind \
              *.lot *.blg *.idx *.lof *.toc *.all
DODS_DOC=~/DODS-doc
# Customize the following for each new document.

# Edit the following to point to the directory where the hyperlatex
# output will go.  Do *NOT* use this file if the hyperlatex output
# doesn't get put in a subdirectory. (see "realclean" and ".html" for why).
SERVER_HTML_DIR=writing_server
SERVER_DEPENDS= writing_server.tex
CLIENT_HTML_DIR=writing_client
CLIENT_DEPENDS= writing_client.tex 

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

writing_server.html: $(SERVER_DEPENDS)
	hyperlatex $<
	cp $(SERVER_HTML_DIR)/$@ $(SERVER_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(SERVER_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(SERVER_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

writing_client.html: $(CLIENT_DEPENDS) Geturl.java.html MatlabFactory.java.html geturl.cc.html   
	hyperlatex $<
	cp $(CLIENT_HTML_DIR)/$@ $(CLIENT_HTML_DIR)/index.html
	cp Geturl.java.html $(CLIENT_HTML_DIR)/
	cp MatlabFactory.java.html  $(CLIENT_HTML_DIR)/
	cp geturl.cc.html  $(CLIENT_HTML_DIR)/
	@echo '$@ will contain a redirect to $(CLIENT_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(CLIENT_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

# For a simple directory, containing a single document with no index
# or bibliography, you won't have to change anything else.  Otherwise,
# edit where noted.

# Stop GNU make from overzealous deletion of intermediate files.  We
# take care of these explicitly, with the clean-up rules.
.PRECIOUS: %.ps %.dvi %.pdf %.aux %.bbl %.ind %.tar \
	%.all %.ps.gz %.tar.gz

%.dvi: %.tex

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
	makeindex -s $(DODS_DOC)/latex/dods-book.ist $*.idx

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

%.tar.gz: %.tar %.ps.gz %.pdf
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
clean:
	-rm -f *.dvi *~
	-rm -f $(TEX_AUX_FILES)

# If there's more than one HTML directory, this needs to be changed.
realclean: clean
	-rm *.html
	-rm -rf $(SYNTH_HTML_DIR)

distclean: realclean
	-rm *.gz
	-rm *.pdf
	-rm *.ps
