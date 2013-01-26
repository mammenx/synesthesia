`ifndef __SYN_ACORTEX_VIRTUAL_SEQR
`define __SYN_ACORTEX_VIRTUAL_SEQR

class syn_acortex_virtual_seqr extends ovm_sequencer;

    /*  Register with factory */
    `ovm_component_utils(syn_acortex_virtual_seqr)

    //connected in acortex_agent
    syn_cortex_lb_seqr#(syn_av_mm_seq_item)        av_mm_seqr;
    syn_acortex_av_st_seqr#(syn_av_st_seq_item)    av_st_seqr;


    OVM_FILE  f;

    function new (string name = "syn_acortex_virtual_seqr", ovm_component parent);
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

 
endclass : syn_acortex_virtual_seqr

`endif
