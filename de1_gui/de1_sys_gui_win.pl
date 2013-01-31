#--------------------------------------------------------------------------
#  Synesthesia - Copyright (C) 2012 Gregory Matthew James.
#
#  This file is part of Synesthesia.
#
#  Synesthesia is free; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Synesthesia is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------------


# Main Module
package main;

# use Tk;
use Tkx;

# Switches to hold the options
$sel_sram;
$sel_sdram;
$sel_flash;
$sel_sdcard;
$sel_psh_switch;
$sel_tggl_switch;
$sel_red_leds;
$sel_green_leds;
$sel_7seg;
$sel_osc_50;
$sel_osc_27;
$sel_osc_24;
$sel_codec;
$sel_vga;
$sel_rs232;
$sel_ps2;
$sel_gpio_1;
$sel_gpio_2;
$gen_qsf_en = 0;
$gen_top_en = 0;


$msg  = "Select Interfaces ....";

sub build_sys_image_frm {
  my  ($parent) = @_;

  my  $sys_image_frm  = $parent->new_ttk__labelframe(-text => "DE1 Board",  -padding => '5');

  # Tkx::package_require("Img");
  Tkx::image_create_photo("imgobj", -file => "de1.GIF");
  # Tkx::image_create_photo("myimg", -file => "de1.png");
  # Tkx::image_create_photo("myimg", -file => "DE1.jpg");
  my $labelImage = $sys_image_frm->new_ttk__label('-image' => 'imgobj')->g_pack;
  # my $labelImage = $sys_image_frm->new_ttk__label('-image' => 'myimg')->g_pack;

  $sys_image_frm->g_grid(-row=>2,-column=>1);

}

sub build_chk_button_frm  {
  my  ($parent) = @_;

  my  $cb_frm = $parent->new_ttk__labelframe(-text =>  "Select Interfaces", -padding=>"5");

  # Checkbuttons
  $cb_frm -> new_ttk__checkbutton(  -text=>"SRAM",
                                    -variable=>\$sel_sram,
                                    -command =>sub{update_msg("SRAM",$sel_sram)}
                                  )->g_grid(-row=>1,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"SDRAM",
                                   -variable=>\$sel_sdram,
                                   -command => sub{update_msg("SDRAM", $sel_sdram)}
                                 ) -> g_grid(-row=>2,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"FLASH",
                                   -variable=>\$sel_flash,
                                   -command => sub{update_msg("FLASH", $sel_flash)}
                                 ) -> g_grid(-row=>3,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"SD CARD",
                                   -variable=>\$sel_sdcard,
                                   -command => sub{update_msg("SD CARD", $sel_sdcard)}
                                 ) -> g_grid(-row=>4,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Push Button Switches",
                                   -variable=>\$sel_psh_switch,
                                   -command => sub{update_msg("Push Button Switches", $sel_psh_switch)}
                                 ) -> g_grid(-row=>5,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Toggle Switches",
                                   -variable=>\$sel_tggl_switch,
                                   -command => sub{update_msg("Toggle Switches", $sel_tggl_switch)}
                                 ) -> g_grid(-row=>6,-column=>1,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Red Leds",
                                   -variable=>\$sel_red_leds,
                                   -command => sub{update_msg("Red Leds", $sel_red_leds)}
                                 ) -> g_grid(-row=>1,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Green Leds",
                                   -variable=>\$sel_green_leds,
                                   -command => sub{update_msg("Green Leds", $sel_green_leds)}
                                 ) -> g_grid(-row=>2,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Seven Segment Display",
                                   -variable=>\$sel_7seg,
                                   -command => sub{update_msg("Seven Segment Display", $sel_7seg)}
                                 ) -> g_grid(-row=>3,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"50MHz Oscillator",
                                   -variable=>\$sel_osc_50,
                                   -command => sub{update_msg("50MHz Oscillator", $sel_osc_50)}
                                 ) -> g_grid(-row=>4,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"27MHz Oscillator",
                                   -variable=>\$sel_osc_27,
                                   -command => sub{update_msg("27MHz Oscillator", $sel_osc_27)}
                                 ) -> g_grid(-row=>5,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"24MHz Oscillator",
                                   -variable=>\$sel_osc_24,
                                   -command => sub{update_msg("24MHz Oscillator", $sel_osc_24)}
                                 ) -> g_grid(-row=>6,-column=>50,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"Audio CODEC",
                                   -variable=>\$sel_codec,
                                   -command => sub{update_msg("Audio CODEC", $sel_codec)}
                                 ) -> g_grid(-row=>1,-column=>100,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"VGA",
                                   -variable=>\$sel_vga,
                                   -command => sub{update_msg("VGA", $sel_vga)}
                                 ) -> g_grid(-row=>2,-column=>100,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"RS232",
                                   -variable=>\$sel_rs232,
                                   -command => sub{update_msg("RS232", $sel_rs232)}
                                 ) -> g_grid(-row=>3,-column=>100,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"PS2",
                                   -variable=>\$sel_ps2,
                                   -command => sub{update_msg("PS2", $sel_ps2)}
                                 ) -> g_grid(-row=>4,-column=>100,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"GPIO Bank 0",
                                   -variable=>\$sel_gpio_1,
                                   -command => sub{update_msg("GPIO Bank 0", $sel_gpio_1)}
                                 ) -> g_grid(-row=>5,-column=>100,-sticky=>"w");

  $cb_frm -> new_ttk__checkbutton( -text=>"GPIO Bank 1",
                                   -variable=>\$sel_gpio_2,
                                   -command => sub{update_msg("GPIO Bank 1", $sel_gpio_2)}
                                 ) -> g_grid(-row=>6,-column=>100,-sticky=>"w");

  #  $cb_frm->g_pack(-anchor=>"w");
  $cb_frm->g_grid(-row=>"1",-column=>"1",-sticky=>"w");
  # $cb_frm->g_grid_rowconfigure(1,-weight=>"2");

}

sub build_button_frm  {
  my  ($parent,$pbar) = @_;

  my  $b_frm = $parent->new_ttk__labelframe(-text =>  "Select Files to Generate", -padding=>"5");

  $b_frm  -> new_ttk__checkbutton( -text=>"QSF",
                                   -variable=>\$gen_qsf_en,
                                   -command => sub{update_msg("QSF Option Selected", $gen_qsf_en)}
                                 ) -> g_grid(-row=>"1",-column=>"1",-sticky=>"w");

  $b_frm  -> new_ttk__checkbutton( -text=>"FPGA Top Module",
                                   -variable=>\$gen_top_en,
                                   -command => sub{update_msg("FPGA Top Module Option Selected", $gen_qsf_en)}
                                 ) -> g_grid(-row=>"2",-column=>"1",-sticky=>"w");

  $b_frm -> new_ttk__button( -text => 'Generate!', 
                             -command => [sub{gen_main($pbar)}]
                           ) -> g_grid(-row=>"3",-column=>"1",-sticky=>"w");

  $b_frm->g_grid(-row=>"1",-column=>"3",-sticky=>"e");
  # $b_frm->g_grid_rowconfigure(1,-weight=>"0");

}

