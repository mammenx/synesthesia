`ifndef __SYN_DAC_SEQ_ITEM
`define __SYN_DAC_SEQ_ITEM


  class syn_dac_seq_item extends ovm_sequence_item;

    //fields
    rand  int rdata;  //Right Channel data
    rand  int ldata;  //Left Channel data

    //registering with factory
    `ovm_object_utils_begin(syn_dac_seq_item)
      `ovm_field_int(ldata,  OVM_ALL_ON | OVM_DEC);
      `ovm_field_int(rdata,  OVM_ALL_ON | OVM_DEC);
    `ovm_object_utils_end

    function new(string name = "syn_dac_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */


  endclass  : syn_dac_seq_item

`endif
