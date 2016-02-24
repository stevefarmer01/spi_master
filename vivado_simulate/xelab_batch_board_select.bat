call C:\Xilinx\Vivado\set_xilinx_vivado_2014_1.bat
cd simulate
xelab --debug typical --snapshot spi_master_tb_board_select_wrap --prj ..\simulate_board_select_xsim.prj spi_master_tb_board_select_wrap -generic_top "DUT_TYPE=input_vector_file_test" -generic_top "make_all_addresses_writeable_for_testing=FALSE"  -generic_top "external_spi_slave_dut=FALSE"