sub build_gui {
  my  $mw=Tkx::widget->new(".");
  $mw->g_wm_title("DE1 System Generator Tool");
  $mw->g_wm_resizable(0,0);

  $mw ->  new_ttk__label(-textvariable => \$msg)->g_grid(-row=>"1",-column=>"1");

  build_sys_image_frm($mw);

  my  $pbar = $mw->new_ttk__progressbar(-orient => 'horizontal', -length => 200, -mode => 'determinate', -value=>"0");

  my  $frm1 = $mw->new_ttk__frame();

  build_chk_button_frm($frm1);

  $frm1->new_ttk__label(-text=>"                                        ")->g_grid(-row=>"1",-column=>"2");  #dummy spacer frame

  build_button_frm($frm1,$pbar);

  $frm1->g_grid(-row=>"3",-column=>"1");
  # $frm1->g_grid_rowconfigure(3,-weight=>"2");

  $pbar->g_grid(-row=>"4",-column=>"1");

  Tkx::MainLoop();
}

sub gen_main {
  my  ($pbar) = @_;

  $pbar->configure(-value=>"0");

  if($gen_qsf_en  ==  1)  {
    gen_qsf("de1.qsf");
  }

  $pbar->configure(-value=>"33");

  if($gen_top_en  ==  1)  {
    gen_top("fpga_top.v");
  }

  $pbar->configure(-value=>"66");

  if(($gen_qsf_en ==  0)  &&  ($gen_top_en  ==  0)) {
    $msg  = "No Files are selected for generation !!";
  }

  $pbar->configure(-value=>"100");
}

