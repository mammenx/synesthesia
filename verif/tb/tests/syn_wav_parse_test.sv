class syn_wav_parse_test extends syn_base_test;

  `ovm_component_utils(syn_wav_parse_test)

  OVM_FILE  f;

  function new (string name="syn_wav_parse_test", ovm_component parent=null);
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


    ovm_report_info(get_full_name(),"End of build",OVM_LOW);
  endfunction : build

  function  void  connect();
    super.connect();

    ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

    ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
  endfunction : connect

  virtual task run ();
    ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

    super.env.sprint();

    #500;

    super.acortex_vseq.wav_seq.wav_pkt.parse_wav("../wav/1kHz_44100Hz_16bit_05sec.wav",256);
    //super.acortex_vseq.wav_seq.wav_pkt.parse_wav("../wav/pcm-8000-16-2.wav",256);

    ovm_report_info(get_full_name(),$psprintf("Wave pkt - \n%s",super.acortex_vseq.wav_seq.wav_pkt.sprint()),OVM_LOW);

    super.run_dut();

    //  ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    //  global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_wav_parse_test
