`ifndef __SYN_ACORTEX_CODEC_AGENT
`define __SYN_ACORTEX_CODEC_AGENT

  class syn_acortex_codec_agent extends ovm_component;

    /*  Register with factory */
    `ovm_component_utils(syn_acortex_codec_agent)

    parameter REG_MAP_W             = 9;
    parameter type  PKT_TYPE        = syn_dac_seq_item;
    parameter type  DAC_INTF_TYPE   = virtual syn_aud_codec_if.TB_DAC;
    parameter type  ADC_INTF_TYPE   = virtual syn_aud_codec_if.TB_ADC;
    parameter type  I2C_INTF_TYPE   = virtual syn_aud_codec_if.TB_I2C;


    syn_acortex_codec_dac_mon#(REG_MAP_W,PKT_TYPE,DAC_INTF_TYPE)  dac_mon;
    syn_acortex_codec_i2c_slave#(REG_MAP_W,I2C_INTF_TYPE)         i2c_slave;
    syn_acortex_codec_adc_drvr#(REG_MAP_W,PKT_TYPE,ADC_INTF_TYPE) adc_drvr;
    syn_acortex_codec_adc_seqr#(PKT_TYPE)                         adc_seqr;


    syn_reg_map#(REG_MAP_W)   reg_map;  //each register is 9b

    OVM_FILE  f;

    function new(string name  = "syn_acortex_codec_agent", ovm_component parent = null);
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

      dac_mon     = syn_acortex_codec_dac_mon#(REG_MAP_W,PKT_TYPE,DAC_INTF_TYPE)::type_id::create("syn_acortex_codec_dac_mon", this);
      i2c_slave   = syn_acortex_codec_i2c_slave#(REG_MAP_W,I2C_INTF_TYPE)::type_id::create("syn_acortex_codec_i2c_slave", this);
      adc_drvr    = syn_acortex_codec_adc_drvr#(REG_MAP_W,PKT_TYPE,ADC_INTF_TYPE)::type_id::create("syn_acortex_codec_adc_drvr", this);
      adc_seqr    = syn_acortex_codec_adc_seqr#(PKT_TYPE)::type_id::create("syn_acortex_codec_adc_seqr", this);

      reg_map     = syn_reg_map#(REG_MAP_W)::type_id::create("aud_codec_reg_map",this);
      build_reg_map();

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction

    function  void  build_reg_map();

      reg_map.create_field("linvol",    0,  0,  4);
      reg_map.create_field("linmute",   0,  7,  7);
      reg_map.create_field("lrinboth",  0,  8,  8);
      reg_map.create_field("rinvol",    1,  0,  4);
      reg_map.create_field("rinmute",   1,  7,  7);
      reg_map.create_field("rlinboth",  1,  8,  8);
      reg_map.create_field("lhpvol",    2,  0,  6);
      reg_map.create_field("lzcen",     2,  7,  7);
      reg_map.create_field("lrhpboth",  2,  8,  8);
      reg_map.create_field("rhpvol",    3,  0,  6);
      reg_map.create_field("rzcen",     3,  7,  7);
      reg_map.create_field("rlhpboth",  3,  8,  8);
      reg_map.create_field("micboost",  4,  0,  0);
      reg_map.create_field("mutemic",   4,  1,  1);
      reg_map.create_field("insel",     4,  2,  2);
      reg_map.create_field("bypass",    4,  3,  3);
      reg_map.create_field("dacsel",    4,  4,  4);
      reg_map.create_field("sdetone",   4,  5,  5);
      reg_map.create_field("sideatt",   4,  6,  7);
      reg_map.create_field("adchpd",    5,  0,  0);
      reg_map.create_field("deemph",    5,  1,  2);
      reg_map.create_field("dacmu",     5,  3,  3);
      reg_map.create_field("hpor",      5,  4,  4);
      reg_map.create_field("lineinpd",  6,  0,  0);
      reg_map.create_field("micpd",     6,  1,  1);
      reg_map.create_field("adcpd",     6,  2,  2);
      reg_map.create_field("dacpd",     6,  3,  3);
      reg_map.create_field("outpd",     6,  4,  4);
      reg_map.create_field("oscpd",     6,  5,  5);
      reg_map.create_field("clkoutpd",  6,  6,  6);
      reg_map.create_field("pwroff",    6,  7,  7);
      reg_map.create_field("format",    7,  0,  1);
      reg_map.create_field("iwl",       7,  2,  3);
      reg_map.create_field("lrp",       7,  4,  4);
      reg_map.create_field("lrswap",    7,  5,  5);
      reg_map.create_field("ms",        7,  6,  6);
      reg_map.create_field("bclkinv",   7,  7,  7);
      reg_map.create_field("usb/norm",  8,  0,  0);
      reg_map.create_field("bosr",      8,  1,  1);
      reg_map.create_field("sr",        8,  2,  5);
      reg_map.create_field("clk1div2",  8,  6,  6);
      reg_map.create_field("clk0div2",  8,  7,  7);
      reg_map.create_field("active",    9,  0,  0);

    endfunction : build_reg_map


    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

      this.i2c_slave.reg_map  = this.reg_map;
      this.dac_mon.reg_map    = this.reg_map;
      this.adc_drvr.reg_map   = this.reg_map;

      adc_drvr.seq_item_port.connect(adc_seqr.seq_item_export);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction

    function  void  disable_agent();
      ovm_report_info(get_name(),"Disabling syn_acortex_av_st_agent [av_st_agent]",OVM_LOW);

        this.dac_mon.enable = 0;
        this.adc_drvr.enable = 0;

    endfunction : disable_agent

  endclass  : syn_acortex_codec_agent

`endif
