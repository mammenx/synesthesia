class syn_adc_cap_test extends syn_base_test;

  `ovm_component_utils(syn_adc_cap_test)

  OVM_FILE  f;

  syn_acortex_adc_cap_seq#(MM_PKT_TYPE)        adc_cap_seq;
  syn_acortex_codec_adc_seq#(ADC_PKT_TYPE)     codec_adc_seq;
  syn_acortex_i2c_config_seq#(MM_PKT_TYPE)     i2c_config_seq;

  //int bps = 32;
  int bps = 16;

  function new (string name="syn_adc_cap_test", ovm_component parent=null);
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

      adc_cap_seq   = syn_acortex_adc_cap_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_adc_cap_seq");
      codec_adc_seq = syn_acortex_codec_adc_seq#(ADC_PKT_TYPE)::type_id::create("syn_acortex_codec_adc_seq");
      i2c_config_seq= syn_acortex_i2c_config_seq#(MM_PKT_TYPE)::type_id::create("syn_acortex_i2c_config_seq");

    ovm_report_info(get_full_name(),"End of build",OVM_LOW);
  endfunction : build

  function  void  connect();
    super.connect();

    ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

      super.env.fgyrus_agent_lchnl.disable_agent();
      super.env.fgyrus_agent_rchnl.disable_agent();

    ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
  endfunction : connect

  virtual task run ();
    bit found_error = 0;
    shortint temp;

    ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

    super.env.sprint();

    #500;

    codec_adc_seq.ldata = new[128];
    codec_adc_seq.rdata = new[128];

    if(bps  ==  32)
    begin
      foreach(codec_adc_seq.ldata[i])
      begin
        codec_adc_seq.ldata[i]  = $random;
        codec_adc_seq.rdata[i]  = $random;
      end
    end
    else  //16bps
    begin
      foreach(codec_adc_seq.ldata[i])
      begin
        temp  = $random;
        $cast(codec_adc_seq.ldata[i],temp);
        temp  = $random;
        $cast(codec_adc_seq.rdata[i],temp);
      end
    end

    i2c_config_seq.field  = "iwl";

    if(bps  ==  32)
    begin
      i2c_config_seq.val    = 'b11;
      adc_cap_seq.bps       = 'b1;
    end
    else  //16bps
    begin
      i2c_config_seq.val    = 'b00;
      adc_cap_seq.bps       = 'b0;
    end

    i2c_config_seq.start(super.env.cortex_lb_agent.seqr);

    fork
      begin
        codec_adc_seq.start(super.env.acortex_agent.codec_agent.adc_seqr);
      end

      begin
        adc_cap_seq.start(super.env.cortex_lb_agent.seqr);
      end
    join  //join_all

    foreach(codec_adc_seq.ldata[i])
    begin
      if(codec_adc_seq.ldata[i] !=  adc_cap_seq.lcap[i])
      begin
        ovm_report_error(get_name(),$psprintf("Mismatch in LDATA[%1d] : Actual = %1d\tExpected = %1d",i,adc_cap_seq.lcap[i],codec_adc_seq.ldata[i]),OVM_LOW);
        found_error = 1;
      end

      if(codec_adc_seq.rdata[i] !=  adc_cap_seq.rcap[i])
      begin
        ovm_report_error(get_name(),$psprintf("Mismatch in RDATA[%1d] : Actual = %1d\tExpected = %1d",i,adc_cap_seq.rcap[i],codec_adc_seq.rdata[i]),OVM_LOW);
        found_error = 1;
      end
    end

    if(found_error)
    begin
      ovm_report_info(get_name(),"TEST FAILED !",OVM_LOW);
    end
    else
    begin
      ovm_report_info(get_name(),"TEST PASSED !",OVM_LOW);
    end

    ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
    global_stop_request();

    ovm_report_info(get_full_name(),"End of run",OVM_LOW);
  endtask : run 


endclass  : syn_adc_cap_test
