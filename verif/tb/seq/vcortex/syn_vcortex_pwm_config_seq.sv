`ifndef __SYN_VCORTEX_PWM_CONFIG_SEQ
`define __SYN_VCORTEX_PWM_CONFIG_SEQ

  class syn_vcortex_pwm_config_seq  #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_vcortex_pwm_config_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "vcortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt;

    int unsigned  pwm_val[];

    function new(string name  = "syn_vcortex_pwm_config_seq");
      super.new(name);

      pkt = new();
      pwm_val = new[16];
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_vcortex_pwm_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Vcortex PWM Config")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[16];
      pkt.data        = new[16](pwm_val);

      for(bit [7:0] i = 'd0; i < 'd16; i++)
      begin
        pkt.addr[i]   = {VCORTEX_BLK,VCORTEX_PWM_RAM_CODE,i};
      end

      //pkt.data has to be built by the test case !

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_vcortex_pwm_config_seq

`endif
