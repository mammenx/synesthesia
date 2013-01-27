//  --------------------------------------------------------------------------------
// | simple_atlantic_fifo
//  --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module limbus_sys_acortex_st_timing_adaptor_fifo (
   output reg  [ 3: 0] fill_level ,
    
      // Interface: clock
      input              clk,
      input              reset_n,
      // Interface: data_in
      output reg         in_ready,
      input              in_valid,
      input      [31: 0] in_data,
      // Interface: data_out
      input              out_ready,
      output reg         out_valid,
      output reg [31: 0] out_data
);

   // ---------------------------------------------------------------------
   //| Internal Parameters
   // ---------------------------------------------------------------------
   parameter DEPTH = 8;
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 3;
	       
   // ---------------------------------------------------------------------
   //| Signals
   // ---------------------------------------------------------------------
   reg [ADDR_WIDTH-1:0] wr_addr;
   reg [ADDR_WIDTH-1:0] rd_addr;
   reg [ADDR_WIDTH-1:0] next_wr_addr;
   reg [ADDR_WIDTH-1:0] next_rd_addr;
   reg [ADDR_WIDTH-1:0] mem_rd_addr;
   reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];
   reg 			empty;
   reg 			full;
   reg [0:0] out_ready_vector;
   
   // ---------------------------------------------------------------------
   //| FIFO Status
   // ---------------------------------------------------------------------
   always @* begin
//      out_valid = !empty;
      out_ready_vector[0] = out_ready;
      in_ready  = !full;
      next_wr_addr = wr_addr + 1'b1;
      next_rd_addr = rd_addr + 1'b1;
	    fill_level[ADDR_WIDTH-1:0] = wr_addr - rd_addr;
	    fill_level[ADDR_WIDTH] = 0;
	    if (full)
	       fill_level = DEPTH[ADDR_WIDTH:0];
   end
   
   // ---------------------------------------------------------------------
   //| Manage Pointers
   // ---------------------------------------------------------------------
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
	 wr_addr  <= 0;
	 rd_addr  <= 0;
	 empty    <= 1;
	 rd_addr  <= 0;
	 full <= 0;
	 out_valid <= 0;
      end else begin
	 out_valid <= !empty;
	 if (in_ready && in_valid) begin
	    wr_addr <= next_wr_addr;
	    empty   <= 0;
	    if (next_wr_addr == rd_addr)
	      full <= 1;
	 end
	 
	 if (out_ready_vector[0] && out_valid) begin
	    rd_addr <= next_rd_addr;
	    full    <= 0;
	    if (next_rd_addr == wr_addr) begin
	       empty <= 1;
	       out_valid <= 0;
	    end
	 end
	 
	 if (out_ready_vector[0] && out_valid && in_ready && in_valid) begin
	    full  <= full;
	    empty <= empty;
	 end
      end
   end // always @ (negedge reset_n, posedge clk)
   
   always @* begin
      mem_rd_addr = rd_addr;
      if (out_ready && out_valid) begin
	 mem_rd_addr = next_rd_addr;
      end
   end
   

   // ---------------------------------------------------------------------
   //| Infer Memory
   // ---------------------------------------------------------------------
   always @ (posedge clk) begin
      if (in_ready && in_valid)
         mem[wr_addr] <= in_data;
      out_data <= mem[mem_rd_addr];
   end
   
endmodule // simple_atlantic_fifo

// synthesis translate_off

//  --------------------------------------------------------------------------------
// | test bench
//  --------------------------------------------------------------------------------

