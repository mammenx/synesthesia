`ifndef __SYN_VCORTEX_PWM_MEM_ACC_SEQ
`define __SYN_VCORTEX_PWM_MEM_ACC_SEQ

  class syn_vcortex_pwm_mem_acc_seq #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_vcortex_pwm_mem_acc_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "vcortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt,rsp;
    shortint  no_locs;
    bit       error_found;

    function new(string name  = "syn_vcortex_pwm_mem_acc_seq");
      super.new(name);

      pkt = new();
      rsp = new();

      no_locs = 16;
      error_found = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      //shortint  unsigned  pwm_addr_base = {VCORTEX_BLK,(VCORTEX_PWM_RAM_CODE  <<  8)};
      shortint  unsigned  pwm_addr_base = {VCORTEX_BLK,VCORTEX_PWM_RAM_CODE,8'd0};
      int addr,dat,exp_dat;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_vcortex_pwm_mem_acc_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Vcortex PWM Mem Write")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[no_locs];
      pkt.data        = new[no_locs];

      foreach(pkt.addr[i])
      begin
        pkt.addr[i]     = pwm_addr_base + (i  & 'hf);
        pkt.data[i]     = i;
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      repeat($random  % 8)  #100;


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Vcortex PWM Mem Read")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = READ;
      pkt.addr        = new[no_locs];
      pkt.data        = new[no_locs];

      rsp.data        = new[no_locs];
      rsp.addr        = new[no_locs];

      foreach(pkt.addr[i])
      begin
        pkt.addr[i]     = pwm_addr_base + (i  & 'hf);
        pkt.data[i]     = $random;
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);


      get_response(rsp);  //wait for response

      p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp.sprint()),OVM_LOW);

      foreach(rsp.data[i])
      begin
        if(rsp.data[i]  !=  i)
        begin
          addr  = rsp.addr[i];
          dat   = rsp.data[i];
          exp_dat = pkt.data[i];
          p_sequencer.ovm_report_error(get_name(),$psprintf("Mismatch in addr[0x%x]\texp[0x%x]\tact[0x%x]", dat, exp_dat,addr),OVM_LOW);
          error_found = 1;
        end
      end

      if(error_found)
      begin
        p_sequencer.ovm_report_info(get_name(),"Sequence check failed ...",OVM_LOW);
      end
      else
      begin
        p_sequencer.ovm_report_info(get_name(),"Sequence check passed ...",OVM_LOW);
      end
 
      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_vcortex_pwm_mem_acc_seq

`endif
