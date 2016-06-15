; IDL-DODS interface.
; Written by Daniel J. Carr - Research Systems, Inc.
; Copyright 1999, UCAR
;
; Function to get a DDS variable and return it as an IDL variable.
; This funcion is called recursively for DDS Structure and Sequence
; variable types.
;
;    var_p - (Input )
;       Pointer to DDS variable.
;    var - (Output)
;       Returns the DDS variable's data.
;    name - (Output)
;       Returns the DDS variable's name.
;    in_seq - (Optional input parameter)
;       Whether or not the function is getting variables that are
;       inside a sequence
;
;    returns -
;       Status (1=ok, 0=fail).
;

FUNCTION DODS_VAR, conn, dds, var_p, var, name, $
                   SEQ_BLOCKSIZE=seq_blocksize, GET_DATA=get_data, $
                   INSIDE_SEQUENCE=in_seq
    

   DODS_VAR_INFO, var_p, type, var_name, pix

   IF (N_ELEMENTS(var_name) GT 0L) THEN name = var_name
   if (N_ELEMENTS(in_seq) LE 0L) THEN in_seq = 0

   ;PRINT, 'Type: ', type, ', var_name: ', var_name, ', pix: ', pix

   ; Based on the type of the variable, call the appropriate function
   ; from idl_dods.cc to get the data
   CASE type OF
      !dods_str_c: BEGIN
	 ;PRINT, 'dods_str_c';
         status = GET_DODS_STR(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         
         ; The STRTRIM shouldn't have any effect here, however
         ; if it's removed, the sequence code returns the last value
         ; for every value of the array
         var = STRTRIM(TEMPORARY(val))
      END
      !dods_byte_c: BEGIN
	 ;PRINT, 'dods_byte_c';
         status = GET_DODS_BYTE(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_int16_c: BEGIN
	 ;PRINT, 'dods_int_c';16
         status = GET_DODS_INT16(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_uint16_c: BEGIN
	 ;PRINT, 'dods_uint16_c';
         status = GET_DODS_UINT16(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_int32_c: BEGIN
	 ;PRINT, 'dods_int32_c';
         status = GET_DODS_INT32(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_uint32_c: BEGIN
	 ;PRINT, 'dods_uint32_c';
         status = GET_DODS_UINT32(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_float32_c: BEGIN
	 ;PRINT, 'dods_float32_c:var_p:',var_p;
         status = GET_DODS_FLOAT32(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_float64_c: BEGIN
	 ;PRINT, 'dods_float64_c';
         status = GET_DODS_FLOAT64(conn, dds, var_p, val, get_data)
         IF ((status EQ 0UL) OR (N_ELEMENTS(val) LE 0L)) THEN RETURN, 0UL
         var = REFORM(TEMPORARY(val))
      END
      !dods_array_c: BEGIN
	 ;PRINT, 'dods_array_c';
         d_names = BYTARR(65, 8)
         sss = LONARR(3, 8)
         status = GET_DODS_ARRAY(conn, dds, var_p, arr, arr_name, d_names, $
                                 sss, get_data)

         IF ((status EQ 0UL) OR (N_ELEMENTS(arr) LE 0L)) THEN RETURN, 0UL
         arr_size = SIZE(arr)
         arr_dims = arr_size[0]

         ; Figure out how many dimensions are actually used
         d_dims = 0
         FOR j=0, 7 DO BEGIN
            IF(d_names[0, j] NE 0) THEN d_dims = d_dims + 1
         ENDFOR

         ; And create an array of the appropriate size to hold them
         str_names = STRARR(d_dims)
         FOR i=d_dims - arr_dims, d_dims - 1 DO BEGIN
            temp_name = REFORM(d_names[*,i])
            DODS_FIX_NAME, temp_name
            str_names[i] = temp_name
         ENDFOR

	DODS_FIX_NAME, arr_name

         ; Build IDL structure to hold the components.
        var = CREATE_STRUCT(STRING(arr_name), TEMPORARY(arr), $
                  'start_stride_stop', sss[*,0:arr_dims-1], $
                  'dimension_names', REVERSE(str_names[d_dims - arr_dims:d_dims-1]))
      END
      !dods_grid_c: BEGIN
	 ;PRINT, 'dods_grid_c';
         d_names = BYTARR(65, 8)
         grid_var_p = 0UL
         status = GET_DODS_GRID(conn, dds, var_p, grid_var_p, d_names, $
                     d0, d1, d2, d3, d4, d5, d6, d7, get_data)
         IF ((status EQ 0UL) OR (grid_var_p EQ 0UL)) THEN RETURN, 0UL
         status = DODS_VAR(conn, dds, grid_var_p, grid_var, grid_name, GET_DATA=get_data)

         IF ((status EQ 0UL) OR (N_ELEMENTS(grid_var) LE 0L)) THEN RETURN, 0UL
         
         str_names = STRARR(8)
         n_names = size(d_names)
         FOR i=0, n_names[2]-1 DO BEGIN
            temp_name = REFORM(d_names[*,i])
            DODS_FIX_NAME, temp_name
            str_names[i] = temp_name
         ENDFOR
         d_names = TEMPORARY(str_names)

         var = CREATE_STRUCT(grid_name, REFORM(TEMPORARY(grid_var)))
         
         ; Build IDL structure to hold the components.
         
         ; The names of the map vectors (which are not returned correctly)
         ; are ignored at this point, and the names of the dimensions of
         ; the array are used instead.  
         
         IF (N_ELEMENTS(d0) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[0])
            IF (ind[0] GE 0L) THEN d_names[0] = d_names[0] + '_1'
            var = CREATE_STRUCT(var, d_names[0], $
                     TEMPORARY(d0))
         ENDIF
         IF (N_ELEMENTS(d1) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[1])
            IF (ind[0] GE 0L) THEN d_names[1] = d_names[1] + '_1'
            var = CREATE_STRUCT(var, d_names[1], $
                     TEMPORARY(d1))
         ENDIF
         IF (N_ELEMENTS(d2) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[2])
            IF (ind[0] GE 0L) THEN d_names[2] = d_names[2] + '_2'
            var = CREATE_STRUCT(var, d_names[2], $
                     TEMPORARY(d2))
         ENDIF
         IF (N_ELEMENTS(d3) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[3])
            IF (ind[0] GE 0L) THEN d_names[3] = d_names[3] + '_3'
            var = CREATE_STRUCT(var, d_names[3], $
                     TEMPORARY(d3))
         ENDIF
         IF (N_ELEMENTS(d4) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[4])
            IF (ind[0] GE 0L) THEN d_names[4] = d_names[4] + '_4'
            var = CREATE_STRUCT(var, d_names[4], $
                     TEMPORARY(d4))
         ENDIF
         IF (N_ELEMENTS(d5) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[5])
            IF (ind[0] GE 0L) THEN d_names[5] = d_names[5] + '_5'
            var = CREATE_STRUCT(var, d_names[5], $
                     TEMPORARY(d5))
         ENDIF
         IF (N_ELEMENTS(d6) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[6])
            IF (ind[0] GE 0L) THEN d_names[6] = d_names[6] + '_6'
            var = CREATE_STRUCT(var, d_names[6], $
                     TEMPORARY(d6))
         ENDIF
         IF (N_ELEMENTS(d7) GT 0L) THEN BEGIN
            ind = WHERE(TAG_NAMES(var) EQ d_names[7])
            IF (ind[0] GE 0L) THEN d_names[7] = d_names[7] + '_7'
            var = CREATE_STRUCT(var, d_names[7], $
                     TEMPORARY(d7))
         ENDIF
         
         ; var = CREATE_STRUCT(grid_name, REFORM(TEMPORARY(grid_var)))
      END
      !dods_structure_c: BEGIN
	 ;PRINT, 'dods_structure_c:var_p:',var_p;
         var_ptrs = PTR_NEW()
         names = ''

         ; Cycle through all the subvars in the struct and call
         ; DODS_VAR recursively to get them.

         WHILE (pix NE 0UL) DO BEGIN
            sub_var_p = 0UL

            DODS_NEXT, conn, dds, var_p, pix, sub_var_p, get_data
            status = DODS_VAR(conn, dds, sub_var_p, curr_var, curr_name, $
                             GET_DATA=get_data)
            IF ((status NE 0UL) AND (N_ELEMENTS(curr_var) GT 0L)) THEN BEGIN
               var_ptrs = [TEMPORARY(var_ptrs), PTR_NEW(TEMPORARY(curr_var))]
               DODS_FIX_NAME, curr_name
               names = [TEMPORARY(names), TEMPORARY(curr_name)]
            ENDIF ELSE pix = 0UL
         ENDWHILE

         ; Build IDL structure to hold the components.

         IF (N_ELEMENTS(var_ptrs) GT 1L) THEN BEGIN
            var_ptrs = var_ptrs[1:*]
            names = names[1:*]

            var = CREATE_STRUCT(names[0], TEMPORARY(*var_ptrs[0L]))
            FOR i=1L, N_ELEMENTS(var_ptrs)-1L DO BEGIN
               ind = WHERE(TAG_NAMES(var) EQ names[i])
               IF (ind[0] GE 0L) THEN names[i] = names[i] + '_1'
               var = CREATE_STRUCT(TEMPORARY(var), $
                        names[i], TEMPORARY(*var_ptrs[i]))
            ENDFOR
         ENDIF
         PTR_FREE, var_ptrs
      END
      !dods_sequence_c: BEGIN
          
	  ;PRINT, 'dods_sequence_c';
          IF ( N_ELEMENTS(seq_blocksize) LE 0 ) THEN seq_blocksize = 4096UL
          
          ; Call dods_var_seq to get the sequence
          status = DODS_VAR_SEQ(conn, dds, var_p, not_needed, name, $
                                seq, seq_blocksize, GET_DATA=get_data, $
                                INSIDE_SEQUENCE=in_seq)
          
          ; Clean up the struct DODS_VAR_SEQ created (Resize the
          ; arrays and ignore tags used to store internal paramenters).

          array = (TEMPORARY(*seq.(4)))[0:seq.index]
          var = CREATE_STRUCT((TAG_NAMES(seq))[4], TEMPORARY(array))
          
          FOR i=5, N_TAGS(seq) - 1 DO BEGIN
              
              array = (TEMPORARY(*seq.(i)))[0:seq.index]
              var = CREATE_STRUCT(TEMPORARY(var), (TAG_NAMES(seq))[i], $
                                  TEMPORARY(array))
          ENDFOR
          
      END
      ELSE:
   ENDCASE

   RETURN, 1UL
END
























