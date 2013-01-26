`ifndef __SYN_ACORTEX_DAC_DRVR_FS_DIV_SEQ
`define __SYN_ACORTEX_DAC_DRVR_FS_DIV_SEQ

  class syn_acortex_dac_drvr_fs_div_seq #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_dac_drvr_fs_div_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    shortint  fs_div_val;

    const int bclk_freq = 6250000;  //BCLK frequency

    PKT_TYPE  pkt;

    function new(string name  = "syn_acortex_dac_drvr_fs_div_seq");
      super.new(name);

      pkt = new();

      fs_div_val  = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_dac_drvr_fs_div_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Driver FS div config")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  DAC_DRVR, DAC_DRVR_FS_DIV_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = fs_div_val  & 'h7ff;  //11b field

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


    /*  function to calculate the fs div val  */
    function  void  update_fs_div(int fs);

      this.fs_div_val = bclk_freq / fs;

      //p_sequencer.ovm_report_info(get_name(),$psprintf("FS DIV val updated to %d",fs_div_val),OVM_LOW);

    endfunction : update_fs_div

  endclass  : syn_acortex_dac_drvr_fs_div_seq

`endif
