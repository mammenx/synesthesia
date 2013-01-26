`ifndef __SYN_ACORTEX_CODEC_ADC_SEQR
`define __SYN_ACORTEX_CODEC_ADC_SEQR

class syn_acortex_codec_adc_seqr  #(type  PKT_TYPE  = syn_dac_seq_item
                                  ) extends ovm_sequencer #(PKT_TYPE);

    /*  Register with factory */
    `ovm_component_param_utils(syn_acortex_codec_adc_seqr#(PKT_TYPE))
  
    OVM_FILE  f;

    function new (string name = "syn_acortex_codec_adc_seqr", ovm_component parent);
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

 
endclass : syn_acortex_codec_adc_seqr

`endif
