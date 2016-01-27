----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2016 11:03:20
-- Design Name: 
-- Module Name: gdrb_ctrl_address_pkg - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.spi_package.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package gdrb_ctrl_address_pkg is
	
	constant gdrb_ctrl_example0_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) 		:= std_logic_vector(to_unsigned(16#0#,SPI_ADDRESS_BITS));
	constant gdrb_ctrl_example1_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) 		:= std_logic_vector(to_unsigned(16#1#,SPI_ADDRESS_BITS));

end gdrb_ctrl_address_pkg;

package body gdrb_ctrl_address_pkg is

end;
