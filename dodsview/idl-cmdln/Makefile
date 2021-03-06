
# $Id$



# Set makefile variables, some with values supplied by configure 
# DEFS gets the `-D' defines that describe what a particular system has
# or doesn't have.

# Build the IDL DODS sharable object.

PROG = idl_dods.so
DODS_ROOT = /usr/local/src/DODS-3.4/DODS/
#DODS_ROOT = ../../../
# DODS_ROOT has been redefined to an absolute path so idl_dods.so may be
# placed elsewhere on the system

IDL_ROOT = /usr/local/rsi/idl
INCS = -I. -I$(IDL_ROOT)/external  -I../../../include
DEFS = -DHAVE_CONFIG_H
CPPFLAGS =  $(DEFS) $(INCS)
CXXFLAGS = -g3 -O0  -Wall -fPIC -O0
TEST_COV_FLAGS = -ftest-coverage -fprofile-arcs
# for SGI, change -G to -shared.
# I think it needs to be -shared for any gcc/g++/gld linker. It certainly
# does for linux. 10/3/2000 jhrg
LDFLAGS = -shared -u main  -L../../../lib -L. -L/usr/local/rsi/idl_5.4/bin/bin.alpha
LFLAGS = -8
YFLAGS = -d -v
LIBS = -ldap++ -L/usr/local/src/DODS-3.4/DODS/lib -lcurl -lz -lrx -lidl
TAGS_FLAGS =

# Set the instalation directories; prefix can be set on the command line
# during Makefile construction with `./configure --prefix /my/choice'

prefix = $(DODS_ROOT)
exec_prefix = $(prefix)
bindir = $(exec_prefix)bin
libdir = $(exec_prefix)lib
includedir = $(prefix)include
manext = 1
mandir = $(prefix)man/man$(manext)

src = $(DODS_ROOT)src
etcdir = $(DODS_ROOT)etc

INSTALLMAN = man

SHELL = /bin/sh
srcdir = .
version = 3.4.1
basedir = idl-cmdln
dir = $(basedir)-3.4.1
host = alphaev56-dec-osf5.1

COMPONENT_NAME = IDL Command Line Tool
AWK = awk
TAR = tar
PERL = /usr/local/bin/perl

# testsuite specifics
RUNTEST = runtest
RUNTESTFLAGS = --all

# names of key programs

LN_S = ln -s
CP = cp
CC = gcc
CXX = g++
PURIFY = purify -chain-length="10"
AR = ar
TAGS = etags
INSTALL = ../../../etc/install-sh -c
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_PROGRAM = ${INSTALL}
STRIP = strip
DOCXX = doc++

SRCS = idl_dods.cc
OBJS = idl_dods.o

CLIENTSRCS = 

CLIENTOBJS = 

ALLSRCS = $(SRCS) $(CLIENTSRCS)

all: $(PROG)

# If the shared object is to be built using `ld' and not `g++', then make
# sure to add -lstdc++ and -lgcc after $(LIBS). Then add the path to the
# directory containing those libraries to $(LDFLAGS) (i.e., -L<path>). Use
# the DODS_GCC autoconf macro to have configure find that path. Look in
# $(DODS_ROOT)etc/aclocal.m4 under DODS_GCC for more information. 9/23/99
# jhrg 

idl_dods.so: $(OBJS) $(CLIENTOBJS)
	g++ $(LDFLAGS) -o idl_dods.so $(OBJS) $(CLIENTOBJS) $(LIBS)

# Standard targets

install: all 
	-mkdir $(DODS_ROOT)bin
	-mkdir $(DODS_ROOT)bin/idl
	$(INSTALL_PROGRAM) idl_dods.so /usr/local/apache/htdocs/idl
	for f in *.pro; do \
	  $(INSTALL_DATA) $$f /usr/local/apache/htdocs/idl; \
	done
	$(INSTALL_DATA) README /usr/local/apache/htdocs/idl

configure: configure.in $(DODS_ROOT)etc/aclocal.m4
	autoconf --localdir=$(DODS_ROOT)etc

Makefile: Makefile.in
	if [ -x ./config.status ]; \
	then \
	    ${SHELL} ./config.status; \
	else \
	    ./configure; \
	fi

check: 
#check: idl_dods.so getdods-check

getdods-check: idl_dods.so
	$(RUNTEST) $(RUNTESTFLAGS) --srcdir testsuite/ --tool getdods

