`ifndef __SYN_ACORTEX_CODEC_I2C_SLAVE
`define __SYN_ACORTEX_CODEC_I2C_SLAVE

  class syn_acortex_codec_i2c_slave #(parameter REG_MAP_W = 9,
                                      type  INTF_TYPE = virtual syn_aud_codec_if.TB_I2C
                                    ) extends ovm_component;

    /*  Register with factory */
    `ovm_component_param_utils(syn_acortex_codec_i2c_slave#(REG_MAP_W,INTF_TYPE))

    OVM_FILE  f;

    INTF_TYPE intf;

    /*  Register Map to hold DAC registers  */
    syn_reg_map#(REG_MAP_W)   reg_map;  //each register is 9b

    function new(string name  = "syn_acortex_codec_i2c_slave", ovm_component parent = null);
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


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);


      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    task  run();
      bit[6:0]  addr;
      bit       rd_n_wr;
      bit[15:0] data;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      intf.tb_i2c_drive = 0;
      intf.tb_i2c_data  = 0;

      forever
      begin
        @(negedge intf.sda);
        @(negedge intf.scl);

        ovm_report_info({get_name(),"[run]"},"<Start> detected ...",OVM_LOW);

        addr  = 'd0;

        repeat(7)
        begin
          @(posedge intf.scl);
          #1;

          addr  = (addr <<  1)  + intf.sda; //sample address bits
        end

        ovm_report_info({get_name(),"[run]"},$psprintf("Got address : 0x%x",addr),OVM_LOW);

        @(posedge intf.scl);
        #1;

        rd_n_wr = intf.sda;   //sample RD/nWR bit

        ovm_report_info({get_name(),"[run]"},$psprintf("Got Read/nWr : 0x%x",rd_n_wr),OVM_LOW);

        @(posedge intf.scl)
        #2;

        if({addr,rd_n_wr}  ==  'h34)  //Device address
        begin
          ovm_report_info({get_name(),"[run]"},$psprintf("Driving ACK"),OVM_LOW);
          intf.tb_i2c_data  = 0;
          intf.tb_i2c_drive = 1;

          @(negedge intf.scl);
          intf.tb_i2c_drive = 0;
        end
        else
        begin
          ovm_report_error({get_name(),"[run]"},$psprintf("Driving NACK"),OVM_LOW);
          intf.tb_i2c_data  = 1;
          intf.tb_i2c_drive = 1;

          @(negedge intf.scl);
          intf.tb_i2c_drive = 0;

          @(posedge intf.scl);
          @(posedge intf.sda);
          ovm_report_info({get_name(),"[run]"},$psprintf("<STOP> detected ...\n\n\n"),OVM_LOW);

          continue;
        end

        data  = 'd0;

        repeat(2)
        begin
          repeat(8)
          begin
            @(posedge intf.scl);
            #1;

            data  = (data <<  1)  + intf.sda;
          end

          @(posedge intf.scl);
          #2;

          ovm_report_info({get_name(),"[run]"},$psprintf("Driving ACK"),OVM_LOW);
          intf.tb_i2c_data  = 0;
          intf.tb_i2c_drive = 1;

          @(negedge intf.scl);
          intf.tb_i2c_drive = 0;
        end

        @(posedge intf.scl);
        @(posedge intf.sda);
        ovm_report_info({get_name(),"[run]"},$psprintf("<STOP> detected ...\n\n\n"),OVM_LOW);

        if(reg_map.chk_addr_exist(data[15:9]) ==  syn_reg_map#(REG_MAP_W)::SUCCESS)
        begin
          reg_map.set_reg(data[15:9], data[8:0]);
        end
        else
        begin
          ovm_report_error({get_name(),"[run]"},$psprintf("Invalid DAC address 0x%x",data[15:9]),OVM_LOW);
        end
      end

    endtask : run

  endclass  : syn_acortex_codec_i2c_slave

`endif
