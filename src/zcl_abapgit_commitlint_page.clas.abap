CLASS zcl_abapgit_commitlint_page DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_gui_component
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_abapgit_gui_event_handler .
    INTERFACES zif_abapgit_gui_renderable .

    CONSTANTS: mc_id               TYPE string VALUE 'commitlint',
               mc_form_id          TYPE string VALUE 'repo-settings-form-commitLint',
               mc_linter_interface TYPE seoclsname VALUE 'ZIF_ABAPGIT_COMMITLINT_LINTER'.

    CONSTANTS: BEGIN OF mc_form_field,
                 group               TYPE string VALUE 'commitlint-settings',
                 is_active           TYPE string VALUE 'commitlint-is-active',
                 linter_class        TYPE string VALUE 'commitlint-linter-class',
                 url                 TYPE string VALUE 'commitlint-linter-url',
                 allow_push_if_error TYPE string VALUE 'commitlint-allow-push-if-error',
                 button_save         TYPE string VALUE 'commitlint-save',
               END OF mc_form_field.

    CLASS-METHODS create
      IMPORTING
        !io_repo       TYPE REF TO zcl_abapgit_repo
      RETURNING
        VALUE(ri_page) TYPE REF TO zif_abapgit_gui_renderable
      RAISING
        zcx_abapgit_commitlint .

    CLASS-METHODS enhance_repo_toolbar
      IMPORTING io_menu TYPE REF TO zcl_abapgit_html_toolbar
                iv_key  TYPE zif_abapgit_persistence=>ty_value
                iv_act  TYPE string.

    METHODS constructor
      IMPORTING
        !io_repo TYPE REF TO zcl_abapgit_repo
      RAISING
        zcx_abapgit_commitlint .

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_commitlint_settings,
             active TYPE abap_bool,
           END OF ty_commitlint_settings.

    DATA mo_form_data TYPE REF TO zcl_abapgit_string_map .
    DATA mo_validation_log TYPE REF TO zcl_abapgit_string_map .
    DATA mo_repo TYPE REF TO zcl_abapgit_repo .
    DATA mo_form TYPE REF TO zcl_abapgit_html_form .
    DATA mo_form_util TYPE REF TO zcl_abapgit_html_form_utils .

    DATA ms_commitlint_settings TYPE ty_commitlint_settings.

    CLASS-DATA: BEGIN OF ms_pages,
                  sett_locl TYPE REF TO zif_abapgit_gui_renderable,
                END OF ms_pages.

    METHODS get_form_schema
      RETURNING
        VALUE(ro_form) TYPE REF TO zcl_abapgit_html_form
      RAISING
        zcx_abapgit_commitlint .

    METHODS read_settings
      RAISING
        zcx_abapgit_commitlint .

    METHODS save_settings
      RAISING
        zcx_abapgit_commitlint.

    METHODS validate_form
      IMPORTING
        !io_form_data            TYPE REF TO zcl_abapgit_string_map
      RETURNING
        VALUE(ro_validation_log) TYPE REF TO zcl_abapgit_string_map
      RAISING
        zcx_abapgit_commitlint
        zcx_abapgit_exception .

    METHODS get_form_data
      RETURNING
        VALUE(rs_settings) TYPE zabapcommitlint.

    METHODS set_form_data
      IMPORTING is_settings TYPE zabapcommitlint
      RAISING   zcx_abapgit_commitlint.

ENDCLASS.



