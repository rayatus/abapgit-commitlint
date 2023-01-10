CLASS zcl_abapgit_commitlint_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS display_log
      IMPORTING it_log          TYPE zcl_abapgit_commitlint=>ty_t_log
                iv_start_column TYPE i DEFAULT 1
                iv_end_column   TYPE i DEFAULT 60
                iv_start_line   TYPE i DEFAULT 1
                iv_end_line     TYPE i DEFAULT 10
      RAISING   zcx_abapgit_exception.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_commitlint_ui IMPLEMENTATION.

  METHOD display_log.

    DATA(lt_log_alv) = it_log[].    "So that SALV could accept it in "change"

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = DATA(lo_alv)
          CHANGING
            t_table      = lt_log_alv ).

        lo_alv->get_columns( )->set_optimize( ).

        lo_alv->set_screen_popup(
          EXPORTING
            start_column = iv_start_column
            end_column   = iv_end_column
            start_line   = iv_start_line
            end_line     = iv_end_line
        ).
        lo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lo_alv_exception).
        zcx_abapgit_exception=>raise(
          EXPORTING
            iv_text     = 'CommitLit exception while displaying report log'
            ix_previous = lo_alv_exception ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
