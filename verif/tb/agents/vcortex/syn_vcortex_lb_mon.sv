`ifndef __VCORTEX_LB_MON
`define __VCORTEX_LB_MON

  class syn_vcortex_lb_mon  #(
                              type  INTF_TYPE = virtual syn_cortex_lb_if.TB
                            ) extends ovm_component;

    `include  "vcortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    INTF_TYPE intf;

    OVM_FILE  f;

    syn_reg_map#(16)  pwm_reg_map;  //connected to SB reg map !

    int   enable;

    /*  Register with factory */
    `ovm_component_param_utils(syn_vcortex_lb_mon#(INTF_TYPE))

    function new( string name = "syn_vcortex_lb_mon" , ovm_component parent = null) ;
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

      enable  = 1;

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

    task run();
      int pwm_no, pwm_val;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      @(posedge intf.av_rst);  //wait for reset

      if(enable)
      begin
        fork
        begin
          /*  --------------  */
          forever
          begin
            @(posedge intf.av_clk);

            if(intf.cb.av_write &&  ~intf.cb.av_wait_req  &&  (intf.cb.av_addr[15:8]  ==  {VCORTEX_BLK,VCORTEX_PWM_RAM_CODE}))
            begin
              $cast(pwm_no, intf.cb.av_addr[3:0]);
              $cast(pwm_val,  intf.cb.av_write_data[15:0]);

              ovm_report_info({get_name(),"[run]"},$psprintf("Updating PWM_%1x to 0x%4x",pwm_no,pwm_val),OVM_LOW);

              if(pwm_reg_map.set_field($psprintf("PWM_%1x",pwm_no), pwm_val)  !=  syn_reg_map#(16)::SUCCESS)
              begin
                ovm_report_fatal({get_name(),"[run]"},"Please check if pwm_reg_map is setup correctly !!!",OVM_LOW);
                break;
              end

              //ovm_report_info({get_name(),"[run]"},$psprintf("Checking PWM_%1x : 0x%4x",pwm_no, $psprintf("PWM_%1x",pwm_val)),OVM_LOW);
            end
          end
          /*  --------------  */
        end
        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"syn_vcortex_lb_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : syn_vcortex_lb_mon

`endif
