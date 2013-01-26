#include <stdio.h>
#include <math.h>
#include "svdpi.h"
#include "fft.h"

double
syn_cos(
    double rTheta){
  return  cos(rTheta);
}

double
syn_log(
    double rVal){
  return  log(rVal);
}

double
syn_log10(
    double rVal){
  return  log10(rVal);
}

double
syn_sin(
    double rTheta){
  return  sin(rTheta);
}

/*  Complex data type  */
typedef struct {double re; double im} complex_t;

//function for calculating absaloute value of a complex array
void  syn_calc_abs(int size, const svOpenArrayHandle complex_arry_real, const svOpenArrayHandle complex_arry_im)
{
  int i;
  double  * c_arry_re_ptr;
  double  * c_arry_im_ptr;

  c_arry_re_ptr  = (double  *)svGetArrayPtr(complex_arry_real);
  c_arry_im_ptr  = (double  *)svGetArrayPtr(complex_arry_im);

  for(i=0;i<size;i++) {
    //  printf("[syn_calc_abs - C] i : %d\tre : %f\t",i,c_arry_re_ptr[i]);

    //abs vaure is stored in real part
    c_arry_re_ptr[i] = sqrt((c_arry_re_ptr[i] * c_arry_re_ptr[i]) + (c_arry_im_ptr[i] * c_arry_im_ptr[i]));

    //  printf("im : %f\t abs : %f\n",c_arry_im_ptr[i],c_arry_re_ptr[i]);
  }

  return;
}


/*  Wrapper for calculating FFT */
//  SV Data Types -     int                             real[]                                real[]                              real[]
void syn_calc_fft(int num_samples,  const svOpenArrayHandle data_in_arry, const svOpenArrayHandle data_out_re_arry, const svOpenArrayHandle data_out_im_arry)
{
  int i;
  double (*x)[2];   /* pointer to time-domain samples */
  double (*X)[2];   /* pointer to frequency-domain samples */


  x = malloc(2 * num_samples  * sizeof(double));
  X = malloc(2 * num_samples  * sizeof(double));



  printf("\n \n Data In Array Left %d, Data In Array Right %d \n\n", svLeft(data_in_arry,1), svRight(data_in_arry, 1) );
  for (i= svLeft(data_in_arry,1); i <= svRight(data_in_arry,1); i++) {  //packing to double type
      x[i][0] = *(double*)svGetArrElemPtr1(data_in_arry, i);
      x[i][1] = 0;
  }

  /* Calculate FFT. */
  fft(num_samples, x, X);

  printf("\n \n Data Out Real Array Left %d, Data Out Real Array Right %d \n\n", svLeft(data_out_re_arry,1), svRight(data_out_re_arry, 1) );
  for(i= svLeft(data_out_re_arry,1); i <= svRight(data_out_re_arry,1); i++) { //packing real arry
    *(double*)svGetArrElemPtr1(data_out_re_arry, i) = X[i][0];
  }

  printf("\n \n Data Out Imaginary Array Left %d, Data Out Imaginary Array Right %d \n\n", svLeft(data_out_im_arry,1), svRight(data_out_im_arry, 1) );
  for(i= svLeft(data_out_im_arry,1); i <= svRight(data_out_im_arry,1); i++) { //packing im arry
    *(double*)svGetArrElemPtr1(data_out_im_arry, i) = X[i][1];
  }


  return;
}
