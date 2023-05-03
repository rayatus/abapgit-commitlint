INTERFACE zif_abapgit_commitlint_types
  PUBLIC .

  TYPES ty_v_severity TYPE c LENGTH 1.
  CONSTANTS: BEGIN OF mc_severity,
               error   TYPE ty_v_severity VALUE 'E',
               warning TYPE ty_v_severity VALUE 'W',
               info    TYPE ty_v_severity VALUE 'I',
             END OF mc_severity.

  TYPES: BEGIN OF ty_s_message_log,
           severity  TYPE ty_v_severity,
           rule_name TYPE string,
           message   TYPE string,
         END   OF ty_s_message_log,
         ty_t_log TYPE STANDARD TABLE OF ty_s_message_log WITH EMPTY KEY.

ENDINTERFACE.
