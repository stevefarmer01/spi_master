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

use work.multi_array_types_pkg.all;

package gdrb_ctrl_bb_pkg is

--    --Set sizes of data and addresse as required for particular application
    constant SPI_ADDRESS_BITS : integer := 4;
    constant SPI_DATA_BITS : integer := 16;
--    constant DATA_SIZE_C : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1;                             -- Total data size = read/write bit + address + data
--    --Array type for all register map values
--    type gdrb_ctrl_address_type is array (integer range 0 to (SPI_ADDRESS_BITS**2)-1) of std_logic_vector(SPI_DATA_BITS-1 downto 0);
--    --This function allows non-zero initialising of register map array for testing and possible other uses
--    function initalise_gdrb_ctrl_data_array(inc_values_enable : boolean; inc_data_start_value : natural ) return gdrb_ctrl_address_type;
--    --Deferred constants below
--    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type;

--    subtype gdrb_ctrl_mem_array_t is mem_array_t(0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);

end gdrb_ctrl_bb_pkg;

package body gdrb_ctrl_bb_pkg is

--    --This function allows non-zero initialising of register map array for testing and possible other uses
--    function initalise_gdrb_ctrl_data_array(inc_values_enable : boolean; inc_data_start_value : natural ) return gdrb_ctrl_address_type is
--        variable gdrb_ctrl_data_array : gdrb_ctrl_address_type := (others => (others => '0'));
--    begin
--        if inc_values_enable then
--            for i in gdrb_ctrl_data_array'RANGE loop
--                gdrb_ctrl_data_array(i) := std_logic_vector(to_unsigned(inc_data_start_value+i,SPI_DATA_BITS)); -- Automatically incrementing values with an offset if required
--            end loop;
----                gdrb_ctrl_data_array(0) := (others => '1');                  -- Example of how to manually set defualt values(these will overwrite incremented values above)
----                gdrb_ctrl_data_array(1) := std_logic_vector(to_unsigned(16#8001#,SPI_DATA_BITS));                  -- Example of how to manually set defualt values(these will overwrite incremented values above)
----                gdrb_ctrl_data_array(2) := (others => '1');                  -- Example of how to manually set defualt values(these will overwrite incremented values above)
------.                gdrb_ctrl_data_array(0) := std_logic_vector(to_unsigned(16#0#,SPI_DATA_BITS));                  -- Example of how to manually set defualt values(these will overwrite incremented values above)
------.                gdrb_ctrl_data_array(1) := std_logic_vector(to_unsigned(16#1#,SPI_DATA_BITS));                  -- Example of how to manually set defualt values(these will overwrite incremented values above)
--            end if;
--        return gdrb_ctrl_data_array;
--    end;
--    
--    --Pre-load register map array for testing and possible other uses
--    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type := initalise_gdrb_ctrl_data_array(inc_values_enable => FALSE, inc_data_start_value => 0);
----    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type := initalise_gdrb_ctrl_data_array(inc_values_enable => TRUE, inc_data_start_value => 0);

end;