call C:\Xilinx\Vivado\set_xilinx_vivado_2014_1.bat
cd simulate
xelab --debug typical --snapshot spi_master_tb_behav --prj ..\simulate_xsim.prj spi_master_tb -generic_top "DUT_TYPE=input_vector_file_test" -generic_top "board_select=FALSE" -generic_top "make_all_addresses_writeable_for_testing=FALSE" 