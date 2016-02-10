----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2016 17:28:49
-- Design Name: 
-- Module Name: board_select_reg_map_top - Behavioral
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

use IEEE.NUMERIC_STD.ALL;

use work.gdrb_ctrl_bb_pkg.ALL;

use work.gdrb_ctrl_bb_address_pkg.ALL;

use work.spi_board_select_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_board_select_top is
    generic ( make_all_addresses_writeable_for_testing : boolean := FALSE ); -- This is for testbenching only
    Port ( 
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in gdrb_ctrl_address_type := (others => (others => '0'));
            reg_map_array_to_pins : out gdrb_ctrl_address_type;
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
          );
end spi_board_select_top;

architecture Behavioral of spi_board_select_top is

component spi_board_select_slave is
    generic(
            BOARD_SELECT_ADDRESS_SIZE : natural := 4
            );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            ---Outputs
            board_select : out std_logic_vector(BOARD_SELECT_ADDRESS_SIZE-1 downto 0) := (others => '0');
            board_select_valid : out std_logic := '0'
            );
end component;

component gdrb_ctrl_reg_map_top is
    generic ( make_all_addresses_writeable_for_testing : boolean := FALSE ); -- This is for testbenching only
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in gdrb_ctrl_address_type := (others => (others => '0'));
            reg_map_array_to_pins : out gdrb_ctrl_address_type;
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
            );
end component;

signal board_select_s : std_logic_vector(SPI_BOARD_SEL_ADDR_BITS-1 downto 0) := (others => '0');
signal board_select_valid_s : std_logic := '0';

begin

spi_board_select_slave_proc : spi_board_select_slave
    generic map(
            BOARD_SELECT_ADDRESS_SIZE => SPI_BOARD_SEL_ADDR_BITS -- : natural := 4
            )
    Port map(  
            clk => clk,                                -- : in std_logic;
            reset => reset,                            -- : in std_logic;
            ---Slave SPI interface pins
            sclk => sclk,                              -- : in STD_LOGIC;
            ss_n => ss_n,                              -- : in STD_LOGIC;
            mosi => mosi,                              -- : in STD_LOGIC;
            ---Outputs
            board_select => board_select_s,            -- : out std_logic_vector(BOARD_SELECT_ADDRESS_SIZE-1 downto 0) := (others => '0');
            board_select_valid => board_select_valid_s -- : out std_logic := '0'
            );

reg_map_proc : gdrb_ctrl_reg_map_top
    generic map(
            make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing -- :     natural := 16
            )
    Port map(  
            clk => clk,                                         -- : std_logic;
            reset => reset,                                     -- : std_logic;
            --Slave SPI interface pins
            sclk => sclk,                                       -- : in STD_LOGIC;
            ss_n => ss_n,                                       -- : in STD_LOGIC;
            mosi => mosi,                                       -- : in STD_LOGIC;
            miso => miso,                                       -- : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins => reg_map_array_from_pins, -- : in gdrb_ctrl_address_type := (others => (others => '0'));
            reg_map_array_to_pins => reg_map_array_to_pins      -- : out gdrb_ctrl_address_type
            );


end Behavioral;
