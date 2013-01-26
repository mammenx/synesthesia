`ifndef __SYN_ACORTEX_CODEC_DAC_MON
`define __SYN_ACORTEX_CODEC_DAC_MON

  class syn_acortex_codec_dac_mon   #(parameter REG_MAP_W = 9,
                                      type  PKT_TYPE  = syn_dac_seq_item,
                                      type  INTF_TYPE = virtual syn_aud_codec_if.TB_DAC
                                    ) extends ovm_component;

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_acortex_codec_dac_mon#(REG_MAP_W,PKT_TYPE,INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
    `ovm_component_utils_end

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;

    OVM_FILE  f;

    INTF_TYPE intf;

    shortint enable;

    /*  Register Map to hold DAC registers  */
    syn_reg_map#(REG_MAP_W)   reg_map;  //each register is 9b

    function new(string name  = "syn_acortex_codec_dac_mon", ovm_component parent = null);
      super.new(name, parent);

      enable  = 1;
    endfunction: new

    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

        Mon2Sb_port = new("Mon2Sb_port",  this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);


      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    task  run();
      PKT_TYPE  pkt;
      int sample_no = 0;
      int bps = 16;


      if(enable)
      begin
        forever
        begin
          ovm_report_info({get_name(),"[run]"},$psprintf("Waiting for LRC ..."),OVM_LOW);

          @(posedge intf.dac_lrc);
          @(negedge intf.dac_lrc);

          ovm_report_info({get_name(),"[run]"},$psprintf("Detected LRC sync pulse..."),OVM_LOW);
          pkt = new($psprintf("DAC sample[%d]",sample_no));
          pkt.ldata = 0;
          pkt.rdata = 0;

          case(reg_map.get_field("iwl"))

            syn_reg_map#(REG_MAP_W)::FAIL_FIELD_N_EXIST : ovm_report_fatal({get_name(),"[run]"},$psprintf("Could not find field <iwl> !!!"),OVM_LOW);

            0 : bps = 16;
            3 : bps = 32;

            default : ovm_report_fatal({get_name(),"[run]"},$psprintf("IWL val : %d not supported !!!", reg_map.get_field("iwl")),OVM_LOW);

          endcase

          ovm_report_info({get_name(),"[run]"},$psprintf("Operating in %db mode",bps),OVM_LOW);


          repeat(bps)
          begin
            @(posedge intf.dac_bclk);
            //  ovm_report_info({get_name(),"[run]"},$psprintf("Lchannel sda - %x",intf.dac_dat),OVM_LOW);

            pkt.ldata = (pkt.ldata  <<  1)  + intf.dac_dat;
          end


          repeat(bps)
          begin
            @(posedge intf.dac_bclk);
            //  ovm_report_info({get_name(),"[run]"},$psprintf("Rchannel sda - %x",intf.dac_dat),OVM_LOW);

            pkt.rdata = (pkt.rdata  <<  1)  + intf.dac_dat;
          end

          #1;

          ovm_report_info({get_name(),"[run]"},$psprintf("Sending Packet to Scoreboard - \n%s\n\n\n", pkt.sprint()),OVM_LOW);
          Mon2Sb_port.write(pkt);

          sample_no++;
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_acortex_codec_dac_mon is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end

    endtask : run

  endclass  : syn_acortex_codec_dac_mon

`endif
