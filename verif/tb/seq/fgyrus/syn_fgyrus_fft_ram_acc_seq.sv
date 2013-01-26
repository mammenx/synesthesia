`ifndef __SYN_FGYRUS_FFT_RAM_ACC_SEQ
`define __SYN_FGYRUS_FFT_RAM_ACC_SEQ

  class syn_fgyrus_fft_ram_acc_seq    #(
                                  type  PKT_TYPE  = syn_av_mm_seq_item 
                                ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_fgyrus_fft_ram_acc_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "fgyrus_reg_map.v"

    bit[3:0]  fgyrus_blk_code;  //need to be configured from syn_env !!

    PKT_TYPE  pkt,rsp;

    bit real_n_im;  //to select between Real & Imaginary FFT rams

    function new(string name  = "syn_fgyrus_fft_ram_acc_seq");
      super.new(name);

      pkt = new();
      rsp = new();

      fgyrus_blk_code = 'd0;

      real_n_im = 1;
    endfunction

    /*  Body of sequence  */
    task  body();
      shortint  ram_base_addr;
      bit error_found = 0;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_fgyrus_fft_ram_acc_seq",OVM_LOW);

      if(real_n_im)
      begin
        ram_base_addr = {fgyrus_blk_code,FGYRUS_FFT_REAL_RAM_CODE,8'd0};
      end
      else
      begin
        ram_base_addr = {fgyrus_blk_code,FGYRUS_FFT_IM_RAM_CODE,8'd0};
      end


      foreach(pkt.addr[i])
      begin
        pkt.addr[i] = ram_base_addr + i;
        pkt.data[i] = $urandom;
      end

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Fgyrus FFT RAM Write")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.addr  = new[128];
      pkt.data  = new[128];

      pkt.av_xtn      = WRITE;

      foreach(pkt.addr[i])
      begin
        pkt.addr[i] = ram_base_addr + i;
        pkt.data[i] = $urandom;
      end


      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Fgyrus FFT RAM Read")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.addr  = new[128];
      pkt.data  = new[128];

      pkt.av_xtn      = READ;

      foreach(pkt.addr[i])
      begin
        pkt.addr[i] = ram_base_addr + i;
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;

      get_response(rsp);  //wait for response

      p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", pkt.sprint()),OVM_LOW);

      foreach(rsp.data[i])
      begin
        if(rsp.data[i]  !=  pkt.data[i])
        begin
          error_found = 1;

          p_sequencer.ovm_report_error(get_name(),$psprintf("Mismatch in addr[%d]\texp[%d]\tact[%d]", rsp.addr[i],pkt.data[i],rsp.data[i]),OVM_LOW);
        end
      end

      if(!error_found)
      begin
        p_sequencer.ovm_report_info(get_name(),"Sequence check passed ...\n\n\n\n",OVM_LOW);
      end
      else
      begin
        p_sequencer.ovm_report_info(get_name(),"Sequence check failed ...\n\n\n\n",OVM_LOW);
      end

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_fgyrus_fft_ram_acc_seq

`endif
