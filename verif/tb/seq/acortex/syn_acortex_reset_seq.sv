`ifndef __SYN_ACORTEX_RESET_SEQ
`define __SYN_ACORTEX_RESET_SEQ

  class syn_acortex_reset_seq   #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_reset_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt;

    function new(string name  = "syn_acortex_reset_seq");
      super.new(name);

      pkt = new();
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_reset_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex Reset Command")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  RESET, 8'd0};
      pkt.data        = new[1];
      pkt.data[0]     = $random;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_reset_seq

`endif
