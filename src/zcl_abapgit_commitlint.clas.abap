class ZCL_ABAPGIT_COMMITLINT definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_COMMENT type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_COMMENT "zif_abapgit_definitions=>ty_comment
      !IV_URL type STRING
      !IV_BRANCH_NAME type STRING
      !IO_LINTER type ref to ZIF_ABAPGIT_COMMITLINT_LINTER .
  methods HAS_ERRORS
    returning
      value(RV_HAS_ERRORS) type ABAP_BOOL .
  methods GET_LOG
    returning
      value(RT_LOG) type ZIF_ABAPGIT_COMMITLINT_TYPES=>TY_T_LOG .
  methods VALIDATE
    raising
      ZCX_ABAPGIT_COMMITLINT .
  class-methods GET_LINTER
    importing
      !IO_REPO type ref to ZCL_ABAPGIT_REPO_ONLINE
    returning
      value(RO_LINTER) type ref to ZIF_ABAPGIT_COMMITLINT_LINTER
    raising
      ZCX_ABAPGIT_COMMITLINT .
  class-methods IS_PUSH_ALLOWED_WITH_ERRORS
    importing
      !IO_REPO type ref to ZCL_ABAPGIT_REPO_ONLINE
    returning
      value(RF_ALLOWED) type ABAP_BOOL
    raising
      ZCX_ABAPGIT_COMMITLINT .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: BEGIN OF ms_detail,
            comment     TYPE zif_abapgit_git_definitions=>ty_comment,
            repo_url    TYPE string,
            branch_name TYPE string,
            linter      TYPE REF TO zif_abapgit_commitlint_linter,
          END OF ms_detail.

    DATA mt_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
    DATA mv_has_errors TYPE abap_bool.

    METHODS set_log
      IMPORTING
        it_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
ENDCLASS.



CLASS ZCL_ABAPGIT_COMMITLINT IMPLEMENTATION.


  METHOD constructor.
    ms_detail-branch_name   = iv_branch_name.
    ms_detail-comment       = is_comment.
    ms_detail-repo_url      = iv_url.
    ms_detail-linter        = io_linter.
  ENDMETHOD.


  METHOD validate.
    set_log( ms_detail-linter->lint( ms_detail-comment-comment ) ).
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


  METHOD get_linter.
    DATA(lv_repourl) = io_repo->get_url(  ).
    ro_linter = lcl_custo_reader=>factory(  )->get_linter_from_repourl( lv_repourl ).
  ENDMETHOD.


  METHOD is_push_allowed_with_errors.
    DATA(lv_repourl) = io_repo->get_url(  ).
    rf_allowed = lcl_custo_reader=>factory(  )->get_by_repourl( lv_repourl )-allow_push_if_error.
  ENDMETHOD.
ENDCLASS.
