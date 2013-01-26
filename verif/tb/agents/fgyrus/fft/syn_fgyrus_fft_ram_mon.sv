`ifndef __FGYRUS_FFT_RAM_MON
`define __FGYRUS_FFT_RAM_MON

  class syn_fgyrus_fft_ram_mon  #(type  PKT_TYPE  = syn_fgyrus_fft_ram_seq_item,
                                  type  INTF_TYPE = virtual syn_fgyrus_fft_ram_if.TB
                                ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;
    ovm_analysis_port #(PKT_TYPE) Mon2Sb_abs_port;  //used for final abs value of FFT

    OVM_FILE  f;

    PKT_TYPE  pkt;

    int   enable;

    /*  Register with factory */
    `ovm_component_param_utils(syn_fgyrus_fft_ram_mon#(PKT_TYPE, INTF_TYPE))

    function new( string name = "syn_fgyrus_fft_ram_mon" , ovm_component parent = null) ;
      super.new( name , parent );
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

      Mon2Sb_port = new("Mon2Sb_port", this);
      Mon2Sb_abs_port = new("Mon2Sb_abs_port", this);

      pkt = new();

      enable  = 1;

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

    task run();
      syn_complex_seq_item  temp;
      int i;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      @(posedge intf.sys_rst);  //wait for reset

      if(enable)
      begin
        fork
          begin
            forever
            begin
              @(posedge intf.sys_clk_100);

              if(intf.fft_ram_wr_real_en_w)
              begin
                temp  = new();
                //#1;
                //temp.data_real  = {{32{intf.fft_ram_wr_real_data_w[31]}},intf.fft_ram_wr_real_data_w};
                //temp.data_im    = {{32{intf.fft_ram_wr_im_data_w[31]}},intf.fft_ram_wr_im_data_w};
                //pkt.fft_data[intf.fft_ram_wr_addr_w]  = temp;
                i = intf.fft_ram_wr_addr_w;
                //ovm_report_info({get_name(),"[run]"},$psprintf("write_addr=0x%x\tdata_real=0x%x\tdata_im=0x%x",i,intf.fft_ram_wr_real_data_w,intf.fft_ram_wr_im_data_w),OVM_LOW);
                pkt.fft_data[i].data_real  = {{32{intf.fft_ram_wr_real_data_w[31]}},intf.fft_ram_wr_real_data_w};
                pkt.fft_data[i].data_im    = {{32{intf.fft_ram_wr_im_data_w[31]}},intf.fft_ram_wr_im_data_w};
              end
            end
          end

          begin
            forever
            begin
              @(posedge intf.sys_clk_100);

              if(intf.fft_ram_wr_im_en_w)
              begin
                temp  = new();
                //#1;
                //temp.data_real  = {{32{intf.fft_ram_wr_real_data_w[31]}},intf.fft_ram_wr_real_data_w};
                //temp.data_im    = {{32{intf.fft_ram_wr_im_data_w[31]}},intf.fft_ram_wr_im_data_w};
                //pkt.fft_data[intf.fft_ram_wr_addr_w]  = temp;
                i = intf.fft_ram_wr_addr_w;
                //ovm_report_info({get_name(),"[run]"},$psprintf("write_addr=0x%x\tdata_real=0x%x\tdata_im=0x%x",i,intf.fft_ram_wr_real_data_w,intf.fft_ram_wr_im_data_w),OVM_LOW);
                pkt.fft_data[i].data_real  = {{32{intf.fft_ram_wr_real_data_w[31]}},intf.fft_ram_wr_real_data_w};
                pkt.fft_data[i].data_im    = {{32{intf.fft_ram_wr_im_data_w[31]}},intf.fft_ram_wr_im_data_w};
              end
            end
          end

          begin
            forever
            begin
              //@(posedge intf.fft_stage_done, posedge  intf.decimate_ovr);
              @(posedge intf.fft_done);

              @(negedge intf.fft_ram_wr_real_en_w);
              repeat  (2) @(posedge intf.sys_clk_100);

              ovm_report_info({get_name(),"[run]"},$psprintf("Sending pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
              Mon2Sb_port.write(pkt);
            end
          end

          begin
            forever
            begin
              @(posedge intf.pcm_done);

              ovm_report_info({get_name(),"[run]"},$psprintf("Sending abs pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
              Mon2Sb_abs_port.write(pkt);

              @(posedge intf.sys_clk_100);
              pkt = new();
            end
          end

        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_fgyrus_fft_ram_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : syn_fgyrus_fft_ram_mon

`endif
