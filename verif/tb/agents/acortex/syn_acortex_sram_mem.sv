`ifndef __SYN_ACORTEX_SRAM_MEM
`define __SYN_ACORTEX_SRAM_MEM

  class syn_acortex_sram_mem  #(parameter DATA_W = 16,
                                parameter ADDR_W = 18,
                                type      INTF_TYPE = virtual syn_sram_if.TB
                              ) extends ovm_component;

    /*  Register with factory */
    `ovm_component_param_utils(syn_acortex_sram_mem#(DATA_W,ADDR_W,INTF_TYPE))

    OVM_FILE  f;

    INTF_TYPE intf;

    //memory variable
    bit [DATA_W-1:0] mem [];

    function new(string name  = "syn_acortex_sram_mem", ovm_component parent = null);
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

        mem = new[2**ADDR_W];
        ovm_report_info(get_name(),$psprintf("Size of mem[] = %d",mem.size),OVM_LOW);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);


      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    task  run();
      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      intf.tb_dq_sel  = 0;  //release bus

      forever
      begin
        @(intf.sram_dq, intf.sram_addr, intf.sram_lb_n, intf.sram_ub_n, intf.sram_ce_n, intf.sram_oe_n, intf.sram_we_n);

        #2ns;

        if(!intf.sram_oe_n  &&  !intf.sram_ce_n) //read command
        begin
          intf.tb_dq      = mem[intf.sram_addr];  //drive data to bus
          intf.tb_dq_sel  = 1;

          //  ovm_report_info({get_name(),"[run]"},$psprintf("READ - addr : 0x%x\tdata : 0x%x",intf.sram_addr,mem[intf.sram_addr]),OVM_LOW);
        end
        else
        begin
          intf.tb_dq_sel  = 0;  //release bus
        end

        if(!intf.sram_we_n  &&  !intf.sram_ce_n)  //write command
        begin
          mem[intf.sram_addr]   = intf.sram_dq;   //sample data from bus
          //  ovm_report_info({get_name(),"[run]"},$psprintf("WRITE - addr : 0x%x\tmdata : 0x%x\tidata : 0x%x",intf.sram_addr,mem[intf.sram_addr],intf.sram_dq),OVM_LOW);
        end

      end

    endtask : run

  endclass  : syn_acortex_sram_mem

`endif
