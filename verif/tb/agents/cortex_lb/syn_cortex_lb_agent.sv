`ifndef __SYN_CORTEX_LB_AGENT
`define __SYN_CORTEX_LB_AGENT

  class syn_cortex_lb_agent extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_cortex_lb_agent)

    parameter type  PKT_TYPE  = syn_av_mm_seq_item;
    parameter type  INTF_TYPE = virtual syn_cortex_lb_if.TB;

    syn_cortex_lb_drvr#(PKT_TYPE,INTF_TYPE) drvr;
    syn_cortex_lb_seqr#(PKT_TYPE)           seqr;

    OVM_FILE  f;

    function new(string name  = "syn_cortex_lb_agent", ovm_component parent = null);
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

      drvr   = syn_cortex_lb_drvr#(PKT_TYPE,INTF_TYPE)::type_id::create("syn_cortex_lb_drvr",this);
      seqr   = syn_cortex_lb_seqr#(PKT_TYPE)::type_id::create("syn_cortex_lb_seqr",this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      drvr.seq_item_port.connect(seqr.seq_item_export);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_cortex_lb_drvr [drvr]",OVM_LOW);

      drvr.enable = 0;

    endfunction : disable_agent

    virtual function  void  report();
      $fclose(f);
    endfunction : report

  endclass  : syn_cortex_lb_agent

`endif
