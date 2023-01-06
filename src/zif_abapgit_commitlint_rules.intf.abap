INTERFACE zif_abapgit_commitlint_rules
  PUBLIC .
  TYPES ty_v_severity TYPE c LENGTH 1.
  CONSTANTS: BEGIN OF mc_severity,
               error   TYPE ty_v_severity VALUE 'E',
               warning TYPE ty_v_severity VALUE 'W',
               info    TYPE ty_v_severity VALUE 'I',
             END OF mc_severity.

  CONSTANTS: BEGIN OF mc_rule_status,
               enabled  TYPE abap_bool VALUE abap_true,
               disabled TYPE abap_bool VALUE abap_false,
             END OF mc_rule_status.

  TYPES: BEGIN OF ty_s_rules,
           dummy TYPE c LENGTH 1,
         END   OF ty_s_rules.

  TYPES: BEGIN OF ty_s_comment,
           header TYPE string,
           body   TYPE string,
         END   OF ty_s_comment.

  TYPES: BEGIN OF ty_s_log,
           severity TYPE ty_v_severity,
           message  TYPE string,
         END   OF ty_s_log,
         ty_t_log TYPE STANDARD TABLE OF ty_s_log WITH EMPTY KEY.

  METHODS has_errors RETURNING VALUE(rv_has_errors) TYPE abap_bool.
  METHODS get_log
    EXPORTING et_log TYPE ty_t_log.

  METHODS set_comment
    IMPORTING is_comment TYPE ty_s_comment.

  METHODS set
    IMPORTING
      iv_json TYPE string.

  METHODS get_default
    RETURNING VALUE(rv_json) TYPE string.

  METHODS validate.

ENDINTERFACE.
