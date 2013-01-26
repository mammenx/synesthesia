OVM_PATH=/ws/grejames-bgl/synesthesia/verif/ovm-2.1.2
PRJ_TOP=/ws/grejames-bgl/synesthesia
#VCS_HOME=/auto/edatools2-bgl/synopsys/vcs/v2010.06
VCS_HOME=/auto/edatools/synopsys/vcs/v2010.06-1
# TEST_NAME=syn_base_test
#	TEST_NAME=syn_data_path_32b_dual_test
#	TEST_NAME=syn_pwm_test
# TEST_NAME=syn_sine_16b_dual_10kHz
#	TEST_NAME=syn_mem_acc_test
TEST_NAME=syn_wav_parse_test

all : clean compile run

clean :
	rm -rf simv rm ucli.key vc_hdrs.h csrc/ simv.daidir/ *.log ./logs *.vpd simv.vdb/ DVEfiles/ *.ver *.obj *.dll;
	mkdir logs;

compile :
	vcs --v v2010.06-1 -l vcs_compile.log -assert enable_diag -debug_pp -timescale=1ns/100ps -sverilog +v2k +libext+.v +verilog2001ext+.v +systemverilogext+.sv +incdir+$(OVM_PATH)/src $(OVM_PATH)/src/ovm_pkg.sv -f files.list +OVM_TESTNAME=$(TEST_NAME) +define+USE_RANDOMIZE +define+SIMULATION +define+VCS

run :
	./simv -l vcs_runtime.log -assert success +OVM_TESTNAME=$(TEST_NAME)

sim :
	dve --v v2010.06-1 -vpd vcdplus.vpd
