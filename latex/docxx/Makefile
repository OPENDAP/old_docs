#! gmake
#

#  $Id$
#
#  $Log: Makefile,v $
#  Revision 1.1  2001/07/20 19:32:45  tom
#  Doc++ appears to be orphan software.  Since the DODS project relies on
#  it, we have imported it into our own source control system.  It remains
#  the product of Roland Wunderling and Malte Zoeckler, though the DODS
#  project has incorporated some bugfixes and improvements.
#
#


CXX 	= 
CC 	=
LIB	= lib
UNAME	:= $(shell uname -s)

ifeq ($(UNAME),IRIX64)
    UNAME = IRIX
endif

#######################################################################
#
#  IRIX
#
#######################################################################
ifeq ($(UNAME),IRIX)
    SHAREDSUFFIX = so

    ifeq ($(LIB),lib32)
	CXX = CC -n32 -mips3
	CC = cc -n32 -mips3
	OPTIMIZER = -O2
    else
	CXX = CC -o32 -mips2
	CC = cc -o32 -mips2
	OPTIMIZER = -O2 -Olimit 2000
    endif
endif

#######################################################################
#
#  Linux
#
#######################################################################
ifeq ($(UNAME),Linux)
    CXX = g++
    CC = gcc
    OPTIMIZER = -O2 
    SHAREDSUFFIX = so
endif

#######################################################################
#
#  HP_UX
#
#######################################################################
ifeq ($(UNAME),HP-UX)
    CXX = aCC
    CC = cc
    OPTIMIZER = +O2 +Z
endif


#######################################################################
#
#  Solaris
#
#######################################################################
ifeq ($(UNAME),SunOS)
    CXX = g++ -Wall -g
    CC = gcc -Wall -g
    OPTIMIZER = -O0
    # -funroll-all-loops breaks Entry.cpp; -O2 depletes VM in cpp.cpp
    #OPTIMIZER = -O2 -funroll-all-loops
endif


CXXFLAGS	= -DUNIX -DNDEBUG $(OPTIMIZER)
    LD		= $(CXX)

#    LDFLAGS	= 
#    LDFLAGS	= -s	# strip

    FLEX  	= flex
    LFLAGS	= 


#------------------------------------------------------------------------
#
# Don't change anything bejond this point:
#
    OBJ		= main.o doc.o doc2tex.o html.o \
		  cpp.o java.o doc2html.o classgraph.o Entry.o nametable.o	\
		  readfiles.o tex2gif.o McWildMatch.o McHashTable.o McDirectory.o
    SRC		= doc.cpp html.cpp classgraph.cpp main.cpp Entry.cpp	\
		  nametable.cpp tex2gif.cpp McWildMatch.cpp McHashTable.cpp
    MORESRC	= doc2tex.cpp doc2html.cpp doc.cpp	\
		  readfiles.cpp docify.cpp java.cpp cpp.cpp
    CLEAN	= $(MORESRC) *.o *.bak *.swp y.* *~ core doc++ docxx parser.h docify promote
    YTAB        = y.tab
    TARGET      = doc++

#-------------------------------------------------------------------------
.PHONY:	all clean install dos help


help:
	@-echo	""
	@-echo	"make clean                              to remove unneccessary stuff"
	@-echo	"make all                                to build doc++ and docify"
	@-echo  "make dos CXX=gcc YTAB=y_tab MOVE=move   to build on dos"
	@-echo	"make release                            to release"
	@-echo	""
	@-echo	"     Note: make release requires, that we did make all on"
	@-echo	"           all plattforms we want to release"
	@-echo	""

dos2unix:
	-mkdir dos2unix.bak
	  for f in *.cpp *.h *.l *.hh ; do \
	    echo $$f ;\
	    cp $$f dos2unix.bak ;\
	    perl dos2unix.pl $$f > tmp.tmp ;\
	    mv tmp.tmp $$f ;\
	  done

