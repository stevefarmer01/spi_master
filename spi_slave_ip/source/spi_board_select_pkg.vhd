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

package spi_board_select_pkg is

    --Set sizes of data and addresse as required for particular application
    constant SPI_BOARD_SEL_ADDR_BITS : integer := 4;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant SPI_BOARD_SEL_PROTOCOL_ADDR_BITS : integer := 6;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant SPI_BOARD_SEL_PROTOCOL_DATA_BITS : integer := 8;	-- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant DATA_SIZE_C : integer   := SPI_BOARD_SEL_PROTOCOL_ADDR_BITS+SPI_BOARD_SEL_PROTOCOL_DATA_BITS+1;                             -- Total data size = read/write bit + address + data

    --Deferred constants below
    constant bs_mem_array_t_initalised_c : mem_array_t;
    --Function for multi-dimensional array initialisation via deferred constant
    function initalise_mem_array_t(inc_values_enable : boolean; inc_data_start_value : natural ) return mem_array_t;

end spi_board_select_pkg;

package body spi_board_select_pkg is

    --This function allows non-zero initialising of register map array for testing and possible other uses
    function initalise_mem_array_t(inc_values_enable : boolean; inc_data_start_value : natural ) return mem_array_t is
        variable mem_array_v : mem_array_t( 0 to (SPI_BOARD_SEL_PROTOCOL_ADDR_BITS**2)-1, SPI_BOARD_SEL_PROTOCOL_DATA_BITS-1 downto 0) := (others => (others => '0'));
    begin
        if inc_values_enable then
            for i in 0 to (SPI_BOARD_SEL_PROTOCOL_ADDR_BITS**2)-1 loop
                set_data_v(mem_array_v, i, std_logic_vector(to_unsigned(inc_data_start_value+i,SPI_BOARD_SEL_PROTOCOL_DATA_BITS)));
            end loop;
        end if;
        --Examples of how to manually set default values(these will overwrite incremented values above)
        --set_data_v(mem_array_v, 0, std_logic_vector(to_unsigned(16#8#,SPI_DATA_BITS)));-- Example of how to manually set defualt values(these will overwrite incremented values above)
        --set_data_v(mem_array_v, 1, std_logic_vector(to_unsigned(16#9#,SPI_DATA_BITS)));-- Example of how to manually set defualt values(these will overwrite incremented values above)
        return mem_array_v;
    end;
    
    --Pre-load register map array for testing and possible other uses
    constant bs_mem_array_t_initalised_c : mem_array_t := initalise_mem_array_t(inc_values_enable => TRUE, inc_data_start_value => 16#0#);

end;
