`ifndef __SYN_FGYRUS_AGENT
`define __SYN_FGYRUS_AGENT

  class syn_fgyrus_agent  extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_fgyrus_agent)

    syn_fgyrus_butter_agent   butter_agent;
    syn_fgyrus_fft_agent      fft_agent;

    OVM_FILE  f;

    function new(string name  = "syn_fgyrus_agent", ovm_component parent = null);
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

      butter_agent  = syn_fgyrus_butter_agent::type_id::create("syn_fgyrus_butter_agent",this);
      fft_agent     = syn_fgyrus_fft_agent::type_id::create("syn_fgyrus_fft_agent",this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction
    
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_fgyrus_butter_agent [butter_agent]",OVM_LOW);

      butter_agent.disable_agent();

      ovm_report_info(get_name(),"Disabling syn_fgyrus_fft_agent [fft_agent]",OVM_LOW);

      fft_agent.disable_agent();

    endfunction : disable_agent



  endclass  : syn_fgyrus_agent

`endif
