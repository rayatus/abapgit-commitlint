INTERFACE zif_abapgit_commitlint_linter
  PUBLIC .

  METHODS lint
    IMPORTING iv_comment    TYPE string
    RETURNING VALUE(rt_log) TYPE zcl_abapgit_commitlint=>ty_t_log
    RAISING   zcx_abapgit_commitlint.

ENDINTERFACE.
