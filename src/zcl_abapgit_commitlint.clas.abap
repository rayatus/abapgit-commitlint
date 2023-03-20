CLASS zcl_abapgit_commitlint DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !is_comment TYPE zif_abapgit_git_definitions=>ty_comment
        !io_repo    TYPE REF TO zif_abapgit_repo_online
        !io_linter  TYPE REF TO zif_abapgit_commitlint_linter .

    METHODS has_errors
      RETURNING
        VALUE(rv_has_errors) TYPE abap_bool .

    METHODS get_log
      RETURNING
        VALUE(rt_log) TYPE zif_abapgit_commitlint_types=>ty_t_log .

    METHODS validate
      RAISING
        zcx_abapgit_commitlint .

    CLASS-METHODS get_linter
      IMPORTING
        !io_repo         TYPE REF TO zcl_abapgit_repo_online
      RETURNING
        VALUE(ro_linter) TYPE REF TO zif_abapgit_commitlint_linter
      RAISING
        zcx_abapgit_commitlint .

    CLASS-METHODS is_push_allowed_with_errors
      IMPORTING
        !io_repo          TYPE REF TO zcl_abapgit_repo_online
      RETURNING
        VALUE(rf_allowed) TYPE abap_bool
      RAISING
        zcx_abapgit_commitlint .

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: BEGIN OF ms_detail,
            comment        TYPE zif_abapgit_git_definitions=>ty_comment,
            repo           TYPE REF TO zif_abapgit_repo_online,
            linter         TYPE REF TO zif_abapgit_commitlint_linter,
            commitlint_url TYPE string,
          END OF ms_detail.

    DATA mt_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
    DATA mv_has_errors TYPE abap_bool.

    CLASS-METHODS create_linter
      IMPORTING iv_linter        TYPE zabapcommitlint-linter
      RETURNING VALUE(ro_linter) TYPE REF TO zif_abapgit_commitlint_linter
      RAISING   zcx_abapgit_commitlint .

    METHODS set_log
      IMPORTING
        it_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
ENDCLASS.



CLASS zcl_abapgit_commitlint IMPLEMENTATION.


  METHOD constructor.
    ms_detail-comment       = is_comment.
    ms_detail-repo          = io_repo.
    ms_detail-linter        = io_linter.
  ENDMETHOD.

  METHOD validate.
    set_log( ms_detail-linter->lint( iv_comment = ms_detail-comment-comment ) ).
  ENDMETHOD.

  METHOD has_errors.
    rv_has_errors = mv_has_errors.
  ENDMETHOD.

  METHOD get_log.
    rt_log = mt_log.
  ENDMETHOD.

  METHOD set_log.
    mt_log = it_log.
    IF line_exists( mt_log[ severity = zif_abapgit_commitlint_types=>mc_severity-error ] ).
      mv_has_errors = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD create_linter.
    TRY.
        CREATE OBJECT ro_linter TYPE (iv_linter).
      CATCH cx_sy_create_object_error.
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            message = |{ iv_linter } does not implement 'zif_abapgit_commitlint_linter' interface.|.
    ENDTRY.
  ENDMETHOD.

  METHOD get_linter.
    DATA(ls_settings) = new zcl_abapgit_commitlint_db(  )->get_settings( io_repo ).
    IF ls_settings-active = abap_true AND ls_settings-linter IS NOT INITIAL.
      ro_linter = create_linter( ls_settings-linter ).
      ro_linter->initialize( conv #( ls_settings-url ) ).
    ENDIF.
  ENDMETHOD.


  METHOD is_push_allowed_with_errors.
    rf_allowed = new zcl_abapgit_commitlint_db(  )->get_settings( io_repo )-allow_push_if_error.
  ENDMETHOD.
ENDCLASS.
