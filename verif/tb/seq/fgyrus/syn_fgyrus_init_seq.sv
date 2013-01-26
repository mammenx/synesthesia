`ifndef __SYN_FGYRUS_INIT_SEQ
`define __SYN_FGYRUS_INIT_SEQ

  class syn_fgyrus_init_seq    #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_fgyrus_init_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "fgyrus_reg_map.v"

    PKT_TYPE  pkt;

    bit[3:0]  fgyrus_blk_code;

    function new(string name  = "syn_fgyrus_init_seq");
      super.new(name);

      pkt = new();

      fgyrus_blk_code = 'd0;
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_fgyrus_init_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Fgyrus Enable")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.data        = new[1];

      pkt.addr[0]     = {fgyrus_blk_code,FGYRUS_REG_CODE,FGYRUS_CONTROL_REG_ADDR};
      pkt.data[0]     = 8'd1;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_fgyrus_init_seq

`endif