sub gen_top {
  my  ($file) = @_;

  $msg  = "Generating $file";

  open(FILE, ">",  "$file") or die  print "Could not open file <$file>\n";  # Open file

  print FILE  "/*\n";
  print FILE  " --------------------------------------------------------------------------\n";
  print FILE  " -- Project Code      :\n";
  print FILE  " -- Module Name       :\n";
  print FILE  " -- Author            :\n";
  print FILE  " -- Associated modules:\n";
  print FILE  " -- Function          :\n";
  print FILE  " --------------------------------------------------------------------------\n";
  print FILE  "*/\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "`timescale 1ns / 10ps\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "module <fpga_top_name>\n";
  print FILE  "   (\n";
  print FILE  "     /*  Clocks  */\n";
  if($sel_osc_50  ==  1)  {
    print FILE"     CLOCK_50,               //50MHz clock\n";
  }
  print FILE  "     EXT_CLOCK,              //External clock\n";
  if($sel_osc_27  ==  1)  {
    print FILE"     CLOCK_27,               //27MHz clock\n";
  }
  if($sel_osc_24  ==  1)  {
    print FILE"     CLOCK_24,               //24MHz clock\n";
  }
  if($sel_tggl_switch ==  1)  {
    print FILE"\n";
    print FILE"     /*  TOGGLE SWITCH    */\n";
    print FILE"     SW,                     //Toggle Switch\n";
  }
  if($sel_sdram ==  1)  {
    print FILE"\n";
    print FILE"     /*  SDRAM            */\n";
    print FILE"     DRAM_DQ,                //SDRAM Data bus 16 Bits\n";
    print FILE"     DRAM_ADDR,              //SDRAM Address bus 12 Bits\n";
    print FILE"     DRAM_LDQM,              //SDRAM Low-byte Data Mask \n";
    print FILE"     DRAM_UDQM,              //SDRAM High-byte Data Mask\n";
    print FILE"     DRAM_WE_N,              //SDRAM Write Enable\n";
    print FILE"     DRAM_CAS_N,             //SDRAM Column Address Strobe\n";
    print FILE"     DRAM_RAS_N,             //SDRAM Row Address Strobe\n";
    print FILE"     DRAM_CS_N,              //SDRAM Chip Select\n";
    print FILE"     DRAM_BA_0,              //SDRAM Bank Address 0\n";
    print FILE"     DRAM_BA_1,              //SDRAM Bank Address 0\n";
    print FILE"     DRAM_CLK,               //SDRAM Clock\n";
    print FILE"     DRAM_CKE,               //SDRAM Clock Enable\n";
  }
  if($sel_flash ==  1)  {
    print FILE"\n";
    print FILE"     /*  FLASH            */\n";
    print FILE"     FL_DQ,                  // FLASH Data bus 8 Bits\n";
    print FILE"     FL_ADDR,                // FLASH Address bus 22 Bits\n";
    print FILE"     FL_WE_N,                // FLASH Write Enable\n";
    print FILE"     FL_RST_N,               // FLASH Reset\n";
    print FILE"     FL_OE_N,                // FLASH Output Enable\n";
    print FILE"     FL_CE_N,                // FLASH Chip Enable\n";
  }
  if($sel_7seg  ==  1)  {
    print FILE"\n";
    print FILE"     /*  7 SEGMENT DISPLAY */\n";
    print FILE"     HEX0,                   // Seven Segment Digit 0\n";
    print FILE"     HEX1,                   // Seven Segment Digit 1\n";
    print FILE"     HEX2,                   // Seven Segment Digit 2\n";
    print FILE"     HEX3,                   // Seven Segment Digit 3\n";
  }
  if($sel_psh_switch  ==  1)  {
    print FILE"\n";
    print FILE"     /*  PUSH BUTTON SWITCH*/\n";
    print FILE"     KEY,                    // Pushbutton[3:0]\n";
  }
  if(($sel_red_leds ==  1)  ||  ($sel_green_leds  ==  1)) {
    print FILE"\n";
    print FILE"     /*      LEDs    */\n";
  }
  if($sel_red_leds  ==  1)  {
    print FILE"     LEDR,                   // LED Red[9:0]\n";
  }
  if($sel_green_leds  ==  1)  {
    print FILE"     LEDG,                   // LED Green[7:0]\n";
  }
  if($sel_ps2 ==  1)  {
    print FILE"\n";
    print FILE"     /*      PS2     */\n";
    print FILE"     PS2_DAT,                // PS2 Data\n";
    print FILE"     PS2_CLK,                // PS2 Clock\n";
  }
  if($sel_rs232 ==  1)  {
    print FILE"\n";
    print FILE"     /*      RS232   */\n";
    print FILE"     UART_TXD,               // RS232 UART Transmitter\n";
    print FILE"     UART_RXD,               // RS232 UART Receiver\n";
  }
  if($sel_sram  ==  1)  {
    print FILE"\n";
    print FILE"     /*      SRAM    */\n";
    print FILE"     SRAM_DQ,                // SRAM Data bus 16 Bits\n";
    print FILE"     SRAM_ADDR,              // SRAM Address bus 18 Bits\n";
    print FILE"     SRAM_UB_N,              // SRAM High-byte Data Mask \n";
    print FILE"     SRAM_LB_N,              // SRAM Low-byte Data Mask \n";
    print FILE"     SRAM_WE_N,              // SRAM Write Enable\n";
    print FILE"     SRAM_CE_N,              // SRAM Chip Enable\n";
    print FILE"     SRAM_OE_N,              // SRAM Output Enable\n";
  }
  if($sel_vga ==  1)  {
    print FILE"\n";
    print FILE"     /*      VGA     */\n";
    print FILE"     VGA_HS,                 // VGA H_SYNC\n";
    print FILE"     VGA_VS,                 // VGA V_SYNC\n";
    print FILE"     VGA_R,                  // VGA Red[3:0]\n";
    print FILE"     VGA_G,                  // VGA Green[3:0]\n";
    print FILE"     VGA_B,                  // VGA Blue[3:0]\n";
  }
  if($sel_codec ==  1)  {
    print FILE"\n";
    print FILE"     /*  AUDIO CODEC */\n";
    print FILE"     I2C_SCLK,               // I2C Clock\n";
    print FILE"     I2C_SDAT,               // I2C Data\n";
    print FILE"     AUD_ADCLRCK,            // Audio CODEC ADC LR Clock\n";
    print FILE"     AUD_ADCDAT,             // Audio CODEC ADC Data\n";
    print FILE"     AUD_DACLRCK,            // Audio CODEC DAC LR Clock\n";
    print FILE"     AUD_DACDAT,             // Audio CODEC DAC Data\n";
    print FILE"     AUD_BCLK,               // Audio CODEC Bit-Stream Clock\n";
    print FILE"     AUD_XCK,                // Audio CODEC Chip Clock\n";
  }
  if(($sel_gpio_1 ==  1)  ||  ($sel_gpio_2  ==  1)) {
    print FILE"\n";
    print FILE"     /*   GPIOs      */\n";
  }
  if($sel_gpio_1  ==  1)  {
    print FILE"     GPIO_0,                 // GPIO Connection 0\n";
  }
  if($sel_gpio_2  ==  1)  {
    print FILE"     GPIO_1,                 // GPIO Connection 1\n";
  }
  if($sel_sdcard  ==  1)  {
    print FILE"\n";
    print FILE"     /*   SDCARD     */\n";
    print FILE"     SD_DAT,                 // SD Card Data\n";
    print FILE"     SD_DAT3,                // SD Card Data 3\n";
    print FILE"     SD_CMD,                 // SD Card Command Signal\n";
    print FILE"     SD_CLK,                 // SD Card Clock\n";
  }
  print FILE  "\n";
  print FILE  "     /* USB JTAG UART  */\n";
  print FILE  "     TDI,                    // CPLD -> FPGA (data in)\n";
  print FILE  "     TCK,                    // CPLD -> FPGA (clk)\n";
  print FILE  "     TCS,                    // CPLD -> FPGA (CS)\n";
  print FILE  "     TDO                     // FPGA -> CPLD (data out)\n";
  print FILE  "\n";
  print FILE  "   );\n";
  print FILE  "\n";
  print FILE  "//----------------------- Global parameters Declarations ------------------\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Input Declarations ------------------------------\n";
  if($sel_osc_50  ==  1)  {
    print FILE"   input                       CLOCK_50;\n";
  }
  print FILE  "   input                       EXT_CLOCK;\n";
  if($sel_osc_27  ==  1)  {
    print FILE"   input   [1:0]               CLOCK_27;\n";
  }
  if($sel_osc_24  ==  1)  {
    print FILE"   input   [1:0]               CLOCK_24;\n";
  }
  if($sel_tggl_switch ==  1)  {
    print FILE"\n";
    print FILE"   input   [9:0]               SW;\n";
  }
  if($sel_psh_switch  ==  1)  {
    print FILE"\n";
    print FILE"   input   [3:0]               KEY;\n";
  }
  if($sel_ps2 ==  1)  {
    print FILE"\n";
    print FILE"   input                       PS2_DAT;\n";
    print FILE"   input                       PS2_CLK;\n";
  }
  if($sel_rs232 ==  1)  {
    print FILE"\n";
    print FILE"   input                       UART_RXD;\n";
  }
  if($sel_codec ==  1)  {
    print FILE"\n";
    print FILE"   input                       AUD_ADCDAT;\n";
  }
  if($sel_sdcard  ==  1)  {
    print FILE"\n";
    print FILE"   input                       SD_DAT;\n";
  } 
  print FILE  "   input                       TDI;\n";
  print FILE  "   input                       TCK;\n";
  print FILE  "   input                       TCS;\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Inout Declarations ------------------------------\n";
  if($sel_sdram ==  1)  {
    print FILE"   inout   [15:0]              DRAM_DQ;\n";
  }
  if($sel_flash ==  1)  {
    print FILE"\n";
    print FILE"   inout   [7:0]               FL_DQ;\n";
  }
  if($sel_sram  ==  1)  {
    print FILE"\n";
    print FILE"   inout   [15:0]              SRAM_DQ;\n";
  }
  if($sel_codec ==  1)  {
    print FILE"\n";
    print FILE"   inout                       I2C_SDAT;\n";
    print FILE"   inout                       AUD_BCLK;\n";
  }
  print FILE  "\n";
  if($sel_gpio_1  ==  1)  {
    print FILE"   inout   [35:0]              GPIO_0;\n";
  }
  if($sel_gpio_2  ==  1)  {
    print FILE"   inout   [35:0]              GPIO_1;\n";
  }
  print FILE  "\n";
  print FILE  "//----------------------- Output Declarations -----------------------------\n";
  if($sel_sdram ==  1)  {
    print FILE"   output  [11:0]              DRAM_ADDR;\n";
    print FILE"   output                      DRAM_LDQM;\n";
    print FILE"   output                      DRAM_UDQM;\n";
    print FILE"   output                      DRAM_WE_N;\n";
    print FILE"   output                      DRAM_CAS_N;\n";
    print FILE"   output                      DRAM_RAS_N;\n";
    print FILE"   output                      DRAM_CS_N;\n";
    print FILE"   output                      DRAM_BA_0;\n";
    print FILE"   output                      DRAM_BA_1;\n";
    print FILE"   output                      DRAM_CLK;\n";
    print FILE"   output                      DRAM_CKE;\n";
  }
  if($sel_flash ==  1)  {
    print FILE"\n";
    print FILe"   output  [21:0]              FL_ADDR;\n";
    print FILe"   output                      FL_WE_N;\n";
    print FILe"   output                      FL_RST_N;\n";
    print FILe"   output                      FL_OE_N;\n";
    print FILe"   output                      FL_CE_N;\n";
  }
  if($sel_7seg  ==  1)  {
    print FILE"\n";
    print FILE"   output  [6:0]               HEX0;\n";
    print FILE"   output  [6:0]               HEX1;\n";
    print FILE"   output  [6:0]               HEX2;\n";
    print FILE"   output  [6:0]               HEX3;\n";
  }
  if($sel_red_leds  ==  1)  {
    print FILE"\n";
    print FILE"   output  [9:0]               LEDR;\n";
  }
  if($sel_green_leds  ==  1)  {
    print FILE"\n";
    print FILE"   output  [7:0]               LEDG;\n";
  }
  if($sel_rs232 ==  1)  {
    print FILE"\n";
    print FILE"   output                      UART_TXD;\n";
  }
  if($sel_sram  ==  1)  {
    print FILE"\n";
    print FILE"   output  [17:0]              SRAM_ADDR;\n";
    print FILE"   output                      SRAM_UB_N;\n";
    print FILE"   output                      SRAM_LB_N;\n";
    print FILE"   output                      SRAM_WE_N;\n";
    print FILE"   output                      SRAM_CE_N;\n";
    print FILE"   output                      SRAM_OE_N;\n";
  }
  if($sel_vga ==  1)  {
    print FILE"\n";
    print FILE"   output                      VGA_HS;\n";
    print FILE"   output                      VGA_VS;\n";
    print FILE"   output  [3:0]               VGA_R;\n";
    print FILE"   output  [3:0]               VGA_G;\n";
    print FILE"   output  [3:0]               VGA_B;\n";
  }
  if($sel_codec ==  1)  {
    print FILE"\n";
    print FILE"   output                      I2C_SCLK;\n";
    print FILE"   output                      AUD_ADCLRCK;\n";
    print FILE"   output                      AUD_DACLRCK;\n";
    print FILE"   output                      AUD_DACDAT;\n";
    print FILE"   output                      AUD_XCK;\n";
  }
  if($sel_sdcard  ==  1)  {
    print FILE"\n";
    print FILE"   output                      SD_CLK;\n";
    print FILE"   output                      SD_DAT3;\n";
    print FILE"   output                      SD_CMD;\n";
  }
  print FILE  "\n";
  print FILE  "   output                      TDO;\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Output Register Declaration ---------------------\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Internal Register Declarations ------------------\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Internal Wire Declarations ----------------------\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "//----------------------- Start of Code -----------------------------------\n";
  print FILE  "\n";
  print FILE  "\n";
  print FILE  "endmodule // <fpga_top_name>";

  $msg  = "Generated $file ...";
  close(FILE);

}

sub gen_qsf {
  my  ($file) = @_;

  $msg  = "Generating $file";

  open(FILE, ">",  "$file") or die  print "Could not open file <$file>\n";  # Open file

  print FILE  "set_global_assignment -name DEVICE EP2C20F484C7\n";
  print FILE  "set_global_assignment -name FAMILY \"Cyclone II\"\n";

  $msg  = "Generating $file .";

  if($sel_tggl_switch ==  1)  {
    print FILE  "set_location_assignment PIN_L22 -to SW[0]\n";
    print FILE  "set_location_assignment PIN_L21 -to SW[1]\n";
    print FILE  "set_location_assignment PIN_M22 -to SW[2]\n";
    print FILE  "set_location_assignment PIN_V12 -to SW[3]\n";
    print FILE  "set_location_assignment PIN_W12 -to SW[4]\n";
    print FILE  "set_location_assignment PIN_U12 -to SW[5]\n";
    print FILE  "set_location_assignment PIN_U11 -to SW[6]\n";
    print FILE  "set_location_assignment PIN_M2 -to SW[7]\n";
    print FILE  "set_location_assignment PIN_M1 -to SW[8]\n";
    print FILE  "set_location_assignment PIN_L2 -to SW[9]\n";
  }

  if($sel_sdram ==  1)  {
    print FILE  "set_location_assignment PIN_W4 -to DRAM_ADDR[0]\n";
    print FILE  "set_location_assignment PIN_W5 -to DRAM_ADDR[1]\n";
    print FILE  "set_location_assignment PIN_Y3 -to DRAM_ADDR[2]\n";
    print FILE  "set_location_assignment PIN_Y4 -to DRAM_ADDR[3]\n";
    print FILE  "set_location_assignment PIN_R6 -to DRAM_ADDR[4]\n";
    print FILE  "set_location_assignment PIN_R5 -to DRAM_ADDR[5]\n";
    print FILE  "set_location_assignment PIN_P6 -to DRAM_ADDR[6]\n";
    print FILE  "set_location_assignment PIN_P5 -to DRAM_ADDR[7]\n";
    print FILE  "set_location_assignment PIN_P3 -to DRAM_ADDR[8]\n";
    print FILE  "set_location_assignment PIN_N4 -to DRAM_ADDR[9]\n";
    print FILE  "set_location_assignment PIN_W3 -to DRAM_ADDR[10]\n";
    print FILE  "set_location_assignment PIN_N6 -to DRAM_ADDR[11]\n";
    print FILE  "set_location_assignment PIN_U3 -to DRAM_BA_0\n";
    print FILE  "set_location_assignment PIN_V4 -to DRAM_BA_1\n";
    print FILE  "set_location_assignment PIN_T3 -to DRAM_CAS_N\n";
    print FILE  "set_location_assignment PIN_N3 -to DRAM_CKE\n";
    print FILE  "set_location_assignment PIN_U4 -to DRAM_CLK\n";
    print FILE  "set_location_assignment PIN_T6 -to DRAM_CS_N\n";
    print FILE  "set_location_assignment PIN_U1 -to DRAM_DQ[0]\n";
    print FILE  "set_location_assignment PIN_U2 -to DRAM_DQ[1]\n";
    print FILE  "set_location_assignment PIN_V1 -to DRAM_DQ[2]\n";
    print FILE  "set_location_assignment PIN_V2 -to DRAM_DQ[3]\n";
    print FILE  "set_location_assignment PIN_W1 -to DRAM_DQ[4]\n";
    print FILE  "set_location_assignment PIN_W2 -to DRAM_DQ[5]\n";
    print FILE  "set_location_assignment PIN_Y1 -to DRAM_DQ[6]\n";
    print FILE  "set_location_assignment PIN_Y2 -to DRAM_DQ[7]\n";
    print FILE  "set_location_assignment PIN_N1 -to DRAM_DQ[8]\n";
    print FILE  "set_location_assignment PIN_N2 -to DRAM_DQ[9]\n";
    print FILE  "set_location_assignment PIN_P1 -to DRAM_DQ[10]\n";
    print FILE  "set_location_assignment PIN_P2 -to DRAM_DQ[11]\n";
    print FILE  "set_location_assignment PIN_R1 -to DRAM_DQ[12]\n";
    print FILE  "set_location_assignment PIN_R2 -to DRAM_DQ[13]\n";
    print FILE  "set_location_assignment PIN_T1 -to DRAM_DQ[14]\n";
    print FILE  "set_location_assignment PIN_T2 -to DRAM_DQ[15]\n";
    print FILE  "set_location_assignment PIN_R7 -to DRAM_LDQM\n";
    print FILE  "set_location_assignment PIN_M5 -to DRAM_UDQM\n";
    print FILE  "set_location_assignment PIN_T5 -to DRAM_RAS_N\n";
    print FILE  "set_location_assignment PIN_R8 -to DRAM_WE_N\n";
  }

  if($sel_flash ==  1)  {
    print FILE  "set_location_assignment PIN_AB20 -to FL_ADDR[0]\n";
    print FILE  "set_location_assignment PIN_AA14 -to FL_ADDR[1]\n";
    print FILE  "set_location_assignment PIN_Y16 -to FL_ADDR[2]\n";
    print FILE  "set_location_assignment PIN_R15 -to FL_ADDR[3]\n";
    print FILE  "set_location_assignment PIN_T15 -to FL_ADDR[4]\n";
    print FILE  "set_location_assignment PIN_U15 -to FL_ADDR[5]\n";
    print FILE  "set_location_assignment PIN_V15 -to FL_ADDR[6]\n";
    print FILE  "set_location_assignment PIN_W15 -to FL_ADDR[7]\n";
    print FILE  "set_location_assignment PIN_R14 -to FL_ADDR[8]\n";
    print FILE  "set_location_assignment PIN_Y13 -to FL_ADDR[9]\n";
    print FILE  "set_location_assignment PIN_R12 -to FL_ADDR[10]\n";
    print FILE  "set_location_assignment PIN_T12 -to FL_ADDR[11]\n";
    print FILE  "set_location_assignment PIN_AB14 -to FL_ADDR[12]\n";
    print FILE  "set_location_assignment PIN_AA13 -to FL_ADDR[13]\n";
    print FILE  "set_location_assignment PIN_AB13 -to FL_ADDR[14]\n";
    print FILE  "set_location_assignment PIN_AA12 -to FL_ADDR[15]\n";
    print FILE  "set_location_assignment PIN_AB12 -to FL_ADDR[16]\n";
    print FILE  "set_location_assignment PIN_AA20 -to FL_ADDR[17]\n";
    print FILE  "set_location_assignment PIN_U14 -to FL_ADDR[18]\n";
    print FILE  "set_location_assignment PIN_V14 -to FL_ADDR[19]\n";
    print FILE  "set_location_assignment PIN_U13 -to FL_ADDR[20]\n";
    print FILE  "set_location_assignment PIN_R13 -to FL_ADDR[21]\n";
    print FILE  "set_location_assignment PIN_AA15 -to FL_OE_N\n";
    print FILE  "set_location_assignment PIN_AB16 -to FL_DQ[0]\n";
    print FILE  "set_location_assignment PIN_AA16 -to FL_DQ[1]\n";
    print FILE  "set_location_assignment PIN_AB17 -to FL_DQ[2]\n";
    print FILE  "set_location_assignment PIN_AA17 -to FL_DQ[3]\n";
    print FILE  "set_location_assignment PIN_AB18 -to FL_DQ[4]\n";
    print FILE  "set_location_assignment PIN_AA18 -to FL_DQ[5]\n";
    print FILE  "set_location_assignment PIN_AB19 -to FL_DQ[6]\n";
    print FILE  "set_location_assignment PIN_AA19 -to FL_DQ[7]\n";
    print FILE  "set_location_assignment PIN_W14 -to FL_RST_N\n";
    print FILE  "set_location_assignment PIN_Y14 -to FL_WE_N\n";
  }

  if($sel_7seg  ==  1)  {
    print FILE  "set_location_assignment PIN_J2 -to HEX0[0]\n";
    print FILE  "set_location_assignment PIN_J1 -to HEX0[1]\n";
    print FILE  "set_location_assignment PIN_H2 -to HEX0[2]\n";
    print FILE  "set_location_assignment PIN_H1 -to HEX0[3]\n";
    print FILE  "set_location_assignment PIN_F2 -to HEX0[4]\n";
    print FILE  "set_location_assignment PIN_F1 -to HEX0[5]\n";
    print FILE  "set_location_assignment PIN_E2 -to HEX0[6]\n";
    print FILE  "set_location_assignment PIN_E1 -to HEX1[0]\n";
    print FILE  "set_location_assignment PIN_H6 -to HEX1[1]\n";
    print FILE  "set_location_assignment PIN_H5 -to HEX1[2]\n";
    print FILE  "set_location_assignment PIN_H4 -to HEX1[3]\n";
    print FILE  "set_location_assignment PIN_G3 -to HEX1[4]\n";
    print FILE  "set_location_assignment PIN_D2 -to HEX1[5]\n";
    print FILE  "set_location_assignment PIN_D1 -to HEX1[6]\n";
    print FILE  "set_location_assignment PIN_G5 -to HEX2[0]\n";
    print FILE  "set_location_assignment PIN_G6 -to HEX2[1]\n";
    print FILE  "set_location_assignment PIN_C2 -to HEX2[2]\n";
    print FILE  "set_location_assignment PIN_C1 -to HEX2[3]\n";
    print FILE  "set_location_assignment PIN_E3 -to HEX2[4]\n";
    print FILE  "set_location_assignment PIN_E4 -to HEX2[5]\n";
    print FILE  "set_location_assignment PIN_D3 -to HEX2[6]\n";
    print FILE  "set_location_assignment PIN_F4 -to HEX3[0]\n";
    print FILE  "set_location_assignment PIN_D5 -to HEX3[1]\n";
    print FILE  "set_location_assignment PIN_D6 -to HEX3[2]\n";
    print FILE  "set_location_assignment PIN_J4 -to HEX3[3]\n";
    print FILE  "set_location_assignment PIN_L8 -to HEX3[4]\n";
    print FILE  "set_location_assignment PIN_F3 -to HEX3[5]\n";
    print FILE  "set_location_assignment PIN_D4 -to HEX3[6]\n";
  }

  if($sel_psh_switch  ==  1)  {
    print FILE  "set_location_assignment PIN_R22 -to KEY[0]\n";
    print FILE  "set_location_assignment PIN_R21 -to KEY[1]\n";
    print FILE  "set_location_assignment PIN_T22 -to KEY[2]\n";
    print FILE  "set_location_assignment PIN_T21 -to KEY[3]\n";
  }

  if($sel_red_leds  ==  1)  {
    print FILE  "set_location_assignment PIN_R20 -to LEDR[0]\n";
    print FILE  "set_location_assignment PIN_R19 -to LEDR[1]\n";
    print FILE  "set_location_assignment PIN_U19 -to LEDR[2]\n";
    print FILE  "set_location_assignment PIN_Y19 -to LEDR[3]\n";
    print FILE  "set_location_assignment PIN_T18 -to LEDR[4]\n";
    print FILE  "set_location_assignment PIN_V19 -to LEDR[5]\n";
    print FILE  "set_location_assignment PIN_Y18 -to LEDR[6]\n";
    print FILE  "set_location_assignment PIN_U18 -to LEDR[7]\n";
    print FILE  "set_location_assignment PIN_R18 -to LEDR[8]\n";
    print FILE  "set_location_assignment PIN_R17 -to LEDR[9]\n";
  }

  if($sel_green_leds  ==  1)  {
    print FILE  "set_location_assignment PIN_U22 -to LEDG[0]\n";
    print FILE  "set_location_assignment PIN_U21 -to LEDG[1]\n";
    print FILE  "set_location_assignment PIN_V22 -to LEDG[2]\n";
    print FILE  "set_location_assignment PIN_V21 -to LEDG[3]\n";
    print FILE  "set_location_assignment PIN_W22 -to LEDG[4]\n";
    print FILE  "set_location_assignment PIN_W21 -to LEDG[5]\n";
    print FILE  "set_location_assignment PIN_Y22 -to LEDG[6]\n";
    print FILE  "set_location_assignment PIN_Y21 -to LEDG[7]\n";
  }

  if($sel_osc_50  ==  1)  {
    print FILE  "set_location_assignment PIN_L1 -to CLOCK_50\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to CLOCK_50\n";
  }

  print FILE  "set_location_assignment PIN_M21 -to EXT_CLOCK\n";

  if($sel_ps2 ==  1)  {
    print FILE  "set_location_assignment PIN_H15 -to PS2_CLK\n";
    print FILE  "set_location_assignment PIN_J14 -to PS2_DAT\n";
  }

  if($sel_rs232 ==  1)  {
    print FILE  "set_location_assignment PIN_F14 -to UART_RXD\n";
    print FILE  "set_location_assignment PIN_G12 -to UART_TXD\n";
  }

  if($sel_sram  ==  1)  {
    print FILE  "set_location_assignment PIN_AA3 -to SRAM_ADDR[0]\n";
    print FILE  "set_location_assignment PIN_AB3 -to SRAM_ADDR[1]\n";
    print FILE  "set_location_assignment PIN_AA4 -to SRAM_ADDR[2]\n";
    print FILE  "set_location_assignment PIN_AB4 -to SRAM_ADDR[3]\n";
    print FILE  "set_location_assignment PIN_AA5 -to SRAM_ADDR[4]\n";
    print FILE  "set_location_assignment PIN_AB10 -to SRAM_ADDR[5]\n";
    print FILE  "set_location_assignment PIN_AA11 -to SRAM_ADDR[6]\n";
    print FILE  "set_location_assignment PIN_AB11 -to SRAM_ADDR[7]\n";
    print FILE  "set_location_assignment PIN_V11 -to SRAM_ADDR[8]\n";
    print FILE  "set_location_assignment PIN_W11 -to SRAM_ADDR[9]\n";
    print FILE  "set_location_assignment PIN_R11 -to SRAM_ADDR[10]\n";
    print FILE  "set_location_assignment PIN_T11 -to SRAM_ADDR[11]\n";
    print FILE  "set_location_assignment PIN_Y10 -to SRAM_ADDR[12]\n";
    print FILE  "set_location_assignment PIN_U10 -to SRAM_ADDR[13]\n";
    print FILE  "set_location_assignment PIN_R10 -to SRAM_ADDR[14]\n";
    print FILE  "set_location_assignment PIN_T7 -to SRAM_ADDR[15]\n";
    print FILE  "set_location_assignment PIN_Y6 -to SRAM_ADDR[16]\n";
    print FILE  "set_location_assignment PIN_Y5 -to SRAM_ADDR[17]\n";
    print FILE  "set_location_assignment PIN_AA6 -to SRAM_DQ[0]\n";
    print FILE  "set_location_assignment PIN_AB6 -to SRAM_DQ[1]\n";
    print FILE  "set_location_assignment PIN_AA7 -to SRAM_DQ[2]\n";
    print FILE  "set_location_assignment PIN_AB7 -to SRAM_DQ[3]\n";
    print FILE  "set_location_assignment PIN_AA8 -to SRAM_DQ[4]\n";
    print FILE  "set_location_assignment PIN_AB8 -to SRAM_DQ[5]\n";
    print FILE  "set_location_assignment PIN_AA9 -to SRAM_DQ[6]\n";
    print FILE  "set_location_assignment PIN_AB9 -to SRAM_DQ[7]\n";
    print FILE  "set_location_assignment PIN_Y9 -to SRAM_DQ[8]\n";
    print FILE  "set_location_assignment PIN_W9 -to SRAM_DQ[9]\n";
    print FILE  "set_location_assignment PIN_V9 -to SRAM_DQ[10]\n";
    print FILE  "set_location_assignment PIN_U9 -to SRAM_DQ[11]\n";
    print FILE  "set_location_assignment PIN_R9 -to SRAM_DQ[12]\n";
    print FILE  "set_location_assignment PIN_W8 -to SRAM_DQ[13]\n";
    print FILE  "set_location_assignment PIN_V8 -to SRAM_DQ[14]\n";
    print FILE  "set_location_assignment PIN_U8 -to SRAM_DQ[15]\n";
    print FILE  "set_location_assignment PIN_AA10 -to SRAM_WE_N\n";
    print FILE  "set_location_assignment PIN_T8 -to SRAM_OE_N\n";
    print FILE  "set_location_assignment PIN_W7 -to SRAM_UB_N\n";
    print FILE  "set_location_assignment PIN_Y7 -to SRAM_LB_N\n";
    print FILE  "set_location_assignment PIN_AB5 -to SRAM_CE_N\n";
  }

  print FILE  "set_location_assignment PIN_E8 -to TDI\n";
  print FILE  "set_location_assignment PIN_D8 -to TCS\n";
  print FILE  "set_location_assignment PIN_C7 -to TCK\n";
  print FILE  "set_location_assignment PIN_D7 -to TDO\n";

  if($sel_vga ==  1)  {
    print FILE  "set_location_assignment PIN_D9 -to VGA_R[0]\n";
    print FILE  "set_location_assignment PIN_C9 -to VGA_R[1]\n";
    print FILE  "set_location_assignment PIN_A7 -to VGA_R[2]\n";
    print FILE  "set_location_assignment PIN_B7 -to VGA_R[3]\n";
    print FILE  "set_location_assignment PIN_B8 -to VGA_G[0]\n";
    print FILE  "set_location_assignment PIN_C10 -to VGA_G[1]\n";
    print FILE  "set_location_assignment PIN_B9 -to VGA_G[2]\n";
    print FILE  "set_location_assignment PIN_A8 -to VGA_G[3]\n";
    print FILE  "set_location_assignment PIN_A9 -to VGA_B[0]\n";
    print FILE  "set_location_assignment PIN_D11 -to VGA_B[1]\n";
    print FILE  "set_location_assignment PIN_A10 -to VGA_B[2]\n";
    print FILE  "set_location_assignment PIN_B10 -to VGA_B[3]\n";
    print FILE  "set_location_assignment PIN_A11 -to VGA_HS\n";
    print FILE  "set_location_assignment PIN_B11 -to VGA_VS\n";
  }

  if($sel_codec ==  1)  {
    print FILE  "set_location_assignment PIN_A3 -to I2C_SCLK\n";
    print FILE  "set_location_assignment PIN_B3 -to I2C_SDAT\n";
    print FILE  "set_location_assignment PIN_A6 -to AUD_ADCLRCK\n";
    print FILE  "set_location_assignment PIN_B6 -to AUD_ADCDAT\n";
    print FILE  "set_location_assignment PIN_A5 -to AUD_DACLRCK\n";
    print FILE  "set_location_assignment PIN_B5 -to AUD_DACDAT\n";
    print FILE  "set_location_assignment PIN_B4 -to AUD_XCK\n";
    print FILE  "set_location_assignment PIN_A4 -to AUD_BCLK\n";
  }

  if($sel_gpio_1  ==  1)  {
    print FILE  "set_location_assignment PIN_A13 -to GPIO_0[0]\n";
    print FILE  "set_location_assignment PIN_B13 -to GPIO_0[1]\n";
    print FILE  "set_location_assignment PIN_A14 -to GPIO_0[2]\n";
    print FILE  "set_location_assignment PIN_B14 -to GPIO_0[3]\n";
    print FILE  "set_location_assignment PIN_A15 -to GPIO_0[4]\n";
    print FILE  "set_location_assignment PIN_B15 -to GPIO_0[5]\n";
    print FILE  "set_location_assignment PIN_A16 -to GPIO_0[6]\n";
    print FILE  "set_location_assignment PIN_B16 -to GPIO_0[7]\n";
    print FILE  "set_location_assignment PIN_A17 -to GPIO_0[8]\n";
    print FILE  "set_location_assignment PIN_B17 -to GPIO_0[9]\n";
    print FILE  "set_location_assignment PIN_A18 -to GPIO_0[10]\n";
    print FILE  "set_location_assignment PIN_B18 -to GPIO_0[11]\n";
    print FILE  "set_location_assignment PIN_A19 -to GPIO_0[12]\n";
    print FILE  "set_location_assignment PIN_B19 -to GPIO_0[13]\n";
    print FILE  "set_location_assignment PIN_A20 -to GPIO_0[14]\n";
    print FILE  "set_location_assignment PIN_B20 -to GPIO_0[15]\n";
    print FILE  "set_location_assignment PIN_C21 -to GPIO_0[16]\n";
    print FILE  "set_location_assignment PIN_C22 -to GPIO_0[17]\n";
    print FILE  "set_location_assignment PIN_D21 -to GPIO_0[18]\n";
    print FILE  "set_location_assignment PIN_D22 -to GPIO_0[19]\n";
    print FILE  "set_location_assignment PIN_E21 -to GPIO_0[20]\n";
    print FILE  "set_location_assignment PIN_E22 -to GPIO_0[21]\n";
    print FILE  "set_location_assignment PIN_F21 -to GPIO_0[22]\n";
    print FILE  "set_location_assignment PIN_F22 -to GPIO_0[23]\n";
    print FILE  "set_location_assignment PIN_G21 -to GPIO_0[24]\n";
    print FILE  "set_location_assignment PIN_G22 -to GPIO_0[25]\n";
    print FILE  "set_location_assignment PIN_J21 -to GPIO_0[26]\n";
    print FILE  "set_location_assignment PIN_J22 -to GPIO_0[27]\n";
    print FILE  "set_location_assignment PIN_K21 -to GPIO_0[28]\n";
    print FILE  "set_location_assignment PIN_K22 -to GPIO_0[29]\n";
    print FILE  "set_location_assignment PIN_J19 -to GPIO_0[30]\n";
    print FILE  "set_location_assignment PIN_J20 -to GPIO_0[31]\n";
    print FILE  "set_location_assignment PIN_J18 -to GPIO_0[32]\n";
    print FILE  "set_location_assignment PIN_K20 -to GPIO_0[33]\n";
    print FILE  "set_location_assignment PIN_L19 -to GPIO_0[34]\n";
    print FILE  "set_location_assignment PIN_L18 -to GPIO_0[35]\n";
  }

  if($sel_gpio_2  ==  1)  {
    print FILE  "set_location_assignment PIN_H12 -to GPIO_1[0]\n";
    print FILE  "set_location_assignment PIN_H13 -to GPIO_1[1]\n";
    print FILE  "set_location_assignment PIN_H14 -to GPIO_1[2]\n";
    print FILE  "set_location_assignment PIN_G15 -to GPIO_1[3]\n";
    print FILE  "set_location_assignment PIN_E14 -to GPIO_1[4]\n";
    print FILE  "set_location_assignment PIN_E15 -to GPIO_1[5]\n";
    print FILE  "set_location_assignment PIN_F15 -to GPIO_1[6]\n";
    print FILE  "set_location_assignment PIN_G16 -to GPIO_1[7]\n";
    print FILE  "set_location_assignment PIN_F12 -to GPIO_1[8]\n";
    print FILE  "set_location_assignment PIN_F13 -to GPIO_1[9]\n";
    print FILE  "set_location_assignment PIN_C14 -to GPIO_1[10]\n";
    print FILE  "set_location_assignment PIN_D14 -to GPIO_1[11]\n";
    print FILE  "set_location_assignment PIN_D15 -to GPIO_1[12]\n";
    print FILE  "set_location_assignment PIN_D16 -to GPIO_1[13]\n";
    print FILE  "set_location_assignment PIN_C17 -to GPIO_1[14]\n";
    print FILE  "set_location_assignment PIN_C18 -to GPIO_1[15]\n";
    print FILE  "set_location_assignment PIN_C19 -to GPIO_1[16]\n";
    print FILE  "set_location_assignment PIN_C20 -to GPIO_1[17]\n";
    print FILE  "set_location_assignment PIN_D19 -to GPIO_1[18]\n";
    print FILE  "set_location_assignment PIN_D20 -to GPIO_1[19]\n";
    print FILE  "set_location_assignment PIN_E20 -to GPIO_1[20]\n";
    print FILE  "set_location_assignment PIN_F20 -to GPIO_1[21]\n";
    print FILE  "set_location_assignment PIN_E19 -to GPIO_1[22]\n";
    print FILE  "set_location_assignment PIN_E18 -to GPIO_1[23]\n";
    print FILE  "set_location_assignment PIN_G20 -to GPIO_1[24]\n";
    print FILE  "set_location_assignment PIN_G18 -to GPIO_1[25]\n";
    print FILE  "set_location_assignment PIN_G17 -to GPIO_1[26]\n";
    print FILE  "set_location_assignment PIN_H17 -to GPIO_1[27]\n";
    print FILE  "set_location_assignment PIN_J15 -to GPIO_1[28]\n";
    print FILE  "set_location_assignment PIN_H18 -to GPIO_1[29]\n";
    print FILE  "set_location_assignment PIN_N22 -to GPIO_1[30]\n";
    print FILE  "set_location_assignment PIN_N21 -to GPIO_1[31]\n";
    print FILE  "set_location_assignment PIN_P15 -to GPIO_1[32]\n";
    print FILE  "set_location_assignment PIN_N15 -to GPIO_1[33]\n";
    print FILE  "set_location_assignment PIN_P17 -to GPIO_1[34]\n";
    print FILE  "set_location_assignment PIN_P18 -to GPIO_1[35]\n";
  }

  if($sel_sdcard  ==  1)  {
    print FILE  "set_location_assignment PIN_V20 -to SD_CLK\n";
    print FILE  "set_location_assignment PIN_Y20 -to SD_CMD\n";
    print FILE  "set_location_assignment PIN_W20 -to SD_DAT\n";
    print FILE  "set_location_assignment PIN_U20 -to SD_DAT3\n";
    print FILE  "set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION \"USE AS REGULAR IO\"\n";

  }

  $msg  = "Generating $file ..";

  print FILE  "set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top\n";

  print FILE  "set_global_assignment -name IGNORE_CLOCK_SETTINGS ON\n";
  print FILE  "set_global_assignment -name FMAX_REQUIREMENT \"50 MHz\"\n";
  print FILE  "set_global_assignment -name PARTITION_COLOR 2147039 -section_id Top\n";
  print FILE  "set_global_assignment -name LL_ROOT_REGION ON -section_id \"Root Region\"\n";
  print FILE  "set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id \"Root Region\"\n";

  print FILE  "set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0\n";
  print FILE  "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85\n";

  if($sel_gpio_1  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[7]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[8]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[9]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[10]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[11]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[12]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[13]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[14]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[15]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[16]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[17]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[18]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[19]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[20]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[21]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[22]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[23]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[24]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[25]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[26]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[27]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[28]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[29]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[30]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[31]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[32]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[33]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[34]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_0[35]\n";
  }

  if($sel_gpio_2  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[7]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[8]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[9]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[10]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[11]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[12]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[13]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[14]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[15]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[16]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[17]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[18]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[19]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[20]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[21]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[22]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[23]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[24]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[25]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[26]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[27]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[28]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[29]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[30]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[31]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[32]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[33]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[34]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to GPIO_1[35]\n";
  }

  if($sel_tggl_switch ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[7]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[8]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to SW[9]\n";
  }

  if($sel_7seg  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX0[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX1[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX2[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to HEX3[6]\n";
  }

  if($sel_psh_switch  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to KEY[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to KEY[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to KEY[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to KEY[3]\n";
  }

  if($sel_red_leds  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[7]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[8]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDR[9]\n";
  }

  if($sel_green_leds  ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[4]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[5]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[6]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to LEDG[7]\n";
  }

  if($sel_osc_27  ==  1)  {
    print FILE  "set_location_assignment PIN_D12 -to CLOCK_27[0]\n";
    print FILE  "set_location_assignment PIN_E12 -to CLOCK_27[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to CLOCK_27[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to CLOCK_27[1]\n";
  }

  if($sel_osc_24  ==  1)  {
    print FILE  "set_location_assignment PIN_B12 -to CLOCK_24[0]\n";
    print FILE  "set_location_assignment PIN_A12 -to CLOCK_24[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to CLOCK_24[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to CLOCK_24[1]\n";
  }

  print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to EXT_CLOCK\n";

  if($sel_ps2 ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to PS2_CLK\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to PS2_DAT\n";
  }

  if($sel_rs232 ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to UART_RXD\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to UART_TXD\n";
  }

  print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to TDI\n";
  print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to TCS\n";
  print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to TCK\n";
  print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to TDO\n";

  if($sel_vga ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_R[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_R[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_R[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_R[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_G[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_G[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_G[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_G[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_B[0]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_B[1]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_B[2]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_B[3]\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_HS\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to VGA_VS\n";
  }

  if($sel_codec ==  1)  {
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to I2C_SCLK\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to I2C_SDAT\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_ADCLRCK\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_ADCDAT\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_DACLRCK\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_DACDAT\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_XCK\n";
    print FILE  "set_instance_assignment -name IO_STANDARD LVTTL -to AUD_BCLK\n";
  }

  $msg  = "Generating $file ...";

  print FILE  "set_instance_assignment -name FAST_INPUT_REGISTER ON -to *\n";
  print FILE  "set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to *\n";
  print FILE  "set_instance_assignment -name TSU_REQUIREMENT \"10 ns\" -from * -to *\n";
  print FILE  "set_instance_assignment -name CURRENT_STRENGTH_NEW \"MINIMUM CURRENT\" -to *\n";

  if($sel_codec ==  1)  {
    print FILE  "set_instance_assignment -name CURRENT_STRENGTH_NEW \"MAXIMUM CURRENT\" -to I2C_SCLK\n";
    print FILE  "set_instance_assignment -name CURRENT_STRENGTH_NEW \"MAXIMUM CURRENT\" -to I2C_SDAT\n";
  }


  print FILE  "set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top\n";

  close(FILE);

  $msg  = "Generated $file ...";
}

sub update_msg  {
  my  ($name,$status) = @_;

  if($status  ==  1){
    $msg  = "$name Selected ...";
  }
  else{
    $msg  = "$name De-Selected ...";
  }
}

sub main_do {

  build_gui();

}

# ------------------------  Main execution block  -------------
# Comment this section if using as lib/.pm file

main_do();

exit;
# -------------------------------------------------------------

1;
