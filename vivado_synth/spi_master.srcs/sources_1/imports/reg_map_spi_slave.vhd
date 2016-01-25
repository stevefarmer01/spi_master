----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.01.2016 12:55:50
-- Design Name: 
-- Module Name: reg_map_spi_slave - Behavioral
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

use work.spi_package.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_map_spi_slave is
    generic(
        DATA_SIZE  :     natural := 16);
    Port (  
            clk : std_logic;
            reset : std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC);
end reg_map_spi_slave;

architecture Behavioral of reg_map_spi_slave is

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
        o_rx_ready : out std_logic;     -- Receiver ready, can read data
        o_tx_error : out std_logic;     -- Transmitter error
        o_rx_error : out std_logic;     -- Receiver error
        i_cpol      : in std_logic;     -- CPOL value - 0 or 1
        i_cpha      : in std_logic;     -- CPHA value - 0 or 1 
        i_lsb_first : in std_logic;     -- lsb first when '1' /msb first when 
        o_miso      : out std_logic;    -- Slave output to Master
        i_mosi      : in  std_logic;    -- Slave input from Master
        i_ssn       : in  std_logic;    -- Slave Slect Active low
        i_sclk      : in  std_logic;    -- Clock from SPI Master
        miso_tri_en : out std_logic;
        o_tx_ack    : out std_logic;
        o_tx_no_ack : out std_logic
        );
end component;

signal reset_domain_cross_s : std_logic_vector(1 downto 0) := (others => '0');
signal reset_s : std_logic := '0';
signal o_rx_ready_slave_s : std_logic := '0';
signal data_i_slave_tx_s, o_data_slave_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');
signal wr_i_s : std_logic_vector(1 downto 0) := "01";

    signal temp_count_s : integer range 0 to 15 := 0;
    signal o_rx_ready_slave_s1 : std_logic := '1';

---Array of data spanning entire address range declared and initialised in 'spi_package'
signal gdrb_ctrl_data_array : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise;
signal rx_address_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');
signal rx_data_s, read_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
signal rx_read_write_bit : std_logic := '0';
signal tx_data_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');

begin

sync_reset_proc : process(clk)
begin
    if rising_edge(clk) then
        reset_domain_cross_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT-1 downto 0) & reset;
        reset_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT);
    end if;
end process;

temp_count_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset_s = '1' then
            wr_i_s <= "01";
        else
        wr_i_s <= wr_i_s(wr_i_s'LEFT-1 downto 0) & '0';
        o_rx_ready_slave_s1 <= ss_n;
            if o_rx_ready_slave_s1 = '0' and ss_n = '1' then
                if temp_count_s = input_data'HIGH then
                    temp_count_s <= 0;
                else
                    temp_count_s <= temp_count_s + 1;
                end if;
                wr_i_s <= "01";
            end if;
        end if;
    end if;
end process;

data_i_slave_tx_s <= input_data(temp_count_s);

    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE)
        port map(
        i_sys_clk      => clk,       -- : in  std_logic;                                               -- system clock
        i_sys_rst      => reset_s,       -- : in  std_logic;                                               -- system reset
        i_csn          => '0',             -- : in  std_logic;                                               -- chip select for SPI master
--.        i_data         => data_i_slave_tx_s, -- : in  std_logic_vector(15 downto 0);                           -- Input data
        i_data         => tx_data_s, -- : in  std_logic_vector(15 downto 0);                           -- Input data
        i_wr           => wr_i_s(wr_i_s'LEFT),            -- : in  std_logic;                                               -- Active Low Write, Active High Read
        i_rd           => '0',            -- : in  std_logic;                                               -- Active Low Write, Active High Read
        o_data      => o_data_slave_s,       -- o_data     : out std_logic_vector(15 downto 0);  --output data
        o_tx_ready  => open,   -- o_tx_ready : out std_logic;                                    -- Transmitter ready, can write another
        o_rx_ready  => o_rx_ready_slave_s,   -- o_rx_ready : out std_logic;                                    -- Receiver ready, can read data
        o_tx_error  => open,               -- o_tx_error : out std_logic;                                    -- Transmitter error
        o_rx_error  => open,               -- o_rx_error : out std_logic;                                    -- Receiver error
        i_cpol         => '0',             -- : in  std_logic;                                               -- CPOL value - 0 or 1
        i_cpha         => '0',             -- : in  std_logic;                                               -- CPHA value - 0 or 1
        i_lsb_first    => '0',             -- : in  std_logic;                                               -- lsb first when '1' /msb first when
        i_ssn       => ss_n,               -- i_ssn  : in  std_logic;                                        -- Slave Slect Active low
        i_mosi      => mosi,             -- i_mosi : in  std_logic;                                        -- Slave input from Master
        o_miso      => miso,               -- o_miso : out std_logic;                                        -- Slave output to Master
        i_sclk      => sclk,             -- i_sclk : in  std_logic;                                        -- Clock from SPI Master
        o_tx_ack    => open,               -- o_tx_ack : out std_logic;
        o_tx_no_ack => open                -- o_tx_no_ack : out std_logic
            );

spi_rx_bits_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset_s = '1' then
            rx_address_s <= (others => '0');
            rx_data_s <= (others => '0');
            rx_read_write_bit <= '0';        
        else
            o_rx_ready_slave_s1 <= ss_n;
            if o_rx_ready_slave_s1 = '0' and ss_n = '1' then
                rx_data_s <= o_data_slave_s((SPI_DATA_BITS-1) downto 0);
                rx_address_s <= o_data_slave_s((SPI_ADDRESS_BITS-1)+SPI_DATA_BITS downto SPI_DATA_BITS);
                rx_read_write_bit <= o_data_slave_s(SPI_ADDRESS_BITS+SPI_DATA_BITS);
            end if;
        end if;
    end if;
end process;

read_data_s <= gdrb_ctrl_data_array(to_integer(unsigned(rx_address_s)));

tx_data_s(tx_data_s'LEFT downto (tx_data_s'LEFT-read_data_s'LEFT)) <= read_data_s;

end Behavioral;
