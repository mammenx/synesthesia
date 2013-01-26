class syn_pwm_test extends syn_base_test;

  `ovm_component_utils(syn_pwm_test)

  OVM_FILE  f;

  syn_vcortex_init_seq#(MM_PKT_TYPE)        pwm_init_seq;
  syn_vcortex_pwm_config_seq#(MM_PKT_TYPE)  pwm_config_seq;

  function new (string name="syn_pwm_test", ovm_component parent=null);
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

      pwm_init_seq  = syn_vcortex_init_seq#(MM_PKT_TYPE)::type_id::create("syn_vcortex_init_seq");
      pwm_config_seq= syn_vcortex_pwm_config_seq#(MM_PKT_TYPE)::type_id::create("syn_vcortex_pwm_config_seq");

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

    pwm_init_seq.start(super.env.cortex_lb_agent.seqr);

    #2ms;

    for(int i=0; i<16; i++)
    begin
      pwm_config_seq.pwm_val[i] = 1 <<  i;
    end

    pwm_config_seq.pwm_val[0] = 'hffff;

    pwm_config_seq.start(super.env.cortex_lb_agent.seqr);

    #4ms;

    ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_pwm_test
