----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2016 08:56:18
-- Design Name: 
-- Module Name: gdrb_ctrl_reg_map_top - Behavioral
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

entity gdrb_ctrl_reg_map_top is
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC);
end gdrb_ctrl_reg_map_top;

architecture Behavioral of gdrb_ctrl_reg_map_top is

component reg_map_spi_slave is
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --register map interface
            rx_valid : out std_logic; -- High pulse when spi receives packet
            rx_read_write_bit : out std_logic;
            rx_address : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0);
            rx_data : out std_logic_vector(SPI_DATA_BITS-1 downto 0);
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            gdrb_ctrl_data_array : in gdrb_ctrl_address_type
            );
end component;

signal reset_s : std_logic := '0';
signal reset_domain_cross_s : std_logic_vector(1 downto 0) := (others => '0');

signal rx_valid_s : std_logic := '0';
signal rx_read_write_bit_s : std_logic := '0';
signal rx_address_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');
signal rx_data_s, read_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

signal write_enable_from_spi_s : std_logic := '0';

-----Array of data spanning entire address range declared and initialised in 'spi_package'
signal gdrb_ctrl_data_array_s : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise;

begin

sync_reset_proc : process(clk)
begin
    if rising_edge(clk) then
        reset_domain_cross_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT-1 downto 0) & reset;
        reset_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT);
    end if;
end process;

reg_map_spi_slave_inst : reg_map_spi_slave
    Port map(  
            clk => clk,                                    -- : in std_logic;
            reset => reset_s,                              -- : in std_logic;
            ---Slave SPI interface pins
            sclk => sclk,                                  -- : in STD_LOGIC;
            ss_n => ss_n,                                  -- : in STD_LOGIC;
            mosi => mosi,                                  -- : in STD_LOGIC;
            miso => miso,                                  -- : out STD_LOGIC;
            --register map interface
            rx_valid => rx_valid_s,                        -- : out std_logic;
            rx_read_write_bit => rx_read_write_bit_s,      -- : out std_logic;
            rx_address => rx_address_s,                    -- : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0);
            rx_data => rx_data_s,                          -- : out std_logic_vector(SPI_DATA_BITS-1 downto 0);
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            gdrb_ctrl_data_array => gdrb_ctrl_data_array_s -- : in gdrb_ctrl_address_type
            );

write_enable_from_spi_s <= '1' when (rx_valid_s = '1' and rx_read_write_bit_s = '0') else '0';

---Put write data receieved from SPI into reg map array
spi_write_to_reg_map_proc : process(clk)
begin
    if rising_edge(clk) then
        if reset_s = '1' then
            gdrb_ctrl_data_array_s <= gdrb_ctrl_data_array_initalise;                -- reset reg map array with a function (allows pre_loading of data values which could be useful for testing and operation)
        else
        	if write_enable_from_spi_s = '1' then
                gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
			end if;
        end if;
    end if;
end process;


end Behavioral;
