
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

// dods_connect()
// Establish connection and return connect object and DDS object.
//    argv[0] - (Input ) url byte stream (null terminated).
//    argv[1] - (Input ) Constraint expression byte stream (null terminated).
//    argv[2] - (Output) Named IDL variable to recieve a pointer
//                       to the DDS or to the DAS object.
//    argv[3] - (Output) Named IDL variable to recieve the number
//                       of variables in the DDS or set to 0 in case the request is a DAS.
//    argv[4] - (Input ) WWW_VERBOSE_ERRORS flag.
//    argv[5] - (Input ) ACCEPT_DEFLATE flag.
//    argv[6] - (Input ) GUI flag.
//    argv[7] - (Input ) A flag indicating what kind of data request is: data=0, dds=1, das=2
//    returns -          Pointer to Connect object.
//
// In version 3.0.x of DODS the progress dialog is not supported. In version
// 3.1 or 3.2 we will reintroduce this with a new, more robust,
// implementation. In this code I have disabled the GUI flag option (which
// activated the progress dialog feature). 6/8/99 jhrg
//
extern "C" IDL_VPTR dods_connect(int argc, IDL_VPTR argv[])
{
   // Jose Garcia
   // We must assure there are 8 elements in argv
   // For debbuging purposes we use now assert
   // This can be removed by comiling with -DNDEBUG 
   assert(argc==8);
  
   IDL_VPTR lReturn;
   bool www_verbose_errors = false;
   bool accept_deflate = false;
   bool gui_flag = false;
   DDS* dds=0;
   DAS* das=0;

#if 0
   Gui* gui;
#endif

   if (argv[4]->value.ul == 0ul) www_verbose_errors = false;
   else www_verbose_errors = true;

   if (argv[5]->value.ul == 0ul) accept_deflate = false;
   else accept_deflate = true;

#if 0
   if (argv[6]->value.ul == 0ul) gui_flag = false;
   else gui_flag = true;
#endif

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_MEMINT;
   lReturn->value.memint = 0ul;

   string url;
   url = string((char *) argv[0]->value.arr->data);
   string expr;
   expr = string((char *) argv[1]->value.arr->data);

   Connect* connect_obj = 0;

   DBG(cerr << url << endl);

   // If the user is requesting a dds, the constraint expression needs
   // to be appended to the URL for the dds to be constrained.  
   // Otherwise the two can be kept seperate and the CE applied later
   // rph 06/04/2001.

   if (argv[7]->value.ul == 1) 
     connect_obj = new Connect( (url + "?" + expr).c_str() );
   else 
     connect_obj = new Connect((char *) argv[0]->value.arr->data);
   
   if (connect_obj == 0) return lReturn; // Connection failed.

#if 0
   gui = connect_obj->gui();
   gui->show_gui((int) gui_flag);
#endif

   switch(argv[7]->value.ul)
     {
     case 0:
       {
	 try 
	   {
#ifndef WIN32
	     IDL_TimerBlock(TRUE);
#endif
	     dds = connect_obj->request_data(expr, gui_flag, false);
#ifndef WIN32
	     IDL_TimerBlock(FALSE);
#endif

	     if (dds == 0) { 
	       cout << "Null DataDDS" << endl;
	       return lReturn; // Request_data failed.
	     }
	     lReturn->value.memint = (IDL_MEMINT) connect_obj;
	     argv[2]->value.memint = (IDL_MEMINT) dds;
	     argv[3]->value.ul = (IDL_ULONG) dds->num_var();
	   }
	 catch (Error &e)
	   {
	     cout << "Null DataDDS" << endl;
	     return lReturn; // Request_data failed.
	   }
       }
       break;
     case 1:
       {

	 try 
	   {
	     if (connect_obj->request_dds())
	       {
		 dds=&(connect_obj->dds());
		 if(!dds)
		   return lReturn;
		 lReturn->value.memint = (IDL_MEMINT) connect_obj;
		 argv[2]->value.memint = (IDL_MEMINT) dds;
		 argv[3]->value.ul = (IDL_ULONG) dds->num_var();
	       }
	     else
	       return lReturn;
	   }
	 catch (Error &e)
	   {
	     return lReturn; // Request_data failed.
	   }
       }
       break;
     case 2:
       {
	 try 
	   {
	     if (connect_obj->request_das())
	       {
		 das=&(connect_obj->das());
		 if(!das) {
		   return lReturn;
		 }
		 lReturn->value.memint = (IDL_MEMINT) connect_obj;
		 argv[2]->value.memint = (IDL_MEMINT) das;
		 argv[3]->value.ul = 0ul;
	       }
	     else
	       return lReturn;
	   }
	 catch (Error &e)
	   {
	     return lReturn; // Request_data failed.
	   }
       }
       break;
     default:
       // The value for flag argv[7] shall never be different from {0,1,2}
       assert(0);
       break;
     }
   return lReturn;

}

// dods_var_p()
// Get the pointer to a variable in the DDS.
//    argv[0] - (Input ) Pointer to the connect object
//    argv[1] - (Input ) DDS pointer.
//    argv[2] - (Input ) Index of desired variable in the DDS.
//    returns -          Variable pointer.
//
extern "C" IDL_VPTR dods_var_p(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;

   DDS *dds = (DDS *)argv[1]->value.memint;
   Pix q = dds->first_var();

   for (int i = 1; i < (int) argv[2]->value.ul; i++)
      dds->next_var(q);

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_MEMINT;
   lReturn->value.memint = (IDL_MEMINT) dds->var(q);

   return lReturn;
}


