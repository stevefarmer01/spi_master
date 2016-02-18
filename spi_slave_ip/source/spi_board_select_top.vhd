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

use work.multi_array_types_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_board_select_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := TRUE; -- This is for testbenching only
            SPI_BOARD_SEL_ADDR_BITS : integer := 4;
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16
           );
    Port ( 
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
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

component generic_spi_reg_map_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16
           );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
            );
end component;

constant board_select_addr_0_c : natural := 16#8#;

constant valid_delayed_c : positive := 1; -- Delay board select edge detect due to delay caused by domain crossing of sclk in spi_slave.vhd

signal board_select_s, prev_board_select_s : std_logic_vector((SPI_BOARD_SEL_ADDR_BITS-1) downto 0) := (others => '0');
signal board_select_valid_s : std_logic := '0';
signal board_select_mux_ss_n_s, miso_board_select_mux_ss_n_s : std_logic_vector(((SPI_BOARD_SEL_ADDR_BITS**2)-1) downto 0) := (others => '1'); -- Default to all ss_n's de-asserted
signal board_select_valid_r0 : std_logic := '0';
signal board_select_valid_delayed_s : std_logic_vector(valid_delayed_c-1 downto 0) := (others => '0');
signal board_select_valid_delayed_bit_s : std_logic := '0';
signal miso_s : std_logic_vector(((SPI_BOARD_SEL_ADDR_BITS**2)-1) downto 0) := (others => '0');

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

--Delay +ve edge of select_valid and hence board_select until sclk low due to particulars of how spi_slave.vhd and board select protocol work
board_select_delay_proc : process
    variable board_select_pos_edge_v : std_logic := '0';
begin
    wait until rising_edge(clk);
    board_select_valid_r0 <= board_select_valid_s;
    if ss_n = '1' then
        board_select_pos_edge_v := '0';
        board_select_valid_delayed_s <= (others => '0');
        board_select_valid_delayed_bit_s <= '0';
    elsif board_select_valid_r0 = '0' and board_select_valid_s = '1' then
        board_select_pos_edge_v := '1';
    elsif sclk = '0' and board_select_pos_edge_v = '1' then
        board_select_pos_edge_v := '0';
        board_select_valid_delayed_bit_s <= '1';
    end if;
    if valid_delayed_c = 1 then
        board_select_valid_delayed_s(0) <= board_select_valid_delayed_bit_s; -- Delay board select edge detect due to delay caused by domain crossing of sclk in spi_slave.vhd
    else
        board_select_valid_delayed_s <= board_select_valid_delayed_s(board_select_valid_delayed_s'LEFT-1 downto 0) & board_select_valid_delayed_bit_s; -- Delay board select edge detect due to delay caused by domain crossing of sclk in spi_slave.vhd
    end if;
end process;

board_select_ss_n_mux_proc : process
begin
    wait until rising_edge(clk);
    board_select_mux_ss_n_s <= (others => '1');      -- Default value
    for i in 0 to ((SPI_BOARD_SEL_ADDR_BITS**2)-1) loop
        if ((to_integer(unsigned(board_select_s))) = i) and board_select_valid_delayed_s(board_select_valid_delayed_s'LEFT) = '1' then 
            board_select_mux_ss_n_s(i) <= ss_n;         -- Mux main ss_n through to slave as per received board select bits from 'spi_board_select_slave'
--            miso <= miso_s(i);
        end if;
    end loop;
end process;

--For tx replies back on 'miso' use last receieved board select and raw ss_n so that data is sent back as soon as ss_n goes low and before new board select has been recieved(due to Griffin protcol)
miso_board_select_ss_n_mux_proc : process
    variable ss_n_v : std_logic := '0';
begin
    wait until rising_edge(clk);
    if ss_n_v = '0' and ss_n = '1' then
        prev_board_select_s <= board_select_s;
    end if;
    miso_board_select_mux_ss_n_s <= (others => '1');      -- Default value
    for i in 0 to ((SPI_BOARD_SEL_ADDR_BITS**2)-1) loop
--        if ((to_integer(unsigned(board_select_s))) = i) and board_select_valid_delayed_s(board_select_valid_delayed_s'LEFT) = '1' then 
        if ((to_integer(unsigned(prev_board_select_s))) = i) and ss_n = '0' then 
            miso_board_select_mux_ss_n_s(i) <= ss_n;         -- Mux main ss_n through to slave as per received board select bits from 'spi_board_select_slave'
            miso <= miso_s(i);
        end if;
    end loop;
    ss_n_v := ss_n;
end process;


----Example of one spi_slace register map connected to board select address 0
reg_map_selected_inst : generic_spi_reg_map_top
    generic map(
            make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing, -- : boolean := FALSE;                                        -- This is for testbenching only
            SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                                                 -- : integer := 4;
            SPI_DATA_BITS => SPI_DATA_BITS                                                        -- : integer := 16
            )
    Port map(  
            clk => clk,                                                                           -- : std_logic;
            reset => reset,                                                                       -- : std_logic;
            --Slave SPI interface pins
            sclk => sclk,                                                                         -- : in STD_LOGIC;
            ss_n => board_select_mux_ss_n_s(board_select_addr_0_c),                               -- : in STD_LOGIC;
            i_raw_ssn => miso_board_select_mux_ss_n_s(board_select_addr_0_c),                     -- : in  std_logic;                                           -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
            mosi => mosi,                                                                         -- : in STD_LOGIC;
            miso => miso_s(board_select_addr_0_c),                                                -- : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins => reg_map_array_from_pins,                                   -- : in gdrb_ctrl_mem_array_t := (others => (others => '0'));
            reg_map_array_to_pins => reg_map_array_to_pins                                        -- : out gdrb_ctrl_mem_array_t
            );

--    set_all_data(spi_array_to_pins_s, spi_array_from_pins_s);

--.--Example of all 16 spi_slace register maps connected to board select addresses 0 thru 15
--.reg_map_gen : for i in 0 to ((SPI_BOARD_SEL_ADDR_BITS**2)-1) generate
--.    reg_map_selected_inst : generic_spi_reg_map_top
--.        generic map(
--.                make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing -- :     natural := 16
--.                )
--.        Port map(  
--.                clk => clk,                                         -- : std_logic;
--.                reset => reset,                                     -- : std_logic;
--.                --Slave SPI interface pins
--.                sclk => sclk,                                       -- : in STD_LOGIC;
--.                ss_n => board_select_mux_ss_n_s(i),                                       -- : in STD_LOGIC;
--.            i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
--.                mosi => mosi,                                       -- : in STD_LOGIC;
--.                miso => miso_s(i),                                       -- : out STD_LOGIC;
--.                --Discrete signals
--.                reg_map_array_from_pins => open, -- : in gdrb_ctrl_mem_array_t := (others => (others => '0'));
--.                reg_map_array_to_pins => open      -- : out gdrb_ctrl_mem_array_t
--.                );
--.end generate;


end Behavioral;
