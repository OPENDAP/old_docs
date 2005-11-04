;
; Function to get a sequence variable from dods and return it as a
; struct.  This function works by allocating chunks of
; memory as needed, and copying the data into these arrays.  This
; avoids the overhead of creating an array one element larger for each
; new row.
;
;    var_p - (Input )
;       Pointer to DDS variable.
;    var - (Output)
;       Returns the DDS variable's data.
;    name - (Output)
;       Returns the DDS variable's name.
;    in_seq - (Optional input flag) 
;       Whether or not the function is getting variables that are 
;       inside a sequence
;
;    TODO: If the code for all the primative types in dods_var were
;    copied in here and modified slightly, it would cut the number of
;    calls to dods_var_info in half, saving a few seconds on large datasets

FUNCTION DODS_VAR_SEQ, conn, dds, var_p, var, name, seq, blocksize, $
                       GET_DATA=get_data, INSIDE_SEQUENCE=in_seq
   
   IF(N_ELEMENTS(get_data) LE 0L) THEN get_data = 0
   IF(N_ELEMENTS(in_seq) LE 0L) THEN in_seq = 0

   DODS_VAR_INFO, var_p, type, var_name, pix

   IF (N_ELEMENTS(var_name) GT 0L) THEN name = var_name
   
   CASE type OF
      !dods_sequence_c: BEGIN
         
      ; This was moved outside and to the bottom of the while loop to fix a 
      ; bug where the last entry was repeated.  06/12/00 rph.
         
	 IF(get_data EQ 0) THEN BEGIN
	    number_of_rows = 1;
	 ENDIF ELSE BEGIN
	    number_of_rows = DODS_SEQUENCE_LENGTH(var_p)
	 ENDELSE

         number_of_elements = DODS_SEQUENCE_WIDTH(var_p)
         more_seq = 1
         
         ; Cycle through the rows in the sequence until all of the
         ; sequence has been deserialized and stored as an IDL structure

	 FOR row=0, number_of_rows - 1 DO BEGIN
            ; Cycle through each element in a row, using DODS_VAR_SEQ
            ; to get the variable.
	    FOR column=0, number_of_elements - 1 DO BEGIN
               sub_var_p = 0UL

	       IF(get_data EQ 0) THEN BEGIN
 	          DODS_NEXT, conn, dds, var_p, pix, sub_var_p
	       ENDIF ELSE BEGIN
        	  DODS_NEXT_SEQUENCE_ELEMENT, var_p, row, column, sub_var_p
	       ENDELSE

               status = DODS_VAR_SEQ(conn, dds, sub_var_p, curr_var, $
                                     curr_name, seq, blocksize, $
                                     GET_DATA=get_data, INSIDE_SEQUENCE=1) 

               IF ((status GT 0UL) AND (N_ELEMENTS(curr_var) GT 0UL)) THEN BEGIN 
                  ; If there are no elements in the structure, 
                  ; or we haven't gone all the way through the 
                  ; elements yet, set tag_num to -1
          
                  IF ( N_ELEMENTS(seq) GE 1 ) THEN BEGIN
                     IF ( seq.index GT 0 ) THEN BEGIN
                        tag_num = seq.tag

                     ENDIF ELSE tag_num = -1
                  ENDIF ELSE tag_num = -1
                                          
                  ; If tag_num < 0, then either the structure hasn't
                  ; been created, or we haven't made it all the way
                  ; through the first row

                  IF (tag_num LT 0L) THEN BEGIN
                     DODS_FIX_NAME, curr_name

                     tags = N_TAGS(seq)
                     IF ( tags GE 1) THEN BEGIN 
                        seq = CREATE_STRUCT(TEMPORARY(seq), curr_name, $
                                            PTR_NEW(REPLICATE(curr_var, blocksize)))
			seq.columns = seq.columns + 1
                        seq.tag = tags + 1
                     ENDIF ELSE BEGIN 
                        ; The first four tags of the structure are
                        ; only used in creating the structure, and
                        ; will be discarded before the data is
                        ; returned to the user.
                        seq = CREATE_STRUCT("BLOCK_NUM", 1UL, "INDEX", 0UL, $
                                            "TAG", 4UL, "COLUMNS", 1UL, $
                                            curr_name, $
                                            PTR_NEW(REPLICATE(curr_var, blocksize)))
                     ENDELSE
                     
                  ENDIF ELSE BEGIN ; Concatenate existing data
                     ; If we have room, set the array value, otherwise
                     ; allocate another block

                     IF ( seq.index LT blocksize * seq.block_num) THEN BEGIN 
                        IF ( SIZE(curr_var, /TYPE) NE 8) THEN BEGIN
                           (*seq.(tag_num))[seq.index] = TEMPORARY(curr_var)
                        ENDIF ELSE BEGIN
                           FOR i=0, N_TAGS(curr_var) - 1 DO BEGIN
                              (*seq.(tag_num))[seq.index].(i) = curr_var.(i)
                           ENDFOR
                        ENDELSE
                     ENDIF ELSE BEGIN
                        ; INDGEN doesn't work for structs, so REPLICATE
                        ; is used instead.  rph 05/25/01

                        ;*seq.(tag_num) = [ TEMPORARY(*seq.(tag_num)), $ 
                        ;                   INDGEN(blocksize, $
                        ;                         TYPE=size(curr_var, /TYPE)) ]

                        *seq.(tag_num) = [ *seq.(tag_num), $
                                           REPLICATE((*seq.(tag_num))[0], blocksize) ]

                        IF ( SIZE(curr_var, /TYPE) NE 8) THEN BEGIN
                           (*seq.(tag_num))[seq.index] = TEMPORARY(curr_var)
                        ENDIF ELSE BEGIN
                           FOR i=0, N_TAGS(curr_var) - 1 DO BEGIN
                              (*seq.(tag_num))[seq.index].(i) = curr_var.(i)
                           ENDFOR
                        ENDELSE

                     ENDELSE
                     
                     seq.tag = seq.tag + 1
                  ENDELSE
                  IF ( seq.tag - 4 GE seq.columns ) THEN BEGIN
                     seq.tag = 4
                  ENDIF 
                  
               ENDIF ELSE BEGIN 
		  pix = 0UL
		  ENDELSE
            ENDFOR
            
            
            ; deserialize more of the sequence and indicate that it's 
            ; moved on to the next row.  If the index goes past
            ; the boundary of a block, increment seq.block_num and the
            ; code in the inner loop will handle resizing the structure

            ;IF(get_data EQ 1) $
            ;  THEN more_seq = DODS_SEQ(conn, dds, var_p, in_seq) $
            ;ELSE more_seq = 0

            ;IF(more_seq EQ 1) THEN BEGIN
               IF ( seq.index GE blocksize * seq.block_num ) THEN BEGIN
                  seq.block_num = seq.block_num + 1
               ENDIF
               seq.index = seq.index + 1
            ;ENDIF
            
            ;DODS_VAR_INFO, var_p, type, var_name, pix

         ENDFOR
         seq.index = seq.index - 1

      END
      ELSE: BEGIN
         ; If this ends up being called on a non-sequence, have
         ; dods_var deal with it
         RETURN, DODS_VAR(conn, dds, var_p, var, name, GET_DATA=get_data)
      END
   ENDCASE
END



