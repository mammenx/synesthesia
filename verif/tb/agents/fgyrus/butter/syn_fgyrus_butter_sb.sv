`ifndef __SYN_FGYRUS_BUTTER_SB
`define __SYN_FGYRUS_BUTTER_SB

`ovm_analysis_imp_decl(_rcvd_fft_pkt)
`ovm_analysis_imp_decl(_sent_fft_pkt)

  class syn_fgyrus_butter_sb  #(type  DRVR_PKT_TYPE = syn_fgyrus_fft_seq_item,
                                type  MON_PKT_TYPE  = syn_complex_seq_item

                              ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(syn_fgyrus_butter_sb#(DRVR_PKT_TYPE, MON_PKT_TYPE))

    MON_PKT_TYPE exp_que[$];

    ovm_analysis_imp_rcvd_fft_pkt #(MON_PKT_TYPE,syn_fgyrus_butter_sb)   Mon2Sb_port;
    ovm_analysis_imp_sent_fft_pkt #(DRVR_PKT_TYPE,syn_fgyrus_butter_sb)  Drvr2Sb_port;

    OVM_FILE  f;

    
    function new(string name = "syn_fgyrus_butter_sb", ovm_component parent);
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
      Drvr2Sb_port = new("Drvr2Sb_port", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    virtual function void write_rcvd_fft_pkt(input MON_PKT_TYPE pkt);
      MON_PKT_TYPE  exp_pkt = new();
      bit           mismatch  = 0;

      ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Received pkt from monitor-\n%s", pkt.sprint()),OVM_LOW);
      //ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Que size - %d",exp_que.size()),OVM_LOW);

      //exp_pkt = exp_que[0];
      //ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Expected pkt\n%s", exp_pkt.sprint()),OVM_LOW);
      //exp_pkt = exp_que[1];
      //ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Expected pkt\n%s", exp_pkt.sprint()),OVM_LOW);
 
      if(exp_que.size())
      begin
        exp_pkt = exp_que.pop_front();
        //exp_pkt = exp_que.pop_back();
        //exp_pkt = exp_que[0];
        //exp_que = exp_que[1:$];
        ovm_report_info({get_name(),"[write_rcvd_pkt]"},$psprintf("Expected pkt\n%s", exp_pkt.sprint()),OVM_LOW);

        if(exp_pkt.data_real  < 0)  //get only |abs|
        begin
          exp_pkt.data_real = -exp_pkt.data_real;
          pkt.data_real     = -pkt.data_real;
        end

        if(exp_pkt.data_im  < 0)  //get only |abs|
        begin
          exp_pkt.data_im = -exp_pkt.data_im;
          pkt.data_im     = -pkt.data_im;
        end

        //if(pkt.compare(exp_pkt))exp_pkt
        if(((pkt.data_real  >=  (exp_pkt.data_real*0.95 -1)) &&  (pkt.data_real  <=  (1+ exp_pkt.data_real*1.05)))  &&
           ((pkt.data_im    >=  (exp_pkt.data_im*0.95 -1))   &&  (pkt.data_im    <=  (1+ exp_pkt.data_im*1.05))))
        begin
          ovm_report_info({get_type_name(),"[write_rcvd_pkt]"},$psprintf("Sent packet and received packet matched\n"), OVM_LOW);
        end
        else
        begin
          ovm_report_error({get_type_name(),"[write_rcvd_pkt]"},$psprintf("Sent packet and received packet mismatched\n"), OVM_LOW);
        end
      end
      else
        ovm_report_error({get_type_name(),"[write_rcvd_pkt]"},$psprintf("No more packets in the expected queue to compare\n"), OVM_LOW);
    endfunction : write_rcvd_fft_pkt

    virtual function void write_sent_fft_pkt(input DRVR_PKT_TYPE  pkt);
      MON_PKT_TYPE  data_a  = new("data_a");
      MON_PKT_TYPE  res_a   = new("res_a");
      MON_PKT_TYPE  res_b   = new("res_b");

      ovm_report_info({get_name(),"[write_sent_pkt]"},$psprintf("\n\n\nReceived pkt from driver-\n%s", pkt.sprint()),OVM_LOW);

      //calc_fft( pkt.sample_a.data_real,
      //          pkt.sample_a.data_im,
      //          pkt.sample_b.data_real,
      //          pkt.sample_b.data_im,
      //          pkt.twiddle.data_real,
      //          pkt.twiddle.data_im
      //        );

      complex_mul(pkt.sample_b, pkt.twiddle, 256, data_a);
      complex_add(data_a,  pkt.sample_a,  res_a);
      //  res_a.data_real /=  4;
      //  res_a.data_im   /=  4;
      //ovm_report_info({get_name(),"[write_sent_pkt]"},$psprintf("Expected pkt_1-\n%s", res_a.sprint()),OVM_LOW);
      exp_que.push_back(res_a);
      //exp_que[0]  = res_a;

      data_a.data_real  = data_a.data_real  * -1;
      data_a.data_im    = data_a.data_im    * -1;
      complex_add(data_a,  pkt.sample_a, res_b);
      //res_b.data_real /=  4;
      //res_b.data_im   /=  4;
      //ovm_report_info({get_name(),"[write_sent_pkt]"},$psprintf("Expected pkt_2-\n%s", res_b.sprint()),OVM_LOW);
      exp_que.push_back(res_b);
      //exp_que[1]  = res_b;

    endfunction : write_sent_fft_pkt

    function  void  calc_fft(input int a_real, input int a_im,  input int b_real, input int b_im, input int tw_real, input int tw_im);
      MON_PKT_TYPE  data_a  = new();
      MON_PKT_TYPE  data_b  = new();

      data_b.data_real  = ((b_real * tw_real) - (b_im * tw_im))   >>  8;
      data_b.data_im    = ((b_real * tw_im)   + (b_im * tw_real)) >>  8;

      data_a.data_real  = a_real  + data_b.data_real;
      data_a.data_im    = a_im    + data_b.data_im;

      exp_que.push_back(data_a);

      data_b.data_real  *=  -1;
      data_b.data_im    *=  -1;

      data_b.data_real  = data_a.data_real  + data_b.data_real;
      data_b.data_im    = data_a.data_im    + data_b.data_im;

      exp_que.push_back(data_b);
    endfunction : calc_fft

    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("syn_fgyrus_butter_sb Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report
    
  endclass : syn_fgyrus_butter_sb

`endif
