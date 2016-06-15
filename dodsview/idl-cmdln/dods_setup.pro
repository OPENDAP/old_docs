; IDL-DODS interface.
; Written by Daniel J. Carr - Research Systems, Inc.
; Copyright 1999, UCAR
;
; Batch file to set up system variables and link external routines.
;

DEFSYSV, '!dods_null_c', 0
DEFSYSV, '!dods_byte_c', 1
DEFSYSV, '!dods_int16_c', 2
DEFSYSV, '!dods_uint16_c', 3
DEFSYSV, '!dods_int32_c', 4
DEFSYSV, '!dods_uint32_c', 5
DEFSYSV, '!dods_float32_c', 6
DEFSYSV, '!dods_float64_c', 7
DEFSYSV, '!dods_str_c', 8
DEFSYSV, '!dods_url_c', 9
DEFSYSV, '!dods_array_c', 10
DEFSYSV, '!dods_list_c', 11
DEFSYSV, '!dods_structure_c', 12
DEFSYSV, '!dods_sequence_c', 13
;DEFSYSV, '!dods_function_c', 14 ; It seems as if grid_c should be 14 and
;DEFSYSV, '!dods_grid_c', 15     ; that function_c doesn't exist anymore
DEFSYSV, '!dods_grid_c', 14

FORWARD_FUNCTION dods_var

IF (!VERSION.OS EQ 'Win32') THEN BEGIN
	so_file = 'idl_dods.dll'
ENDIF ELSE BEGIN
	so_file = 'idl_dods.so'
ENDELSE

LINKIMAGE, 'dods_connect', so_file, 1
LINKIMAGE, 'dods_var_p', so_file, 1
LINKIMAGE, 'dods_var_info', so_file, 0
;LINKIMAGE, 'dods_seq', so_file, 1
LINKIMAGE, 'dods_sequence_length', so_file, 1
LINKIMAGE, 'dods_sequence_width', so_file, 1
LINKIMAGE, 'dods_next', so_file, 0
LINKIMAGE, 'dods_next_sequence_element', so_file, 0
LINKIMAGE, 'get_dods_str', so_file, 1
LINKIMAGE, 'get_dods_byte', so_file, 1
LINKIMAGE, 'get_dods_int16', so_file, 1
LINKIMAGE, 'get_dods_uint16', so_file, 1
LINKIMAGE, 'get_dods_int32', so_file, 1
LINKIMAGE, 'get_dods_uint32', so_file, 1
LINKIMAGE, 'get_dods_float32', so_file, 1
LINKIMAGE, 'get_dods_float64', so_file, 1
LINKIMAGE, 'get_dods_array', so_file, 1
LINKIMAGE, 'get_dods_grid', so_file, 1
LINKIMAGE, 'dods_free', so_file, 0
LINKIMAGE, 'dods_das_first_attr', so_file, 0
LINKIMAGE, 'dods_first_attr', so_file, 1
LINKIMAGE, 'dods_attr_info', so_file, 0
LINKIMAGE, 'dods_das_next', so_file, 0
LINKIMAGE, 'dods_attr_data', so_file, 1
LINKIMAGE, 'dods_attr_data_info', so_file, 0
LINKIMAGE, 'dods_print_dds', so_file, 0



































