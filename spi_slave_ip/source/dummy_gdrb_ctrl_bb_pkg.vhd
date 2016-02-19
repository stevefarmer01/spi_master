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
    constant SPI_ADDRESS_BITS : integer := 6;
    constant SPI_DATA_BITS : integer := 8;
--    constant DATA_SIZE_C : integer := SPI_ADDRESS_BITS+SPI_DATA_BITS+1; -- Total data size = read/write bit + address + data
    --Low level SPI interface parameters
    constant SPI_BB_CPOL      : std_logic := '0';                                -- CPOL value - 0 or 1 - these should really be constants but modelsim doesn't like it
    constant SPI_BB_CPHA      : std_logic := '0';                                -- CPHA value - 0 or 1 - these should really be constants but modelsim doesn't like it
    constant SPI_BB_LSB_FIRST : std_logic := '0';                                -- lsb first when '1' /msb first when - these should really be constants but modelsim doesn't like it

    --Deferred constants below
    constant mem_array_t_initalised : mem_array_t;
--    --Function for multi-dimensional array initialisation via deferred constant
--    function initalise_mem_array_t(inc_values_enable : boolean; inc_data_start_value : natural ) return mem_array_t;


end gdrb_ctrl_bb_pkg;

package body gdrb_ctrl_bb_pkg is

--    --This function allows non-zero initialising of register map array for testing and possible other uses
--    function initalise_mem_array_t(inc_values_enable : boolean; inc_data_start_value : natural ) return mem_array_t is
--        variable mem_array_v : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
--    begin
--        if inc_values_enable then
--            for i in 0 to (2**SPI_ADDRESS_BITS)-1 loop
--                set_data_v(mem_array_v, i, std_logic_vector(to_unsigned(inc_data_start_value+i,SPI_DATA_BITS)));
--            end loop;
--        end if;
--        --Examples of how to manually set defualt values(these will overwrite incremented values above)
--        --set_data_v(mem_array_v, 0, std_logic_vector(to_unsigned(16#8#,SPI_DATA_BITS)));-- Example of how to manually set defualt values(these will overwrite incremented values above)
--        --set_data_v(mem_array_v, 1, std_logic_vector(to_unsigned(16#9#,SPI_DATA_BITS)));-- Example of how to manually set defualt values(these will overwrite incremented values above)
--        return mem_array_v;
--    end;
--    
--    --Pre-load register map array for testing and possible other uses
--    constant mem_array_t_initalised : mem_array_t := initalise_mem_array_t(inc_values_enable => FALSE, inc_data_start_value => 16#0#);

constant mem_array_t_initalised : mem_array_t (0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));

end;
