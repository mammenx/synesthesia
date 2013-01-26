`ifndef __SYN_ACORTEX_I2C_CONFIG_SEQ
`define __SYN_ACORTEX_I2C_CONFIG_SEQ

  class syn_acortex_i2c_config_seq  #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_i2c_config_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  pkt,  rsp;
    string    field;
    int       val;

    `define I2C_ADDR      8'h34
    `define I2C_CLK_DIV   8'd100

    function new(string name  = "syn_acortex_i2c_config_seq");
      super.new(name);

      pkt = new();
      rsp = new();

      field = "format";
      val   = 'b11;
    endfunction

    /*  Body of sequence  */
    task  body();
      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_i2c_config_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Config [I2C CLK DIV]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_CLK_DIV_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = `I2C_CLK_DIV;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Config [I2C Addr]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_ADDR_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = `I2C_ADDR;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;


      if(p_sequencer.dac_reg_map.set_field(field, val)  !=  syn_reg_map#(9)::SUCCESS)
      begin
        p_sequencer.ovm_report_fatal(get_name(),{"Could not find field {",field,"} !!!"},OVM_LOW);
      end

      #1;

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Config [I2C Data]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_DATA_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = ((p_sequencer.dac_reg_map.get_addr(field) & 'h7f) <<  9)  + (p_sequencer.dac_reg_map.get_reg(field) & 'h1ff);

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;


      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Config [I2C Start]")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.av_xtn      = WRITE;
      pkt.addr        = new[1];
      pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_STATUS_REG_ADDR};
      pkt.data        = new[1];
      pkt.data[0]     = $random;

      p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;


      do
      begin
        #1us;

        $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("DAC Config [Poll I2C status]")));

        start_item(pkt);  //start_item has wait_for_grant()

        pkt.av_xtn      = READ;
        pkt.addr        = new[1];
        pkt.addr[0]     = {ACORTEX_BLK,  I2C_DRIVER, I2C_DRIVER_STATUS_REG_ADDR};
        pkt.data        = new[1];

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent pkt - \n%s", pkt.sprint()),OVM_LOW);

        finish_item(pkt);

        get_response(rsp);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", pkt.sprint()),OVM_LOW);
      end
      while(rsp.data[0] & 'h1); //while I2C driver is busy

      if(rsp.data[0]  & 'b10)
      begin
        p_sequencer.ovm_report_error(get_name(),$psprintf("NACK was detected ..."),OVM_LOW);
      end
      else
      begin
        p_sequencer.ovm_report_info(get_name(),$psprintf("I2C xtn success ..."),OVM_LOW);
      end

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_i2c_config_seq

`endif
