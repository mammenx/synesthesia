`ifndef __SYN_AV_ST_SEQ_ITEM
`define __SYN_AV_ST_SEQ_ITEM


  class syn_av_st_seq_item extends ovm_sequence_item;

    //fields
    rand  shortint  unsigned  data[]; //16b unsigned

    //registering with factory
    `ovm_object_utils_begin(syn_av_st_seq_item)
      `ovm_field_array_int(data,  OVM_ALL_ON | OVM_HEX);
    `ovm_object_utils_end

    function new(string name = "syn_av_st_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */

  endclass  : syn_av_st_seq_item

`endif
