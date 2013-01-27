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

module limbus_sys_dma_job_fifo_single_clock_fifo (
                                                   // inputs:
                                                    aclr,
                                                    clock,
                                                    data,
                                                    rdreq,
                                                    wrreq,

                                                   // outputs:
                                                    empty,
                                                    full,
                                                    q,
                                                    usedw
                                                 )
;

  output           empty;
  output           full;
  output  [ 31: 0] q;
  output  [  6: 0] usedw;
  input            aclr;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            wrreq;

  wire             empty;
  wire             full;
  wire    [ 31: 0] q;
  wire    [  6: 0] usedw;
  scfifo single_clock_fifo
    (
      .aclr (aclr),
      .clock (clock),
      .data (data),
      .empty (empty),
      .full (full),
      .q (q),
      .rdreq (rdreq),
      .usedw (usedw),
      .wrreq (wrreq)
    );

  defparam single_clock_fifo.add_ram_output_register = "OFF",
           single_clock_fifo.intended_device_family = "CYCLONEII",
           single_clock_fifo.lpm_numwords = 128,
           single_clock_fifo.lpm_showahead = "OFF",
           single_clock_fifo.lpm_type = "scfifo",
           single_clock_fifo.lpm_width = 32,
           single_clock_fifo.lpm_widthu = 7,
           single_clock_fifo.overflow_checking = "ON",
           single_clock_fifo.underflow_checking = "ON",
           single_clock_fifo.use_eab = "ON";


endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_dma_job_fifo_scfifo_with_controls (
                                                      // inputs:
                                                       clock,
                                                       data,
                                                       rdreq,
                                                       reset_n,
                                                       wrclk_control_slave_address,
                                                       wrclk_control_slave_read,
                                                       wrclk_control_slave_write,
                                                       wrclk_control_slave_writedata,
                                                       wrreq,

                                                      // outputs:
                                                       empty,
                                                       full,
                                                       q,
                                                       wrclk_control_slave_readdata
                                                    )
