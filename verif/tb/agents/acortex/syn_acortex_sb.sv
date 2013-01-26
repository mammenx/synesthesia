`ifndef __SYN_ACORTEX_SB
`define __SYN_ACORTEX_SB

`ovm_analysis_imp_decl(_sent_wav_pkt)
`ovm_analysis_imp_decl(_rcvd_dac_pkt)


  class syn_acortex_sb #( type  WAV_PKT_TYPE  = syn_wav_seq_item,
                          type  DAC_PKT_TYPE  = syn_dac_seq_item

                      ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(syn_acortex_sb#(WAV_PKT_TYPE, DAC_PKT_TYPE))

    WAV_PKT_TYPE  wav_pkt;
    int unsigned  sample_no;

    ovm_analysis_imp_sent_wav_pkt #(WAV_PKT_TYPE,syn_acortex_sb)   Seqr2Sb_port;
    ovm_analysis_imp_rcvd_dac_pkt #(DAC_PKT_TYPE,syn_acortex_sb)   Mon2Sb_port;

    OVM_FILE  f;

    function new(string name = "syn_acortex_sb", ovm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Seqr2Sb_port    = new("Seqr2Sb_port", this);
      Mon2Sb_port     = new("Mon2Sb_port", this);

      //  wav_pkt = new();

      sample_no = 0;

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    virtual function void write_sent_wav_pkt(input WAV_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_sent_wav_pkt]"},$psprintf("Received Wave pkt\n%s\n\n",pkt.sprint()),OVM_LOW);

      $cast(wav_pkt,  pkt.clone());
    endfunction : write_sent_wav_pkt


    virtual function void write_rcvd_dac_pkt(input DAC_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Received Dac sample no : %d\n%s",sample_no,pkt.sprint()),OVM_LOW);

      if(wav_pkt.subchunk1NoChnls ==  1)
      begin
        if(pkt.ldata  !=  wav_pkt.data[sample_no])
        begin
          ovm_report_error({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Mismatch in L-Channel - exp[%x], rcvd[%x]\n\n",wav_pkt.data[sample_no],pkt.ldata),OVM_LOW);
        end
        else if(pkt.rdata !=  0)
        begin
          ovm_report_error({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Mismatch in R-Channel - exp[0], rcvd[%x]\n\n",pkt.rdata),OVM_LOW);
        end
        else
        begin
          ovm_report_info({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Sample is perfect ...\n\n"),OVM_LOW);
        end
      end
      else  //Dual channel
      begin
        if(pkt.ldata  !=  wav_pkt.data[sample_no*2])
        begin
          ovm_report_error({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Mismatch in L-Channel - exp[%x], rcvd[%x]\n\n",wav_pkt.data[sample_no*2],pkt.ldata),OVM_LOW);
        end
        else if(pkt.rdata !=  wav_pkt.data[(sample_no*2)  + 1])
        begin
          ovm_report_error({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Mismatch in R-Channel - exp[%x], rcvd[%x]\n\n",wav_pkt.data[(sample_no*2) + 1],pkt.rdata),OVM_LOW);
        end
        else
        begin
          ovm_report_info({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Sample is perfect ...\n\n"),OVM_LOW);
        end
      end

      sample_no++;

      if(sample_no  >=  wav_pkt.no_samples)
      begin
        ovm_report_info({get_name(),"[write_rcvd_dac_pkt]"},$psprintf("Calling global_stop_request()"),OVM_LOW);

        global_stop_request();
      end

    endfunction : write_rcvd_dac_pkt



    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("syn_acortex_sb Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report
    
  endclass : syn_acortex_sb

`endif
