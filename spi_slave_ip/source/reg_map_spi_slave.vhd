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

--use work.gdrb_ctrl_bb_pkg.ALL;

use work.multi_array_types_pkg.all;     -- Multi-dimension array functions and proceedures

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_map_spi_slave is
    generic(
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t;
            make_rx_data_happen_at_ss_n_high_edge : boolean := FALSE     -- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
        );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol      : in std_logic := '0';                                -- CPOL value - 0 or 1
            cpha      : in std_logic := '0';                                -- CPHA value - 0 or 1
            lsb_first : in std_logic := '0';                                -- lsb first when '1' /msb first when
            ---Array of data spanning entire address range declared'
            reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi : out std_logic := '0';
            write_addr_from_spi : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
            );

end reg_map_spi_slave;

architecture Behavioral of reg_map_spi_slave is

component spi_slave is
    generic(
            DATA_SIZE  :     natural := 16;
            make_rx_data_happen_at_ss_n_high_edge : boolean := FALSE     -- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
            );
    port (
        i_sys_clk  : in  std_logic;                                -- system clock
        i_sys_rst  : in  std_logic;                                -- system reset
        i_csn      : in  std_logic;                                -- Slave Enable/select
        i_data     : in  std_logic_vector(DATA_SIZE - 1 downto 0); -- Input data
        i_wr       : in  std_logic;                                -- Active Low Write, Active High Read
        i_rd       : in  std_logic;                                -- Active Low Write, Active High Read
        o_data     : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
        o_tx_ready : out std_logic;                                -- Transmitter ready, can write another
        o_rx_ready : out std_logic;                                -- Receiver ready, can read data
        o_tx_error : out std_logic;                                -- Transmitter error
        o_rx_error : out std_logic;                                -- Receiver error
        i_cpol      : in std_logic;                                -- CPOL value - 0 or 1
        i_cpha      : in std_logic;                                -- CPHA value - 0 or 1
        i_lsb_first : in std_logic;                                -- lsb first when '1' /msb first when
        o_miso      : out std_logic;                               -- Slave output to Master
        i_mosi      : in  std_logic;                               -- Slave input from Master
        i_ssn       : in  std_logic;                               -- Slave Slect Active low
        i_raw_ssn   : in  std_logic;                               -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
        i_sclk      : in  std_logic;                               -- Clock from SPI Master
        miso_tri_en : out std_logic;
        o_tx_ack    : out std_logic;
        o_tx_no_ack : out std_logic
        );
end component;

constant DATA_SIZE_C : integer := SPI_ADDRESS_BITS+SPI_DATA_BITS+1;                          -- Total data size = read/write bit + address + data
constant DATA_SIZE : integer := DATA_SIZE_C;

--signal reg_map_array_to_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0')); -- This may be safer (due to syth support although tested in Diamond 3.5 and vivado 2014.1)) but not as nice
--signal reg_map_array_to_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := mem_array_t_initalised; -- This may be safer (due to syth support although tested in Diamond 3.5 and vivado 2014.1)) but not as nice
signal reg_map_array_to_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := MEM_ARRAY_T_INITIALISATION; -- This may be safer (due to syth support although tested in Diamond 3.5 and vivado 2014.1)) but not as nice

signal o_rx_ready_slave_s : std_logic := '0';
signal o_rx_ready_slave_r0 : std_logic := '0';
signal o_rx_ready_rising_edge_s : std_logic := '0';
signal o_data_slave_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');

signal tx_data_s : std_logic_vector(DATA_SIZE-1 downto 0) := (others  => '0');

signal rx_valid_s : std_logic := '0';
signal rx_read_write_bit_s : std_logic := '0';
signal rx_address_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');
signal rx_data_s, read_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

signal wr_en_to_spi_slave_s : std_logic := '0';

signal write_enable_from_spi_s : std_logic := '0';

signal low_s : std_logic := '0';
signal high_s : std_logic := '1';

