`ifndef __SYN_CORTEX_LB_DRVR
`define __SYN_CORTEX_LB_DRVR

  class syn_cortex_lb_drvr      #(type  PKT_TYPE  = syn_av_mm_seq_item,
                                  type  INTF_TYPE = virtual syn_cortex_lb_if.TB
                                ) extends ovm_driver  #(PKT_TYPE,PKT_TYPE); //request, response

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Drvr2Sb_port;

    OVM_FILE  f;

    int wait_time;
    shortint  enable;

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_cortex_lb_drvr#(PKT_TYPE, INTF_TYPE))
      `ovm_field_int(wait_time,  OVM_ALL_ON);
      `ovm_field_int(enable,  OVM_ALL_ON);
    `ovm_component_utils_end

    function new( string name = "syn_cortex_lb_drvr" , ovm_component parent = null) ;
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
      PKT_TYPE  pkt_rsp;

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
          drive(pkt);

          if((pkt.av_xtn  ==  READ) ||  (pkt.av_xtn ==  BURST_READ))
          begin
            pkt_rsp = new();

            pkt_rsp.av_xtn  = pkt.av_xtn;
            pkt_rsp.addr    = new[pkt.addr.size];
            pkt_rsp.data    = new[pkt.data.size];
            foreach(pkt.addr[i])
            begin
              pkt_rsp.addr[i] = pkt.addr[i];
              pkt_rsp.data[i] = pkt.data[i];
            end

            pkt_rsp.set_id_info(pkt);
            #1;
            seq_item_port.put_response(pkt_rsp);
          end

          seq_item_port.item_done();
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_cortex_lb_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    task  drive(PKT_TYPE  pkt);
      int read_n_write;

      ovm_report_info({get_name(),"[drive]"},"Start of drive ",OVM_LOW);

      if((pkt.av_xtn  ==  READ) ||  (pkt.av_xtn ==  BURST_READ))
      begin
        read_n_write  = 1;
      end
      else  //if WRITE
      begin
        read_n_write  = 0;
      end

      @(posedge intf.av_clk);

      fork
        begin
          foreach(pkt.addr[i])
          begin
            intf.cb.av_read        <=  read_n_write  ? 1 : 0;
            intf.cb.av_write       <=  read_n_write  ? 0 : 1;
            intf.cb.av_addr        <=  pkt.addr[i]  & 'hffff;
            intf.cb.av_write_data  <=  pkt.data[i];

            @(posedge intf.av_clk);

            if(intf.cb.av_wait_req)  //dut is busy
            begin
              @(negedge intf.cb.av_wait_req);
              @(posedge intf.av_clk);
            end
          end

          intf.cb.av_read   <=  0;
          intf.cb.av_write  <=  0;

          @(posedge intf.av_clk);
        end

        begin
          if(read_n_write)
          begin
            foreach(pkt.addr[i])
            begin
              @(posedge intf.av_clk   iff intf.cb.av_read_data_valid  ==  1); //wait for valid to be asserted

              pkt.data[i]          =  intf.cb.av_read_data;  //sample data
            end
          end
          else
          begin
            #1;
          end
        end

      join  //join_all

      repeat(wait_time) @(posedge intf.av_clk);

      ovm_report_info({get_name(),"[drive]"},"End of drive ",OVM_LOW);
    endtask : drive


    task  drive_rst();
      ovm_report_info({get_name(),"[drive_rst]"},"Start of drive_rst ",OVM_LOW);

      intf.cb.av_read        <=  0;
      intf.cb.av_write       <=  0;
      intf.cb.av_addr        <=  0;
      intf.cb.av_write_data  <=  0;

      ovm_report_info({get_name(),"[drive_rst]"},"End of drive_rst ",OVM_LOW);
    endtask : drive_rst

  endclass  : syn_cortex_lb_drvr

`endif
