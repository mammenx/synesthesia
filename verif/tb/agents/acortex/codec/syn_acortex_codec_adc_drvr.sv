`ifndef __ACORTEX_CODEC_ADC_DRVR
`define __ACORTEX_CODEC_ADC_DRVR

  class syn_acortex_codec_adc_drvr  #(parameter REG_MAP_W = 9,
                                      type  PKT_TYPE  = syn_dac_seq_item,
                                      type  INTF_TYPE = virtual syn_aud_codec_if.TB_ADC
                                    ) extends ovm_driver  #(PKT_TYPE);

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Drvr2Sb_port;

    OVM_FILE  f;

    shortint  enable;

    /*  Register Map to hold DAC registers  */
    syn_reg_map#(REG_MAP_W)   reg_map;  //each register is 9b

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_acortex_codec_adc_drvr#(REG_MAP_W,PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
    `ovm_component_utils_end

    function new( string name = "syn_acortex_codec_adc_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      enable    = 1;  //by default enabled; disable from test case
    endfunction : new

    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Drvr2Sb_port  = new("Drvr2Sb_port", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    task run();
      PKT_TYPE  pkt = new();

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      drive_rst();

      @(posedge intf.sys_rst);  //wait for reset

      if(enable)
      begin
        forever
        begin
          ovm_report_info({get_name(),"[run]"},"Waiting for seq_item",OVM_LOW);
          seq_item_port.get_next_item(pkt);

          ovm_report_info({get_name(),"[run]"},$psprintf("Got seq_item - \n%s",pkt.sprint()),OVM_LOW);

          Drvr2Sb_port.write(pkt);
          drive(pkt);

          seq_item_port.item_done();
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_acortex_codec_adc_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    task  drive(PKT_TYPE  pkt);
      bit [31:0]  ldata,rdata;
      int bps;

      ovm_report_info({get_name(),"[drive]"},"Start of drive ",OVM_LOW);

      case(reg_map.get_field("iwl"))

        syn_reg_map#(REG_MAP_W)::FAIL_FIELD_N_EXIST : ovm_report_fatal({get_name(),"[run]"},$psprintf("Could not find field <iwl> !!!"),OVM_LOW);

        0 : bps = 16;
        3 : bps = 32;

        default : ovm_report_fatal({get_name(),"[run]"},$psprintf("IWL val : %d not supported !!!", reg_map.get_field("iwl")),OVM_LOW);

      endcase

      $cast(ldata,  pkt.ldata);
      $cast(rdata,  pkt.rdata);

      @(posedge intf.adc_lrc);
      //@(negedge intf.adc_lrc);
      ovm_report_info({get_name(),"[drive]"},"Detected ADC LRC pulse",OVM_LOW);

      for(int i=bps;  i>0;  i--)
      begin
        @(negedge intf.dac_bclk);
        #10ns;  //propagation delay given in spec

        intf.adc_dat  <=  ldata[i-1];
      end

      ovm_report_info({get_name(),"[drive]"},"Driven LChannel ADC data",OVM_LOW);

      for(int i=bps;  i>0;  i--)
      begin
        @(negedge intf.dac_bclk);
        #10ns;  //propagation delay given in spec

        intf.adc_dat  <=  rdata[i-1];
      end

      ovm_report_info({get_name(),"[drive]"},"Driven RChannel ADC data",OVM_LOW);

      ovm_report_info({get_name(),"[drive]"},"End of drive ",OVM_LOW);
    endtask : drive


    task  drive_rst();
      ovm_report_info({get_name(),"[drive_rst]"},"Start of drive_rst ",OVM_LOW);

      intf.adc_dat <=  0;

      ovm_report_info({get_name(),"[drive_rst]"},"End of drive_rst ",OVM_LOW);
    endtask : drive_rst

  endclass  : syn_acortex_codec_adc_drvr

`endif
