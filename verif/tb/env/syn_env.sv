`ifndef __SYN_ENV
`define __SYN_ENV

  `ovm_analysis_imp_decl(_env_wav_pkt)

  class syn_env extends ovm_env;


    /*  Register with factory */
    `ovm_component_utils(syn_env)

    parameter type  WAV_PKT_TYPE    = syn_wav_seq_item;
    parameter type  PCM_PKT_TYPE    = syn_fgyrus_pcm_seq_item;

    syn_acortex_agent     acortex_agent;
    syn_fgyrus_agent      fgyrus_agent_lchnl;
    syn_fgyrus_agent      fgyrus_agent_rchnl;
    syn_vcortex_agent     vcortex_agent;
    syn_cortex_lb_agent   cortex_lb_agent;

    OVM_FILE  f;

    mailbox#(WAV_PKT_TYPE)  wav_que_mb;

    //For subscribing to wave packet generated from Acortex ST Agent
    ovm_analysis_imp_env_wav_pkt #(WAV_PKT_TYPE,  syn_env)  AcortexStAgent2Env_port;

    //For sending PCM data to the Fgyrus scoreboards ...
    ovm_analysis_port #(PCM_PKT_TYPE) Env2LFgyrusFftSb_port;
    ovm_analysis_port #(PCM_PKT_TYPE) Env2RFgyrusFftSb_port;

    function new(string name  = "syn_env", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new

    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"});

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      Env2LFgyrusFftSb_port = new("Env2LFgyrusFftSb_port",  this);
      Env2RFgyrusFftSb_port = new("Env2RFgyrusFftSb_port",  this);

      acortex_agent = syn_acortex_agent::type_id::create("syn_acortex_agent",this);
      fgyrus_agent_lchnl  = syn_fgyrus_agent::type_id::create("syn_fgyrus_agent_lchnl",this);
      fgyrus_agent_rchnl  = syn_fgyrus_agent::type_id::create("syn_fgyrus_agent_rchnl",this);
      vcortex_agent = syn_vcortex_agent::type_id::create("syn_vcortex_agent", this);
      cortex_lb_agent  = syn_cortex_lb_agent::type_id::create("syn_cortex_lb_agent", this);

      AcortexStAgent2Env_port = new("AcortexStAgent2Env_port",  this);

      wav_que_mb  = new(1); //mailbox of size 1

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction
    
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      acortex_agent.av_st_agent.seqr.Seqr2Sb_port.connect(this.AcortexStAgent2Env_port);

      this.Env2LFgyrusFftSb_port.connect(fgyrus_agent_lchnl.fft_agent.sb.Drvr2Sb_port);
      this.Env2RFgyrusFftSb_port.connect(fgyrus_agent_rchnl.fft_agent.sb.Drvr2Sb_port);

      this.cortex_lb_agent.seqr.mb_acortex_data_sync = this.acortex_agent.mb_acortex_data_sync;
      this.acortex_agent.vseqr.av_mm_seqr = this.cortex_lb_agent.seqr;

      this.cortex_lb_agent.seqr.dac_reg_map = this.acortex_agent.codec_agent.reg_map;

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction


    virtual task  run();
      PCM_PKT_TYPE  lpcm_pkt[],rpcm_pkt[];
      WAV_PKT_TYPE  wav_pkt;

      ovm_report_info({get_name(),"[run]"},$psprintf("Start of run()"),OVM_LOW);

      fork
        begin
          forever
          begin
            ovm_report_info({get_name(),"[run]"},$psprintf("Waiting on wav_que_mb"),OVM_LOW);
            wav_que_mb.get(wav_pkt);  //wait for data to arrive
            ovm_report_info({get_name(),"[run]"},$psprintf("Got item from wav_que_mb"),OVM_LOW);

            gen_pcm(wav_pkt,  lpcm_pkt, rpcm_pkt);
            ovm_report_info({get_name(),"[run]"},$psprintf("lpcm_pkt.size = %d\trpcm_pkt.size = %d",lpcm_pkt.size,rpcm_pkt.size),OVM_LOW);

            foreach(lpcm_pkt[i])
            begin
              ovm_report_info({get_name(),"[run]"},$psprintf("Sending PCM block to L-Fgyrus SB \n%s",lpcm_pkt[i].sprint()),OVM_LOW);
              Env2LFgyrusFftSb_port.write(lpcm_pkt[i]);
            end

            foreach(rpcm_pkt[i])
            begin
              ovm_report_info({get_name(),"[run]"},$psprintf("Sending PCM block to R-Fgyrus SB \n%s",rpcm_pkt[i].sprint()),OVM_LOW);
              Env2RFgyrusFftSb_port.write(rpcm_pkt[i]);
            end

            #1;
          end
        end
      join


    endtask : run


    virtual function void write_env_wav_pkt(input WAV_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_env_wav_pkt]"},$psprintf("Received wave packet from Acortex \n%s",pkt.sprint()),OVM_LOW);

      if(wav_que_mb.try_put(pkt)  <=  0)
      begin
        ovm_report_fatal({get_name(),"[write_env_wav_pkt]"},$psprintf("Could not put into wav_que_mb !!!"),OVM_LOW);
      end

    endfunction : write_env_wav_pkt

    /*  Generate PCM blocks of 128 samples each */
    function  void  gen_pcm(ref WAV_PKT_TYPE  wav_pkt,  ref PCM_PKT_TYPE  lpcm_pkt_arry[],  ref PCM_PKT_TYPE  rpcm_pkt_arry[]);

      lpcm_pkt_arry = new[wav_pkt.no_samples/128];
      rpcm_pkt_arry = new[wav_pkt.no_samples/128];

      foreach(lpcm_pkt_arry[i])
      begin
        ovm_report_info({get_name(),"[gen_pcm]"},$psprintf("Generating L Sample no %d",i),OVM_LOW);
        lpcm_pkt_arry[i]  = new($psprintf("L-PCM Block [%d]",i));

        lpcm_pkt_arry[i].pcm_data = new[128];

        foreach(lpcm_pkt_arry[i].pcm_data[j])
        begin
          if(wav_pkt.subchunk1NoChnls ==  1)
          begin
            lpcm_pkt_arry[i].pcm_data[j]  = wav_pkt.data[(i*128)  + j];
          end
          else  //dual channel
          begin
            lpcm_pkt_arry[i].pcm_data[j]  = wav_pkt.data[(i*256)  + (j  * 2)];
          end
        end
      end

      foreach(rpcm_pkt_arry[i])
      begin
        ovm_report_info({get_name(),"[gen_pcm]"},$psprintf("Generating R Sample no %d",i),OVM_LOW);
        rpcm_pkt_arry[i]  = new($psprintf("R-PCM Block [%d]",i));

        rpcm_pkt_arry[i].pcm_data = new[128];

        foreach(rpcm_pkt_arry[i].pcm_data[j])
        begin
          if(wav_pkt.subchunk1NoChnls ==  1)
          begin
            rpcm_pkt_arry[i].pcm_data[j]  = 0;
          end
          else  //dual channel
          begin
            rpcm_pkt_arry[i].pcm_data[j]  = wav_pkt.data[(i*256)  + (j  * 2)  + 1];
          end
        end
      end

    endfunction : gen_pcm

  endclass  : syn_env

`endif
