`ifndef __SYN_VCORTEX_AGENT
`define __SYN_VCORTEX_AGENT

  class syn_vcortex_agent  extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_vcortex_agent)

    parameter type  PWM_LB_INTF_TYPE    = virtual syn_cortex_lb_if.TB;
    parameter type  PWM_PKT_TYPE        = syn_pwm_seq_item;
    parameter type  PWM_INTF_TYPE       = virtual syn_pwm_if.TB;
    parameter int   REG_MAP_W           = 16;

    syn_vcortex_lb_mon#(PWM_LB_INTF_TYPE)             lb_mon;
    syn_vcortex_pwm_mon#(PWM_PKT_TYPE,PWM_INTF_TYPE)  pwm_mon;
    syn_vcortex_sb#(PWM_PKT_TYPE)                     sb;

    OVM_FILE  f;

    syn_reg_map#(REG_MAP_W)  pwm_reg_map;

    function new(string name  = "syn_vcortex_agent", ovm_component parent = null);
      super.new(name, parent);
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

        lb_mon  = syn_vcortex_lb_mon#(PWM_LB_INTF_TYPE)::type_id::create("syn_vcortex_lb_mon",this);
        pwm_mon = syn_vcortex_pwm_mon#(PWM_PKT_TYPE,PWM_INTF_TYPE)::type_id::create("syn_vcortex_pwm_mon",this);
        sb      = syn_vcortex_sb#(PWM_PKT_TYPE)::type_id::create("syn_vcortex_sb",this);

        build_pwm_reg_map();

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction
    
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

        lb_mon.pwm_reg_map    = this.pwm_reg_map;
        sb.pwm_reg_map        = this.pwm_reg_map;

        pwm_mon.Mon2Sb_port.connect(sb.Mon2Sb_port);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();

    endfunction : disable_agent


    function  void  build_pwm_reg_map();
      ovm_report_info({get_name(),"[build_pwm_reg_map]"},"PWM Reg Map build starting ... ",OVM_LOW);

      pwm_reg_map = syn_reg_map#(REG_MAP_W)::type_id::create("pwm_reg_map",this);

      for(int i=0;i<16;i++)
      begin
        ovm_report_info({get_name(),"[build_pwm_reg_map]"},$psprintf("Building PWM_%1x register",i),OVM_LOW);
        pwm_reg_map.create_field($psprintf("PWM_%1x",i), i,  0 , 15);
      end

      ovm_report_info({get_name(),"[build_pwm_reg_map]"},"PWM Reg Map built ... ",OVM_LOW);
    endfunction : build_pwm_reg_map

  endclass  : syn_vcortex_agent

`endif
