class syn_sine_16b_dual_10kHz extends syn_base_test;

  `ovm_component_utils(syn_sine_16b_dual_10kHz)

  OVM_FILE  f;

  function new (string name="syn_sine_16b_dual_10kHz", ovm_component parent=null);
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

    super.acortex_vseq.wav_seq.wav_pkt.build_pkt(2,16,16000,1024);

    /*
    foreach(super.acortex_vseq.wav_seq.wav_pkt.data[i])
    begin
      //super.acortex_vseq.wav_seq.wav_pkt.data[i] = i/2;
      super.acortex_vseq.wav_seq.wav_pkt.data[i] = $random;

      //ovm_report_info(get_full_name(),$psprintf("data[%d] - %x",i,super.acortex_vseq.wav_seq.wav_pkt.data[i]),OVM_LOW);
    end
    */

    super.acortex_vseq.wav_seq.wav_pkt.fill_sin(0,2000,1000);
    //super.acortex_vseq.wav_seq.wav_pkt.mix_sin(0,2000,100);
    //super.acortex_vseq.wav_seq.wav_pkt.mix_sin(0,4000,100);
    super.acortex_vseq.wav_seq.wav_pkt.fill_sin(1,1000,10000);
  //  super.acortex_vseq.wav_seq.wav_pkt.mix_sin(1,8000,10000);

    ovm_report_info(get_full_name(),$psprintf("Wave pkt - \n%s",super.acortex_vseq.wav_seq.wav_pkt.sprint()),OVM_LOW);

    super.run_dut();

    //  ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    //  global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_sine_16b_dual_10kHz
