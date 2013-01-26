add wave -r sim:/syn_tb_top/acortex_top_inst/*
# add wave -r sim:/syn_tb_top/fgyrus_top_lchnl_inst/*
# add wave -r sim:/syn_tb_top/fgyrus_top_rchnl_inst/*
radix -hex
run -all