// dods_var_info()
// Get information about a variable.
//    argv[0] - (Input ) Variable pointer.
//    argv[1] - (Output) Named IDL variable to receive DDS variable type code.
//                       Memory must be allocated for this IDL variable.
//    argv[2] - (Output) Named IDL variable to receive DDS variable's name.
//                       Memory must be allocated for this IDL variable.
//    argv[3] - (Output) Named IDL variable to receive the pseudo index of
//                       the first sub-variable, where applicable
//                       (for structure and sequence types).
//                       Memory must be allocated for this IDL variable.
//
extern "C" void dods_var_info(int argc, IDL_VPTR argv[])
{
   BaseType* var_p;
   IteratorAdapter q;

   IDL_VPTR type;
   IDL_VPTR name_arr;
   IDL_VPTR pix;

   var_p = (BaseType *) argv[0]->value.memint;

   type = IDL_Gettmp(); // Allocate memory for output variable.
   type->type = IDL_TYP_ULONG;
   type->value.ul = var_p->type();
   IDL_VarCopy(type, argv[1]);

   string var_name = var_p->name();

   // Using IDL_TYP_STRING to return strings to IDL is far more
   // efficient than using arrays.  7/12/00  rph.

   name_arr = IDL_Gettmp();
   name_arr->type = IDL_TYP_STRING;
   name_arr->value.str.slen = var_name.length();
   name_arr->value.str.stype = 0;
   name_arr->value.str.s = (char *) var_name.c_str();
   IDL_VarCopy(name_arr, argv[2]);


   pix = IDL_Gettmp(); // Allocate memory for output variable.
   pix->type = IDL_TYP_MEMINT;
   pix->value.memint = 0;

   switch (var_p->type())
   {
      case dods_structure_c:
	q = ((Structure *)var_p)->first_var();

	if (q) {
	    q.getIterator()->incref();
	    pix->value.memint = (IDL_MEMINT) q.getIterator();
	}
	else
	    pix->value.memint = (IDL_MEMINT) 0;
      break;

      case dods_sequence_c:
	q = ((Sequence *)var_p)->first_var();

	if (q) {
	    q.getIterator()->incref();
	    pix->value.memint = (IDL_MEMINT) q.getIterator();
	}
	else
	    pix->value.memint = (IDL_MEMINT) 0;
      break;

      default:
      break;
   }
   IDL_VarCopy(pix, argv[3]);
}


// dods_next()
// Get the pseudo index of the next variable in a structure or sequence.
//    argv[0] - (Input ) Pointer to the connect object
//    argv[1] - (Input ) DDS Pointer
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (I/O   ) Pseudo index.   Memory already allocated.
//    argv[4] - (Output) Named IDL variable to receive the pointer to the
//                       DDS variable at the current pseudo index.
//                       Memory already allocated.
//    argv[5] - (Input ) Whether to deserialize variables after sequences
extern "C" void dods_next(int argc, IDL_VPTR argv[])
{
   Connect *connect_obj;
   DDS *dds;
   BaseType *var_p;
   IteratorAdapter q;
   BaseType *sub_var_p;

   connect_obj = (Connect *) argv[0]->value.memint;

   dds = (DDS *) argv[1]->value.memint;

   var_p = (BaseType *) argv[2]->value.memint;

   q = (IteratorAdapter *) argv[3]->value.memint;
   if (q.getIterator()) q.getIterator()->decref();

   switch (var_p->type())
     {
     case dods_structure_c:       
       sub_var_p = ((Structure *) var_p)->var(q);
       ((Structure *)var_p)->next_var(q);

       if (q) {
	   q.getIterator()->incref();
	   argv[3]->value.memint = (IDL_MEMINT) q.getIterator();
       }
       else
	   argv[3]->value.memint = (IDL_MEMINT) 0;
       break;
       
     case dods_sequence_c:
       sub_var_p = ((Sequence *) var_p)->var(q);

       ((Sequence *)var_p)->next_var(q);

       if (q) {
	 argv[3]->value.memint = (IDL_MEMINT) q.getIterator();
       }
       else
	 argv[3]->value.memint = (IDL_MEMINT) 0;
       break;
       
     default:
       sub_var_p = 0;
       argv[3]->value.memint = (IDL_MEMINT) 0;
       break;
     }
   
   argv[4]->value.memint = (IDL_MEMINT) sub_var_p;
}


// dods_next_sequence_element()
// Get the pseudo index of the next variable in a structure or sequence.
//    argv[0] - (Input ) Variable pointer.
//    argv[1] - (Input ) Sequence 'row' number to access.
//    argv[2] - (Input ) Sequence 'element' number to access within 'row'.
//    argv[3] - (I/O   ) Pseudo index.   Memory already allocated.
//    argv[4] - (Output) Named IDL variable to receive the pointer to the
//                       DDS variable at the current pseudo index.
//                       Memory already allocated.
//    argv[5] - (Input ) Whether to deserialize variables after sequences
extern "C" void dods_next_sequence_element(int argc, IDL_VPTR argv[])
{
   BaseType *var_p;
   BaseType *sub_var_p;
   size_t row = argv[1]->value.ul;
   size_t element = argv[2]->value.ul;

   var_p = (BaseType *) argv[0]->value.memint;

   switch (var_p->type())
     {
     case dods_sequence_c:
       sub_var_p = ((Sequence *) var_p)->var_value(row,element);
       break;
       
     default:
       sub_var_p = 0;
       break;
     }
   
   argv[3]->value.memint = (IDL_MEMINT) sub_var_p;
}

// dods_sequence_length()
// Get the number of rows in a sequence.
//    argv[0] - (Input ) Variable pointer.
//    returns -          Number of rows in the sequence.
//
extern "C" IDL_VPTR dods_sequence_length(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;

   BaseType *var_p;
   size_t number_of_rows;

   var_p = (BaseType *) argv[0]->value.memint;
   
   number_of_rows = ((Sequence *) var_p)->number_of_rows();

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = (IDL_ULONG) number_of_rows;

   return lReturn;
}

// dods_sequence_width()
// Get the number of elements in a sequence.
//    argv[0] - (Input ) Variable pointer.
//    returns -          Number of elements in the sequence.
//
extern "C" IDL_VPTR dods_sequence_width(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;

   BaseType *var_p;
   size_t number_of_elements;

   var_p = (BaseType *) argv[0]->value.memint;

   number_of_elements = ((Sequence *) var_p)->element_count();

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = (IDL_ULONG) number_of_elements;

   return lReturn;
}

