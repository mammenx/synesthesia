`ifndef __SYN_AV_MM_SEQ_ITEM
`define __SYN_AV_MM_SEQ_ITEM


  typedef enum  {READ=0, WRITE=1, BURST_READ=2, BURST_WRITE=3}  av_xtn_t;

  class syn_av_mm_seq_item extends ovm_sequence_item;

    //fields
    rand  shortint  unsigned  addr[]; //16b unsigned
    rand  int       unsigned  data[]; //32b unsigned
    rand  av_xtn_t            av_xtn;

    //registering with factory
    `ovm_object_utils_begin(syn_av_mm_seq_item)
      `ovm_field_array_int(addr,  OVM_ALL_ON | OVM_HEX);
      `ovm_field_array_int(data,  OVM_ALL_ON | OVM_HEX);
      `ovm_field_enum(av_xtn_t, av_xtn,  OVM_ALL_ON  | OVM_ENUM);
    `ovm_object_utils_end

    function new(string name = "syn_av_mm_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */
    constraint  c_burst_len_lim {
                                  if((av_xtn  ==  READ) ||  (av_xtn ==  WRITE)) {
                                    addr.size ==  1;
                                    data.size ==  1;
                                  }

                                  addr.size   ==  data.size;

                                  solve av_xtn  before  addr;
                                  solve addr    before  data;
                                }



  endclass  : syn_av_mm_seq_item

`endif
