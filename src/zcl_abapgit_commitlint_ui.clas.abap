CLASS zcl_abapgit_commitlint_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS display_log
      IMPORTING it_log TYPE zcl_abapgit_commitlint=>ty_t_log
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
            start_column = 1
            end_column   = 10
            start_line   = 1
            end_line     = 5
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
