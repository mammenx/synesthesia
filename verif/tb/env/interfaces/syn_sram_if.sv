interface syn_sram_if #(ADDR_W  = 18, DATA_W  = 16);

  wire    [DATA_W-1:0]  sram_dq;
  logic   [ADDR_W-1:0]  sram_addr;
  logic                 sram_lb_n;
  logic                 sram_ub_n;
  logic                 sram_ce_n;
  logic                 sram_oe_n;
  logic                 sram_we_n;

  logic                 tb_dq_sel;
  logic   [DATA_W-1:0]  tb_dq;

  /*  Tristating DQ */
  assign  sram_dq = tb_dq_sel ? tb_dq : 'dz;
	
  /*  Clocking Blocks */

  /*  Modports  */
  modport TB  (inout  sram_dq,  input   sram_addr,sram_lb_n,sram_ub_n,sram_ce_n,sram_oe_n,sram_we_n,  output  tb_dq_sel,tb_dq);

  modport DUT (inout  sram_dq,  output  sram_addr,sram_lb_n,sram_ub_n,sram_ce_n,sram_oe_n,sram_we_n);

endinterface  //syn_sram_if
