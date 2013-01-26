`ifndef __SYN_FGYRUS_FFT_SEQ_ITEM
`define __SYN_FGYRUS_FFT_SEQ_ITEM

  typedef enum  {SAMPLE=0, TWIDDLE=1}  complex_t;

  class syn_complex_seq_item extends ovm_sequence_item;

    //fields
    rand  longint       data_real;  //real part
    rand  longint       data_im;    //imaginary part
    rand  complex_t     _type;      //Type of complex number

    //registering with factory
    `ovm_object_utils_begin(syn_complex_seq_item)
      `ovm_field_int(data_real,  OVM_ALL_ON | OVM_DEC);
      `ovm_field_int(data_im,  OVM_ALL_ON | OVM_DEC);
      `ovm_field_enum(complex_t,  _type,  OVM_ALL_ON  | OVM_ENUM);
    `ovm_object_utils_end

    function new(string name = "syn_complex_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */
    constraint  c_data_real_lim { _type==SAMPLE   ->  data_real inside  {[-2147483647:2147483647]}; /*  32b signed  */
                                  _type==TWIDDLE  ->  data_real inside  {[-511:511]};               /*  10b signed  */
                                }

    constraint  c_data_im_lim   { _type==SAMPLE   ->  data_im   inside  {[-2147483647:2147483647]}; /*  32b signed  */
                                  _type==TWIDDLE  ->  data_im   inside  {[-511:511]};               /*  10b signed  */
                                }
  endclass  : syn_complex_seq_item

  function  automatic void  complex_mul(syn_complex_seq_item a, syn_complex_seq_item b, int norm_factor, ref syn_complex_seq_item res);
    //syn_complex_seq_item res = new(name);

    res.data_real = ((a.data_real * b.data_real)  - (a.data_im  * b.data_im)) / norm_factor;

    res.data_im   = ((a.data_im * b.data_real)  + (b.data_im  * a.data_real)) / norm_factor;

    //return res;
    return;
  endfunction : complex_mul

  function automatic  void complex_add(syn_complex_seq_item a, syn_complex_seq_item b, ref syn_complex_seq_item res);
    //syn_complex_seq_item res = new(name);

    res.data_real   = a.data_real + b.data_real;
    res.data_im     = a.data_im   + b.data_im;

    //return  res;
    return;
  endfunction : complex_add


  class syn_fgyrus_fft_seq_item extends ovm_sequence_item;

    //fields
    rand  syn_complex_seq_item  sample_a;
    rand  syn_complex_seq_item  sample_b;
    rand  syn_complex_seq_item  twiddle;

    //registering with factory
    `ovm_object_utils_begin(syn_fgyrus_fft_seq_item)
      `ovm_field_object(sample_a,  OVM_ALL_ON);
      `ovm_field_object(sample_b,  OVM_ALL_ON);
      `ovm_field_object(twiddle,  OVM_ALL_ON);
    `ovm_object_utils_end

    function new(string name = "syn_fgyrus_fft_seq_item");
      super.new(name);

      sample_a  = new("sample_a");
      sample_b  = new("sample_b");
      twiddle   = new("twiddle");
    endfunction : new


    constraint  c_complex_type  {sample_a._type ==  SAMPLE; sample_b._type  ==  SAMPLE; twiddle._type ==  TWIDDLE;}

  endclass  : syn_fgyrus_fft_seq_item

`endif