test-coverage: clean
	$(MAKE) $(MFLAGS) CXXFLAGS="$(CXXFLAGS) $(TEST_COV_FLAGS)" check

# Note that the gcov options -f and -b are useful but sometimes make looking
# at the results of coverage analysis a little taxing. -b reports on all
# branched and -f reports on all functions. The -l -o options summarize on a
# per-file basis. 3/27/98 jhrg
collect-coverage-data:
	(cd test-coverage; \
         cov_dat="coverage-data-`date +%m.%d.%y`"; \
	 touch $$cov_dat; \
	 for f in $(SRCS); do \
	     echo "\n*** Coverage data for $$f ***\n" >> $$cov_dat; \
	     gcov -l -o ../ $$f >> $$cov_dat; \
         done)

# Clean up.

clean:	
	-rm -f $(PROG)
	-rm -f *.o *.sum *.log *~ core
	-rm -f *.bb *.bbg *.da *.gcov

distclean: clean
	-rm -f config.status config.log config.cache

.PHONY: tar
tar:
	-rm -r config.cache config.log config.status
	cd $(DODS_ROOT).. && \
	$(TAR) --exclude 'old' --exclude '.#*' --exclude 'CVS' \
	    --exclude '.flc' --exclude '.snprj' --exclude 'Makefile' \
	    --gzip --create --dereference --file DODS-$(dir).tar.gz \
	    DODS/src/clients/$(dir)

.PHONY: binary-tar
binary-tar:
	cd $(DODS_ROOT).. && \
	$(TAR) --gzip --create --dereference \
            --file DODS-idl-cmdln-$(version)-$(host).tar.gz \
            DODS/NEWS \
	    DODS/docs/README DODS/docs/README-idl-cmdln \
	    DODS/bin/idl

.PHONY: update-version
update-version: check-version
	@echo "Version is: `cat version.h`"
	if test ! -d ../$(dir); then mv ../$(basedir)* ../$(dir); fi
	if test ! -f $(DODS_ROOT)VERSION; then touch $(DODS_ROOT)VERSION; fi
	$(etcdir)/update-manifest.pl "$(COMPONENT_NAME)" $(version) \
		< $(DODS_ROOT)VERSION > tmp.dods.manifest
	mv tmp.dods.manifest $(DODS_ROOT)VERSION

# Compare the version encoded in this Makefile (set by configure) with the
# version in version.h. The version make variable is set up near the top of
# the Makefile.
.PHONY: check-version
check-version:
	@echo "Checking for version.h and Makefile version match-up"
	@if [ "$(version)" != "`cat version.h`" ]; \
	then \
		echo "You must manually re-run configure!"; \
		exit 1; \
	else \
		echo "Yes, they match."; \
	fi

.PHONY: tags
tags:
	$(TAGS) $(TAGS_FLAGS) *.cc

.PHONY: depend
depend: 
	../../..//etc/depend.sh -m Makefile.in -- $(CPPFLAGS) -- $(ALLSRCS)
	$(MAKE) $(MFLAGS) Makefile

.SUFFIXES:      .o .cc .c

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

.cc.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $<

# DO NOT DELETE; depend depends on this line.
idl_dods.o: idl_dods.cc config_idl.h ../../../include/BaseType.h \
 ../../../include/InternalErr.h ../../../include/Error.h \
 ../../../include/Connect.h ../../../include/DAS.h \
 ../../../include/AttrTable.h ../../../include/DDS.h \
 ../../../include/Clause.h ../../../include/expr.h \
 ../../../include/RValue.h ../../../include/util.h \
 ../../../include/Byte.h ../../../include/dods-datatypes.h \
 ../../../include/Int16.h ../../../include/UInt16.h \
 ../../../include/Int32.h ../../../include/UInt32.h \
 ../../../include/Float32.h ../../../include/Float64.h \
 ../../../include/Str.h ../../../include/dods-limits.h \
 ../../../include/Url.h ../../../include/Array.h \
 ../../../include/Vector.h ../../../include/List.h \
 ../../../include/Structure.h ../../../include/Constructor.h \
 ../../../include/Sequence.h ../../../include/Grid.h \
 ../../../include/DataDDS.h ../../../include/HTTPConnect.h \
 ../../../include/RCReader.h ../../../include/ObjectType.h \
 ../../../include/HTTPCache.h ../../../include/ResponseTooBigErr.h \
 ../../../include/HTTPCacheDisconnectedMode.h ../../../include/debug.h
