----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.01.2016 17:11:58
-- Design Name: 
-- Module Name: spi_top - Behavioral
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

entity spi_top is
    generic(
        DATA_SIZE  :     natural := 16);
    Port ( 
            i_sys_clk  : in  std_logic;     -- system clock
            i_sys_rst  : in  std_logic;     -- system reset
            i_csn      : in  std_logic;     -- Slave Enable/select
            i_data     : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
            i_wr       : in  std_logic;     -- Active Low Write, Active High Read
            i_rd       : in  std_logic;     -- Active Low Write, Active High Read
            o_data     : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
            o_tx_ready : out std_logic;     -- Transmitter ready, can write another 
                        -- data
            o_rx_ready : out std_logic;     -- Receiver ready, can read data
            o_tx_error : out std_logic;     -- Transmitter error
            o_rx_error : out std_logic;     -- Receiver error
    
            i_cpol      : in std_logic;     -- CPOL value - 0 or 1
            i_cpha      : in std_logic;     -- CPHA value - 0 or 1 
            i_lsb_first : in std_logic;     -- lsb first when '1' /msb first when 
                        -- '0'
    
            io_miso      : inout std_logic;    -- Slave output to Master
            i_ssn       : in  std_logic;    -- Slave Slect Active low
            i_sclk      : in  std_logic;    -- Clock from SPI Master
            o_tx_ack    : out std_logic;
            o_tx_no_ack : out std_logic
           );
end spi_top;

architecture Behavioral of spi_top is

    component spi_slave is
        generic(
            DATA_SIZE  :     natural := 16);
        port (
            i_sys_clk  : in  std_logic;     -- system clock
            i_sys_rst  : in  std_logic;     -- system reset
            i_csn      : in  std_logic;     -- Slave Enable/select
            i_data     : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
            i_wr       : in  std_logic;     -- Active Low Write, Active High Read
            i_rd       : in  std_logic;     -- Active Low Write, Active High Read
            o_data     : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
            o_tx_ready : out std_logic;     -- Transmitter ready, can write another 
                        -- data
            o_rx_ready : out std_logic;     -- Receiver ready, can read data
            o_tx_error : out std_logic;     -- Transmitter error
            o_rx_error : out std_logic;     -- Receiver error
    
            i_cpol      : in std_logic;     -- CPOL value - 0 or 1
            i_cpha      : in std_logic;     -- CPHA value - 0 or 1 
            i_lsb_first : in std_logic;     -- lsb first when '1' /msb first when 
                        -- '0'
    
            o_miso      : out std_logic;    -- Slave output to Master
            i_mosi      : in  std_logic;    -- Slave input from Master
            i_ssn       : in  std_logic;    -- Slave Slect Active low
            i_sclk      : in  std_logic;    -- Clock from SPI Master
            miso_tri_en : out std_logic;
            o_tx_ack    : out std_logic;
            o_tx_no_ack : out std_logic
            );
    end component;

    signal miso_tri_en, o_miso, io_miso_s : std_logic := '0';

begin

    u0_spis0_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE)
        port map(
        i_sys_clk   => i_sys_clk,      -- i_sys_clk  : in  std_logic;                                    -- system clock
        i_sys_rst   => i_sys_rst,      -- i_sys_rst  : in  std_logic;                                    -- system reset
        i_csn       => i_csn,          -- i_csn      : in  std_logic;                                    -- Slave Enable/select
        i_data      => i_data,         -- i_data     : in  std_logic_vector(15 downto 0);                -- Input data
        i_wr        => i_wr,           -- i_wr       : in  std_logic;                                    -- Active Low Write, Active High Read
        i_rd        => i_rd,           -- i_rd       : in  std_logic;                                    -- Active Low Write, Active High Read
        o_data      => o_data,         -- o_data     : out std_logic_vector(15 downto 0);  --output data
        o_tx_ready  => o_tx_ready,     -- o_tx_ready : out std_logic;                                    -- Transmitter ready, can write another
        o_rx_ready  => o_rx_ready,     -- o_rx_ready : out std_logic;                                    -- Receiver ready, can read data
        o_tx_error  => o_tx_error,     -- o_tx_error : out std_logic;                                    -- Transmitter error
        o_rx_error  => o_rx_error,     -- o_rx_error : out std_logic;                                    -- Receiver error
        i_cpol      => i_cpol,         -- i_cpol      : in std_logic;                                    -- CPOL value - 0 or 1
        i_cpha      => i_cpha,         -- i_cpha      : in std_logic;                                    -- CPHA value - 0 or 1
        i_lsb_first => i_lsb_first,    -- i_lsb_first : in std_logic;                                    -- lsb first when '1' /msb first when
        i_ssn       => i_ssn,          -- i_ssn  : in  std_logic;                                        -- Slave Slect Active low
        i_mosi      => io_miso_s,         -- i_mosi : in  std_logic;                                        -- Slave input from Master
        o_miso      => o_miso,         -- o_miso : out std_logic;                                        -- Slave output to Master
        i_sclk      => i_sclk,         -- i_sclk : in  std_logic;                                        -- Clock from SPI Master
        miso_tri_en => miso_tri_en,    -- miso_tri_en : out std_logic;
        o_tx_ack    => o_tx_ack,       -- o_tx_ack : out std_logic;
        o_tx_no_ack => o_tx_no_ack     -- o_tx_no_ack : out std_logic
            );

    io_miso_s <= o_miso when miso_tri_en = '0' else 'Z';

    io_miso <= io_miso_s;

end Behavioral;
