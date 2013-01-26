`ifndef __SYN_ACORTEX_STATUS_CHK_SEQ
`define __SYN_ACORTEX_STATUS_CHK_SEQ

  class syn_acortex_status_chk_seq  #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE,PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_status_chk_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt,rsp;

    bit mb_key;

    function new(string name  = "syn_acortex_status_chk_seq");
      super.new(name);

      pkt = new();
      rsp = new();

      mb_key  = 1;
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_status_chk_seq",OVM_LOW);

      forever
      begin
        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Polling SRAM Status")));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.av_xtn      = READ;
        pkt.addr        = new[1];
        pkt.addr[0]     = {ACORTEX_BLK,  SRAM, SRAM_STATUS_REG_ADDR};
        pkt.data        = new[1];

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        get_response(rsp);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

        if(rsp.data[0]  & 'h2)  //Check for almost empty flag
        begin
          p_sequencer.ovm_report_info(get_name(),$psprintf("SRAM almost empty ... giving key ..."),OVM_LOW);
          p_sequencer.mb_acortex_data_sync.try_put(mb_key); //give key
        end
        else
        begin
          p_sequencer.ovm_report_info(get_name(),$psprintf("SRAM has no space ... removing key ..."),OVM_LOW);
          p_sequencer.mb_acortex_data_sync.try_get(mb_key); //remove key if present
        end

        #10us;  //polling interval
      end


      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_status_chk_seq

`endif
