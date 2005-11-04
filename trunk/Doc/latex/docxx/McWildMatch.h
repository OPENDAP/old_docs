///////////////////////////////////////////////////////////////////////
//
// $Id$
//
// $Log: McWildMatch.h,v $
// Revision 1.1  2001/07/20 19:32:45  tom
// Doc++ appears to be orphan software.  Since the DODS project relies on
// it, we have imported it into our own source control system.  It remains
// the product of Roland Wunderling and Malte Zoeckler, though the DODS
// project has incorporated some bugfixes and improvements.
//
//
// Id: McWildMatch.h,v 3.0 1997/02/04 17:49:01 bzfzoeck Exp 
//
///////////////////////////////////////////////////////////////////////
#ifndef MC_WILD_MATCH_H
#define MC_WILD_MATCH_H

/// Matches string against pattern containing wildcards '?' and '*'.
/** This routine tests a string against a wild card pattern. The wild 
    characters are '*' and '?'. '*' matches an arbitrary sequence of
    characters while '?' matches any single character. Returns 1 if the
    match is successful, 0 otherwise. */
extern int mcWildMatch(const char* str, const char* pattern);

#endif