;

  output           empty;
  output           full;
  output  [ 31: 0] q;
  output  [ 31: 0] wrclk_control_slave_readdata;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            reset_n;
  input   [  2: 0] wrclk_control_slave_address;
  input            wrclk_control_slave_read;
  input            wrclk_control_slave_write;
  input   [ 31: 0] wrclk_control_slave_writedata;
  input            wrreq;

  wire             empty;
  wire             full;
  wire    [  7: 0] level;
  wire             overflow;
  wire    [ 31: 0] q;
  wire             underflow;
  wire    [  6: 0] usedw;
  reg              wrclk_control_slave_almostempty_n_reg;
  wire             wrclk_control_slave_almostempty_pulse;
  wire             wrclk_control_slave_almostempty_signal;
  reg     [  7: 0] wrclk_control_slave_almostempty_threshold_register;
  reg              wrclk_control_slave_almostfull_n_reg;
  wire             wrclk_control_slave_almostfull_pulse;
  wire             wrclk_control_slave_almostfull_signal;
  reg     [  7: 0] wrclk_control_slave_almostfull_threshold_register;
  reg              wrclk_control_slave_empty_n_reg;
  wire             wrclk_control_slave_empty_pulse;
  wire             wrclk_control_slave_empty_signal;
  reg              wrclk_control_slave_event_almostempty_q;
  wire             wrclk_control_slave_event_almostempty_signal;
  reg              wrclk_control_slave_event_almostfull_q;
  wire             wrclk_control_slave_event_almostfull_signal;
  reg              wrclk_control_slave_event_empty_q;
  wire             wrclk_control_slave_event_empty_signal;
  reg              wrclk_control_slave_event_full_q;
  wire             wrclk_control_slave_event_full_signal;
  reg              wrclk_control_slave_event_overflow_q;
  wire             wrclk_control_slave_event_overflow_signal;
  wire    [  5: 0] wrclk_control_slave_event_register;
  reg              wrclk_control_slave_event_underflow_q;
  wire             wrclk_control_slave_event_underflow_signal;
  reg              wrclk_control_slave_full_n_reg;
  wire             wrclk_control_slave_full_pulse;
  wire             wrclk_control_slave_full_signal;
  reg     [  5: 0] wrclk_control_slave_ienable_register;
  wire    [  7: 0] wrclk_control_slave_level_register;
  wire    [ 31: 0] wrclk_control_slave_read_mux;
  reg     [ 31: 0] wrclk_control_slave_readdata;
  reg              wrclk_control_slave_status_almostempty_q;
  wire             wrclk_control_slave_status_almostempty_signal;
  reg              wrclk_control_slave_status_almostfull_q;
  wire             wrclk_control_slave_status_almostfull_signal;
  reg              wrclk_control_slave_status_empty_q;
  wire             wrclk_control_slave_status_empty_signal;
  reg              wrclk_control_slave_status_full_q;
  wire             wrclk_control_slave_status_full_signal;
  reg              wrclk_control_slave_status_overflow_q;
  wire             wrclk_control_slave_status_overflow_signal;
  wire    [  5: 0] wrclk_control_slave_status_register;
  reg              wrclk_control_slave_status_underflow_q;
  wire             wrclk_control_slave_status_underflow_signal;
  wire    [  7: 0] wrclk_control_slave_threshold_writedata;
  wire             wrreq_valid;
  //the_scfifo, which is an e_instance
  limbus_sys_dma_job_fifo_single_clock_fifo the_scfifo
    (
      .aclr  (~reset_n),
      .clock (clock),
      .data  (data),
      .empty (empty),
      .full  (full),
      .q     (q),
      .rdreq (rdreq),
      .usedw (usedw),
      .wrreq (wrreq_valid)
    );

  assign level = {full,
    usedw};

  assign wrreq_valid = wrreq & ~full;
  assign overflow = wrreq & full;
  assign underflow = rdreq & empty;
  assign wrclk_control_slave_threshold_writedata = (wrclk_control_slave_writedata < 1) ? 1 :
    (wrclk_control_slave_writedata > 127) ? 127 :
    wrclk_control_slave_writedata[7 : 0];

  assign wrclk_control_slave_event_almostfull_signal = wrclk_control_slave_almostfull_pulse;
  assign wrclk_control_slave_event_almostempty_signal = wrclk_control_slave_almostempty_pulse;
  assign wrclk_control_slave_status_almostfull_signal = wrclk_control_slave_almostfull_signal;
  assign wrclk_control_slave_status_almostempty_signal = wrclk_control_slave_almostempty_signal;
  assign wrclk_control_slave_event_full_signal = wrclk_control_slave_full_pulse;
  assign wrclk_control_slave_event_empty_signal = wrclk_control_slave_empty_pulse;
  assign wrclk_control_slave_status_full_signal = wrclk_control_slave_full_signal;
  assign wrclk_control_slave_status_empty_signal = wrclk_control_slave_empty_signal;
  assign wrclk_control_slave_event_overflow_signal = overflow;
  assign wrclk_control_slave_event_underflow_signal = underflow;
  assign wrclk_control_slave_status_overflow_signal = overflow;
  assign wrclk_control_slave_status_underflow_signal = underflow;
  assign wrclk_control_slave_empty_signal = empty;
  assign wrclk_control_slave_empty_pulse = wrclk_control_slave_empty_signal & wrclk_control_slave_empty_n_reg;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_empty_n_reg <= 0;
      else 
        wrclk_control_slave_empty_n_reg <= !wrclk_control_slave_empty_signal;
    end


  assign wrclk_control_slave_full_signal = full;
  assign wrclk_control_slave_full_pulse = wrclk_control_slave_full_signal & wrclk_control_slave_full_n_reg;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_full_n_reg <= 0;
      else 
        wrclk_control_slave_full_n_reg <= !wrclk_control_slave_full_signal;
    end


  assign wrclk_control_slave_almostempty_signal = level <= wrclk_control_slave_almostempty_threshold_register;
  assign wrclk_control_slave_almostempty_pulse = wrclk_control_slave_almostempty_signal & wrclk_control_slave_almostempty_n_reg;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_almostempty_n_reg <= 0;
      else 
        wrclk_control_slave_almostempty_n_reg <= !wrclk_control_slave_almostempty_signal;
    end


  assign wrclk_control_slave_almostfull_signal = level >= wrclk_control_slave_almostfull_threshold_register;
  assign wrclk_control_slave_almostfull_pulse = wrclk_control_slave_almostfull_signal & wrclk_control_slave_almostfull_n_reg;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_almostfull_n_reg <= 0;
      else 
        wrclk_control_slave_almostfull_n_reg <= !wrclk_control_slave_almostfull_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_almostempty_threshold_register <= 1;
      else if ((wrclk_control_slave_address == 5) & wrclk_control_slave_write)
          wrclk_control_slave_almostempty_threshold_register <= wrclk_control_slave_threshold_writedata;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_almostfull_threshold_register <= 127;
      else if ((wrclk_control_slave_address == 4) & wrclk_control_slave_write)
          wrclk_control_slave_almostfull_threshold_register <= wrclk_control_slave_threshold_writedata;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_ienable_register <= 0;
      else if ((wrclk_control_slave_address == 3) & wrclk_control_slave_write)
          wrclk_control_slave_ienable_register <= wrclk_control_slave_writedata[5 : 0];
    end


  assign wrclk_control_slave_level_register = level;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_underflow_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[5])
          wrclk_control_slave_event_underflow_q <= 0;
      else if (wrclk_control_slave_event_underflow_signal)
          wrclk_control_slave_event_underflow_q <= -1;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_overflow_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[4])
          wrclk_control_slave_event_overflow_q <= 0;
      else if (wrclk_control_slave_event_overflow_signal)
          wrclk_control_slave_event_overflow_q <= -1;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_almostempty_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[3])
          wrclk_control_slave_event_almostempty_q <= 0;
      else if (wrclk_control_slave_event_almostempty_signal)
          wrclk_control_slave_event_almostempty_q <= -1;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_almostfull_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[2])
          wrclk_control_slave_event_almostfull_q <= 0;
      else if (wrclk_control_slave_event_almostfull_signal)
          wrclk_control_slave_event_almostfull_q <= -1;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_empty_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[1])
          wrclk_control_slave_event_empty_q <= 0;
      else if (wrclk_control_slave_event_empty_signal)
          wrclk_control_slave_event_empty_q <= -1;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_event_full_q <= 0;
      else if (wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[0])
          wrclk_control_slave_event_full_q <= 0;
      else if (wrclk_control_slave_event_full_signal)
          wrclk_control_slave_event_full_q <= -1;
    end


  assign wrclk_control_slave_event_register = {wrclk_control_slave_event_underflow_q,
    wrclk_control_slave_event_overflow_q,
    wrclk_control_slave_event_almostempty_q,
    wrclk_control_slave_event_almostfull_q,
    wrclk_control_slave_event_empty_q,
    wrclk_control_slave_event_full_q};

  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_underflow_q <= 0;
      else 
        wrclk_control_slave_status_underflow_q <= wrclk_control_slave_status_underflow_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_overflow_q <= 0;
      else 
        wrclk_control_slave_status_overflow_q <= wrclk_control_slave_status_overflow_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_almostempty_q <= 0;
      else 
        wrclk_control_slave_status_almostempty_q <= wrclk_control_slave_status_almostempty_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_almostfull_q <= 0;
      else 
        wrclk_control_slave_status_almostfull_q <= wrclk_control_slave_status_almostfull_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_empty_q <= 0;
      else 
        wrclk_control_slave_status_empty_q <= wrclk_control_slave_status_empty_signal;
    end


  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_status_full_q <= 0;
      else 
        wrclk_control_slave_status_full_q <= wrclk_control_slave_status_full_signal;
    end


  assign wrclk_control_slave_status_register = {wrclk_control_slave_status_underflow_q,
    wrclk_control_slave_status_overflow_q,
    wrclk_control_slave_status_almostempty_q,
    wrclk_control_slave_status_almostfull_q,
    wrclk_control_slave_status_empty_q,
    wrclk_control_slave_status_full_q};

  assign wrclk_control_slave_read_mux = ({32 {(wrclk_control_slave_address == 0)}} & wrclk_control_slave_level_register) |
    ({32 {(wrclk_control_slave_address == 1)}} & wrclk_control_slave_status_register) |
    ({32 {(wrclk_control_slave_address == 2)}} & wrclk_control_slave_event_register) |
    ({32 {(wrclk_control_slave_address == 3)}} & wrclk_control_slave_ienable_register) |
    ({32 {(wrclk_control_slave_address == 4)}} & wrclk_control_slave_almostfull_threshold_register) |
    ({32 {(wrclk_control_slave_address == 5)}} & wrclk_control_slave_almostempty_threshold_register) |
    ({32 {(~((wrclk_control_slave_address == 0))) && (~((wrclk_control_slave_address == 1))) && (~((wrclk_control_slave_address == 2))) && (~((wrclk_control_slave_address == 3))) && (~((wrclk_control_slave_address == 4))) && (~((wrclk_control_slave_address == 5)))}} & wrclk_control_slave_level_register);

  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          wrclk_control_slave_readdata <= 0;
      else if (wrclk_control_slave_read)
          wrclk_control_slave_readdata <= wrclk_control_slave_read_mux;
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module limbus_sys_dma_job_fifo (
                                 // inputs:
                                  avalonmm_read_slave_read,
                                  avalonmm_write_slave_write,
                                  avalonmm_write_slave_writedata,
                                  reset_n,
                                  wrclk_control_slave_address,
                                  wrclk_control_slave_read,
                                  wrclk_control_slave_write,
                                  wrclk_control_slave_writedata,
                                  wrclock,

                                 // outputs:
                                  avalonmm_read_slave_readdata,
                                  avalonmm_read_slave_waitrequest,
                                  avalonmm_write_slave_waitrequest,
                                  wrclk_control_slave_readdata
                               )
