class syn_data_path_32b_dual_test extends syn_base_test;

  `ovm_component_utils(syn_data_path_32b_dual_test)

  syn_acortex_init_seq#(MM_PKT_TYPE)        acortex_init_seq;
  syn_acortex_dac_drvr_en_seq#(MM_PKT_TYPE) dac_drvr_en_seq;
  syn_acortex_prsr_en_seq#(MM_PKT_TYPE)     prsr_en_seq;
  syn_acortex_generic_wav_seq#(ST_PKT_TYPE,WAVE_TYPE) wav_seq;
  syn_acortex_dac_drvr_fs_div_seq#(MM_PKT_TYPE) dac_drvr_fs_div_seq;
  syn_acortex_i2c_config_seq#(MM_PKT_TYPE)  i2c_config_seq;
  syn_fgyrus_init_seq#(MM_PKT_TYPE)         fgyrus_init_seq;

  OVM_FILE  f;

  function new (string name="syn_data_path_32b_dual_test", ovm_component parent=null);
      super.new (name, parent);
  endfunction : new 

  function  void  build();
    super.build();

    f = $fopen({"./logs/",get_full_name(),".log"});

    set_report_default_file(f);
    set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
    set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
    set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
    set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);


    ovm_report_info(get_full_name(),"Start of build",OVM_LOW);

    acortex_init_seq  = syn_acortex_init_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_init_seq");
    dac_drvr_en_seq   = syn_acortex_dac_drvr_en_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_dac_drvr_en_seq");
    prsr_en_seq       = syn_acortex_prsr_en_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_prsr_en_seq");
    wav_seq           = syn_acortex_generic_wav_seq#(ST_PKT_TYPE,WAVE_TYPE)::type_id::create("syn_acortex_generic_wav_seq");
    dac_drvr_fs_div_seq = syn_acortex_dac_drvr_fs_div_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_dac_drvr_fs_div_seq");
    i2c_config_seq    = syn_acortex_i2c_config_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_i2c_config_seq");
    fgyrus_init_seq   = syn_fgyrus_init_seq#(MM_PKT_TYPE)::type_id::create("syn_fgyrus_init_seq");

    ovm_report_info(get_full_name(),"End of build",OVM_LOW);
  endfunction : build

  function  void  connect();
    super.connect();

    ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

    ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
  endfunction : connect

  virtual task run ();
    bit key = 1;  //dummy key

    ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

    super.env.sprint();

    #500;

    this.wav_seq.wav_pkt.build_pkt(2,32,16000,1124);

    foreach(this.wav_seq.wav_pkt.data[i])
    begin
      this.wav_seq.wav_pkt.data[i] = i/2;


      //ovm_report_info(get_full_name(),$psprintf("data[%d] - %x",i,this.wav_seq.wav_pkt.data[i]),OVM_LOW);
    end

    ovm_report_info(get_full_name(),$psprintf("Wave pkt - \n%s",this.wav_seq.wav_pkt.sprint()),OVM_LOW);


    acortex_init_seq.start(super.env.cortex_lb_agent.seqr);

    i2c_config_seq.field  = "format";
    i2c_config_seq.val    = 'b11; //I2S mode
    i2c_config_seq.start(super.env.cortex_lb_agent.seqr);

    i2c_config_seq.field  = "iwl";
    i2c_config_seq.val    = 'b11; //32b samples
    i2c_config_seq.start(super.env.cortex_lb_agent.seqr);

    prsr_en_seq.start(super.env.cortex_lb_agent.seqr);

    dac_drvr_fs_div_seq.update_fs_div(16000);
    dac_drvr_fs_div_seq.start(super.env.cortex_lb_agent.seqr);

    dac_drvr_en_seq.start(super.env.cortex_lb_agent.seqr);

    fgyrus_init_seq.fgyrus_blk_code = FGYRUS_LCHNL_BLK;
    fgyrus_init_seq.start(super.env.cortex_lb_agent.seqr);

    fgyrus_init_seq.fgyrus_blk_code = FGYRUS_RCHNL_BLK;
    fgyrus_init_seq.start(super.env.cortex_lb_agent.seqr);

    fork
      begin
        wav_seq.start(super.env.acortex_agent.av_st_agent.seqr);
      end

      begin //making sure the key is there to be found!
        forever
        begin
          super.env.acortex_agent.mb_acortex_data_sync.try_put(key);
          #100;
        end
      end
    join_any

    #10000;

    ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_data_path_32b_dual_test
