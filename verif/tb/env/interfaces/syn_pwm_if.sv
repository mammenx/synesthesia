interface syn_pwm_if #(NO_LINES  = 16)  (input  logic sys_rst);

  logic [NO_LINES-1:0]  pwm_data;

  modport TB  (input  pwm_data,sys_rst);

  modport DUT (output pwm_data);

endinterface  //syn_pwm_if
