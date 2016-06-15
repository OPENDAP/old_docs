
// IDL-DODS interface.
// Written by Daniel J. Carr - Research Systems, Inc.
// Copyright 1999, UCAR
//
// IDL "LINKIMAGE" routines.
// 
// dods_connect()
// dods_var_p()
// dods_var_info()
// dods_next()
// dods_next_sequence_element()
// dods_sequence_length()
// dods_sequence_width()
// get_dods_str()
// get_dods_byte()
// get_dods_int16()
// get_dods_uint16()
// get_dods_int32()
// get_dods_uint32()
// get_dods_float32()
// get_dods_float64()
// get_dods_array()
// get_dods_grid()
// dods_free()
// dods_das_first_attr()
// dods_first_attr()
// dods_attr_info()
// dods_attr_data_info()
// dods_attr_data()
// dods_das_next()
// dods_print_dds()
//
// dods_hexstring()
// dods_unhexstring()

#include "config_idl.h"

static char not_used rcsid[]={"$Id$"};

#include <stdio.h>
#include <assert.h>
#ifndef WIN32
#include <strings.h>
#endif

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>

#ifdef WIN32
using std::cerr;
using std::endl;
using std::ostream;
#endif

#include "BaseType.h"
#include "Connect.h"
#include "AttrTable.h"
#include "debug.h"

// IDL include.
#include <export.h>
extern string hexstring(unsigned char);
extern string unhexstring(string);

string dodstype;
Type get_type_from_decl(BaseType *var_p);