// get_dods_str()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    argv[4] - (Input ) Whether to download data or fake it
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_str(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   unsigned int n_bytes;
   IDL_MEMINT dim;
   Connect* connect_obj;
   DDS* dds;
   IDL_VPTR temp_string;
   // IDL_VPTR arr_data;
   // Fix: See further down where the call to malloc, buf2val and free are
   // changed. This was necessary due to changes in the DODS DAP software.
   // 6/8/99 jhrg
#if 0
   UCHAR* str_ptr;
#endif
   string str;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   n_bytes = var_p->width();
   if (n_bytes <= 0) return lReturn;

   // Allocate memory for output variable.
   dim = n_bytes + 1;

   // There are some serious problems here. malloc is used but inside
   // Str::buf2val(...) those bytes are going to be deleted using delete().
   // That's going to cause problems. If `str_ptr' is null, then buf2val(...)
   // will allocate storage for you. 6/8/99 jhrg
   //
   // Suggestion: Change the malloc for str_ptr to str_ptr = 0; I'm going to
   // do this one. 6/8/99 jhrg
#if 0
   str_ptr = (UCHAR *) malloc(dim);
#endif
   string *str_ptr;
   str_ptr = new string;
   
   try {
     if(argv[4]->value.ul == 1) n_bytes = var_p->buf2val((void **) &str_ptr);
     else *str_ptr = "";
   }
   catch(Error &err) {
     cerr << err.error_message();
     *str_ptr = "";
     n_bytes = 0;
   }


   // Yet another rewrite of this section of code.  The array stuff 
   // was giving some strange errors on certain sequence datasets.
   // It's faster with strings anyway.  07/12/00  rph.

   temp_string = IDL_Gettmp();
   temp_string->type = IDL_TYP_STRING;
   temp_string->value.str.slen = str_ptr->length();
   temp_string->value.str.stype = 0;
   temp_string->value.str.s = (char *) str_ptr->c_str();
   IDL_VarCopy(temp_string, argv[3]);

   // arr_ptr = IDL_MakeTempArray(IDL_TYP_BYTE, (int) 1, 
   //             (IDL_LONG *) &dim, IDL_BARR_INI_ZERO, &arr_data);

   // IDL_VarCopy(arr_data, argv[3]);

   // Suggestion: Assuming data has enough space use strcpy here. 6/8/99 jhrg
   // for (i = 0; i < n_bytes; i++)
   // {
   //   argv[3]->value.arr->data[i] = str[i];
   //}
   
   // strcpy((char *)argv[3]->value.arr->data,str_ptr->c_str());
   
   // Fix: This must be delete. 6/8/99 jhrg
#if 0
   free(str_ptr);
#endif
   delete(str_ptr);

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_byte()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    argv[4] - (Input ) Whether to download data or fake it
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_byte(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_BYTE, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);

   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else {
     memset(argv[3]->value.arr->data, 0, 1);
   }

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_int16()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_int16(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_INT, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);

   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else {
     memset(argv[3]->value.arr->data, 0, 2);
   }

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_uint16()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_uint16(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_UINT, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);

   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else {
     memset(argv[3]->value.arr->data, 0, 2);
   }

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_int32()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_int32(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_LONG, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);


   IDL_VarCopy(arr_data, argv[3]);

   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else {
     memset(argv[3]->value.arr->data, 0, 4);
   }
   
   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_uint32()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_uint32(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_ULONG, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);

   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else {
     memset(argv[3]->value.arr->data, 0, 4);
   }
   
   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_float32()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_float32(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_FLOAT, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);
   
   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }   
   else {
     memset(argv[3]->value.arr->data, 0, 4);
   }

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_float64()
// Get the data from a DDS variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_float64(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   BaseType* var_p;
   char* arr_ptr;
   unsigned int n_bytes;
   IDL_MEMINT dim=1;
   Connect* connect_obj;
   DDS* dds;
   // bool status;
   IDL_VPTR arr_data;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (BaseType *) argv[2]->value.memint;

   // Allocate memory for output variable.
   arr_ptr = IDL_MakeTempArray(IDL_TYP_DOUBLE, (int) 1, 
                (IDL_MEMINT *) &dim, IDL_BARR_INI_ZERO, &arr_data);
   IDL_VarCopy(arr_data, argv[3]);


   if(argv[4]->value.ul == 1) {
     try {
       n_bytes = var_p->buf2val((void **) &argv[3]->value.arr->data);
     }
     catch(Error &err) {
       cerr << err.error_message();
       n_bytes = 0;
     }
   }
   else { 
     memset(argv[3]->value.arr->data, 0, 8);
   }

   if (n_bytes <= 0) return lReturn;

   lReturn->value.ul = 1;
   return lReturn;
}