begin

    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE,
            make_rx_data_happen_at_ss_n_high_edge => make_rx_data_happen_at_ss_n_high_edge
            )
        port map(
            i_sys_clk   => clk,                  -- : in  std_logic;                   -- system clock
            i_sys_rst   => reset,                -- : in  std_logic;                   -- system reset
            i_csn       => low_s,                -- : in  std_logic;                   -- chip select for SPI master
            i_data      => tx_data_s,            -- : in  std_logic_vector;            -- Input data
            i_wr        => wr_en_to_spi_slave_s, -- : in  std_logic;                   -- Active Low Write, Active High Read
            i_rd        => low_s,                -- : in  std_logic;                   -- Active Low Write, Active High Read
            o_data      => o_data_slave_s,       -- o_data     : out std_logic_vector; -- output data
            o_tx_ready  => open,                 -- o_tx_ready : out std_logic;        -- Transmitter ready, can write another
            o_rx_ready  => o_rx_ready_slave_s,   -- o_rx_ready : out std_logic;        -- Receiver ready, can read data
            o_tx_error  => open,                 -- o_tx_error : out std_logic;        -- Transmitter error
            o_rx_error  => open,                 -- o_rx_error : out std_logic;        -- Receiver error
            i_cpol      => cpol,                 -- : in  std_logic;                   -- CPOL value - 0 or 1
            i_cpha      => cpha,                 -- : in  std_logic;                   -- CPHA value - 0 or 1
            i_lsb_first => lsb_first,            -- : in  std_logic;                   -- lsb first when '1' /msb first when
            i_ssn       => ss_n,                 -- i_ssn  : in  std_logic;            -- Slave Slect Active low
            i_raw_ssn   => i_raw_ssn,            -- : in  std_logic;                   -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            i_mosi      => mosi,                 -- i_mosi : in  std_logic;            -- Slave input from Master
            o_miso      => miso,                 -- o_miso : out std_logic;            -- Slave output to Master
            i_sclk      => sclk,                 -- i_sclk : in  std_logic;            -- Clock from SPI Master
            o_tx_ack    => open,                 -- o_tx_ack : out std_logic;
            o_tx_no_ack => open                  -- o_tx_no_ack : out std_logic
            );

o_rx_ready_rising_edge_s <= '1' when o_rx_ready_slave_r0 = '0' and o_rx_ready_slave_s = '1' else '0';

-- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
gen_ss_n_high : if make_rx_data_happen_at_ss_n_high_edge generate
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
                if o_rx_ready_rising_edge_s = '1' then
                    rx_valid_s <= '1';
                    rx_read_write_bit_s <= o_data_slave_s(SPI_ADDRESS_BITS+SPI_DATA_BITS);                     -- Tead/Write bit is the MSb
                    rx_address_s <= o_data_slave_s((SPI_ADDRESS_BITS-1)+SPI_DATA_BITS downto SPI_DATA_BITS); -- Address bits are the next MSb's after data
                    rx_data_s <= o_data_slave_s((SPI_DATA_BITS-1) downto 0);                                 -- Data bits are LSb's
                end if;
            end if;
        end if;
    end process;
end generate gen_ss_n_high;

-- When set to FALSE SPI rx data will be valid when all required bits have been recieved
gen_not_ss_n_high : if not make_rx_data_happen_at_ss_n_high_edge generate
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
                    rx_valid_s <= '1';
                    rx_read_write_bit_s <= o_data_slave_s(SPI_ADDRESS_BITS+SPI_DATA_BITS);                     -- Tead/Write bit is the MSb
                    rx_address_s <= o_data_slave_s((SPI_ADDRESS_BITS-1)+SPI_DATA_BITS downto SPI_DATA_BITS); -- Address bits are the next MSb's after data
                    rx_data_s <= o_data_slave_s((SPI_DATA_BITS-1) downto 0);                                 -- Data bits are LSb's
                end if;
            end if;
        end if;
    end process;
end generate gen_not_ss_n_high;

---Extract read data from reg map array and send it back across SPI to master
read_data_s <= get_data(reg_map_array_from_pins, to_integer(unsigned(rx_address_s)));           -- Use address received  to extract read data from reg map array to send back on next tx

tx_data_s(tx_data_s'LEFT downto (tx_data_s'LEFT-read_data_s'LEFT)) <= read_data_s; -- Read data goes into MSb's of data sent back (no address or Read/Write bit sent back as per protocol)

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
        else
            write_enable_from_spi <= '0';
            if write_enable_from_spi_s = '1' then
                write_enable_from_spi <= '1';
                write_addr_from_spi <= rx_address_s;
--                reg_map_array_to_pins(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
                set_data(reg_map_array_to_pins_s, (to_integer(unsigned(rx_address_s))), rx_data_s); -- This is a write and so update reg map array with data received
            end if;
        end if;
    end if;
end process;

process(reg_map_array_to_pins_s)
begin
--    reg_map_array_to_pins <= reg_map_array_to_pins_s;
    set_all_data (reg_map_array_to_pins_s, reg_map_array_to_pins);
end process;

end Behavioral;
