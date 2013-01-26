`ifndef __SYN_ACORTEX_AGENT
`define __SYN_ACORTEX_AGENT

  class syn_acortex_agent extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_acortex_agent)

    parameter SRAM_DATA_W          = 16;
    parameter SRAM_ADDR_W          = 18;
    parameter type  SRAM_INTF_TYPE  = virtual syn_sram_if.TB;
    parameter type  WAV_PKT_TYPE    = syn_wav_seq_item;
    parameter type  DAC_PKT_TYPE    = syn_dac_seq_item;

    syn_acortex_av_st_agent     av_st_agent;
    syn_acortex_codec_agent     codec_agent;
    syn_acortex_sram_mem#(SRAM_DATA_W,SRAM_ADDR_W,SRAM_INTF_TYPE) sram_mem;
    syn_acortex_sb#(WAV_PKT_TYPE,DAC_PKT_TYPE)  sb;

    syn_acortex_virtual_seqr    vseqr;

    mailbox#(bit) mb_acortex_data_sync;

    OVM_FILE  f;

    function new(string name  = "syn_acortex_agent", ovm_component parent = null);
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

      av_st_agent   = syn_acortex_av_st_agent::type_id::create("syn_acortex_av_st_agent",this);
      codec_agent   = syn_acortex_codec_agent::type_id::create("syn_acortex_codec_agent",this);
      sram_mem      = syn_acortex_sram_mem#(SRAM_DATA_W,SRAM_ADDR_W,SRAM_INTF_TYPE)::type_id::create("syn_acortex_sram_mem",this);
      sb            = syn_acortex_sb#(WAV_PKT_TYPE,DAC_PKT_TYPE)::type_id::create("syn_acortex_sb", this);

      vseqr         = syn_acortex_virtual_seqr::type_id::create("syn_acortex_virtual_seqr",this);

      mb_acortex_data_sync = new(1);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

        vseqr.av_st_seqr  = this.av_st_agent.seqr;

        av_st_agent.seqr.mb_acortex_data_sync    = this.mb_acortex_data_sync;

        av_st_agent.seqr.Seqr2Sb_port.connect(sb.Seqr2Sb_port);
        codec_agent.dac_mon.Mon2Sb_port.connect(sb.Mon2Sb_port);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_acortex_av_st_agent [av_st_agent]",OVM_LOW);

      av_st_agent.disable_agent();

      ovm_report_info(get_name(),"Disabling syn_acortex_codec_agent [codec_agent]",OVM_LOW);
      codec_agent.disable_agent();

    endfunction : disable_agent

  endclass  : syn_acortex_agent

`endif
