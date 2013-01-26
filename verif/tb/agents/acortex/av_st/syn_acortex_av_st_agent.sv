`ifndef __SYN_ACORTEX_AV_ST_AGENT
`define __SYN_ACORTEX_AV_ST_AGENT


  class syn_acortex_av_st_agent extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_acortex_av_st_agent)

    parameter type  PKT_TYPE    = syn_av_st_seq_item;
    parameter type  WAVE_TYPE   = syn_wav_seq_item;
    parameter type  INTF_TYPE   = virtual syn_av_st_if.TB;

    syn_acortex_av_st_drvr#(PKT_TYPE,INTF_TYPE) drvr;
    syn_acortex_av_st_seqr#(PKT_TYPE,WAVE_TYPE) seqr;

    OVM_FILE  f;

    function new(string name  = "syn_acortex_av_st_agent", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new

    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      drvr   = syn_acortex_av_st_drvr#(PKT_TYPE,INTF_TYPE)::type_id::create("syn_acortex_av_st_drvr",this);
      seqr   = syn_acortex_av_st_seqr#(PKT_TYPE,WAVE_TYPE)::type_id::create("syn_acortex_av_st_seqr",this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      drvr.seq_item_port.connect(seqr.seq_item_export);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_acortex_av_st_drvr [drvr] ",OVM_LOW);

      drvr.enable = 0;

    endfunction : disable_agent


  endclass  : syn_acortex_av_st_agent

`endif
