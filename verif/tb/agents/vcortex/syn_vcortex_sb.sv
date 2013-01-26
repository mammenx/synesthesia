`ifndef __SYN_VCORTEX_SB
`define __SYN_VCORTEX_SB

`ovm_analysis_imp_decl(_rcvd_pwm_pkt)

  class syn_vcortex_sb #(
                          type  PKT_TYPE = syn_pwm_seq_item
                        ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(syn_vcortex_sb#(PKT_TYPE))

    PKT_TYPE mon_pwm_que[$];

    ovm_analysis_imp_rcvd_pwm_pkt #(PKT_TYPE,syn_vcortex_sb)   Mon2Sb_port;

    syn_reg_map#(16)  pwm_reg_map;  //connected to LB Mon reg map !

    const time  pwm_resolution  = 20ns;  //vcortex clk

    OVM_FILE  f;

    function new(string name = "syn_vcortex_sb", ovm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Mon2Sb_port  = new("Mon2Sb_port", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    virtual function void write_rcvd_pwm_pkt(input PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_rcvd_pwm_pkt]"},$psprintf("Received PWM pkt\n%s",pkt.sprint()),OVM_LOW);

      mon_pwm_que.push_back(pkt);
    endfunction : write_rcvd_pwm_pkt


    task run();
      PKT_TYPE  mon_pkt;
      int       pwm_val;
      time      pwm_on_exp, pwm_off_exp;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      forever
      begin
        do
        begin
          #1;
        end
        while(mon_pwm_que.size()  ==  0); //wait for que to get item

        mon_pkt = mon_pwm_que.pop_front();  //get pkt from mon

        pwm_val = pwm_reg_map.get_field($psprintf("PWM_%1x",mon_pkt.line_no));

        if(pwm_val  < 0)
        begin
          ovm_report_fatal({get_name(),"[run]"},"Please check if pwm_reg_map is setup correctly !!!",OVM_LOW);
          break;
        end

        //ovm_report_info({get_name(),"[run]"},$psprintf("Got PWM val from PWM_%1x : 0x%x",mon_pkt.line_no,pwm_val),OVM_LOW);

        pwm_on_exp  = pwm_val  * pwm_resolution;
        pwm_off_exp = (('hffff  - pwm_val)  * pwm_resolution) + pwm_resolution;


        if(mon_pkt.val_on ==  pwm_on_exp)
        begin
          ovm_report_info({get_name(),"[run]"},"PWM ON Period is correct",OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_name(),"[run]"},"PWM ON Period is incorrect",OVM_LOW);
          ovm_report_info({get_name(),"[run]"},$psprintf("PWM On\t|\tExpected : %d\t|\tActual : %d",pwm_on_exp,mon_pkt.val_on),OVM_LOW);
        end

        if(mon_pkt.val_off  ==  pwm_off_exp) 
        //if(((mon_pkt.val_off - pwm_off_exp) >=  -20)  &&  ((mon_pkt.val_off - pwm_off_exp)  <=  20))
        begin
          ovm_report_info({get_name(),"[run]"},"PWM OFF Period is correct",OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_name(),"[run]"},"PWM OFF Period is incorrect",OVM_LOW);
          ovm_report_info({get_name(),"[run]"},$psprintf("PWM Off\t|\tExpected : %d\t|\tActual : %d",pwm_off_exp,mon_pkt.val_off),OVM_LOW);
        end
      end
    endtask : run


    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("syn_vcortex_sb Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report
    
  endclass : syn_vcortex_sb

`endif
