`ifndef __SYN_FGYRUS_BUTTER_MON
`define __SYN_FGYRUS_BUTTER_MON

  class syn_fgyrus_butter_mon  #(type  ING_PKT_TYPE  = syn_fgyrus_fft_seq_item,
                                  type  EGR_PKT_TYPE  = syn_complex_seq_item,
                                  type  INTF_TYPE     = virtual syn_fgyrus_butter_if.TB
                                ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(ING_PKT_TYPE) IngressMon2Sb_port;
    ovm_analysis_port #(EGR_PKT_TYPE) EgressMon2Sb_port;

    OVM_FILE  f;


    ING_PKT_TYPE  ing_pkt;
    EGR_PKT_TYPE  egr_pkt;
    int       i,j;
    shortint  enable;

    /*  Register with factory */
    `ovm_component_param_utils_begin(syn_fgyrus_butter_mon#(ING_PKT_TYPE,EGR_PKT_TYPE,INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
    `ovm_component_utils_end


    function new( string name = "syn_fgyrus_butter_mon" , ovm_component parent = null) ;
      super.new( name , parent );

      enable  = 1;  //enabled by default
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

      EgressMon2Sb_port  = new("EgressMon2Sb_port", this);
      IngressMon2Sb_port = new("IngressMon2Sb_port", this);

      egr_pkt = new();
      ing_pkt = new();
      i=0;
      j=0;

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

    task run();
      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      @(posedge intf.rst);  //wait for reset

      if(enable)
      begin
        ovm_report_info({get_name(),"[run]"},"Starting threads ",OVM_LOW);

        fork
          begin
            mon_egress();
          end

          begin
            mon_ingress();
          end
        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_fgyrus_butter_mon is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end

    endtask : run


    task  mon_ingress();
      forever
      begin
        @(posedge intf.clk);

        ovm_report_info({get_name(),"[mon_ingr]"},"Waiting for input ...",OVM_LOW);
        @(posedge intf.cb.samples_rdy);

        ing_pkt = new($psprintf("%s_ing_item_%1d",get_name(),j));
        ing_pkt.sample_a.data_real      = {{32{intf.cb.sample_a_real[31]}},intf.cb.sample_a_real};
        ing_pkt.sample_a.data_im        = {{32{intf.cb.sample_a_im[31]}},intf.cb.sample_a_im};
        ing_pkt.sample_b.data_real      = {{32{intf.cb.sample_b_real[31]}},intf.cb.sample_b_real};
        ing_pkt.sample_b.data_im        = {{32{intf.cb.sample_b_im[31]}},intf.cb.sample_b_im};
        ing_pkt.twiddle.data_real       = {{54{intf.cb.twdl_real[9]}},intf.cb.twdl_real};
        ing_pkt.twiddle.data_im         = {{54{intf.cb.twdl_im[9]}},intf.cb.twdl_im};
        j++;

        ovm_report_info({get_name(),"[mon_ingr]"},$psprintf("Sending pkt to SB -\n%s", ing_pkt.sprint()),OVM_LOW);
        IngressMon2Sb_port.write(ing_pkt);
      end
    endtask : mon_ingress


    task  mon_egress();
      forever
      begin
        @(posedge intf.clk);

        ovm_report_info({get_name(),"[mon_egr]"},"Waiting for output ...",OVM_LOW);
        @(posedge intf.cb.data_rdy);

        egr_pkt = new($psprintf("%s_egr_item_%1d",get_name(),i));
        egr_pkt.data_real = {{32{intf.cb.data_real[31]}},intf.cb.data_real};
        egr_pkt.data_im   = {{32{intf.cb.data_im[31]}},intf.cb.data_im};
        i++;

        ovm_report_info({get_name(),"[mon_egr]"},$psprintf("Sending data_0 to SB -\n%s", egr_pkt.sprint()),OVM_LOW);
        EgressMon2Sb_port.write(egr_pkt);

        @(posedge intf.clk);
        #1;

        egr_pkt = new($psprintf("%s_item_%1d",get_name(),i));
        egr_pkt.data_real = {{32{intf.cb.data_real[31]}},intf.cb.data_real};
        egr_pkt.data_im   = {{32{intf.cb.data_im[31]}},intf.cb.data_im};
        i++;

        ovm_report_info({get_name(),"[mon_egr]"},$psprintf("Sending data_1 to SB -\n%s", egr_pkt.sprint()),OVM_LOW);
        EgressMon2Sb_port.write(egr_pkt);
      end
    endtask : mon_egress

  endclass  : syn_fgyrus_butter_mon

`endif
