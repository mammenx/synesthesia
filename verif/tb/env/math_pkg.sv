package math_pkg;

  //import dpi task      C Name = SV function name
  import "DPI-C" pure function real syn_cos (input real rTheta);
  import "DPI-C" pure function real syn_sin (input real rTheta);
  import "DPI-C" pure function real syn_log (input real rVal);
  import "DPI-C" pure function real syn_log10 (input real rVal);
  import "DPI-C" pure function void syn_calc_abs(input int size, inout real arry_real[], input real arry_im[]);

  const real  pi  = 3.1416;

endpackage : math_pkg
