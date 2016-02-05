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
--.    generic(
--.        DATA_SIZE  :     natural := 16);
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            reg_map_array_from_pins : in gdrb_ctrl_address_type;
            reg_map_array_to_pins : out gdrb_ctrl_address_type;
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi : out std_logic := '0';
            write_addr_from_spi : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
            );

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

signal o_rx_ready_slave_s : std_logic := '0';
signal o_rx_ready_slave_r0 : std_logic := '0';
signal o_rx_ready_rising_edge_s : std_logic := '0';
signal o_data_slave_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');

signal tx_data_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');

signal rx_valid_s : std_logic := '0';
signal rx_read_write_bit_s : std_logic := '0';
signal rx_address_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');
signal rx_data_s, read_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

-----Array of data spanning entire address range declared and initialised in 'spi_package'
--signal gdrb_ctrl_data_array : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise;

signal wr_en_to_spi_slave_s : std_logic := '0';

signal write_enable_from_spi_s : std_logic := '0';

begin

    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE)
        port map(
        i_sys_clk   => clk,                  -- : in  std_logic;                                -- system clock
        i_sys_rst   => reset,              -- : in  std_logic;                                -- system reset
        i_csn       => '0',                  -- : in  std_logic;                                -- chip select for SPI master
        i_data      => tx_data_s,            -- : in  std_logic_vector(15 downto 0);            -- Input data
        i_wr        => wr_en_to_spi_slave_s, -- : in  std_logic;                                -- Active Low Write, Active High Read
        i_rd        => '0',                  -- : in  std_logic;                                -- Active Low Write, Active High Read
        o_data      => o_data_slave_s,       -- o_data     : out std_logic_vector(15 downto 0); -- output data
        o_tx_ready  => open,                 -- o_tx_ready : out std_logic;                     -- Transmitter ready, can write another
        o_rx_ready  => o_rx_ready_slave_s,   -- o_rx_ready : out std_logic;                     -- Receiver ready, can read data
        o_tx_error  => open,                 -- o_tx_error : out std_logic;                     -- Transmitter error
        o_rx_error  => open,                 -- o_rx_error : out std_logic;                     -- Receiver error
        i_cpol      => '0',                  -- : in  std_logic;                                -- CPOL value - 0 or 1
        i_cpha      => '0',                  -- : in  std_logic;                                -- CPHA value - 0 or 1
        i_lsb_first => '0',                  -- : in  std_logic;                                -- lsb first when '1' /msb first when
        i_ssn       => ss_n,                 -- i_ssn  : in  std_logic;                         -- Slave Slect Active low
        i_mosi      => mosi,                 -- i_mosi : in  std_logic;                         -- Slave input from Master
        o_miso      => miso,                 -- o_miso : out std_logic;                         -- Slave output to Master
        i_sclk      => sclk,                 -- i_sclk : in  std_logic;                         -- Clock from SPI Master
        o_tx_ack    => open,                 -- o_tx_ack : out std_logic;
        o_tx_no_ack => open                  -- o_tx_no_ack : out std_logic
            );

o_rx_ready_rising_edge_s <= '1' when o_rx_ready_slave_r0 = '0' and o_rx_ready_slave_s = '1' else '0';

spi_rx_bits_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            rx_read_write_bit_s <= '0';        
            rx_address_s <= (others => '0');
            rx_data_s <= (others => '0');
        else
            rx_valid_S <= '0';
            o_rx_ready_slave_r0 <= o_rx_ready_slave_s;
            if o_rx_ready_rising_edge_s = '1' and ss_n = '0' then
--            if o_rx_ready_rising_edge_s = '1' then
                rx_valid_s <= '1';
                rx_read_write_bit_s <= o_data_slave_s(SPI_ADDRESS_BITS+SPI_DATA_BITS);                     -- Tead/Write bit is the MSb
                rx_address_s <= o_data_slave_s((SPI_ADDRESS_BITS-1)+SPI_DATA_BITS downto SPI_DATA_BITS); -- Address bits are the next MSb's after data
                rx_data_s <= o_data_slave_s((SPI_DATA_BITS-1) downto 0);                                 -- Data bits are LSb's
            end if;
        end if;
    end if;
end process;

---Extract read data from reg map array and send it back across SPI to master
read_data_s <= reg_map_array_from_pins(to_integer(unsigned(rx_address_s)));           -- Use address received  to extract read data from reg map array to send back on next tx
tx_data_s(tx_data_s'LEFT downto (tx_data_s'LEFT-read_data_s'LEFT)) <= read_data_s; -- Read data goes into MSb's of data sent back (no address or Read/Write bit sent back as per protocol)

-----When valid data recieved load read data from reg map into spi interface to be sent back during next spi transaction (spi reads are always sent back during next spi transaction as per standard spi protocol)
--spi_read_from_reg_map_proc : process(clk)
--begin
--    if rising_edge(clk) then
--        if reset = '1' then
--            wr_en_to_spi_slave_s <= '0';
--        else
--            wr_en_to_spi_slave_s <= '0';
--            if rx_valid_s = '1' then
--                wr_en_to_spi_slave_s <= '1';                                           -- Enable to latch send read or write data back across SPI by slave
--            end if;
--        end if;
--    end if;
--end process;

---When valid data recieved load read data from reg map into spi interface to be sent back during next spi transaction (spi reads are always sent back during next spi transaction as per standard spi protocol)
spi_read_from_reg_map_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            wr_en_to_spi_slave_s <= '0';
        else
            --wr_en_to_spi_slave_s <= '0';
            if rx_valid_s = '1' then
                wr_en_to_spi_slave_s <= '1';                 -- Enable to latch send read or write data back across SPI by slave as soon as valid data has been recieved across SPI from master
            elsif ss_n = '1' then
                wr_en_to_spi_slave_s <= '0';                 -- Send data to transmit back across SPI by slave as soon as master makes ss_n goes high as this is the first definate moment that the slave will accept a write enable in
            end if;
        end if;
    end if;
end process;

write_enable_from_spi_s <= '1' when (rx_valid_s = '1' and rx_read_write_bit_s = '0') else '0';


---Put write data receieved from SPI into reg map array
spi_write_to_reg_map_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            write_enable_from_spi <= '0';
            write_addr_from_spi <= (others => '0');
            reg_map_array_to_pins <= gdrb_ctrl_data_array_initalise;                -- reset reg map array with a function (allows pre_loading of data values which could be useful for testing and operation)
        else
            write_enable_from_spi <= '0';
            if write_enable_from_spi_s = '1' then
                write_enable_from_spi <= '1';
                write_addr_from_spi <= rx_address_s;
                reg_map_array_to_pins(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
            end if;
        end if;
    end if;
end process;




end Behavioral;