// get_dods_array()
// Get the data from a DDS array variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the data.
//                       Memory must be allocated.
//    argv[4] - (Output) Named IDL variable to recieve the name
//                       of the array.
//    argv[5] - (Output) Named IDL variable (array) to receive dimension names.
//                       Memory already allocated as a (65x8) byte array.
//    argv[6] - (Output) Named IDL variable (array) to receive the dimension
//                       start/stride/stop values.   Memory already allocated
//                       as a (3x8) long int array.
//    argv[7] - (Input)  Whether to get the data or fake it
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_array(int argc, IDL_VPTR argv[])
{
   unsigned int ret_val=1;
   IDL_VPTR lReturn;
   Array* var_p;
   // BaseType* dim_var;
   BaseType* cell_var;
   unsigned int n_dim;
   IDL_MEMINT dims[8];
   string dim_name;
   unsigned int name_len;
   char* arr_ptr;
   unsigned int n_bytes;
   unsigned int i, j;
   unsigned int n_elements;
   Connect* connect_obj;
   DDS* dds;
   IteratorAdapter q;
   UCHAR* uchar_p;
   IDL_LONG *long_p;
   IDL_VPTR arr_data;
   IDL_VPTR arr_name;
   Type var_type;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = ret_val;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (Array *) argv[2]->value.memint;

   arr_name = IDL_Gettmp();
   arr_name->type = IDL_TYP_STRING;
   arr_name->value.str.stype = 0;
   arr_name->value.str.slen = var_p->name().length();
   // Instead of casting, this should use strcpy(). 10/3/2000 jhrg
   arr_name->value.str.s = (char *)var_p->name().c_str();

   IDL_VarCopy(arr_name, argv[4]);

   n_dim = var_p->dimensions();
   if (n_dim <= 8)
   {
     q = var_p->first_dim();
     
     if (q)
       {
         for (i = 0; i < n_dim; i++)
	   {
	     // Suggestion: use strncpy(...) here. 6/8/99 jhrg
	     dim_name = var_p->dimension_name(q);
	     name_len = dim_name.length();
	     if (name_len >= 64) name_len = 64;
	     for (j = 0; j < name_len; j++)
	       {
		 uchar_p = (UCHAR *) &argv[5]->value.arr->data[0] + ((65*i) + j);
		 *uchar_p = (UCHAR) dim_name[j];
	       }
	     // Handle case where dimension is not a named dimension;
	     // Create a container for the dimension with a 'space' char in it.
	     if (name_len == 0) {
	       uchar_p = (UCHAR *) &argv[5]->value.arr->data[0] + (65*i);
	       *uchar_p = ' ';
	     }
	     
	     long_p = (IDL_LONG *) &argv[6]->value.arr->data[0] + (3*i);
	     *long_p = (IDL_LONG) var_p->dimension_start(q);
	     long_p++;
	     *long_p = (IDL_LONG) var_p->dimension_stride(q);
	     long_p++;
	     *long_p = (IDL_LONG) var_p->dimension_stop(q);
	     
	     // IDL arrays have their dimensions in the reverse order from
	     // C/C++ arrays, so we have to declare the array dimensions 
	     // in reverse.  06/19/00  rph.
	     // dims[i] = var_p->dimension_size(q);
	     dims[n_dim - i - 1] = var_p->dimension_size(q);
            
	     //var_p->next_dim(q);
	     q.next();

	     if (!q) i = n_dim + 1;
	   }
       }

     n_elements = 1;
     for(unsigned int i=0;i<n_dim;i++) {
       n_elements *= dims[i];
     }

     if(argv[7]->value.ul == 1) {
       cell_var = var_p->var(0);     
       var_type = cell_var->type();
     }
     else {
       var_type = get_type_from_decl(var_p);
     }

     // Allocate memory and copy data to output variable.

     switch (var_type)
       {
       case dods_byte_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_BYTE, (int) n_dim, 
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; 
	   }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 1);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;

       case dods_int16_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_INT, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; 
	   }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 2);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;

       case dods_uint16_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_UINT, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); n_bytes = 0; 
	   }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 2);
	 
	 IDL_VarCopy(arr_data, argv[3]);
	 break;

       case dods_int32_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_LONG, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 4);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;
       case dods_uint32_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_ULONG, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; 
	   }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 4);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;

       case dods_float32_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_FLOAT, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; 
	   }
	 }
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 4);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;

       case dods_float64_c:
	 arr_ptr = IDL_MakeTempArray(IDL_TYP_DOUBLE, (int) n_dim,
				     (IDL_MEMINT *) dims, IDL_BARR_INI_NOP, &arr_data);
	 if(argv[7]->value.ul == 1) {
	   try { 
	     n_bytes = var_p->buf2val((void **) &arr_data->value.arr->data); 
	   } 
	   catch(Error &err) { 
	     cerr << err.error_message(); 
	     n_bytes = 0; 
	   }
	 }
	 
	 else 
	   memset(arr_data->value.arr->data, 0, n_elements * 8);

	 IDL_VarCopy(arr_data, argv[3]);
	 break;
       default:
	 // Question: What about an array of strings? 6/8/99 jhrg
	 break;
	}
   }
   else ret_val = 0;
   
   lReturn->value.ul = ret_val;

   return lReturn;
}


