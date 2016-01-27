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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package spi_package is

--.    constant DATA_SIZE : integer   := 13;
    constant SPI_ADDRESS_BITS : integer := 4;
    constant SPI_DATA_BITS : integer := 8;
    constant DATA_SIZE : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1; -- Total data size = read/write bit + address + data = 13
   
    type input_data_type is array (integer range 0 to 15) of std_logic_vector(DATA_SIZE - 1 downto 0);
    type gdrb_ctrl_address_type is array (integer range 0 to (SPI_ADDRESS_BITS**2)-1) of std_logic_vector(SPI_DATA_BITS-1 downto 0);

    function initalise_gdrb_ctrl_data_array(data_start_value : natural ) return gdrb_ctrl_address_type;

    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type;
    constant gdrb_ctrl_data_array_initalise_offset : gdrb_ctrl_address_type;

end spi_package;

package body spi_package is

    function initalise_gdrb_ctrl_data_array(data_start_value : natural ) return gdrb_ctrl_address_type is
        variable gdrb_ctrl_data_array : gdrb_ctrl_address_type := (others => (others => '0'));
    begin
        for i in gdrb_ctrl_data_array'RANGE loop
            gdrb_ctrl_data_array(i) := std_logic_vector(to_unsigned(data_start_value+i,SPI_DATA_BITS));
        end loop;
        return gdrb_ctrl_data_array;
    end;

    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type := initalise_gdrb_ctrl_data_array(data_start_value => 0);
    constant gdrb_ctrl_data_array_initalise_offset : gdrb_ctrl_address_type := initalise_gdrb_ctrl_data_array(data_start_value => 16#10#);

end;
