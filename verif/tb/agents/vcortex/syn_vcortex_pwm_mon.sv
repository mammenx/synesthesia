`ifndef __VCORTEX_PWM_MON
`define __VCORTEX_PWM_MON

  class syn_vcortex_pwm_mon #(
                              type  PKT_TYPE  = syn_pwm_seq_item,
                              type  INTF_TYPE = virtual syn_pwm_if.TB
                            ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;

    OVM_FILE  f;

    int   enable;

    time  pwm_timestamp[];

    /*  Register with factory */
    `ovm_component_param_utils(syn_vcortex_pwm_mon#(PKT_TYPE, INTF_TYPE))

    function new( string name = "syn_vcortex_pwm_mon" , ovm_component parent = null) ;
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

      pwm_timestamp = new[16];

      foreach(pwm_timestamp[i])
      begin
        pwm_timestamp[i]  = 0ns;
      end

      enable  = 1;

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

    task run();
      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      @(posedge intf.sys_rst);  //wait for reset

      #100ns;

      if(enable)
      begin
        for(int i=0; i<16; i++)
        begin
          //  fork  //start seperate thread for each line
          //  begin
            monitor_pwm_line(i);
          //  end
          //  join_none
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_vcortex_pwm_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    task  monitor_pwm_line(input  int  line_no);
      PKT_TYPE  pkt = new();

      ovm_report_info({get_name(),$psprintf("[monitor_pwm_line_0x%2x]",line_no)},"Starting process ...",OVM_LOW);
      pkt.line_no   = line_no & 'hf;

      fork
      begin
        @(posedge intf.pwm_data[line_no]);  //for synchronization; first pwm  cycle needs to be ignored
        pwm_timestamp[line_no]  = $time;    //store current time stamp

        forever
        begin
          @(negedge intf.pwm_data[line_no]);

          pkt.line_no = line_no & 'hf;
          $cast(pkt.val_off, $time  - pwm_timestamp[line_no]);  //get off period

          ovm_report_info({get_name(),$psprintf("[monitor_pwm_line_0x%2x]",line_no)},$psprintf("Detected Off time %t",pkt.val_off),OVM_LOW);

          pwm_timestamp[line_no]  = $time;  //store current time stamp


          @(posedge intf.pwm_data[line_no]);

          $cast(pkt.val_on, $time  - pwm_timestamp[line_no]);  //get on period

          ovm_report_info({get_name(),$psprintf("[monitor_pwm_line_0x%2x]",line_no)},$psprintf("Detected On time %t",pkt.val_on),OVM_LOW);

          pwm_timestamp[line_no]  = $time;  //store current time stamp

          ovm_report_info({get_name(),$psprintf("[monitor_pwm_line_0x%2x]",line_no)},$psprintf("Sending pwm pkt to SB \n%s",pkt.sprint()),OVM_LOW);
          Mon2Sb_port.write(pkt);
        end
      end
      join_none
    endtask : monitor_pwm_line

  endclass  : syn_vcortex_pwm_mon

`endif