;

  output  [ 31: 0] avalonmm_read_slave_readdata;
  output           avalonmm_read_slave_waitrequest;
  output           avalonmm_write_slave_waitrequest;
  output  [ 31: 0] wrclk_control_slave_readdata;
  input            avalonmm_read_slave_read;
  input            avalonmm_write_slave_write;
  input   [ 31: 0] avalonmm_write_slave_writedata;
  input            reset_n;
  input   [  2: 0] wrclk_control_slave_address;
  input            wrclk_control_slave_read;
  input            wrclk_control_slave_write;
  input   [ 31: 0] wrclk_control_slave_writedata;
  input            wrclock;

  wire    [ 31: 0] avalonmm_read_slave_readdata;
  wire             avalonmm_read_slave_waitrequest;
  wire             avalonmm_write_slave_waitrequest;
  wire             clock;
  wire    [ 31: 0] data;
  wire             empty;
  wire             full;
  wire    [ 31: 0] q;
  wire             rdreq;
  wire    [ 31: 0] wrclk_control_slave_readdata;
  wire             wrreq;
  //the_scfifo_with_controls, which is an e_instance
  limbus_sys_dma_job_fifo_scfifo_with_controls the_scfifo_with_controls
    (
      .clock                         (clock),
      .data                          (data),
      .empty                         (empty),
      .full                          (full),
      .q                             (q),
      .rdreq                         (rdreq),
      .reset_n                       (reset_n),
      .wrclk_control_slave_address   (wrclk_control_slave_address),
      .wrclk_control_slave_read      (wrclk_control_slave_read),
      .wrclk_control_slave_readdata  (wrclk_control_slave_readdata),
      .wrclk_control_slave_write     (wrclk_control_slave_write),
      .wrclk_control_slave_writedata (wrclk_control_slave_writedata),
      .wrreq                         (wrreq)
    );

  //in, which is an e_avalon_slave
  //out, which is an e_avalon_slave
  assign data = avalonmm_write_slave_writedata;
  assign wrreq = avalonmm_write_slave_write;
  assign avalonmm_read_slave_readdata = q;
  assign rdreq = avalonmm_read_slave_read;
  assign clock = wrclock;
  assign avalonmm_write_slave_waitrequest = full;
  assign avalonmm_read_slave_waitrequest = empty;
  //in_csr, which is an e_avalon_slave

endmodule

