`ifndef __SYN_FGYRUS_BUTTER_AGENT
`define __SYN_FGYRUS_BUTTER_AGENT

  class syn_fgyrus_butter_agent extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_fgyrus_butter_agent)

    parameter type  ING_PKT_TYPE  = syn_fgyrus_fft_seq_item;
    parameter type  EGR_PKT_TYPE  = syn_complex_seq_item;
    parameter type  INTF_TYPE     = virtual syn_fgyrus_butter_if.TB;

    syn_fgyrus_butter_mon#(ING_PKT_TYPE,EGR_PKT_TYPE,INTF_TYPE) mon;
    syn_fgyrus_butter_sb#(ING_PKT_TYPE,EGR_PKT_TYPE)            sb;

    OVM_FILE  f;

    function new(string name  = "syn_fgyrus_butter_agent", ovm_component parent = null);
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

      mon   = syn_fgyrus_butter_mon#(ING_PKT_TYPE,EGR_PKT_TYPE,INTF_TYPE)::type_id::create("syn_fgyrus_butter_mon",this);
      sb    = syn_fgyrus_butter_sb#(ING_PKT_TYPE,EGR_PKT_TYPE)::type_id::create("syn_fgyrus_butter_sb",this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction
    
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      mon.IngressMon2Sb_port.connect(sb.Drvr2Sb_port);
      mon.EgressMon2Sb_port.connect(sb.Mon2Sb_port);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_fgyrus_butter_mon [mon]",OVM_LOW);

      mon.enable  = 0;

    endfunction : disable_agent

  endclass  : syn_fgyrus_butter_agent

`endif
