`ifndef __SYN_ACORTEX_CODEC_ADC_SEQ
`define __SYN_ACORTEX_CODEC_ADC_SEQ

  class syn_acortex_codec_adc_seq   #(
                                  type  PKT_TYPE  = syn_dac_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_codec_adc_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_acortex_codec_adc_seqr)


    PKT_TYPE  pkt;
    int       ldata[];  //must be initialised in test case
    int       rdata[];  //must be initialised in test case

    function new(string name  = "syn_acortex_codec_adc_seq");
      super.new(name);

      pkt = new();
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_codec_adc_seq",OVM_LOW);

      foreach(ldata[i])
      begin
        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("ADC Pkt[%1d]",i)));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.ldata = ldata[i];
        pkt.rdata = rdata[i];

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        #1;
      end

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_codec_adc_seq

`endif
