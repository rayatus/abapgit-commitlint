CLASS zcl_abapgit_commitlint_rules DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_abapgit_commitlint_rules.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA ms_comment TYPE zif_abapgit_commitlint_rules=>ty_s_comment.

    METHODS header_max_length
      IMPORTING iv_severity   TYPE zif_abapgit_commitlint_rules=>ty_v_severity
                iv_max_length TYPE i DEFAULT 72
      RETURNING VALUE(rs_log) TYPE zif_abapgit_commitlint_rules=>ty_s_log.

ENDCLASS.



CLASS zcl_abapgit_commitlint_rules IMPLEMENTATION.

  METHOD header_max_length.

    IF strlen( ms_comment-header ) > iv_max_length.
      rs_log-message = condense( |Comment header max length is { iv_max_length }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~set_comment.
    ms_comment = is_comment.
  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~validate.

  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~get_default.

  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~set.

  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~get_log.

  ENDMETHOD.

  METHOD zif_abapgit_commitlint_rules~has_errors.

  ENDMETHOD.

ENDCLASS.
