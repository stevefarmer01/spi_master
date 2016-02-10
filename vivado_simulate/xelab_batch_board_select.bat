call C:\Xilinx\Vivado\set_xilinx_vivado_2014_1.bat
cd simulate
xelab --debug typical --snapshot spi_master_tb_behav --prj ..\simulate_board_select_xsim.prj spi_master_tb -generic_top "board_select=TRUE"
