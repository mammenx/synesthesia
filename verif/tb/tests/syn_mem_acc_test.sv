class syn_mem_acc_test extends syn_base_test;

  `ovm_component_utils(syn_mem_acc_test)


  syn_fgyrus_fft_ram_acc_seq#(MM_PKT_TYPE)  fgyrus_fft_real_ram_acc_seq;
  syn_fgyrus_fft_ram_acc_seq#(MM_PKT_TYPE)  fgyrus_fft_im_ram_acc_seq;
  syn_acortex_sram_acc_seq#(MM_PKT_TYPE)    acortex_sram_acc_seq;
  syn_vcortex_pwm_mem_acc_seq#(MM_PKT_TYPE) vcortex_pwm_mem_acc_seq;


  OVM_FILE  f;

  function new (string name="syn_mem_acc_test", ovm_component parent=null);
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

      fgyrus_fft_real_ram_acc_seq   = syn_fgyrus_fft_ram_acc_seq#(MM_PKT_TYPE)::type_id::create("syn_fgyrus_fft_real_ram_acc_seq");
      fgyrus_fft_im_ram_acc_seq     = syn_fgyrus_fft_ram_acc_seq#(MM_PKT_TYPE)::type_id::create("syn_fgyrus_fft_im_ram_acc_seq");
      acortex_sram_acc_seq          = syn_acortex_sram_acc_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_sram_acc_seq");
      vcortex_pwm_mem_acc_seq       = syn_vcortex_pwm_mem_acc_seq#(MM_PKT_TYPE)::type_id::create("syn_vcortex_pwm_mem_acc_seq");

      fgyrus_fft_real_ram_acc_seq.real_n_im = 1;
      fgyrus_fft_im_ram_acc_seq.real_n_im   = 0;

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

    repeat(3)
    begin
      fgyrus_fft_real_ram_acc_seq.fgyrus_blk_code = FGYRUS_LCHNL_BLK;
      fgyrus_fft_real_ram_acc_seq.start(super.env.cortex_lb_agent.seqr);

      fgyrus_fft_real_ram_acc_seq.fgyrus_blk_code = FGYRUS_RCHNL_BLK;
      fgyrus_fft_real_ram_acc_seq.start(super.env.cortex_lb_agent.seqr);

      fgyrus_fft_im_ram_acc_seq.fgyrus_blk_code   = FGYRUS_LCHNL_BLK;
      fgyrus_fft_im_ram_acc_seq.start(super.env.cortex_lb_agent.seqr);

      fgyrus_fft_im_ram_acc_seq.fgyrus_blk_code   = FGYRUS_RCHNL_BLK;
      fgyrus_fft_im_ram_acc_seq.start(super.env.cortex_lb_agent.seqr);

      vcortex_pwm_mem_acc_seq.start(super.env.cortex_lb_agent.seqr);
    end

    acortex_sram_acc_seq.start(super.env.cortex_lb_agent.seqr);

    ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_mem_acc_test
