`ifndef __SYN_ACORTEX_INIT_SEQ
`define __SYN_ACORTEX_INIT_SEQ

  class syn_acortex_init_seq    #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_init_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt;

    syn_acortex_reset_seq#(PKT_TYPE)  rst_seq;

    function new(string name  = "syn_acortex_init_seq");
      super.new(name);

      pkt = new();

      rst_seq = syn_acortex_reset_seq#(PKT_TYPE)::type_id::create("syn_acortex_reset_seq");
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_init_seq",OVM_LOW);

      rst_seq.start(p_sequencer,  this);

      #100;

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Acortex Init")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[3];
      pkt.data        = new[3];

      pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_CLK_DIV_REG_ADDR};
      pkt.data[0]     = 8'd20;

      pkt.addr[1]     = {ACORTEX_BLK,  WAV_PRSR,   PRSR_CTRL_REG_ADDR};
      pkt.data[1]     = 1;

      pkt.addr[2]     = {ACORTEX_BLK,  DAC_DRVR,   DAC_DRVR_CTRL_REG_ADDR};
      pkt.data[2]     = 0;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_init_seq

`endif