// get_dods_grid()
// Get the data from a DDS grid variable.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    argv[2] - (Input ) Variable pointer.
//    argv[3] - (Output) Named IDL variable to receive the grid variable pointer.
//                       IDL variable must be already defined as an unsigned long.
//    argv[4] - (Output) Named IDL variable (array) to receive dimension names.
//                       Memory already allocated as a (64x8) byte array.
//    argv[5] - (Output) Named IDL variable to receive the 1st dimension array.
//                       Memory must be allocated.
//    argv[6-12] - 
//              (Output) Named IDL variables to receive the 2nd through 8th
//                       dimension arrays (if applicable).   Memory must be allocated.
//    argv[13]  (Input ) 1: get the data     any thing else: fake it
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR get_dods_grid(int argc, IDL_VPTR argv[])
{
   unsigned int ret_val=1;
   IDL_VPTR lReturn;
   Grid* var_p;
   Array* grid_var;
   Vector* dim_var;
   unsigned int n_dim;
   // int dims[8];
   IDL_MEMINT dim;
   string dim_name;
   unsigned int name_len;
   char* arr_ptr;
   unsigned int n_bytes;
   unsigned int i;
   Connect* connect_obj;
   DDS* dds;
   IteratorAdapter q;

   IDL_VPTR arr_data;
   IDL_VPTR dim_names;
   int dim_names_sizes[2];
   Type var_type;
   unsigned int n_elements;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;
   var_p = (Grid *) argv[2]->value.memint;

   grid_var = (Array *) var_p->array_var();

   n_dim = grid_var->dimensions();
   dim_names_sizes[0] = 64;
   dim_names_sizes[1] = n_dim;

   arr_ptr = IDL_MakeTempArray(IDL_TYP_BYTE, (int) 2, 
			       (IDL_MEMINT *) &dim_names_sizes, 
			       IDL_BARR_INI_NOP, &dim_names);
   bzero((char *)dim_names->value.arr->data, 64 * n_dim);
   if (n_dim <= 8)
   {
      q = var_p->first_map_var();

      if (q)
      {
         for (i = 0; i < n_dim; i++)
         {
	     // Suggestion: replace with strncpy(...). 6/8/99 jhrg
	    dim_var = (Vector *) var_p->map_var(q);
            dim_name = dim_var->name();
	    n_elements = dim_var->length();
            name_len = dim_name.length();
            if (name_len >= 64) name_len = 64;
	    // Handle case where dimension is not a named dimension;
	    // Create a container for the dimension with a 'space' char in it.
	    if (name_len == 0) {
	      memcpy(dim_names->value.arr->data + i*64, 
		     " ", 1);
	    }
	    else {
	      memcpy(dim_names->value.arr->data + i*64, 
		     dim_name.c_str(), name_len);
	    }

            //for (j = 0; j < name_len-1; j++)
            //{
            //   argv[4]->value.arr->data[j,i] = (UCHAR) dim_name[j];
            //}

            // Allocate memory and copy data to output dimension variables.

            dim = dim_var->length();
	    
	    if(argv[13]->value.ul == 1) 
	      var_type = dim_var->var(0)->type();
	    else
	      var_type = get_type_from_decl(dim_var);

            switch (var_type)
            {
	    case dods_byte_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_BYTE, (int) 1, 
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); } 
		catch(Error &err) { 
		  cerr << err.error_message(); 
		  n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 1);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_int16_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_INT, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); 
		  n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 2);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_uint16_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_UINT, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); 
		  n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 2);

	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_int32_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_LONG, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); 
		  n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 4);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_uint32_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_ULONG, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); 
		  n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 4);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_float32_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_FLOAT, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 4);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    case dods_float64_c:
	      arr_ptr = IDL_MakeTempArray(IDL_TYP_DOUBLE, (int) 1,
					  (IDL_MEMINT *) &dim, IDL_BARR_INI_NOP, &arr_data);
	      if(argv[13]->value.ul == 1) {
		try { 
		  n_bytes = dim_var->buf2val((void **) &arr_data->value.arr->data); 
		} 
		catch(Error &err) { 
		  cerr << err.error_message(); n_bytes = 0; 
		}
	      } 
	      else 
		memset(arr_data->value.arr->data, 0, n_elements * 8);
	      
	      IDL_VarCopy(arr_data, argv[i+5]);
	      break;
	    default:
	      // Question: What about otehr types (strings, etc.)? 6/8/99
	      // jhrg 
	      break;
            }
            //var_p->next_map_var(q);
	    q.next();

            if ( !q ) i = n_dim + 1;
         }
      }

      // Return grid data pointer.
      argv[3]->value.memint = (IDL_MEMINT) grid_var;
   }
   else ret_val = 0;

   IDL_VarCopy(dim_names, argv[4]);

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = ret_val;
   
   return lReturn;
 
}


// dods_free()
// Delete and free the Connect and DDS objects.
//    argv[0] - (Input ) Pointer to the connect object.
//    argv[1] - (Input ) Pointer to the DDS object.
//    returns -          Status (1=ok, 0=fail).
//
extern "C" IDL_VPTR dods_free(int argc, IDL_VPTR argv[])
{
   IDL_VPTR lReturn;
   Connect* connect_obj;
   DDS* dds;

   lReturn = IDL_Gettmp(); // Allocate memory for return variable.
   lReturn->type = IDL_TYP_ULONG;
   lReturn->value.ul = 0ul;

   connect_obj = (Connect *) argv[0]->value.memint;
   dds = (DDS *) argv[1]->value.memint;

   delete dds;

   // I think that removing the gui stuff where Connect was instantiated
   // should fix the nasty problems with core dumps/seg faults when
   // connect_obj is deleted. 6/8/99 jhrg

   // deleting connect_obj seems to work alright for me.  Doing so also
   // fixes a bug where dods_var_seq would enter an infinite loop when get_dods
   // was called for a second time on a large dataset.  If this breaks 
   // anything, I'll find another way to fix that problem.  rph 05/29/01.

   delete connect_obj;

   // Return a null IDL_VPTR. Hmmm... I don't know about this and I don't
   // have an easy way to test it. I'll leave it commented out for now, but
   // gcc gives a warning about control reaching the end of a non-void
   // function. 10/3/2000 jhrg 
   // Instead, see below (erd 2000/12/05)
#if 0
   return 0;
#endif
   // From changes on rel-3-1-2-branch branch:
   // No real check for failure but SGI complains about "control reaches
   // end of non-void function" without this. (erd 2000/10/12)

   // IDL doesn't seem to ever look at the return value of this function. 
   // Maybe we should just change it to void.  rph 05/29/01.
   lReturn->value.ul = 1;
   return lReturn;

}

// dods_das_first_attr()
// Returns the first top_level attribute table from a DAS
//   argv[0] - (Input ) A pointer to the DAS object
//   argv[1] - (Output) The pix of the first attribute table (Pix)
//   argv[2] - (Output) A pointer to the first attribute table (AttrTable *)
//   argv[3] - (Output) The name of the first attribute table (String)

extern "C" void dods_das_first_attr(int argc, IDL_VPTR argv[]) {

  DAS* das;
  IteratorAdapter q;

  IDL_VPTR pix;
  IDL_VPTR attr_p;
  IDL_VPTR name;
  string temp_string;

  das = (DAS *) argv[0]->value.memint;
  q = das->first_var();

  int num_attrs = das->get_size();

  attr_p = IDL_Gettmp();
  attr_p->type = IDL_TYP_MEMINT;
  attr_p->value.memint = (IDL_MEMINT) das->get_table(q);
  IDL_VarCopy(attr_p, argv[2]);
  
  temp_string = das->get_name(q);
  name = IDL_Gettmp();
  name->type = IDL_TYP_STRING;
  name->value.str.slen = temp_string.length();
  name->value.str.stype = 0;
  name->value.str.s = (char *) temp_string.c_str();
  IDL_VarCopy(name, argv[3]);

  pix = IDL_Gettmp();
  pix->type = IDL_TYP_MEMINT;
  pix->value.memint = (IDL_MEMINT) num_attrs;
  IDL_VarCopy(pix, argv[1]);
}

