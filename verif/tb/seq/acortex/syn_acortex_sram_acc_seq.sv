`ifndef __SYN_ACORTEX_SRAM_ACC_SEQ
`define __SYN_ACORTEX_SRAM_ACC_SEQ

  class syn_acortex_sram_acc_seq    #(
                                      type  PKT_TYPE  = syn_av_mm_seq_item 
                                    ) extends ovm_sequence  #(PKT_TYPE,PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef syn_acortex_sram_acc_seq#(PKT_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(syn_cortex_lb_seqr)

    `include  "acortex_reg_map.v"
    `include  "syn_cortex_reg_map.v"

    PKT_TYPE  wr_pkt[],rsp[],rd_pkt[][],wr_pkt_bkp[];
    shortint  unsigned  no_locs;
    bit       error_found;
    bit [17:0]  addr_tmp;


    function new(string name  = "syn_acortex_sram_acc_seq");
      super.new(name);

      no_locs = 128;
      error_found = 0;
    endfunction

    /*  Body of sequence  */
    task  body();
      wr_pkt = new[no_locs];
      rd_pkt = new[no_locs];
      rsp    = new[no_locs];
      wr_pkt_bkp  = new[no_locs];


      p_sequencer.ovm_report_info(get_name(),"Start of syn_acortex_sram_acc_seq",OVM_LOW);

      foreach(wr_pkt[i])
      begin
        /*  SRAM Write Transactions */
        $cast(wr_pkt[i],create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("SRAM Write xtn no [%d]",i)));

        start_item(wr_pkt[i]);  //start_item has wait_for_grant()

        wr_pkt[i].av_xtn = WRITE;
        wr_pkt[i].addr   = new[4]; //each location needs 4x transactions
        wr_pkt[i].data   = new[4];

        addr_tmp  = $random;

        wr_pkt[i].addr[0]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_ADDR_L_REG_ADDR};
        wr_pkt[i].data[0]    = addr_tmp[15:0]; //lower 16b

        wr_pkt[i].addr[1]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_ADDR_H_REG_ADDR};
        wr_pkt[i].data[1]    = addr_tmp[17:16];  //upper 2b

        wr_pkt[i].addr[2]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_DATA_REG_ADDR};
        wr_pkt[i].data[2]    = $random  & 'hffff;

        wr_pkt[i].addr[3]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_CTRL_REG_ADDR};
        wr_pkt[i].data[3]    = 'h2;  //give write command


        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent wr_pkt - \n%s", wr_pkt[i].sprint()),OVM_LOW);

        $cast(wr_pkt_bkp[i],  wr_pkt[i].clone()); //take a backup !!

        finish_item(wr_pkt[i]);

        repeat(($random  % 8) + 1)  #100;

        /*  SRAM  Read transactions */
        rd_pkt[i] = new[2]; //one write set, followed by a read

        $cast(rd_pkt[i][0],create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("SRAM Read xtn no [%d][0]",i)));

        start_item(rd_pkt[i][0]);  //start_item has wait_for_grant()

        rd_pkt[i][0].av_xtn = WRITE;
        rd_pkt[i][0].addr   = new[3]; //each location needs 4x transactions
        rd_pkt[i][0].data   = new[3];

        rd_pkt[i][0].addr[0]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_ADDR_L_REG_ADDR};
        rd_pkt[i][0].data[0]    = addr_tmp[15:0]; //lower 16b

        rd_pkt[i][0].addr[1]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_ADDR_H_REG_ADDR};
        rd_pkt[i][0].data[1]    = addr_tmp[17:16];  //upper 2b

        rd_pkt[i][0].addr[2]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_CTRL_REG_ADDR};
        rd_pkt[i][0].data[2]    = 'h1;  //give read command

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent rd_pkt - \n%s", rd_pkt[i][0].sprint()),OVM_LOW);

        finish_item(rd_pkt[i][0]);


        $cast(rd_pkt[i][1],create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("SRAM Read xtn no [%d][1]",i)));

        start_item(rd_pkt[i][1]);  //start_item has wait_for_grant()

        rd_pkt[i][1].av_xtn = READ;
        rd_pkt[i][1].addr   = new[1]; //each location needs 4x transactions
        rd_pkt[i][1].data   = new[1];

        rd_pkt[i][1].addr[0]    = {ACORTEX_BLK,  SRAM, SRAM_ACC_DATA_REG_ADDR};
        rd_pkt[i][1].data[0]    = 0;

        p_sequencer.ovm_report_info(get_name(),$psprintf("Sent rd_pkt - \n%s", rd_pkt[i][1].sprint()),OVM_LOW);

        finish_item(rd_pkt[i][1]);


        rsp[i]  = new();

        get_response(rsp[i]);  //wait for response

        p_sequencer.ovm_report_info(get_name(),$psprintf("Got Response pkt - \n%s", rsp[i].sprint()),OVM_LOW);

        repeat(($random  % 8) + 1)  #100;
      end

      #1;

      foreach(rsp[i])
      begin
        if(rsp[i].data[0] !=  wr_pkt_bkp[i].data[2])
        begin
          p_sequencer.ovm_report_error(get_name(),$psprintf("Mismatch xtn[%d]\texp[0x%x]\tact[0x%x]", i,wr_pkt_bkp[i].data[2],rsp[i].data[0]),OVM_LOW);
          //  p_sequencer.ovm_report_info(get_name(),$psprintf("Write xtn[%d] -\n%s", i, wr_pkt_bkp[i].sprint()),OVM_LOW);
          error_found = 1;
        end
      end

      if(error_found)
      begin
        p_sequencer.ovm_report_info(get_name(),$psprintf("Sequence check failed ..."),OVM_LOW);
      end
      else
      begin
        p_sequencer.ovm_report_info(get_name(),$psprintf("Sequence check passed ..."),OVM_LOW);
      end

      #1;

      //p_sequencer.ovm_report_info(get_name(),"Calling global_stop_request().....",OVM_LOW);
      //p_sequencer.global_stop_request();
    endtask : body


  endclass  : syn_acortex_sram_acc_seq

`endif