module test_limbus_sys_acortex_st_timing_adaptor_fifo;
   
   parameter DEPTH = 8;
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 3;

   // ---------------------------------------------------------------------
   //| Internal Parameters
   // ---------------------------------------------------------------------
   localparam CLOCK_HALF_PERIOD       = 10;
   localparam CLOCK_PERIOD            = 2*CLOCK_HALF_PERIOD;
   localparam RESET_TIME              = 25;
   
   // ---------------------------------------------------------------------
   //| Signals
   // ---------------------------------------------------------------------
   reg 	                 clk          = 0;
   reg 			 reset_n      = 0;
   reg 			 test_success = 1;
   reg 			 success      = 1;
   wire 		 in_ready;
   reg 			 in_valid;
   reg [DATA_WIDTH-1:0]  in_data;
   reg 			 out_ready;
   wire 		 out_valid;
   wire [DATA_WIDTH-1:0] out_data;
   reg [DATA_WIDTH-1:0]  next_out_data;
			 
   // ---------------------------------------------------------------------
   //| DUT
   // ---------------------------------------------------------------------
   limbus_sys_acortex_st_timing_adaptor_fifo dut (
		.clk       (clk),
		.reset_n   (reset_n),
		.in_ready  (in_ready),
		.in_valid  (in_valid),      
		.in_data   (in_data),
		.out_ready (out_ready),
		.out_valid (out_valid),      
		.out_data  (out_data)
		);
   
   // ---------------------------------------------------------------------
   //| Clock & Reset
   // ---------------------------------------------------------------------
   initial begin
      reset_n = 0;
      #RESET_TIME;
      reset_n = 1;
   end
   
   always begin
      #CLOCK_HALF_PERIOD;
      clk <= ~clk;
   end
   
   // ---------------------------------------------------------------------
   //| Data Source
   // ---------------------------------------------------------------------
   always @(posedge clk) begin
      if (reset_n == 0)
	in_data <= 0;
      else
	if (in_ready && in_valid)
	  in_data <= in_data + 1;
   end
   
   // ---------------------------------------------------------------------
   //| Data Sink
   // ---------------------------------------------------------------------
   always @(posedge clk) begin
      if (reset_n == 0)
	next_out_data <= 0;
      else
	if (out_ready && out_valid) begin
	   test_assert ("Data Error",out_data == next_out_data);
	   next_out_data <= next_out_data + 1;
	end
   end
   
   // ---------------------------------------------------------------------
   //| Main Test
   // ---------------------------------------------------------------------
   initial begin
      test_exactly_full_and_empty();
      test_random();
      $finish;
   end
   
   // ---------------------------------------------------------------------
   //| Test exactly full and empty
   // ---------------------------------------------------------------------
   task test_exactly_full_and_empty;
      begin
	 test_success = 1;
	 
	 wait (reset_n == 1);
	 @(posedge clk);
	 
	 empty_the_fifo();
	 
	 test_assert ("Empty: should be ready", in_ready == 1);
	 test_assert ("Empty: should not be valid", out_valid == 0);
	 
	 @(posedge clk);
	 in_valid <= 1;
	 out_ready <= 0;
	 
	 @(posedge clk);
	 in_valid <= 0;
	 
	 @(posedge clk);
	 in_valid <= 1;
	 #1;
	 test_assert ("Almost Empty: should be ready", in_ready == 1);
	 test_assert ("Almost Empty: should be valid", out_valid == 1);

	 repeat (DEPTH-2) @(posedge clk);
	 #1;
	 test_assert ("Almost Full: should be ready", in_ready == 1);
	 test_assert ("Almost Full: should be valid", out_valid == 1);
	 
	 @(posedge clk);
	 #1;
	 test_assert ("Full: should be NOT ready", in_ready == 0);
	 test_assert ("Full: should be valid", out_valid == 1);
	 
	 in_valid <= 0;
	 out_ready <= 0;
	 @(posedge clk);
	 #1;
	 test_assert ("Still Full: should be NOT ready", in_ready == 0);
	 test_assert ("Still Full: should be valid", out_valid == 1);

	 in_valid <= 0;
	 out_ready <= 1;
	 @(posedge clk);
	 #1;
	 test_assert ("Almost Full: should be ready", in_ready == 1);
	 test_assert ("Almost Full 2: should be valid", out_valid == 1);
	 
	 repeat (DEPTH-2) @(posedge clk);
	 #1;
	 test_assert ("Almost Empty: should be ready", in_ready == 1);
	 test_assert ("Almost Empty 2: should be valid", out_valid == 1);

	 @(posedge clk);
	 #1;
	 test_assert ("Empty: should be ready", in_ready == 1);
	 test_assert ("Empty 2: should not be valid", out_valid == 0);

	 endtest("test_exactly_full_and_empty");
	 
      end	 
   endtask

   // ---------------------------------------------------------------------
   //| Test random in & out rates
   // ---------------------------------------------------------------------
   task test_random;
      begin
	 test_success = 1;
	 repeat(20 * DEPTH) begin
	    @(posedge clk);
	    in_valid  <= ($random(23) && 1);
	    out_ready <= ($random(23) && 1);
	 end
	 endtest("test_random");
      end
   endtask // test_exactly_full_and_empty

   // ---------------------------------------------------------------------
   //| Empty the FIFO
   // ---------------------------------------------------------------------
   task empty_the_fifo;
      begin
	 in_valid <= 0;
	 out_ready <= 1;
	 repeat (DEPTH) @(posedge clk);
	 out_ready = 0;
      end
   endtask
   
   // ---------------------------------------------------------------------
   //| AssertFail
   // ---------------------------------------------------------------------
   task test_assert;
      input [256:0] message;
      input         condition;
      begin
	 if (! condition) begin
	    $display("(sim)%t: %s",$time, message);
	    success = 0;
	    test_success = 0;
	 end
      end
   endtask

   // ---------------------------------------------------------------------
   //| End Test
   // ---------------------------------------------------------------------
   task endtest;
      input [256:0] message;
      begin
	 if (test_success) begin
	    $display("(sim)%t: %-40s: Pass",$time, message);
	 end else begin
	    $display("(sim)%t: %-40s: Fail",$time, message);
	 end
	 success = success & test_success;
      end
   endtask
     
endmodule

// synthesis translate_on