// dods_first_attr()
// Returns the first attribute in an attribute table
//   argv[0] - (Input ) A pointer to the attribute table
//   returns -          The pix of the first attribute

extern "C" IDL_VPTR dods_first_attr(int argc, IDL_VPTR argv[]) {
  IDL_VPTR lReturn;
  AttrTable *attr_p;
  IteratorAdapter q;

  lReturn = IDL_Gettmp();
  lReturn->type = IDL_TYP_MEMINT;

  attr_p = (AttrTable *) argv[0]->value.memint;

  if ( attr_p ) {
    int numAttrs = attr_p->get_size();
    lReturn->value.memint = (IDL_MEMINT) numAttrs;

    if ( numAttrs > 0 ) {
      q = attr_p->first_attr();  
      string var_name = attr_p->get_name(q);
    }
  }
  else
    lReturn->value.memint = 0UL;

  return lReturn;
}

// dods_attr_info()
// Gets the name of an attribute checks to see if an it
// is a container for more attributes
//   argv[0] - (Input ) A pointer to an attribute table
//   argv[1] - (Input ) The pseudo index of the attribute
//   argv[2] - (Output) 1 if argv[1] is a container, 0 otherwise
//   argv[3] - (Output) The name of the attribute at argv[1] (String)

extern "C" void dods_attr_info(int argc, IDL_VPTR argv[]) {

  AttrTable *attr_p;
  IteratorAdapter pix;
  IDL_VPTR name;

  attr_p = (AttrTable *) argv[0]->value.memint;

  int idx = argv[1]->value.memint;
  AttrTable::Attr_iter i = attr_p->get_attr_iter(idx);

  if( attr_p->is_container(i) ) {
    argv[2]->value.memint = (IDL_MEMINT) 1;
    DBG(cerr << "is_container" << endl);
  }
  else {
    argv[2]->value.memint = (IDL_MEMINT) 0;
    DBG(cerr << "is_not_container" << endl);
  }

  string var_name = attr_p->get_name(i);
  name = IDL_Gettmp();
  name->type = IDL_TYP_STRING;
  name->value.str.slen = var_name.length();
  name->value.str.stype = 0;
  name->value.str.s = (char *) var_name.c_str();
  IDL_VarCopy(name, argv[3]);

}

// dods_attr_data_info() 
// Get the number of elements in the attribute and their type.
//
//   argv[0] - (Input ) A pointer to an attribute table
//   argv[1] - (Input ) The pix of the specific attribute
//   argv[2] - (Output) The type of data (ULONG)
//   argv[3] - (Output) The number of elements

extern "C" void dods_attr_data_info(int argc, IDL_VPTR argv[]) {
  AttrTable * attr_p;
  IteratorAdapter pix;

  IDL_VPTR attr_type;
  IDL_VPTR num_elements;

  attr_p = (AttrTable *) argv[0]->value.memint;

  int idx = argv[1]->value.memint;
  AttrTable::Attr_iter i = attr_p->get_attr_iter(idx);
  string attrName = attr_p->get_name(i);

  attr_type = IDL_Gettmp();
  attr_type->type = IDL_TYP_ULONG;
  attr_type->value.ul = (IDL_ULONG) 0;
  IDL_VarCopy(attr_type, argv[2]);
 
  string attrType = attr_p->get_type(i);

  num_elements = IDL_Gettmp();
  num_elements->type = IDL_TYP_ULONG;
  num_elements->value.ul = (IDL_ULONG) attr_p->get_attr_num(attrName);
  IDL_VarCopy(num_elements, argv[3]);
}

// dods_attr_data()
// Gets the nth element from the vector of values for an attribute
//   argv[0] - (Input ) The pointer to the attribute table
//   argv[1] - (Input ) The pix of the desired attribute
//   argv[2] - (Input ) The index of the value to read from the attribute
//   returns -          The nth value of the attribute (String)

extern "C" IDL_VPTR dods_attr_data(int argc, IDL_VPTR argv[]) {
  AttrTable *attr_p;
  AttrType type;
  IteratorAdapter pix;
  unsigned int index;
  string attribute;

  IDL_VPTR lReturn;
  
  attr_p = (AttrTable *) argv[0]->value.memint;

  int idx = argv[1]->value.memint;
  AttrTable::Attr_iter i = attr_p->get_attr_iter(idx);

  index = argv[2]->value.ul;

  attribute = attr_p->get_attr(i, index);
  type = attr_p->get_attr_type(i);

  lReturn = IDL_Gettmp();

  istringstream sin(attribute.c_str());

  switch(type) 
    {
    case Attr_uint16: {
      unsigned short adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_UINT;
      lReturn->value.ui = (IDL_UINT) adjusted;
      break;
    }
    case Attr_uint32: {
      unsigned int adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_ULONG;
      lReturn->value.ul = (IDL_MEMINT) adjusted;
      break;
    }
    case Attr_byte: {
      char adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_BYTE;
      lReturn->value.c = (UCHAR) adjusted;
    }
    case Attr_int16: {
      short adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_INT;
      lReturn->value.i = adjusted;
      break;
    }
    case Attr_int32: {
      int adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_LONG;
      lReturn->value.l = (IDL_LONG) adjusted;
      break;
    }
    case Attr_float32: {
      float adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_FLOAT;
      lReturn->value.f = adjusted;
      break;
    }
    case Attr_float64: {
      double adjusted;
      sin >> adjusted;
      lReturn->type = IDL_TYP_DOUBLE;
      lReturn->value.d = adjusted;
      break;
    }
    default: 
      lReturn->type = IDL_TYP_STRING;
      lReturn->value.str.slen = attribute.length();
      lReturn->value.str.stype = 0;
      lReturn->value.str.s = (char *) attribute.c_str();
      break;
    }
  
  return lReturn;

}


// dods_das_next()
// Returns the next top-level attribute table in a das
//   argv[0] - (Input ) A pointer to the DAS
//   argv[1] - (I/0   ) Input: the current pix, Output: the next pix
//   argv[2] - (Output) The next attribute table
//   argv[3] - (Output) The name of the attribute table

