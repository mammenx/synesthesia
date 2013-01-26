class syn_mclk_sel_test extends syn_base_test;

  `ovm_component_utils(syn_mclk_sel_test)


  syn_acortex_dac_drvr_mclk_sel_seq#(MM_PKT_TYPE)  mclk_sel_seq;


  OVM_FILE  f;

  function new (string name="syn_mclk_sel_test", ovm_component parent=null);
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

      mclk_sel_seq  = syn_acortex_dac_drvr_mclk_sel_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_dac_drvr_mclk_sel_seq");

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

    for(shortint i=0;  i<4;  i++)
    begin
      ovm_report_info(get_name(),$psprintf("Selecting MCLK[%1d]",i),OVM_LOW);

      mclk_sel_seq.mclk_sel_val = i;

      mclk_sel_seq.start(super.env.cortex_lb_agent.seqr);

      #10us;
    end

    ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_mclk_sel_test
