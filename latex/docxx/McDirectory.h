/*  $Id$

    $Log: McDirectory.h,v $
    Revision 1.1  2001/07/20 19:32:45  tom
    Doc++ appears to be orphan software.  Since the DODS project relies on
    it, we have imported it into our own source control system.  It remains
    the product of Roland Wunderling and Malte Zoeckler, though the DODS
    project has incorporated some bugfixes and improvements.

*/
#ifndef MC_DIRECTORY
#define MC_DIRECTORY

#include "McDArray.h"


class McDirectory {

protected:
  class StringCompare {
  public:
    operator()(const char *t1,const char *t2) {
#ifdef WIN32
      return stricmp(t1,t2);
#else
      return strcasecmp(t1,t2);
#endif
    }
};

public:
    /** Character used to separate directories in a path.*/
  static inline char pathDelimiter() {
#ifdef WIN32
    return('\\');
#else
    return('/');
#endif
  }
  /** Scan a directory for files. dirname contains path of directory,
    pattern specifies which files to use (may contain wildcards),
    the result is returned in list.
    @returns 0 if averything went o.k., !=0 otherwise.*/
  static int scan(const char *dirname, McDArray<char *> &list,
	   const char *pattern);
  /** Check whether a given name is directory.*/
  static int isDirectory(const char *dirname);

};
#endif
