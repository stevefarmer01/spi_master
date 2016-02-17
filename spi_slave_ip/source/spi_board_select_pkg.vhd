----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2016 15:14:34
-- Design Name: 
-- Module Name: spi_package - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--This package sets values for spi interface in the formate of - read/write bit + x number of address bits + x number of data bits


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package spi_board_select_pkg is

    --Set sizes of data and addresse as required for particular application
    constant SPI_BOARD_SEL_ADDR_BITS : integer := 4;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant SPI_BOARD_SEL_PROTOCOL_ADDR_BITS : integer := 8;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant SPI_BOARD_SEL_PROTOCOL_DATA_BITS : integer := 8;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant DATA_SIZE_C : integer   := SPI_BOARD_SEL_PROTOCOL_ADDR_BITS+SPI_BOARD_SEL_PROTOCOL_DATA_BITS+1;                             -- Total data size = read/write bit + address + data

end spi_board_select_pkg;

package body spi_board_select_pkg is

end;