all:	$(TARGET) docify promote
	-mkdir bin
	-mkdir bin/`uname -s`
	- chmod 775 bin
	- chmod 775 bin/`uname -s`
	cp $(TARGET) promote docify bin/`uname -s`
	chmod 775 bin/`uname -s`/*

$(TARGET):	$(OBJ) main.o
	$(LD) $(OBJ) $(LDFLAGS) -o $(TARGET)

docify:	docify.o
	$(LD) $(LDFLAGS) docify.o -o docify

dos:	$(OBJ) main.o docify.o
	gcc $(LDFLAGS) $(OBJ) -o docxx -lgpp -lc 
	gcc $(LDFLAGS) docify.o -o docify -lgpp -lc
	coff2exe -s ../bin/go32.exe docxx
	coff2exe -s ../bin/go32.exe docify

.SUFFIXES: .cpp
.cpp.o:
	$(CXX) $(CXXFLAGS) -c $*.cpp
clean:
	rm -rf $(CLEAN)

#-------------------------------------------------------------------------
.PHONY:	moresources

moresources:	$(MORESRC)

dep:	moresources
	g++ -E -MM -DUNIX $(SRC) $(MORESRC) > .tmp
	mv -f .tmp depend
	-chgrp vispar depend
	-chmod g+w depend

-include	depend

#-------------------------------------------------------------------------
docify.cpp:	docify.l
	$(FLEX) -f -Ca -t docify.l > docify.cpp

promote.cpp:	promote.l
	$(FLEX) -f -Ca -t promote.l > promote.cpp

doc2html.cpp:	doc2html.l
	$(FLEX) -Pstr2htmlyy -t doc2html.l > doc2html.cpp

doc.cpp:	doc.l
	$(FLEX) -Pdocyy -t doc.l > doc.cpp

doc2tex.cpp:	doc2tex.l doc.h
	$(FLEX) -Pdoc2texyy -t doc2tex.l > doc2tex.cpp

java.cpp:	java.l doc.h
	$(FLEX) -PjavaYY -t java.l > java.cpp

cpp.cpp:	cpp.l doc.h
	$(FLEX) -PcppYY -t cpp.l > cpp.cpp

readfiles.cpp:	readfiles.l McString.h nametable.hh doc.h
	$(FLEX) -Preadfilesyy -t readfiles.l > readfiles.cpp

#-------------------------------------------------------------------------
java.h: ClassGraph.class
	perl binToC.pl ClassGraph_class< ClassGraph.class           > java.h
	perl binToC.pl ClassGraphPanel_class< ClassGraphPanel.class >> java.h
	perl binToC.pl ClassLayout_class< ClassLayout.class         >> java.h
	perl binToC.pl NavigatorButton_class< NavigatorButton.class >> java.h
	echo " " >> java.h

ClassGraph.class: ClassGraph.java
	javac -O ClassGraph.java

#-------------------------------------------------------------------------
.PHONY:	test textest java
test:	$(TARGET)
	$(TARGET) -v -a -f -d test test/test.hh
	-chgrp vispar test/*
	-chmod g+w test/*

textest:	$(TARGET)
	$(TARGET) -A -v -t -o test/test.tex test/test.hh
	cd test ; latex test.tex ; latex test.tex
	-chgrp vispar test/*
	-chmod g+w test/*

java:	$(TARGET)
	$(TARGET) -J -H -f -d java java

texjava:	$(TARGET)
	$(TARGET) -t -J -H -f -o java/java.tex /vispar/work/java/src
	cd java ; latex java.tex
	-chgrp vispar test/*
	-chmod g+w test/*

tmp:	$(TARGET)
	$(TARGET) -v -t -J -H -f -o java/java.tex java/*.java
	cd java ; latex java.tex
	-chgrp vispar test/*
	-chmod g+w test/*

#-------------------------------------------------------------------------
docxxsrc.tar.gz:	moresources dep
	-mkdir src
	-rm -f src/*
	-rm -f docxxsrc.tar.gz docxxsrc.zip
	-cp *.c *.cpp *.h *.sty *.hh *.y *.l binToC.pl *.java *.class depend Makefile src
	-touch		src/*.c
	-touch		src/*.cpp
	-touch		src/*.h
	-touch		src/*.hh
	-chmod 775	src
	-chmod 664	src/*
	tar cvf docxxsrc.tar src
	gzip --best docxxsrc.tar
	cd src ; zip -r -9 ../docxxsrc.zip *
	-chmod 664	docxxsrc.tar.gz docxxsrc.zip
	-rm -rf src

docxxdoc.tar.gz:	
	-rm docxxdoc.tar docxxdoc.tar.gz docxxdoc.zip
	cd doc ; make clean ; make DOCXX=../bin/`uname`/doc++ html ; make DOCXX=../doc++ ps
	cd doc ; zip -r -9 ../docxxdoc.zip *
	tar cvf docxxdoc.tar doc
	gzip --best docxxdoc.tar
	-chmod 664 docxxdoc.tar.gz

#-------------------------------------------------------------------------
.PHONY:	release	ftp

release:	docxxsrc.tar.gz docxxdoc.tar.gz
	-mkdir release
	-rm -rf release/*
	-chmod 775 release
	-cp docxx.sty ChangeLog release/	
	-cp general/* release
	chmod 664 release/*
	-mkdir release/doc
	-rm -rf release/doc/*
	-chmod 775 release/doc
	cd doc ; make clean
	-cp doc/* release/doc
	-chmod 664 release/doc/*
	-mkdir release/bin
	-chmod 775 release/bin
	cd bin ;\
	umask 2 ;\
	for os in * ; do \
	    echo $$os ;\
	    rm -rf ../release/bin/* ;\
	    rm -f ../docxx_$$os.zip ../docxx_$$os.tar ../docxx_$$os.tar.gz ;\
	    cp $$os/* ../release/bin ;\
	    cd ../release ;\
	    tar cvf ../docxx_$$os.tar * ;\
	    zip -r -9 ../docxx_$$os.zip * ;\
	    cd .. ;\
	    gzip --best docxx_$$os.tar ;\
	    cd bin ;\
	done
	-chmod go+r doc/*
	-cp doc/* /zibis/Visual/software/doc++/
	-cp docxx_*.tar.gz /zibis/Visual/software/doc++/distributions/
	-cp docxx_*.zip /zibis/Visual/software/doc++/distributions/
	-cp docxxsrc.tar.gz docxxsrc.zip docxxdoc.tar.gz docxxdoc.zip	\
	    /zibis/Visual/software/doc++
	-cp docxxsrc.tar.gz docxxsrc.zip docxxdoc.tar.gz docxxdoc.zip	\
	    /zibis/Visual/software/doc++/distributions/
	@echo ""
	@echo "Do not forget to 'make ftp' as grafsabt !"
	@echo ""

install_release:
	mv docxxsrc.tar.gz release
	mv docxxdoc.tar.gz release
	mv docxx.irix.tar.gz release
	mv docxx.linux.tar.gz release
	mv docxx.solaris.tar.gz release
	cd release ; $(TARGET) ../doc/doc.dxx
	cd doc ; make ps
	cp doc/doc.ps release
	-chmod 664 release/*.*
        @echo "Now type:"
	@echo cp release/* /zibis/Visual/software/doc++/
	@echo cp *.tar.gz *.zip serv03:/ftp/pub/vispar/software/doc++ ;\
	@echo ""
	@echo "DOC++ released for SUN, SGI and LINUX-elf"
	@echo ""
