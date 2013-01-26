package dsp_pkg;
  //import dpi task      C Name = SV function name
  //  import "DPI-C" pure function void syn_calc_fft(input  int num_samples,  input real data_in_arry[], output real data_out_re_arry[], output real data_out_im_arry[]);
  import "DPI-C" pure function void syn_calc_fft(input int num_samples,input real data_in_arry[], inout real data_out_re_arry[], inout real data_out_im_arry[]);

endpackage :  dsp_pkg 
