vmap -del work
vdel -all -lib work
vlib work
vmap work work
vlog -f files.msim.list +define+SIMULATION -sv  -timescale "1ns / 10ps"
# vsim syn_tb_top -dpiexportobj syn_dpi_export
exec gcc -c -g ../tb/dpi/fft.c -o fft.obj
exec gcc -c -g ../tb/dpi/syn_dpi.c -o syn_dpi.obj -IL:\altera\modelsim\modelsim_ase\include
exec gcc -shared -g -Bsymbolic -lmtipli -I. -IL:\altera\modelsim\modelsim_ase\include  -L../tb/dpi -LL:\altera\modelsim\modelsim_ase\win32aloem -o syn_dpi_lib.dll syn_dpi.obj fft.obj
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_base_test syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_data_path_16b_mono_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_data_path_32b_mono_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_data_path_16b_dual_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_data_path_32b_dual_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_sine_16b_dual_10kHz   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_mem_acc_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_wav_parse_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_mclk_sel_test   syn_tb_top +define+SIMULATION -l transcript.txt
# vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_adc_cap_test   syn_tb_top +define+SIMULATION -l transcript.txt
vsim -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=syn_pwm_test   syn_tb_top +define+SIMULATION -l transcript.txt
