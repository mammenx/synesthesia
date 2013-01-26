class syn_base_test extends ovm_test;

    `ovm_component_utils(syn_base_test)

    `include  "syn_cortex_reg_map.v"

    parameter type  MM_PKT_TYPE = syn_av_mm_seq_item;
    parameter type  ST_PKT_TYPE = syn_av_st_seq_item;
    parameter type  WAVE_TYPE   = syn_wav_seq_item;
    parameter type  ADC_PKT_TYPE= syn_dac_seq_item;

    syn_env   env;

    syn_acortex_virtual_seq#(MM_PKT_TYPE,ST_PKT_TYPE,WAVE_TYPE) acortex_vseq;
    syn_fgyrus_init_seq#(MM_PKT_TYPE)                           fgyrus_init_seq;

    OVM_FILE  f;
    ovm_table_printer printer;


    function new (string name="syn_base_test", ovm_component parent=null);
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

      env = new("syn_env", this);

      acortex_vseq  = syn_acortex_virtual_seq#(MM_PKT_TYPE,ST_PKT_TYPE,WAVE_TYPE)::type_id::create("syn_acortex_virtual_seq", this);
      fgyrus_init_seq = syn_fgyrus_init_seq#(MM_PKT_TYPE)::type_id::create("syn_fgyrus_init_seq",  this);

      printer = new();
      printer.knobs.name_width  = 50; //width of Name collumn
      printer.knobs.type_width  = 50; //width of Type collumn
      printer.knobs.size_width  = 5;  //width of Size collumn
      printer.knobs.value_width = 30; //width of Value collumn
      printer.knobs.depth = -1;       //print all levels

      ovm_report_info(get_full_name(),"End of build",OVM_LOW);
    endfunction : build

    function  void  connect();
      super.connect();

      ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

      this.env.acortex_agent.sram_mem.intf          = $root.syn_tb_top.sram_if;
      this.env.acortex_agent.av_st_agent.drvr.intf  = $root.syn_tb_top.av_st_if;

      this.env.acortex_agent.codec_agent.dac_mon.intf   = $root.syn_tb_top.aud_codec_if;
      this.env.acortex_agent.codec_agent.i2c_slave.intf = $root.syn_tb_top.aud_codec_if;
      this.env.acortex_agent.codec_agent.adc_drvr.intf  = $root.syn_tb_top.aud_codec_if;

      this.env.fgyrus_agent_lchnl.butter_agent.mon.intf = $root.syn_tb_top.syn_cortex_top_inst.fgyrus_lchnl_inst.butter_intf;
      this.env.fgyrus_agent_lchnl.fft_agent.mon.intf    = $root.syn_tb_top.syn_cortex_top_inst.fgyrus_lchnl_inst.fft_ram_intf;

      this.env.fgyrus_agent_rchnl.butter_agent.mon.intf = $root.syn_tb_top.syn_cortex_top_inst.fgyrus_rchnl_inst.butter_intf;
      this.env.fgyrus_agent_rchnl.fft_agent.mon.intf    = $root.syn_tb_top.syn_cortex_top_inst.fgyrus_rchnl_inst.fft_ram_intf;

      this.env.cortex_lb_agent.drvr.intf                = $root.syn_tb_top.cortex_lb_if;

      this.env.vcortex_agent.lb_mon.intf                = $root.syn_tb_top.cortex_lb_if;
      this.env.vcortex_agent.pwm_mon.intf               = $root.syn_tb_top.pwm_if;

      ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
    endfunction : connect

    function void end_of_elaboration();
        ovm_report_info(get_full_name(),"End_of_elaboration", OVM_LOG);

        env.fgyrus_agent_lchnl.butter_agent.disable_agent();
        env.fgyrus_agent_rchnl.butter_agent.disable_agent();

        ovm_report_info(get_full_name(),$psprintf("OVM Hierarchy -\n%s",  this.sprint(printer)), OVM_LOG);
        print();
    endfunction

    virtual task run ();
      ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

      env.sprint();

      #1000;

      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run 

    /*  To configure via LB */
    task  configure_dut();
      ovm_report_info(get_full_name(),"Start of configure_dut()",OVM_LOW);


      ovm_report_info(get_full_name(),"End of configure_dut()",OVM_LOW);
    endtask : configure_dut


    task  run_dut();
      ovm_report_info(get_full_name(),"Start of run_dut()",OVM_LOW);

        fgyrus_init_seq.start(env.cortex_lb_agent.seqr);

        /*
        if(acortex_vseq.wav_seq.wav_pkt.subchunk1NoChnls  ==  2)  //enable RFGYRUS also
        begin
          fgyrus_init_seq.fgyrus_blk_code = 4'd1;
          fgyrus_init_seq.start(env.cortex_lb_agent.seqr);
        end
        */

        acortex_vseq.start(env.acortex_agent.vseqr);

      ovm_report_info(get_full_name(),"End of run_dut()",OVM_LOW);
    endtask : run_dut

endclass : syn_base_test
