@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;C:/Xilinx/Vivado/2014.1/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2014.1/ids_lite/ISE/lib/nt64;C:/Xilinx/Vivado/2014.1/bin;%PATH%
set XILINX_PLANAHEAD=C:/Xilinx/Vivado/2014.1

xelab -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot spi_master_tb_behav --prj F:/usr/SFarmer/Griffin/GDRB/common_ip/spi_master/vivado_synth/spi_master.sim/sim_1/behav/spi_master_tb.prj   xil_defaultlib.spi_master_tb
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)
