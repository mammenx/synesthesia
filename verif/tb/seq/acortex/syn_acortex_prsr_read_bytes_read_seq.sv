`ifndef __SYN_ACORTEX_PRSR_READ_BYTES_READ_SEQ
`define __SYN_ACORTEX_PRSR_READ_BYTES_READ_SEQ

  class syn_acortex_prsr_read_bytes_read_seq  #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE,PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_prsr_read_bytes_read_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt,rsp;

    int unsigned  prsr_bytes_read;

    function new(string name  = "syn_acortex_prsr_read_bytes_read_seq");
      super.new(name);

      pkt = new();
      rsp = new();

      prsr_bytes_read = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_prsr_read_bytes_read_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Wav Parser bytes read [h]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = READ;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  WAV_PRSR, PRSR_BYTES_READ_H_REG_ADDR};
      pkt.data        = new[1];

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      get_response(rsp);  //wait for response

      p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", pkt.sprint()),OVM_LOW);

      prsr_bytes_read = pkt.data[0];


      #150;


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Wav Parser bytes read [l]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = READ;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  WAV_PRSR, PRSR_BYTES_READ_L_REG_ADDR};
      pkt.data        = new[1];

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      get_response(rsp);  //wait for response

      p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", pkt.sprint()),OVM_LOW);

      prsr_bytes_read = (prsr_bytes_read  <<  16) | pkt.data[0];

      p_sequencer.ovm_report_info(get_name(),$psprintf("Total bytes read by wav parser = %d", prsr_bytes_read),OVM_LOW);

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_prsr_read_bytes_read_seq

`endif
