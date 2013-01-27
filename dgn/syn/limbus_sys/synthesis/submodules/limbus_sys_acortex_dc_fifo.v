//Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_acortex_dc_fifo_dual_clock_fifo (
                                                    // inputs:
                                                     aclr,
                                                     data,
                                                     rdclk,
                                                     rdreq,
                                                     wrclk,
                                                     wrreq,

                                                    // outputs:
                                                     q,
                                                     rdempty,
                                                     wrfull
                                                  )
;

  output  [ 31: 0] q;
  output           rdempty;
  output           wrfull;
  input            aclr;
  input   [ 31: 0] data;
  input            rdclk;
  input            rdreq;
  input            wrclk;
  input            wrreq;

  wire             int_wrfull;
  wire    [ 31: 0] q;
  wire             rdempty;
  wire             wrfull;
  wire    [  6: 0] wrusedw;
  assign wrfull = (wrusedw >= 128-3) | int_wrfull;
  dcfifo dual_clock_fifo
    (
      .aclr (aclr),
      .data (data),
      .q (q),
      .rdclk (rdclk),
      .rdempty (rdempty),
      .rdreq (rdreq),
      .wrclk (wrclk),
      .wrfull (int_wrfull),
      .wrreq (wrreq),
      .wrusedw (wrusedw)
    );

  defparam dual_clock_fifo.intended_device_family = "CYCLONEII",
           dual_clock_fifo.lpm_hint = "MAXIMIZE_SPEED=5,",
           dual_clock_fifo.lpm_numwords = 128,
           dual_clock_fifo.lpm_showahead = "OFF",
           dual_clock_fifo.lpm_type = "dcfifo",
           dual_clock_fifo.lpm_width = 32,
           dual_clock_fifo.lpm_widthu = 7,
           dual_clock_fifo.overflow_checking = "ON",
           dual_clock_fifo.rdsync_delaypipe = 4,
           dual_clock_fifo.underflow_checking = "ON",
           dual_clock_fifo.use_eab = "ON",
           dual_clock_fifo.wrsync_delaypipe = 4;


endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_acortex_dc_fifo_dcfifo_with_controls (
                                                         // inputs:
                                                          data,
                                                          rdclk,
                                                          rdreq,
                                                          wrclk,
                                                          wrreq,
                                                          wrreset_n,

                                                         // outputs:
                                                          q,
                                                          rdempty,
                                                          wrfull
                                                       )
;

  output  [ 31: 0] q;
  output           rdempty;
  output           wrfull;
  input   [ 31: 0] data;
  input            rdclk;
  input            rdreq;
  input            wrclk;
  input            wrreq;
  input            wrreset_n;

  wire    [ 31: 0] q;
  wire             rdempty;
  wire             wrfull;
  wire             wrreq_valid;
  //the_dcfifo, which is an e_instance
  limbus_sys_acortex_dc_fifo_dual_clock_fifo the_dcfifo
    (
      .aclr    (~wrreset_n),
      .data    (data),
      .q       (q),
      .rdclk   (rdclk),
      .rdempty (rdempty),
      .rdreq   (rdreq),
      .wrclk   (wrclk),
      .wrfull  (wrfull),
      .wrreq   (wrreq_valid)
    );

  assign wrreq_valid = wrreq & ~wrfull;

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_acortex_dc_fifo_map_avalonmm_to_avalonst (
                                                             // inputs:
                                                              avalonmm_data,

                                                             // outputs:
                                                              avalonst_data
                                                           )
;

  output  [ 31: 0] avalonst_data;
  input   [ 31: 0] avalonmm_data;

  wire    [ 31: 0] avalonst_data;
  assign avalonst_data[31 : 24] = avalonmm_data[7 : 0];
  assign avalonst_data[23 : 16] = avalonmm_data[15 : 8];
  assign avalonst_data[15 : 8] = avalonmm_data[23 : 16];
  assign avalonst_data[7 : 0] = avalonmm_data[31 : 24];

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_acortex_dc_fifo (
                                    // inputs:
                                     avalonmm_write_slave_address,
                                     avalonmm_write_slave_write,
                                     avalonmm_write_slave_writedata,
                                     avalonst_source_ready,
                                     rdclock,
                                     rdreset_n,
                                     wrclock,
                                     wrreset_n,

                                    // outputs:
                                     avalonmm_write_slave_waitrequest,
                                     avalonst_source_data,
                                     avalonst_source_valid
                                  )
;

  output           avalonmm_write_slave_waitrequest;
  output  [ 31: 0] avalonst_source_data;
  output           avalonst_source_valid;
  input            avalonmm_write_slave_address;
  input            avalonmm_write_slave_write;
  input   [ 31: 0] avalonmm_write_slave_writedata;
  input            avalonst_source_ready;
  input            rdclock;
  input            rdreset_n;
  input            wrclock;
  input            wrreset_n;

  wire    [ 31: 0] avalonmm_map_data_in;
  wire             avalonmm_write_slave_waitrequest;
  wire    [ 31: 0] avalonst_map_data_out;
  wire    [ 31: 0] avalonst_source_data;
  reg              avalonst_source_valid;
  wire    [ 31: 0] data;
  wire    [ 31: 0] q;
  wire             rdclk;
  wire             rdempty;
  wire             rdreq;
  wire             wrclk;
  wire             wrfull;
  wire             wrreq;
  wire             wrreq_driver;
  //the_dcfifo_with_controls, which is an e_instance
  limbus_sys_acortex_dc_fifo_dcfifo_with_controls the_dcfifo_with_controls
    (
      .data      (data),
      .q         (q),
      .rdclk     (rdclk),
      .rdempty   (rdempty),
      .rdreq     (rdreq),
      .wrclk     (wrclk),
      .wrfull    (wrfull),
      .wrreq     (wrreq),
      .wrreset_n (wrreset_n)
    );

  //in, which is an e_avalon_slave
  assign avalonmm_write_slave_waitrequest = wrfull;
  //the_map_avalonmm_to_avalonst, which is an e_instance
  limbus_sys_acortex_dc_fifo_map_avalonmm_to_avalonst the_map_avalonmm_to_avalonst
    (
      .avalonmm_data (avalonmm_map_data_in),
      .avalonst_data (avalonst_map_data_out)
    );

  assign wrreq_driver = (avalonmm_write_slave_address == 0) & avalonmm_write_slave_write;
  assign avalonmm_map_data_in = avalonmm_write_slave_writedata;
  assign wrreq = wrreq_driver;
  assign data = avalonst_map_data_out;
  assign wrclk = wrclock;
  assign rdclk = rdclock;
  assign avalonst_source_data = q;
  assign rdreq = !rdempty & avalonst_source_ready;
  always @(posedge rdclk or negedge rdreset_n)
    begin
      if (rdreset_n == 0)
          avalonst_source_valid <= 0;
      else 
        avalonst_source_valid <= !rdempty & avalonst_source_ready;
    end


  //out, which is an e_atlantic_master

endmodule

