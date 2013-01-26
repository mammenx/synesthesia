`ifndef __ACORTEX_AV_ST_DRVR
`define __ACORTEX_AV_ST_DRVR

  class syn_acortex_av_st_drvr  #(type  PKT_TYPE  = syn_av_st_seq_item,
                                  type  INTF_TYPE = virtual syn_av_st_if.TB
                                ) extends ovm_driver  #(PKT_TYPE);

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Drvr2Sb_port;

    OVM_FILE  f;

    int wait_time;
    shortint  enable;

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_acortex_av_st_drvr#(PKT_TYPE, INTF_TYPE))
      `ovm_field_int(wait_time,  OVM_ALL_ON);
      `ovm_field_int(enable,  OVM_ALL_ON);
    `ovm_component_utils_end

    function new( string name = "syn_acortex_av_st_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      wait_time = 20;
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

      @(posedge intf.av_rst);  //wait for reset
      @(posedge intf.av_clk);

      if(enable)
      begin
        forever
        begin
          ovm_report_info({get_name(),"[run]"},"Waiting for seq_item",OVM_LOW);
          seq_item_port.get_next_item(pkt);

          ovm_report_info({get_name(),"[run]"},$psprintf("Got seq_item - \n%s",pkt.sprint()),OVM_LOW);

          Drvr2Sb_port.write(pkt);
          drive_write(pkt);

          seq_item_port.item_done();
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_acortex_av_st_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    task  drive_write(PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[drive_write]"},"Start of drive_write ",OVM_LOW);

      @(posedge intf.av_clk);

      foreach(pkt.data[i])
      begin
        intf.cb.av_st_data   <=  pkt.data[i];
        intf.cb.av_st_valid  <=  1;
        intf.cb.av_st_sop    <=  (i  ==  0)  ? 1 : 0;
        intf.cb.av_st_eop    <=  (i  ==  pkt.data.size - 1)  ? 1 : 0;

        @(posedge intf.av_clk);

        while(!intf.cb.av_st_ready)
        begin
          @(posedge intf.av_clk);
        end
      end

      intf.cb.av_st_valid  <=  0;
      intf.cb.av_st_sop    <=  0;
      intf.cb.av_st_eop    <=  0;

      repeat(wait_time) @(posedge intf.av_clk);

      ovm_report_info({get_name(),"[drive_write]"},"End of drive_write ",OVM_LOW);
    endtask : drive_write


    task  drive_rst();
      ovm_report_info({get_name(),"[drive_rst]"},"Start of drive_rst ",OVM_LOW);

      intf.cb.av_st_data   <=  0;
      intf.cb.av_st_valid  <=  0;
      intf.cb.av_st_sop    <=  0;
      intf.cb.av_st_eop    <=  0;

      ovm_report_info({get_name(),"[drive_rst]"},"End of drive_rst ",OVM_LOW);
    endtask : drive_rst

  endclass  : syn_acortex_av_st_drvr

`endif
