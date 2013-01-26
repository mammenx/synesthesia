`ifndef __SYN_ACORTEX_AV_ST_SEQR
`define __SYN_ACORTEX_AV_ST_SEQR

class syn_acortex_av_st_seqr #( type  PKT_TYPE  = syn_av_st_seq_item,
                                type  WAVE_TYPE = syn_wav_seq_item 
                              ) extends ovm_sequencer #(PKT_TYPE);

    /*  Register with factory */
    `ovm_component_param_utils(syn_acortex_av_st_seqr#(PKT_TYPE))
  
    OVM_FILE  f;

    ovm_analysis_port #(WAVE_TYPE) Seqr2Sb_port;

    //For inter sequence communication; connected in acortex_qgent
    mailbox#(bit) mb_acortex_data_sync;

    function new (string name = "syn_acortex_av_st_seqr", ovm_component parent);
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

      Seqr2Sb_port  = new("Seqr2Sb_port", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

 
endclass : syn_acortex_av_st_seqr

`endif
