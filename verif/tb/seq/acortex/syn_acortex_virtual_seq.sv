`ifndef __SYN_ACORTEX_VIRTUAL_SEQ
`define __SYN_ACORTEX_VIRTUAL_SEQ

  class syn_acortex_virtual_seq #(
                                  type  MM_PKT_TYPE  = syn_av_mm_seq_item, 
                                  type  ST_PKT_TYPE  = syn_av_st_seq_item,
                                  type  WAVE_TYPE    = syn_wav_seq_item 
                                ) extends ovm_sequence;

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_virtual_seq#(MM_PKT_TYPE,ST_PKT_TYPE,WAVE_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_acortex_virtual_seqr)

    /*  Child Sequences */
    syn_acortex_init_seq#(MM_PKT_TYPE)                      acortex_init_seq;
    syn_acortex_generic_wav_seq#(ST_PKT_TYPE,WAVE_TYPE)     wav_seq;
    syn_acortex_status_chk_seq#(MM_PKT_TYPE)                status_chk_seq;
    syn_acortex_prsr_read_bytes_read_seq#(MM_PKT_TYPE)      prsr_read_bytes_seq;
    syn_acortex_dac_drvr_en_seq#(MM_PKT_TYPE)               dac_drvr_en_seq;
    syn_acortex_prsr_en_seq#(MM_PKT_TYPE)                   prsr_en_seq;
    syn_acortex_dac_drvr_fs_div_seq#(MM_PKT_TYPE)           dac_drvr_fs_div_seq;
    syn_acortex_i2c_config_seq#(MM_PKT_TYPE)                i2c_config_seq;

    function new(string name  = "syn_acortex_virtual_seq");
      super.new(name);

      acortex_init_seq= syn_acortex_init_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_init_seq");
      wav_seq         = syn_acortex_generic_wav_seq#(ST_PKT_TYPE,WAVE_TYPE)::type_id::create("syn_acortex_generic_wav_seq");
      status_chk_seq  = syn_acortex_status_chk_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_status_chk_seq");
      prsr_read_bytes_seq = syn_acortex_prsr_read_bytes_read_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_prsr_read_bytes_read_seq");
      dac_drvr_en_seq = syn_acortex_dac_drvr_en_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_dac_drvr_en_seq");
      prsr_en_seq     = syn_acortex_prsr_en_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_prsr_en_seq");
      dac_drvr_fs_div_seq = syn_acortex_dac_drvr_fs_div_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_dac_drvr_fs_div_seq");
      i2c_config_seq  = syn_acortex_i2c_config_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_i2c_config_seq");

    endfunction

    /*  Body of sequence  */
    virtual task  body();
      int bytes_to_wait = 0;

      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_virtual_seq",OVM_LOW);

      acortex_init_seq.start(p_sequencer.av_mm_seqr,  this);

      i2c_config_seq.field  = "format";
      i2c_config_seq.val    = 'b11; //I2S mode
      i2c_config_seq.start(p_sequencer.av_mm_seqr,  this);

      dac_drvr_fs_div_seq.update_fs_div(wav_seq.wav_pkt.subchunk1SampleRate);
      dac_drvr_fs_div_seq.start(p_sequencer.av_mm_seqr, this);

      prsr_en_seq.start(p_sequencer.av_mm_seqr, this);

      #100;

      bytes_to_wait = 40  + ((wav_seq.wav_pkt.subchunk1NoChnls  * wav_seq.wav_pkt.subchunk1BitsPerSample  * 128)/8);

      fork
        begin //poll the SRAM occupancy for flow control
          p_sequencer.ovm_report_info(get_name(),$psprintf("Starting status_chk_seq"),OVM_LOW);

          status_chk_seq.start(p_sequencer.av_mm_seqr,  this);
        end

        begin //drive wave file data to the SRAM
          p_sequencer.ovm_report_info(get_name(),$psprintf("Starting wav_seq"),OVM_LOW);

          wav_seq.start(p_sequencer.av_st_seqr,  this);
        end

        begin //wait for parser to read enough bytes, then enable the DAC driver
          p_sequencer.ovm_report_info(get_name(),$psprintf("Waiting for %d bytes to be read by wav parser",bytes_to_wait),OVM_LOW);

          do
          begin
            prsr_read_bytes_seq.start(p_sequencer.av_mm_seqr, this);

            #1us;
          end
          while(prsr_read_bytes_seq.prsr_bytes_read < bytes_to_wait);


          i2c_config_seq.field  = "iwl";

          if(wav_seq.wav_pkt.subchunk1BitsPerSample ==  16)
          begin
            p_sequencer.ovm_report_info(get_name(),$psprintf("Configuring 16bps in Codec"),OVM_LOW);
            i2c_config_seq.val    = 'b00; //16b samples
          end
          else if(wav_seq.wav_pkt.subchunk1BitsPerSample  ==  32)
          begin
            p_sequencer.ovm_report_info(get_name(),$psprintf("Configuring 32bps in Codec"),OVM_LOW);
            i2c_config_seq.val    = 'b11; //32b samples
          end
          else  //unsupported bps!
          begin
            p_sequencer.ovm_report_fatal(get_name(),$psprintf("Unsupported Bps [%d] !!!",wav_seq.wav_pkt.subchunk1BitsPerSample),OVM_LOW);
          end

          i2c_config_seq.start(p_sequencer.av_mm_seqr,  this);

          p_sequencer.ovm_report_info(get_name(),$psprintf("Starting dac_drvr_en_seq"),OVM_LOW);
          dac_drvr_en_seq.start(p_sequencer.av_mm_seqr, this);
        end
      join

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_virtual_seq

`endif
