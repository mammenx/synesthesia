`ifndef __SYN_ACORTEX_ADC_CAP_SEQ
`define __SYN_ACORTEX_ADC_CAP_SEQ

  class syn_acortex_adc_cap_seq   #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_adc_cap_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt,rsp;

    int lcap[],rcap[];

    bit bps;  //1->32bps, 0->16bps
    int fs;   //Sampling freq

    function new(string name  = "syn_acortex_adc_cap_seq");
      super.new(name);

      pkt = new();
      rsp = new();
      lcap  = new[128];
      rcap  = new[128];
      bps = 1;
      fs  = 44100;
    endfunction


    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_adc_cap_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Audio Src Select Sequence")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  ACORTEX_AUDIO_SRC_SEL_REG, 8'd0};
      pkt.data        = new[1];
      pkt.data[0]     = 'h0;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex FS Config Sequence")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  DAC_DRVR, DAC_DRVR_FS_DIV_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = 6250000 / fs;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture Config Sequence")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  ADC_START_CAPTURE, 8'd0};
      pkt.data        = new[1];
      pkt.data[0]     = $random;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Enable Sequence")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  DAC_DRVR, DAC_DRVR_CTRL_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = {'h0,bps,1'b1,1'b0};  //bit[1] is adc_enable

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      while(1)
      begin
        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture Poll Sequence")));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.av_xtn      = READ;
        pkt.addr        = new[1];
        pkt.addr[0]     = {ACORTEX_BLK,  ADC_START_CAPTURE, 8'd0};
        pkt.data        = new[1];
        pkt.data[0]     = $random;

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        get_response(rsp);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

        if(rsp.data[0]  & 'h1)  //Check for cap busy status
        begin
          p_sequencer.ovm_report_info(get_name(),$psprintf("ADC Capture busy"),OVM_LOW);
        end
        else
        begin
          p_sequencer.ovm_report_info(get_name(),$psprintf("ADC Capture completed"),OVM_LOW);
          break;
        end

        #100us;
      end

      #1;

      for(int i=0; i<128; i++)
      begin
        lcap[i] = 0;

        for(int j=0; j<2; j++)
        begin
          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture LDATA[%1d][%1d] Addr Write Sequence",i,j)));

          start_item(pkt);  //start_item has wait_for_grant()

          pkt.av_xtn      = WRITE;
          pkt.addr        = new[1];
          pkt.data        = new[1];
          pkt.addr[0]   = {ACORTEX_BLK,  ADC_LCAPTURE_RAM, 8'd0};
          pkt.data[0]   = ((i << 1) + j) & 'hff;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          #1;

          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture LDATA[%1d][%1d] Read Sequence",i,j)));

          start_item(pkt);  //start_item has wait_for_grant()

          pkt.av_xtn      = READ;
          pkt.addr        = new[1];
          pkt.data        = new[1];
          pkt.addr[0]   = {ACORTEX_BLK,  ADC_LCAPTURE_RAM, 8'd0};
          pkt.data[0]   = $random;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          #1;

          get_response(rsp);  //wait for response

          p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

          lcap[i] +=  (rsp.data[0] & 'hffff)  <<  (j * 16);
        end
      end

      for(int i=0; i<128; i++)
      begin
        rcap[i] = 0;

        for(int j=0; j<2; j++)
        begin
          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture RDATA[%1d][%1d] Addr Write Sequence",i,j)));

          start_item(pkt);  //start_item has wait_for_grant()

          pkt.av_xtn      = WRITE;
          pkt.addr        = new[1];
          pkt.data        = new[1];
          pkt.addr[0]   = {ACORTEX_BLK,  ADC_RCAPTURE_RAM, 8'd0};
          pkt.data[0]   = ((i << 1) + j) & 'hff;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          #1;

          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex ADC Capture RDATA[%1d][%1d] Read Sequence",i,j)));

          start_item(pkt);  //start_item has wait_for_grant()

          pkt.av_xtn      = READ;
          pkt.addr        = new[1];
          pkt.data        = new[1];
          pkt.addr[0]   = {ACORTEX_BLK,  ADC_RCAPTURE_RAM, 8'd0};
          pkt.data[0]   = $random;

          p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          #1;

          get_response(rsp);  //wait for response

          p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

          rcap[i] +=  (rsp.data[0] & 'hffff)  <<  (j * 16);
        end
      end


      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_adc_cap_seq

`endif
