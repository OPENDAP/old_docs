PRO TEST
   ; Setup the test URL and a constraint expression.
   url = 'http://dods.gso.uri.edu/cgi-bin/nph-nc/data/fnoc1.nc'
   ce = 'u'
   print, "DODS TEST: The URL used in this test:"
   print, "DODS TEST:   ", url
   print, "DODS TEST: The constraint expression used in this test:" 
   print, "DODS TEST:   ", ce
   
   ; Request the DAS
   print, "DODS TEST: Requesting DAS"
   stat = GET_DODS(url, das, mode='das')
   print, "DODS TEST: Info on the DAS:
   help, /str, das
   help, /str, das.u

   ;Request the data
   print, "DODS TEST: Requesting the data"
   stat = GET_DODS(url, data)
   print, "DODS TEST: Info on the data:
   help, /str, data
   help, /str, data.u

   ;Request the data with the constraint expression
   print, "DODS TEST: Requesting the data with constraint (", ce, ")"
   stat = GET_DODS(url, data2, ce=ce)
   print, "DODS TEST: Info on the data (with ce):
   help, /str, data2
   help, /str, data2.u

stop

END