extern "C" void dods_das_next(int argc, IDL_VPTR argv[]) {
    IDL_VPTR next_attr;
    IDL_VPTR name;
    DAS *das;

    das = (DAS *) argv[0]->value.memint;

    int idx = argv[1]->value.memint;
    AttrTable::Attr_iter i = das->get_attr_iter(idx);
    
    next_attr = IDL_Gettmp();
    next_attr->type = IDL_TYP_MEMINT;
    next_attr->value.memint = (IDL_MEMINT) das->get_table(i);
    IDL_VarCopy(next_attr, argv[2]);
    
    string temp_name = das->get_name(i);
    name = IDL_Gettmp();
    name->type = IDL_TYP_STRING;
    name->value.str.slen = temp_name.length();
    name->value.str.stype = 0;
    name->value.str.s = (char *) temp_name.c_str();
    IDL_VarCopy(name, argv[3]);
}

// dods_print_dds
// This function prints the DDS of a dataset to STDOUT
// argv[0]  (Input ) - A pointer to the DDS object to be printed.
extern "C" void dods_print_dds(int argc, IDL_VPTR argv[]) {
  DDS *dds;

  dds = (DDS *)argv[0]->value.memint;

  dds->print(cout);
}

// get_type_from_decl
// This function returns the type of an array based on its declaration.
// It is used in constructing empty DDS's, where BaseType::type() won't work.
//   var_p   (Input ) - A pointer to the variable to find the type of
Type get_type_from_decl(BaseType *var_p) {

  // There has to be a better way to do this... rph
  
  Type var_type;
  ostringstream sout;
  string temp;

  var_p->print_decl(sout);
  temp = sout.str();
  
  if(temp.find("Byte"))
    var_type = dods_byte_c;
  if(temp.find("Int16"))
    var_type = dods_int16_c;
  if(temp.find("UInt16"))
    var_type = dods_uint16_c;
  if(temp.find("Int32"))
    var_type = dods_int32_c;
  if(temp.find("UInt32"))
    var_type = dods_uint32_c;
  if(temp.find("Float32"))
    var_type = dods_float32_c;
  if(temp.find("Float64"))
    var_type = dods_float64_c;
  
  return var_type;
}

// dods_hexstring()
// Get the hex representation for a character.
//    argv[0] - (Input ) character to be converted to hex.
//    returns -          character string containing the 
//                       hex representation of the input char.
//
extern "C" IDL_VPTR dods_hexstring(int argc, IDL_VPTR argv[]) {
  IDL_VPTR lReturn;

  unsigned char unescaped_char = argv[0]->value.c;
  string escaped_char = hexstring(unescaped_char);

  //cout << "hexify this(" << unescaped_char << ") = " << escaped_char << endl;

  lReturn = IDL_Gettmp();
  lReturn->type = IDL_TYP_STRING;
  lReturn->value.str.slen = escaped_char.length();
  lReturn->value.str.stype = 0;
  lReturn->value.str.s = (char *) escaped_char.c_str();

  return lReturn;
}

// dods_unhexstring()
// Replace the escaped characters with the proper characters
// for transmission is a URL request.  Some characters will 
// remain represented in hex.tation for a character.
//    argv[0] - (Input ) character string to be unescaped.
//    returns -          character string containing the 
//                       unescaped representation.
//
extern "C" IDL_VPTR dods_unhexstring(int argc, IDL_VPTR argv[]) {
  IDL_VPTR lReturn;
  static const string ESC = "%";
  string::size_type i = 0;

  string in = argv[0]->value.str.s;

  if ((i = in.find_first_of("esc__", 0)) != string::npos) {
    in.erase(i, 5);
  }

  while ((i = in.find_first_of("_e_", i)) != string::npos) {
    in.replace(i, 3, ESC);
    i=0;
  }

  string unescaped_varname = unhexstring(in);

  lReturn = IDL_Gettmp();
  lReturn->type = IDL_TYP_STRING;
  lReturn->value.str.slen = unescaped_varname.length();
  lReturn->value.str.stype = 0;
  lReturn->value.str.s = (char *) unescaped_varname.c_str();

  return lReturn;
}


