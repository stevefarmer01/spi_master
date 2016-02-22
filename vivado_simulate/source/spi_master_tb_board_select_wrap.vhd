----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2016 13:42:09
-- Design Name: 
-- Module Name: spi_master_tb_gdrb_ctrl_bb_wrap - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.multi_array_types_pkg.all;

use work.spi_board_select_pkg.ALL;

entity spi_master_tb_board_select_wrap is
     generic(
--            board_select : boolean := FALSE; -- Use generate statement - xxxxxx_gen : if not board_select generate xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx end generate;
            make_all_addresses_writeable_for_testing : boolean := TRUE;
            DUT_TYPE : string := "write_and_then_read_an_address"
--            DUT_TYPE : string := "spi_reg_map_simple"
            );
end spi_master_tb_board_select_wrap;

architecture Behavioral of spi_master_tb_board_select_wrap is

component spi_master_tb is
    generic(
            board_select : boolean := FALSE;                           -- Use generate statement - xxxxxx_gen : if not board_select generate xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx end generate;
            make_all_addresses_writeable_for_testing : boolean := TRUE;
            DUT_TYPE : string := "write_and_then_read_an_address";
            --.            DUT_TYPE : string := "spi_reg_map_simple"
            --Set sizes of data and addresse as required for particular application
            SPI_ADDRESS_BITS : integer := 4;                           -- This has to be a multiple of 4 for HREAD to work OK in testbench
            SPI_DATA_BITS : integer := 16;                             -- This has to be a multiple of 4 for HREAD to work OK in testbench
            DATA_SIZE_C : integer := 21;                               -- Total data size = read/write bit + address + data
            --Low level SPI interface parameters
            SPI_CPOL      : std_logic := '0';                       -- CPOL value - 0 or 1 - these should really be constants but modelsim doesn't like it
            SPI_CPHA      : std_logic := '0';                       -- CPHA value - 0 or 1 - these should really be constants but modelsim doesn't like it
            SPI_LSB_FIRST : std_logic := '0';                       -- lsb first when '1' /msb first when - these should really be constants but modelsim doesn't like it
            --Pre-load register map array for testing and possible other uses
            mem_array_t_initalised : mem_array_t := initalise_mem_array_t(inc_values_enable => FALSE, inc_data_start_value => 16#0#);
            --Board select version's parameters
            SPI_BOARD_SEL_ADDR_BITS : integer := 0;
            SPI_BOARD_SEL_PROTOCOL_ADDR_BITS : integer := 8;
            SPI_BOARD_SEL_PROTOCOL_DATA_BITS : integer := 8
            );
end component;

    --Set sizes of board select address as they are still required by testbench even though this simulation is not going to directly use them
--    constant board_select : boolean := FALSE;                   -- This simulation is not using the Griffin SPI board select bits
--    constant SPI_BOARD_SEL_ADDR_BITS : integer := 0;            -- This has to be zero otherwise DATA_SIZE in testbench is calculated to the wrong size for these tests
--    constant SPI_BOARD_SEL_PROTOCOL_ADDR_BITS : integer := 8;   -- These don't really matter            -- This has to be zero otherwise 
--    constant SPI_BOARD_SEL_PROTOCOL_DATA_BITS : integer := 8;   -- These don't really matter

--    constant SPI_ADDRESS_BITS : integer := 4;                             -- This has to be a multiple of 4 for HREAD to work OK in testbench
--    constant SPI_DATA_BITS : integer := 16;                               -- This has to be a multiple of 4 for HREAD to work OK in testbench

    constant board_select : boolean := TRUE;                   -- This simulation is not using the Griffin SPI board select bits
    constant SPI_ADDRESS_BITS : integer := SPI_BOARD_SEL_PROTOCOL_ADDR_BITS;                             -- This has to be a multiple of 4 for HREAD to work OK in testbench
    constant SPI_DATA_BITS : integer := SPI_BOARD_SEL_PROTOCOL_DATA_BITS;                               -- This has to be a multiple of 4 for HREAD to work OK in testbench

begin

spi_master_tb_inst : spi_master_tb
    generic map(
            board_select => board_select,                                                         -- : boolean := FALSE;                                                                                -- Use generate statement - xxxxxx_gen : if not board_select generate xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx end generate;
            make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing, -- : boolean := TRUE;
            DUT_TYPE => DUT_TYPE,                                                                 -- : string := "write_and_then_read_an_address";
            --.            DUT_TYPE : string := "spi_reg_map_simple"
            --Set sizes of data and addresse as required for particular application
            SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                                                 -- : integer := 4;                                                                                    -- This has to be a multiple of 4 for HREAD to work OK in testbench
            SPI_DATA_BITS => SPI_DATA_BITS,                                                       -- : integer := 16;                                                                                   -- This has to be a multiple of 4 for HREAD to work OK in testbench
            DATA_SIZE_C => DATA_SIZE_C,                                                           -- : integer := SPI_ADDRESS_BITS+SPI_DATA_BITS+1;                                                     -- Total data size = read/write bit + address + data
            --Low level SPI interface parameters
            SPI_CPOL => SPI_BOARD_CPOL,                                                        -- : std_logic := '0';                                                                                -- CPOL value - 0 or 1 - these should really be constants but modelsim doesn't like it
            SPI_CPHA => SPI_BOARD_CPHA,                                                        -- : std_logic := '0';                                                                                -- CPHA value - 0 or 1 - these should really be constants but modelsim doesn't like it
            SPI_LSB_FIRST => SPI_BOARD_LSB_FIRST,                                              -- : std_logic := '0';                                                                                -- lsb first when '1' /msb first when - these should really be constants but modelsim doesn't like it
            --Pre-load register map array for testing and possible other uses
            mem_array_t_initalised => bs_mem_array_t_initalised_c,                                -- : mem_array_t := initalise_mem_array_t(inc_values_enable => FALSE, inc_data_start_value => 16#0#);
            --Board select version's parameters
            SPI_BOARD_SEL_ADDR_BITS => SPI_BOARD_SEL_ADDR_BITS,                                   -- : integer := 0;
            SPI_BOARD_SEL_PROTOCOL_ADDR_BITS => SPI_BOARD_SEL_PROTOCOL_ADDR_BITS,                 -- : integer := 8;
            SPI_BOARD_SEL_PROTOCOL_DATA_BITS => SPI_BOARD_SEL_PROTOCOL_DATA_BITS                  -- : integer := 8
            );


end Behavioral;
