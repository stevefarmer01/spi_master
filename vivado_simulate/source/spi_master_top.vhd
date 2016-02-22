----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.01.2016 12:49:35
-- Design Name: 
-- Module Name: spi_master_top - Behavioral
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

entity spi_master_top is
    generic(
        DATA_SIZE      :     integer := 16;
        FIFO_REQ       :     Boolean := True
        );
    port(
        i_sys_clk  : in  std_logic;  -- system clock
        i_sys_rst  : in  std_logic;  -- system reset
        i_csn      : in  std_logic;  -- SPI Master chip select
        i_data     : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
        i_wr       : in  std_logic;  -- Active Low Write, Active High Read
        i_rd       : in  std_logic;  -- Active Low Write, Active High Read
        o_data     : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
        o_tx_ready : out std_logic;  -- Transmitter ready, can write another 
        o_rx_ready : out std_logic;  -- Receiver ready, can read data
        o_tx_error : out std_logic;  -- Transmitter error
        o_rx_error : out std_logic;  -- Receiver error
        i_slave_addr   : in  std_logic_vector(1 downto 0);  -- Slave Address
        i_cpol         : in  std_logic;  -- CPOL value - 0 or 1
        i_cpha         : in  std_logic;  -- CPHA value - 0 or 1 
        i_lsb_first    : in  std_logic;  -- lsb first when '1' /msb first when 
        i_spi_start    : in  std_logic;  -- START SPI Master Transactions
        i_clk_period   : in  std_logic_vector(7 downto 0);  -- SCL clock period in terms of i_sys_clk
        i_setup_cycles : in  std_logic_vector(7 downto 0);  -- SPIM setup time  in terms of i_sys_clk
        i_hold_cycles  : in  std_logic_vector(7 downto 0);  -- SPIM hold time  in terms of i_sys_clk
        i_tx2tx_cycles : in  std_logic_vector(7 downto 0);  -- SPIM interval between data transactions in terms of i_sys_clk
        o_slave_csn    : out std_logic_vector(3 downto 0);  -- SPI Slave select (chip select) active low
        o_mosi         : out std_logic;  -- Master output to Slave
        i_miso         : in  std_logic;  -- Master input from Slave
        o_sclk         : out std_logic  -- Master clock
        );
end spi_master_top;

architecture Behavioral of spi_master_top is

component spi_master
    generic(
        DATA_SIZE      :     integer := 16;
        FIFO_REQ       :     Boolean := True
        );
    port(
        i_sys_clk      : in  std_logic;  -- system clock
        i_sys_rst      : in  std_logic;  -- system reset
        i_csn          : in  std_logic;  -- chip select for SPI master
        i_data         : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
        i_wr           : in  std_logic;  -- Active Low Write, Active High Read
        i_rd           : in  std_logic;  -- Active Low Write, Active High Read
        o_data         : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
        o_tx_ready     : out std_logic;  -- Transmitter ready, can write another 
        o_rx_ready     : out std_logic;  -- Receiver ready, can read data
        o_tx_error     : out std_logic;  -- Transmitter error
        o_rx_error     : out std_logic;  -- Receiver error
        o_intr         : out std_logic;
        i_slave_addr   : in  std_logic_vector(1 downto 0);  -- Slave Address
        i_cpol         : in  std_logic;  -- CPOL value - 0 or 1
        i_cpha         : in  std_logic;  -- CPHA value - 0 or 1 
        i_lsb_first    : in  std_logic;  -- lsb first when '1' /msb first when 
        i_spi_start    : in  std_logic;  -- START SPI Master Transactions
        i_clk_period   : in  std_logic_vector(7 downto 0);  -- SCL clock period in terms of i_sys_clk
        i_setup_cycles : in  std_logic_vector(7 downto 0);  -- SPIM setup time  in terms of i_sys_clk
        i_hold_cycles  : in  std_logic_vector(7 downto 0);  -- SPIM hold time  in terms of i_sys_clk
        i_tx2tx_cycles : in  std_logic_vector(7 downto 0);  -- SPIM interval between data transactions in terms of i_sys_clk
        o_slave_csn    : out std_logic_vector(3 downto 0);  -- SPI Slave select (chip select) active low
        o_mosi         : out std_logic;  -- Master output to Slave
        i_miso         : in  std_logic;  -- Master input from Slave
        o_sclk         : out std_logic;  -- Master clock
        mosi_tri_en    : out std_logic
        );
