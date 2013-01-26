`ifndef __SYN_ACORTEX_GENERIC_WAV_SEQ
`define __SYN_ACORTEX_GENERIC_WAV_SEQ

  class syn_acortex_generic_wav_seq  #(
                                      type  PKT_TYPE  = syn_av_st_seq_item,
                                      type  WAVE_TYPE = syn_wav_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_generic_wav_seq#(PKT_TYPE,WAVE_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_acortex_av_st_seqr)


    WAVE_TYPE wav_pkt;
    PKT_TYPE  pkt;

    int   blk_size; //block size in 16b words
    int   subBlk_avg_size;  //average sub block size in 16b words

    shortint  unsigned  raw_wav[];

    bit mb_key;

    function new(string name  = "syn_acortex_generic_wav_seq");
      super.new(name);

      wav_pkt = new();
      pkt = new();

      blk_size  = 131072;     //256KB
      subBlk_avg_size = 1024; //2KB
    endfunction

    /*  Body of sequence  */
    task  body();
      int subblk_no = 0;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_generic_wav_seq",OVM_LOW);

      p_sequencer.ovm_report_info(get_name(),$psprintf("Working with Wave File - \n%s",wav_pkt.sprint()),OVM_LOW);
      p_sequencer.Seqr2Sb_port.write(wav_pkt);

      //Test casw has to take care of building the wave packet. This sequence
      //just drives it & emmulates LEDOS [or at least tries to].

      wav_pkt.get_raw(raw_wav); //get raw contents of wave packet

      foreach(raw_wav[i])
      begin
        if((i !=  0)  &&  !(i % blk_size))
        begin
          p_sequencer.ovm_report_info(get_name(),$psprintf("Waiting for key ..."),OVM_LOW);

          p_sequencer.mb_acortex_data_sync.get(mb_key); //wait for go ahead

          p_sequencer.ovm_report_info(get_name(),$psprintf("Got key ..."),OVM_LOW);
        end

        //  if(i > raw_wav.size - 30)
        //  begin
        //    p_sequencer.ovm_report_info({get_name(),"[DEBUG]"},$psprintf("raw_wave[%d] = 0x%x",i,raw_wav[i]),OVM_LOW);
        //  end

        if(!(i%subBlk_avg_size))
        begin
          $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("Wave sub block : %d",subblk_no)));

          start_item(pkt);  //start_item has wait_for_grant()

          if((raw_wav.size  - i)  ==  (raw_wav.size % subBlk_avg_size))
          begin
            pkt.data  = new[raw_wav.size  % subBlk_avg_size];
          end
          else
          begin
            pkt.data  = new[subBlk_avg_size];
          end

          pkt.data[i-(subblk_no*subBlk_avg_size)] = raw_wav[i];
        end
        else if((!((i+1)%subBlk_avg_size))  ||  (i  ==  raw_wav.size -1))
        begin
          pkt.data[i-(subblk_no*subBlk_avg_size)] = raw_wav[i];

          p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

          finish_item(pkt);

          subblk_no++;

          if(i  !=  raw_wav.size -1)  #15us;
        end
        else
        begin
          pkt.data[i-(subblk_no*subBlk_avg_size)] = raw_wav[i];
        end
      end


      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_generic_wav_seq

`endif