// $Log: idl_dods.cc,v $
// Revision 1.1  2004/06/22 14:02:35  schneide
// build environment for idlgif with modifications for Alpha
//
// Revision 1.21.2.2  2003/06/18 15:52:36  jimg
// I removed the include of <ostream> because it was causing builds to fail. The
// class ostream is defined in <iostream>. I also removed the strstream header
// since that class is not used here and is deprecated by the new C++ standard.
//
// Revision 1.21.2.1  2003/06/16 04:43:05  rmorris
// Put in a couple of missing headers flaged as missing under VC++.
//
// Revision 1.21  2003/04/23 17:25:33  dan
// Merged release-3-3 branch back to trunk.
//
// Revision 1.20.2.4  2003/04/23 16:06:22  dan
// Removed unused variables from dods_var_p
//
// Revision 1.20.2.3  2003/04/23 16:02:32  dan
// Removed 'found sequence' from dods_var_p()
//
// Revision 1.20.2.2  2003/04/23 15:28:28  dan
// Updated to use new get_attr_iter methods in AttrTable.
// Removed any non-required Pix operations.  The variable
// access methods still use Pix operations but should be
// updated to get_iter methods added to DDS.  In next
// release.
//
// Revision 1.20.2.1  2003/03/04 21:55:00  dan
// Replace Pix usage with new IteratorAdapters.  Still
// a problem using IteratorAdapters on AttrTables.
//
// Revision 1.20  2003/01/29 19:28:40  dan
// Merged with release-3-2-6
//
// Revision 1.19  2001/10/14 01:05:51  jimg
// Merged with release-3-2-4.
//
// Revision 1.16.2.25  2003/01/28 16:50:54  dan
// Removed include for IDLSequence
//
// Revision 1.16.2.24  2002/12/29 20:50:38  jimg
// Removed the call to Connect::source() since that method is now private.
// See Connect.cc/h for a description of those changes. Briefly, using
// the source() method triggers a bug when access multiple variables. It is
// no longer necessary because Connect::request_data() now reads entire
// Sequences and stores the result in the DataDDS.
//
// Revision 1.16.2.23  2002/11/18 01:10:35  rmorris
// VC++ required some explicit casts to Pix in some cases instead of letting
// an implicit cast take place.
//
// Revision 1.16.2.22  2002/09/13 06:36:03  jimg
// Fixed casts from IDL integer types to Pix. Pix is now really an
// IteraorAdapter, it used to be a void *. I changed the casts so that they
// look like q = *(Pix *)...; We should really be using static_cast<>().
//
// Revision 1.16.2.21  2002/05/23 20:09:30  dan
// Fixed problem with passing array dimensions back to the idl
// procedures calling get_dods_array.  The dimension array is
// a 32-bit int array, but get_dods_array was using IDL_MEMINT
// to address into it, which is 64-bit in size on some archs.
//
// Revision 1.16.2.20  2002/04/23 18:47:06  dan
// Modified variable type used to contain dimension sizes in
// calls to IDL_MakeTempArray used in each of the get_dods_<type> functions.
//
// Revision 1.16.2.19  2002/04/23 17:38:30  dan
// Removed debug statement in dods_var_p
//
// Revision 1.16.2.18  2002/04/19 19:02:10  dan
// Fixed a bad pointer affected on 64-bit archs.
//
// Revision 1.16.2.17  2002/04/19 18:50:21  dan
// Fixed problem with 64-bit archs. with IDL_MakeTempArray
//
// Revision 1.16.2.16  2002/04/19 15:58:48  dan
// Added explicit cast to IDL_MEMINT for calls to IDL_MakeTempArray,
// required for IDL 5.4+
//
// Revision 1.16.2.14  2002/02/06 00:11:44  rmorris
// #ifdef 0 not ok with VC++.  Used #if 0 instead.
//
// Revision 1.16.2.13  2002/02/05 11:44:25  dan
// Modified Sequence handling, removing dods_seq, and replacing
// with dods_next_sequence_element, dods_sequence_length, and
// dods_sequence_width.  These new functions work with the current
// release-3.2 sequence deserialize behavior which reads the
// entire sequence into memory, and uses rows and elements(width)
// to access the subsequent elements in the sequence.
//
// Modified return types from IDL_ULONG, to IDL_MEMINT, the
// new usage is provided by the IDL API to better support 64-bit
// architectures.
//
// Revision 1.16.2.12  2001/12/26 04:53:18  rmorris
// Changes to get some recent code changes to go through MS Visual C++.
//
// Revision 1.16.2.11  2001/10/10 22:26:29  jimg
// Changed #include "export.h" to #include <export.h>. This means that fewer
// users will need to run `make depend' since they won't depend on the location
// of the RSI code.
//
// Revision 1.18  2001/09/28 23:56:49  jimg
// Merged with 3.2.4.
//
// Revision 1.16.2.10  2001/09/27 19:39:27  jimg
// Added debug.h.
//
// Revision 1.17  2001/06/19 22:17:32  jimg
// Merged with relesae-3-2-2.
//
// Revision 1.16.2.9  2001/06/07 20:32:32  rich
// Added code to handle errors thrown by the functions in the DAP
//
// Revision 1.16.2.8  2001/06/04 16:30:15  rich
// Fixed a bug where DDS wouldn't be constrained if the CE keyword was used to
// supply the constraint expression instead of appending ?<constraint expression>
// to the url.
//
// Revision 1.16.2.7  2001/06/01 20:05:15  rich
// Fixed the grid handling code (It stopped working after I added the empty DDS
// support).
//
// Revision 1.16.2.6  2001/05/31 20:51:28  rich
// Fixed a bug calculating the size of arrays when creating an empty DDS
//
// Revision 1.16.2.5  2001/05/29 18:28:23  rich
// Uncommented the 'delete connect_obj;' in dods_free() to fix a bug where
// get_dods would sometimes segfault when called a second time.
//
// Revision 1.16.2.4  2001/05/25 18:04:12  rich
// Added support for getting the DDS as an empty IDL structure (as opposed to
// using the print_dods_dds procedure)
//
// Revision 1.16.2.3  2001/05/25 14:35:26  rich
// This should theoretically work on datasets that have sequence followed by
// other variables at the top level now.
//
// Revision 1.16.2.2  2001/05/25 13:54:50  dan
// Fixed a bug where variables after a sequence would not be deserialized
//
// Revision 1.16.2.1  2000/12/06 00:39:59  edavis
// Add changes from rel-3-1-2-branch branch.
//
// Revision 1.16  2000/10/30 17:27:56  jimg
// Fixes for exception-based error reporting.
//
// Revision 1.15  2000/10/03 23:40:09  jimg
// Moved the CVS Log entries to the end of the files.
// Changed the read() mfuncs so that they match the definition in the
// dap++ library.
// Removed lots of dead code.
//
// Revision 1.14  2000/10/03 18:38:25  dan
// Fixed several small problems. Can't recall them all
// at this point.
//
// Revision 1.4.2.1  1999/09/23 23:06:36  jimg
// This collection of files builds under Solaris 2.6. The resulting idl_dods.so
// runs correctly on the fnoc1.nc test dataset.
//
// Revision 1.4  1999/06/08 21:57:28  jimg
// Final fix for the String --> string changes. See line 355.
//
// Revision 1.3  1999/06/08 18:42:36  jimg
// Fixes for the String --> string fixes.
//
// Revision 1.2  1999/06/08 17:44:37  jimg
// Changed instances of String to string.
// Added suggestions for ways to shorten the code. These mostly come about
// because of the shift to string.
// Found several bugs in get_dods_str(...) which I tried to fix.
// Noted some omissions in the get_dods_array and get_dods_grid functions.
//
// Revision 1.1  1999/06/08 16:51:50  jimg
// Added


