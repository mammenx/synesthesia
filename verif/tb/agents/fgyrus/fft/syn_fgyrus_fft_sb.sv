`ifndef __SYN_FGYRUS_FFT_SB
`define __SYN_FGYRUS_FFT_SB

`ovm_analysis_imp_decl(_rcvd_pcm_pkt)
`ovm_analysis_imp_decl(_rcvd_abs_pkt)
`ovm_analysis_imp_decl(_sent_pcm_pkt)

  import  math_pkg::*;
  import  dsp_pkg::*;

  class syn_fgyrus_fft_sb #(type  DRVR_PKT_TYPE = syn_fgyrus_pcm_seq_item,
                            type  MON_PKT_TYPE  = syn_fgyrus_fft_ram_seq_item

                      ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(syn_fgyrus_fft_sb#(DRVR_PKT_TYPE, MON_PKT_TYPE))

    DRVR_PKT_TYPE pcm_sent_que[$];
    MON_PKT_TYPE  fft_ram_exp_pkt;

    ovm_analysis_imp_rcvd_pcm_pkt #(MON_PKT_TYPE,syn_fgyrus_fft_sb)   Mon2Sb_port;
    ovm_analysis_imp_rcvd_abs_pkt #(MON_PKT_TYPE,syn_fgyrus_fft_sb)   Mon2Sb_abs_port;
    ovm_analysis_imp_sent_pcm_pkt #(DRVR_PKT_TYPE,syn_fgyrus_fft_sb)  Drvr2Sb_port;

    OVM_FILE  f;

    real fft_arry_real[],fft_arry_im[];
    
    function new(string name = "syn_fgyrus_fft_sb", ovm_component parent);
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
      Mon2Sb_abs_port  = new("Mon2Sb_abs_port", this);
      Drvr2Sb_port = new("Drvr2Sb_port", this);

      fft_ram_exp_pkt = new();

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    virtual function void write_sent_pcm_pkt(input DRVR_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_sent_pcm_pkt]"},$psprintf("Received PCM pkt\n%s",pkt.sprint()),OVM_LOW);

      pcm_sent_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_sent_pcm_pkt]"},$psprintf("Now there are %d items in pcm_sent_que[$]",pcm_sent_que.size()),OVM_LOW);
    endfunction : write_sent_pcm_pkt


    virtual function void write_rcvd_pcm_pkt(input MON_PKT_TYPE pkt);
      DRVR_PKT_TYPE pcm_pkt = new();
      real  data_in[];
      real  data_out_re[];
      real  data_out_im[];
      string mismatch_res;
      MON_PKT_TYPE  rcvd_pkt  = new();

      $cast(rcvd_pkt, pkt);

      //  data_in         = new[128];
      //  data_out_re     = new[128];
      //  data_out_im     = new[128];
      fft_ram_exp_pkt = new();

      ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("Received FFT pkt\n%s",rcvd_pkt.sprint()),OVM_LOW);

      if(pcm_sent_que.size  > 0)
      begin
        pcm_pkt = pcm_sent_que.pop_front();
      end
      else
      begin
        ovm_report_fatal({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("pcm_sent_que is empty !!!"),OVM_LOW);
        global_stop_request();
      end

      data_in         = new[pcm_pkt.pcm_data.size()];
      data_out_re     = new[pcm_pkt.pcm_data.size()];
      data_out_im     = new[pcm_pkt.pcm_data.size()];
      fft_arry_real   = new[pcm_pkt.pcm_data.size()];
      fft_arry_im     = new[pcm_pkt.pcm_data.size()];

      for(int i=0; i<data_in.size;  i++)
      begin
        $cast(data_in[i],pcm_pkt.pcm_data[i]);
        //ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("data_in[%d] : %f\tdata_out_re[%d] : %f\tdata_out_im[%d] : %f",i,data_in[i],i,data_out_re[i],i,data_out_im[i]),OVM_LOW);
      end

      ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("pcm_pkt.pcm_data.size() = %d",pcm_pkt.pcm_data.size()),OVM_LOW);
      ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("data_in.size() = %d",data_in.size()),OVM_LOW);
      ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("data_out_re.size() = %d",data_out_re.size()),OVM_LOW);
      ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("data_out_im.size() = %d",data_out_im.size()),OVM_LOW);

      //  Calculate the FFT
      syn_calc_fft(pcm_pkt.pcm_data.size(),  data_in, data_out_re, data_out_im);

      for(int i=0; i<fft_ram_exp_pkt.fft_data.size(); i++)
      begin
        fft_ram_exp_pkt.fft_data[i].data_real  = data_out_re[i];
        fft_ram_exp_pkt.fft_data[i].data_im    = data_out_im[i];

        //for input to calculating abs
        fft_arry_real[i]  = data_out_re[i];
        fft_arry_im[i]    = data_out_im[i];
        //ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("i : %d\tReal : %f\tIm : %f",i,fft_arry_real[i],fft_arry_im[i]),OVM_LOW);
        //ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("i : %d\tReal : %f\tIm : %f",i,data_out_re[i],data_out_im[i]),OVM_LOW);
      end

      //  if(rcvd_pkt.compare(fft_ram_exp_pkt))
      if(rcvd_pkt.compare_fft(fft_ram_exp_pkt, 0.05))
      begin
        ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},"Packets match",OVM_LOW);
      end
      else
      begin
        ovm_report_error({get_name(),"[write_rcvd_pcm_pkt]"},"Packets mismatch",OVM_LOW);

        mismatch_res  = $psprintf("\n\tExpected Real\t\tExpected Im\t\t--\t\tReal\t\tIm");

        for(int i=0; i<rcvd_pkt.fft_data.size(); i++)
        begin
          mismatch_res  = {mismatch_res,$psprintf("\ni=%d\t%d\t\t%d\t\t--\t\t%d\t\t%d",i,fft_ram_exp_pkt.fft_data[i].data_real,fft_ram_exp_pkt.fft_data[i].data_im,rcvd_pkt.fft_data[i].data_real,rcvd_pkt.fft_data[i].data_im)};
        end

        ovm_report_info({get_name(),"[write_rcvd_pcm_pkt]"},$psprintf("%s",mismatch_res),OVM_LOW);
      end


    endfunction : write_rcvd_pcm_pkt


    virtual function void write_rcvd_abs_pkt(input MON_PKT_TYPE pkt);
      string mismatch = "";

      //  foreach(fft_arry_real[i])
      //  begin
      //    ovm_report_info({get_name(),"[write_rcvd_abs_pkt]"},$psprintf("i : %d\tReal : %f\tIm : %f",i,fft_arry_real[i],fft_arry_im[i]),OVM_LOW);
      //  end

      syn_calc_abs(pkt.fft_data.size(), fft_arry_real,  fft_arry_im);

      foreach(fft_arry_real[i])
      begin
        if(!((pkt.fft_data[i].data_real > (fft_arry_real[i] * 0.95)) &&  (pkt.fft_data[i].data_real  < fft_arry_real[i] * 1.05)))
        begin
          mismatch = "i\t\tActual\t\tExpected";
          break;
        end
      end

      if(mismatch ==  "")
      begin
        ovm_report_info({get_name(),"[write_rcvd_abs_pkt]"},"Packets match",OVM_LOW);
      end
      else
      begin
        foreach(fft_arry_real[i])
        begin
          mismatch  = {mismatch,$psprintf("\n%d\t\t%d\t\t%d",i,pkt.fft_data[i].data_real,fft_arry_real[i])};
        end

        ovm_report_error({get_name(),"[write_rcvd_abs_pkt]"},{"Packets mismatch\n",mismatch},OVM_LOW);
      end

    endfunction : write_rcvd_abs_pkt

    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("syn_fgyrus_fft_sb Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report
    
  endclass : syn_fgyrus_fft_sb

`endif
