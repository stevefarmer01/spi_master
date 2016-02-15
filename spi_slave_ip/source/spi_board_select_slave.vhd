----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.01.2016 12:55:50
-- Design Name: 
-- Module Name: spi_board_select_slave - Behavioral
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

--use work.gdrb_ctrl_bb_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_board_select_slave is
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
end spi_board_select_slave;

architecture Behavioral of spi_board_select_slave is

component spi_slave is
    generic(
        DATA_SIZE  :     natural := 16
        );
    port (
        i_sys_clk  : in  std_logic;                              -- system clock
        i_sys_rst  : in  std_logic;                              -- system reset
        i_csn      : in  std_logic;                              -- Slave Enable/select
        i_data     : in  std_logic_vector(DATA_SIZE-1 downto 0); -- Input data
        i_wr       : in  std_logic;                              -- Active Low Write, Active High Read
        i_rd       : in  std_logic;                              -- Active Low Write, Active High Read
        o_data     : out std_logic_vector(DATA_SIZE-1 downto 0); -- output data
        o_tx_ready : out std_logic;                              -- Transmitter ready, can write another
        o_rx_ready : out std_logic;                              -- Receiver ready, can read data
        o_tx_error : out std_logic;                              -- Transmitter error
        o_rx_error : out std_logic;                              -- Receiver error
        i_cpol      : in std_logic;                              -- CPOL value - 0 or 1
        i_cpha      : in std_logic;                              -- CPHA value - 0 or 1
        i_lsb_first : in std_logic;                              -- lsb first when '1' /msb first when
        o_miso      : out std_logic;                             -- Slave output to Master
        i_mosi      : in  std_logic;                             -- Slave input from Master
        i_ssn       : in  std_logic;                             -- Slave Slect Active low
        i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
        i_sclk      : in  std_logic;                             -- Clock from SPI Master
        miso_tri_en : out std_logic;
        o_tx_ack    : out std_logic;
        o_tx_no_ack : out std_logic
        );
end component;

signal o_rx_ready_slave_s : std_logic := '0';
signal o_rx_ready_slave_r0 : std_logic := '0';
signal o_rx_ready_rising_edge_s : std_logic := '0';
signal o_data_slave_s : std_logic_vector(BOARD_SELECT_ADDRESS_SIZE-1 downto 0) := (others  => '0');
signal board_select_valid_s : std_logic := '0';

signal low_s : std_logic := '0';                                                                 -- Needed because Modelsim will not handle '0' in component's instantation ports
signal low_vector_s : std_logic_vector(BOARD_SELECT_ADDRESS_SIZE-1 downto 0) := (others => '0'); -- Needed because Modelsim will not handle '0' in component's instantation ports

begin

    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => BOARD_SELECT_ADDRESS_SIZE
            )
        port map(
            i_sys_clk   => clk,                -- : in  std_logic;                                -- system clock
            i_sys_rst   => reset,              -- : in  std_logic;                                -- system reset
            i_csn       => low_s,              -- : in  std_logic;                                -- chip select for SPI master
            i_data      => low_vector_s,       -- : in  std_logic_vector(15 downto 0);            -- Input data
            i_wr        => low_s,              -- : in  std_logic;                                -- Active Low Write, Active High Read
            i_rd        => low_s,              -- : in  std_logic;                                -- Active Low Write, Active High Read
            o_data      => o_data_slave_s,     -- o_data     : out std_logic_vector(15 downto 0); -- output data
            o_tx_ready  => open,               -- o_tx_ready : out std_logic;                     -- Transmitter ready, can write another
            o_rx_ready  => o_rx_ready_slave_s, -- o_rx_ready : out std_logic;                     -- Receiver ready, can read data
            o_tx_error  => open,               -- o_tx_error : out std_logic;                     -- Transmitter error
            o_rx_error  => open,               -- o_rx_error : out std_logic;                     -- Receiver error
            i_cpol      => low_s,              -- : in  std_logic;                                -- CPOL value - 0 or 1
            i_cpha      => low_s,              -- : in  std_logic;                                -- CPHA value - 0 or 1
            i_lsb_first => low_s,              -- : in  std_logic;                                -- lsb first when '1' /msb first when
            i_ssn       => ss_n,               -- i_ssn  : in  std_logic;                         -- Slave Slect Active low
            i_raw_ssn   => ss_n,               -- : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
            i_mosi      => mosi,               -- i_mosi : in  std_logic;                         -- Slave input from Master
            o_miso      => open,               -- o_miso : out std_logic;                         -- Slave output to Master
            i_sclk      => sclk,               -- i_sclk : in  std_logic;                         -- Clock from SPI Master
            o_tx_ack    => open,               -- o_tx_ack : out std_logic;
            o_tx_no_ack => open                -- o_tx_no_ack : out std_logic
            );

o_rx_ready_rising_edge_s <= '1' when o_rx_ready_slave_r0 = '0' and o_rx_ready_slave_s = '1' else '0';

spi_rx_bits_proc : process(clk)
begin
    if rising_edge(clk) then
        o_rx_ready_slave_r0 <= o_rx_ready_slave_s;
        if ss_n = '1' then
            board_select_valid_s <= '0';
        elsif board_select_valid_s = '0' and o_rx_ready_rising_edge_s = '1' and ss_n = '0' then  -- If the first BOARD_SELECT_ADDRESS_SIZE number of bits has been recieved then..
            board_select_valid_s <= '1';                                                         -- ..this is the board select data
            board_select <= o_data_slave_s;
        end if;
    end if;
end process;

board_select_valid <= board_select_valid_s;

end Behavioral;