CLASS zcl_abapgit_commitlint_page IMPLEMENTATION.

  METHOD zif_abapgit_gui_event_handler~on_event.

    mo_form_data = mo_form_util->normalize( ii_event->form_data( ) ).

    CASE ii_event->mv_action.
      WHEN zif_abapgit_definitions=>c_action-go_back.
        rs_handled-state = mo_form_util->exit( mo_form_data ).

      WHEN mc_form_field-button_save.
        TRY.
            mo_validation_log = validate_form( mo_form_data ).
            IF mo_validation_log->is_empty( ) = abap_true.
              save_settings( ).
            ENDIF.
            rs_handled-state = zcl_abapgit_gui=>c_event_state-re_render.
          CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).
            zcx_abapgit_exception=>raise( iv_text = lo_exception->get_text( )
                                          ix_previous = lo_exception ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.

  METHOD zif_abapgit_gui_renderable~render.
    register_handlers( ).

    IF mo_form_util->is_empty( mo_form_data ) = abap_true.
      TRY.
          read_settings( ).
        CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).
          zcx_abapgit_exception=>raise( iv_text     = lo_exception->get_text( )
                                        ix_previous = lo_exception ).
      ENDTRY.
    ENDIF.

    CREATE OBJECT ri_html TYPE zcl_abapgit_html.

    ri_html->add( `<div class="repo">` ).

    ri_html->add( zcl_abapgit_gui_chunk_lib=>render_repo_top(
      io_repo               = mo_repo
      iv_show_commit        = abap_false
      iv_interactive_branch = abap_true ) ).

    ri_html->add( mo_form->render(
      io_values         = mo_form_data
      io_validation_log = mo_validation_log ) ).

    ri_html->add( `</div>` ).
  ENDMETHOD.

  METHOD create.
    DATA lo_component TYPE REF TO zcl_abapgit_commitlint_page.

    CREATE OBJECT lo_component
      EXPORTING
        io_repo = io_repo.

    TRY.
        ri_page = zcl_abapgit_gui_page_hoc=>create(
          iv_page_title      = 'CommitLint settings'
          io_page_menu       = zcl_abapgit_gui_chunk_lib=>settings_repo_toolbar(
                                 iv_key = io_repo->get_key( )
                                 iv_act = mc_id )
          ii_child_component = lo_component ).

      CATCH zcx_abapgit_exception INTO DATA(lo_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint EXPORTING previous = lo_exception.
    ENDTRY.

  ENDMETHOD.

  METHOD constructor.

    super->constructor( ).
    CREATE OBJECT mo_validation_log.
    CREATE OBJECT mo_form_data.
    mo_repo = io_repo.
    mo_form = get_form_schema( ).
    mo_form_util = zcl_abapgit_html_form_utils=>create( mo_form ).

    read_settings( ).

  ENDMETHOD.

  METHOD get_form_schema.

    ro_form = zcl_abapgit_html_form=>create(
      iv_form_id   = mc_form_id
      "iv_help_page = 'https://docs.abapgit.org/settings-local.html'
    ).

    ro_form->start_group(
      iv_name        = mc_form_field-group
      iv_label       = 'CommitLint Settings'
      iv_hint        = 'Settings valid for this system only'
    )->checkbox(
      iv_name        = mc_form_field-is_active
      iv_label       = 'Activate CommitLint'
      iv_hint        = 'Is commitLint activated for this repo?'
    )->text(
      iv_name        = mc_form_field-linter_class
      iv_label       = 'Lintern'
      iv_upper_case  = abap_true
      iv_condense    = abap_true
      iv_max         = 30
      iv_hint        = |ABAP Class that implements { mc_linter_interface  }|
    )->text(
      iv_name        = mc_form_field-url
      iv_label       = 'URL'
      iv_condense    = abap_true
      iv_hint        = 'URL where the Linter is hosted'
    )->checkbox(
      iv_name        = mc_form_field-allow_push_if_error
      iv_label       = 'Allow push if error'
      iv_hint        = 'Allow commit push even if commit message has errors?'
    )->command(
      iv_label       = 'Save Settings'
      iv_cmd_type    = zif_abapgit_html_form=>c_cmd_type-input_main
      iv_action      = mc_form_field-button_save
    )->command(
      iv_label       = 'Back'
      iv_action      = zif_abapgit_definitions=>c_action-go_back ).

  ENDMETHOD.

  METHOD read_settings.

    DATA(ls_settings) = NEW zcl_abapgit_commitlint_db(  )->get_settings( CAST zif_abapgit_repo_online( mo_repo ) ).
    set_form_data( ls_settings ).

  ENDMETHOD.

  METHOD save_settings.
    NEW zcl_abapgit_commitlint_db(  )->save_settings( io_repo = CAST zif_abapgit_repo_online( mo_repo )
                                                      is_settings = get_form_data( ) ).

  ENDMETHOD.


  METHOD enhance_repo_toolbar.
    "ToDo: Move this into an UserExit!
    io_menu->add( iv_txt = 'CommitLint'
                  iv_act = |{ mc_id }?key={ iv_key }|
                  iv_cur = boolc( iv_act = mc_id ) ).

  ENDMETHOD.


  METHOD validate_form.

    DATA:
      lv_folder           TYPE string,
      lv_len              TYPE i,
      lv_component        TYPE zif_abapgit_dot_abapgit=>ty_requirement-component,
      lv_min_release      TYPE zif_abapgit_dot_abapgit=>ty_requirement-min_release,
      lv_min_patch        TYPE zif_abapgit_dot_abapgit=>ty_requirement-min_patch,
      lv_version_constant TYPE string,
      lx_exception        TYPE REF TO zcx_abapgit_exception.

    ro_validation_log = mo_form_util->validate( io_form_data ).
    DATA(ls_settings) = get_form_data(  ).
    IF ls_settings-active = abap_true AND ls_settings-linter IS INITIAL.
      ro_validation_log->set( iv_key = mc_form_field-linter_class
                              iv_val = |Enter a valid Lintern class| ).
    ENDIF.
    IF ls_settings-active = abap_true AND ls_settings-linter IS NOT INITIAL.

      TRY.
          DATA(lt_implementing_classes) = NEW cl_oo_interface( intfname = mc_linter_interface  )->get_implementing_classes(  ).
          IF NOT line_exists( lt_implementing_classes[ clsname = ls_settings-linter ] ).
            ro_validation_log->set( iv_key = mc_form_field-linter_class
                                   iv_val = |{ ls_settings-linter } does not implement { mc_linter_interface  }| ).
          ENDIF.
        CATCH cx_class_not_existent INTO DATA(lo_exception).
          RAISE EXCEPTION TYPE zcx_abapgit_commitlint
            EXPORTING
              message  = |Interface { mc_linter_interface  } does not exist.|
              previous = lo_exception.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD set_form_data.
    TRY.
        mo_form_data->set(
            iv_key = mc_form_field-is_active
            iv_val = is_settings-active
        )->set(
            iv_key = mc_form_field-linter_class
            iv_val = is_settings-linter
        )->set(
            iv_key = mc_form_field-allow_push_if_error
            iv_val = is_settings-allow_push_if_error
        )->set(
            iv_key = mc_form_field-url
            iv_val = is_settings-url
        ).

        mo_form_util->set_data( mo_form_data ).

      CATCH zcx_abapgit_exception INTO DATA(lo_exception).
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint EXPORTING previous = lo_exception.
    ENDTRY.
  ENDMETHOD.
  METHOD get_form_data.

    rs_settings-active              = mo_form_data->get( mc_form_field-is_active ).
    rs_settings-linter              = mo_form_data->get( mc_form_field-linter_class ).
    rs_settings-allow_push_if_error = mo_form_data->get( mc_form_field-allow_push_if_error ).
    rs_settings-url                 = mo_form_data->get( mc_form_field-url ).

  ENDMETHOD.

ENDCLASS.
