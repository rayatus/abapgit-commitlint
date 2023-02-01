CLASS zcl_abapgit_commitlint_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS display_log
      IMPORTING it_log          TYPE zif_abapgit_commitlint_types=>ty_t_log
                iv_start_column TYPE i DEFAULT 1
                iv_end_column   TYPE i DEFAULT 60
                iv_start_line   TYPE i DEFAULT 1
                iv_end_line     TYPE i DEFAULT 10
      RAISING   zcx_abapgit_commitlint.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_s_alv,
             status  TYPE c LENGTH 1,
             rule    TYPE string,
             message TYPE string,
           END   OF ty_s_alv,
           ty_t_alv TYPE STANDARD TABLE OF ty_s_alv WITH NON-UNIQUE KEY table_line.

    CLASS-DATA mt_alv TYPE ty_t_alv.

    CLASS-METHODS display
      IMPORTING
        iv_end_line     TYPE i
        iv_start_line   TYPE i
        iv_end_column   TYPE i
        iv_start_column TYPE i
      RAISING
        zcx_abapgit_commitlint.
    CLASS-METHODS to_alv
      IMPORTING
        it_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
    CLASS-METHODS build_catalog
      IMPORTING
        io_alv TYPE REF TO cl_salv_table
      RAISING
        zcx_abapgit_commitlint .
ENDCLASS.



CLASS zcl_abapgit_commitlint_ui IMPLEMENTATION.

  METHOD display_log.

    to_alv( it_log[] ).

    display(
      EXPORTING
        iv_end_line     = iv_end_line
        iv_start_line   = iv_start_line
        iv_end_column   = iv_end_column
        iv_start_column = iv_start_column ).

  ENDMETHOD.


  METHOD display.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = DATA(lo_alv)
          CHANGING
            t_table      = mt_alv[] ).

        build_catalog( lo_alv ).

        lo_alv->set_screen_popup(
          EXPORTING
            start_column = iv_start_column
            end_column   = iv_end_column
            start_line   = iv_start_line
            end_line     = iv_end_line
        ).
        lo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lo_alv_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            previous = lo_alv_exception.

    ENDTRY.

  ENDMETHOD.


  METHOD to_alv.
    mt_alv = VALUE #( FOR ls_log IN it_log (
        VALUE #( status  = SWITCH #( ls_log-severity
                                     WHEN zif_abapgit_commitlint_types=>mc_severity-error   THEN '1'
                                     WHEN zif_abapgit_commitlint_types=>mc_severity-warning THEN '2'
                                     WHEN zif_abapgit_commitlint_types=>mc_severity-info    THEN '3'
                                   )
                 rule    = ls_log-rule_name
                 message = ls_log-message )
        ) ).
  ENDMETHOD.


  METHOD build_catalog.
    TRY.

        io_alv->get_columns( )->set_exception_column( value = 'STATUS' group = '6' ).
        DATA(lt_cols) = io_alv->get_columns( )->get( ).
        LOOP AT lt_cols ASSIGNING FIELD-SYMBOL(<ls_col>).
          DATA(lo_col) = CAST cl_salv_column_list( <ls_col>-r_column ).
          CASE <ls_col>-columnname.
            WHEN 'STATUS'.
              lo_col->set_long_text( 'Status' ).
              lo_col->set_medium_text( 'Status' ).
              lo_col->set_short_text( 'Status' ).
              lo_col->set_optimized( ).
              lo_col->set_key( ).
            WHEN 'RULE'.
              lo_col->set_long_text( 'Rule' ).
              lo_col->set_medium_text( 'Rule' ).
              lo_col->set_short_text( 'Rule' ).
              lo_col->set_output_length( 10 ).
              lo_col->set_key( ).
            WHEN 'MESSAGE'.
              lo_col->set_long_text( 'Message' ).
              lo_col->set_medium_text( 'Message' ).
              lo_col->set_short_text( 'Message' ).
              lo_col->set_output_length( 30 ).
          ENDCASE.
        ENDLOOP.

      CATCH cx_salv_data_error INTO DATA(lo_alv_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            previous = lo_alv_exception.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
