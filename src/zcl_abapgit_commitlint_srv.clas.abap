CLASS zcl_abapgit_commitlint_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_commitlint_linter.

    CONSTANTS mc_poc_url TYPE string VALUE 'https://abap-srv-commitlint-shiny-klipspringer-bk.cfapps.us10-001.hana.ondemand.com/'.

    METHODS constructor.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_url TYPE string.

    CONSTANTS: BEGIN OF mc_uri,
                 lint TYPE string VALUE '/lint',
               END   OF mc_uri.

    METHODS create_http_client
      RETURNING VALUE(ri_client) TYPE REF TO if_http_client
      RAISING   zcx_abapgit_commitlint.

    METHODS to_json
      IMPORTING ir_data        TYPE data
      RETURNING VALUE(rv_json) TYPE string
      RAISING   zcx_abapgit_commitlint.

    METHODS send_recive
      IMPORTING ii_client          TYPE REF TO if_http_client
      RETURNING VALUE(rv_response) TYPE string
      RAISING   zcx_abapgit_commitlint.
    METHODS to_log
      IMPORTING
                iv_json       TYPE string
      RETURNING VALUE(rt_log) TYPE zif_abapgit_commitlint_types=>ty_t_log
      RAISING   zcx_abapgit_commitlint.

ENDCLASS.



CLASS zcl_abapgit_commitlint_srv IMPLEMENTATION.

  METHOD constructor.
    mv_url = mc_poc_url.
  ENDMETHOD.

  METHOD create_http_client.
    cl_http_client=>create_by_url(
      EXPORTING
        url    = |{ mv_url }|
        ssl_id = 'ANONYM'
      IMPORTING
        client = ri_client
      EXCEPTIONS
        OTHERS = 999 ).
    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          message = |Create_client error: sy-subrc={ sy-subrc }, url={ mv_url }|.
    ENDIF.
  ENDMETHOD.

  METHOD to_json.

    DATA(lo_ajson) = NEW zcl_abapgit_ajson(  ).
    TRY.
        rv_json = lo_ajson->set( iv_path = '/message' iv_val = ir_data )->stringify(  ).
      CATCH zcx_abapgit_ajson_error INTO DATA(lo_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            previous = lo_exception.
    ENDTRY.


  ENDMETHOD.

  METHOD send_recive.

    ii_client->send(
    " EXPORTING
    "   timeout                    = ms_config-http_timeout
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5 ).
    IF sy-subrc  = 0.
      ii_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          OTHERS                     = 4 ).
    ENDIF.

    IF sy-subrc <> 0.
      DATA lv_ecode TYPE i.
      DATA lv_emessage TYPE string.
      ii_client->get_last_error(
        IMPORTING
          code    = lv_ecode
          message = lv_emessage ).

      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          message = |{ lv_ecode } { lv_emessage }|.
    ENDIF.

    DATA lv_scode TYPE i.
    DATA lv_sreason TYPE string.

    ii_client->response->get_status(
      IMPORTING
        code   = lv_scode
        reason = lv_sreason ).
    rv_response = ii_client->response->get_cdata( ).

    IF rv_response IS INITIAL.
      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          message = |API request failed [{ lv_scode }]|.
    ENDIF.

    IF lv_scode <> 200.
      "server not reachable
      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          message = |{ rv_response }|.
    ENDIF.

  ENDMETHOD.

  METHOD to_log.

    TRY.

        DATA(li_reader) = zcl_abapgit_ajson=>parse( iv_json ).

        DATA(lt_node) = li_reader->members( '/errors' ).
        LOOP AT lt_node INTO DATA(lv_node).
          DATA(lv_prefix) = '/errors/' && lv_node.
          INSERT VALUE #( severity   = zif_abapgit_commitlint_types=>mc_severity-error
                           rule_name  = li_reader->get_string( lv_prefix && '/name' )
                           message    = li_reader->get_string( lv_prefix && '/message' )
                        ) INTO TABLE rt_log.

        ENDLOOP.

        lt_node = li_reader->members( '/warnings' ).
        LOOP AT lt_node INTO lv_node.
          lv_prefix = '/warnings/' && lv_node.
          INSERT VALUE #( severity   = zif_abapgit_commitlint_types=>mc_severity-warning
                           rule_name  = li_reader->get_string( lv_prefix && '/name' )
                           message    = li_reader->get_string( lv_prefix && '/message' )
                        ) INTO TABLE rt_log.
        ENDLOOP.

      CATCH zcx_abapgit_ajson_error INTO DATA(lo_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            previous = lo_exception
            message  = lo_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_abapgit_commitlint_linter~lint.

    TRY.
        DATA(li_client) = create_http_client(  ).

        cl_http_utility=>set_request_uri(
          request = li_client->request
          uri     = mc_uri-lint ).

        li_client->request->set_method( if_http_request=>co_request_method_post ).
        li_client->request->set_compression( ).

        li_client->request->set_cdata( to_json( iv_comment ) ) .

        li_client->request->set_header_field(
          name  = 'content-type'
          value = 'text/plain; charset=utf-8' ).

        rt_log = to_log( EXPORTING iv_json = send_recive( li_client ) ).
        li_client->close(  ).

      CLEANUP.
        IF li_client IS BOUND.
          li_client->close( ).
        ENDIF.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
