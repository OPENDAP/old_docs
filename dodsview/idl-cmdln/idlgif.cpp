/*A happy little program written with much help from Rich.  Makes a gif using idlrpc.
You can easily customize the result of this program by playing with dods_gif.pro.
The current dods_gif.pro is quite simplistic, and just begging to be embelished by
someone who actually knows IDL.  Just remember that you need to restart idlrpc in order for
your changes to take effect.

To get this program to compile on fwiffo use the following line:

g++ idlgif.cpp -o idlgif -lidl_rpc -I/usr/local/rsi/idl/external/rpc -L/usr/local/rsi/idl/bin/bin.alpha -w


If you want to run this program you will need to set the LD_LIBRARY_PATH first, in csh the desired command looks like this:

setenv LD_LIBRARY_PATH "/usr/local/rsi/idl/bin/bin.linux"
*/
#include "idl_rpc.h"
#include<string>
#include<strings.h>
#include<iostream>
#include<stdio.h>

CLIENT *idlClient;
string dodstype;


#include "config_idl.h"

static char not_used rcsid[]={"$Id$"};

#include <assert.h>
#include <strings.h>

#include <sstream>
#include <fstream>


#include "BaseType.h"
#include "Connect.h"
#include "AttrTable.h"
#include "debug.h"

// IDL include.
#include <export.h>
extern string hexstring(unsigned char);
extern string unhexstring(string);

/* These first three functions just consern themselves with converting from strings to integers and back again.
There really should be premade functions somewhere to do this, but I didn't bother looking them up.
*/

int raise(int n) {
  int rval=1;
  for(int i=0; i<n-1;i++) rval*=10;
  return rval;
}

int make_int(string num) {
  char *cnum = num.c_str();
  int mag= strlen(cnum);
  int rval=0;
  for(int i=0;i<mag;i++) rval+=raise(mag-i)*(cnum[i]-'0');
  return rval;
}

string make_str(int n) {
  char *foo = new char[n/10+1];
  sprintf(foo,"%d",n);
  return foo;
}

/* This function makes a get_dods call and puts the resulting array into the IDL variable specified in name.  Note that the function is
smart enough to handel 2, 3 and 4 dimensional cases.  The perl code that calls this program is generalized to do 2+ dimensions, and
it should be quite straight forward to generalize this code as well.  However, Peter has never heard of a DODS dataset with more then
four dimensions, so generalizing this code is a very low priority for me.
*/

void get_dods(string name, string url, string variable, string xlo, string xhi, string ylo, string yhi, string third, string forth) {

  if(!(forth=="")) IDL_RPCExecuteStr(idlClient,("stat = GET_DODS('"+url+"',CE='"+variable+"."+variable+"["+forth+"]["+third+"]["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)").c_str());
  else if(!(third=="")) {
    //printf(("stat = GET_DODS('"+url+"',CE='"+variable+"."+variable+"["+third+"]"+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)\n").c_str());
    IDL_RPCExecuteStr(idlClient,("stat = GET_DODS('"+url+"',CE='"+variable+"."+variable+"["+third+"]"+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)").c_str());
  }
  else {
    //printf(("stat = GET_DODS('"+url+"?"+variable+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)\n").c_str());
    //IDL_RPCExecuteStr(idlClient,("stat = GET_DODS('"+url+"?"+variable+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)").c_str());
    if(dodstype=="not_grid") IDL_RPCExecuteStr(idlClient,("stat = GET_DODS('"+url+"?"+variable+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)").c_str());
    else IDL_RPCExecuteStr(idlClient,("stat = GET_DODS('"+url+"',CE='"+variable+"."+variable+"["+ylo+":"+yhi+"]["+xlo+":"+xhi+"]',data)").c_str());
  }
  IDL_RPCExecuteStr(idlClient,(name+"=data."+variable+"."+variable).c_str());	
}



main(int argc, char *args[]) {
      string url = args[1];
      string variable = args[2];
      string xlo =args[3];
      string xhi =args[4];
      string ylo =args[5];
      string yhi =args[6];
      string lonlow = args[7];
      string lonhigh = args[8];
      string latlow = args[9];
      string lathigh = args[10];
      string xsize = args[11];
      string output = args[12];
      string orientation = args[13];
      string FillValue= args[14];
      dodstype=args[15];
      string landmask=args[16];
      string script = args[17];
      string client_dir=args[18];
      string third, forth;
      if(args[19]) {
      	third = args[19];
      	if(args[20]) forth = args[20];
      	else forth = "";
      }
      else third = "";

      idlClient = IDL_RPCInit(0, 0);
/* printf(("cd, '"+client_dir+"'").c_str());
*/
      IDL_RPCExecuteStr(idlClient,("cd, '"+client_dir+"'").c_str());

 /* This if else deals with the problems that come from requests that include the seam of the dataset
*/
      if(make_int(xhi) > make_int(xsize)) {
      	get_dods("b", url, variable, xlo, make_str(make_int(xsize)-1), ylo, yhi, third, forth);
      	get_dods("c", url, variable, "0", make_str(make_int(xhi)-make_int(xsize)), ylo, yhi, third, forth);
      	IDL_RPCExecuteStr(idlClient,"a = [b,c]");
                                        	 	
      }
      else get_dods("a", url, variable, xlo, xhi, ylo, yhi, third, forth);

      if(landmask!="none") get_dods("mask", landmask, variable, xlo, xhi, ylo, yhi, third, forth);
      else IDL_RPCExecuteStr(idlClient,"mask=0");

      IDL_RPCExecuteStr(idlClient,"cd, '/usr/local/apache/htdocs/DodsView.Test'");
      IDL_RPCExecuteStr(idlClient,("print, 'dods_gif, a, "+output+orientation+", "+FillValue+"'").c_str());
      IDL_RPCExecuteStr(idlClient,(script+", a, '"+output+"', "+lonlow+", "+lonhigh+", "+latlow+", "+lathigh+", '"+orientation+"', "+FillValue + ",mask").c_str());
      IDL_RPCExecuteStr(idlClient,"delvar,foo,sst2,a,data");
      IDL_RPCExecuteStr(idlClient,"exit");
      IDL_RPCCleanup(idlClient, FALSE);
}