end component;

signal io_miso_s : std_logic := 'Z';
signal o_mosi_s, mosi_tri_en_s : std_logic := '0';

begin

spi_master_inst : spi_master
    generic map(
        DATA_SIZE => DATA_SIZE,           -- :     integer := 16;
        FIFO_REQ => FIFO_REQ              -- :     Boolean := True
        )
    port map(
        i_sys_clk => i_sys_clk,           -- : in  std_logic;                                    -- system clock
        i_sys_rst => i_sys_rst,           -- : in  std_logic;                                    -- system reset
        i_csn => i_csn,                   -- : in  std_logic;                                    -- chip select for SPI master
        i_data => i_data,                 -- : in  std_logic_vector(15 downto 0);                -- Input data
        i_wr => i_wr,                     -- : in  std_logic;                                    -- Active Low Write, Active High Read
        i_rd => i_rd,                     -- : in  std_logic;                                    -- Active Low Write, Active High Read
        o_data => o_data,                 -- : out std_logic_vector(15 downto 0);  --output data
        o_tx_ready => o_tx_ready,         -- : out std_logic;                                    -- Transmitter ready, can write another
        o_rx_ready => o_rx_ready,         -- : out std_logic;                                    -- Receiver ready, can read data
        o_tx_error => o_tx_error,         -- : out std_logic;                                    -- Transmitter error
        o_rx_error => o_rx_error,         -- : out std_logic;                                    -- Receiver error
        o_intr => open,                   -- : out std_logic;
        i_slave_addr => i_slave_addr,     -- : in  std_logic_vector(1 downto 0);                 -- Slave Address
        i_cpol => i_cpol,                 -- : in  std_logic;                                    -- CPOL value - 0 or 1
        i_cpha => i_cpha,                 -- : in  std_logic;                                    -- CPHA value - 0 or 1
        i_lsb_first => i_lsb_first,       -- : in  std_logic;                                    -- lsb first when '1' /msb first when
        i_spi_start => i_spi_start,       -- : in  std_logic;                                    -- START SPI Master Transactions
        i_clk_period => i_clk_period,     -- : in  std_logic_vector(7 downto 0);                 -- SCL clock period in terms of i_sys_clk
        i_setup_cycles => i_setup_cycles, -- : in  std_logic_vector(7 downto 0);                 -- SPIM setup time  in terms of i_sys_clk
        i_hold_cycles => i_hold_cycles,   -- : in  std_logic_vector(7 downto 0);                 -- SPIM hold time  in terms of i_sys_clk
        i_tx2tx_cycles => i_tx2tx_cycles, -- : in  std_logic_vector(7 downto 0);                 -- SPIM interval between data transactions in terms of i_sys_clk
        o_slave_csn => o_slave_csn,       -- : out std_logic_vector(3 downto 0);                 -- SPI Slave select (chip select) active low
        o_mosi => o_mosi_s,                 -- : out std_logic;                                    -- Master output to Slave
        i_miso => i_miso,                 -- : in  std_logic;                                    -- Master input from Slave
        o_sclk => o_sclk,                 -- : out std_logic;                                    -- Master clock
        mosi_tri_en => mosi_tri_en_s        -- : out std_logic
        );

    io_miso_s <= o_mosi_s when mosi_tri_en_s = '0' else 'Z';

    o_mosi <= io_miso_s;

 end Behavioral;
