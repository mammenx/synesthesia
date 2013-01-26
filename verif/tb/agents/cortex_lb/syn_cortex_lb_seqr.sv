`ifndef __SYN_CORTEX_LB_SEQR
`define __SYN_CORTEX_LB_SEQR

class syn_cortex_lb_seqr #(type  PKT_TYPE  = syn_av_mm_seq_item)  extends ovm_sequencer #(PKT_TYPE,PKT_TYPE); //req, rsp

    /*  Register with factory */
    `ovm_component_param_utils(syn_cortex_lb_seqr#(PKT_TYPE))
  
    OVM_FILE  f;

    //For inter sequence communication; connected in env
    mailbox#(bit)  mb_acortex_data_sync;

    //Connected in acortex_agent
    syn_reg_map#(9) dac_reg_map;

    function new (string name = "syn_cortex_lb_seqr", ovm_component parent);
        super.new(name, parent);
    endfunction : new

    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

 
endclass : syn_cortex_lb_seqr

`endif
