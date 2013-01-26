`ifndef __SYN_PWM_SEQ_ITEM
`define __SYN_PWM_SEQ_ITEM


  class syn_pwm_seq_item extends ovm_sequence_item;

    //fields
    rand  bit[3:0]  line_no;
    rand  time      val_on;
    rand  time      val_off;

    //registering with factory
    `ovm_object_utils_begin(syn_pwm_seq_item)
      `ovm_field_int(line_no, OVM_ALL_ON | OVM_DEC);
      `ovm_field_int(val_on,  OVM_ALL_ON | OVM_HEX);
      `ovm_field_int(val_off, OVM_ALL_ON | OVM_HEX);
    `ovm_object_utils_end

    function new(string name = "syn_pwm_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */

  endclass  : syn_pwm_seq_item

`endif
