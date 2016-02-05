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

use work.gdrb_ctrl_address_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gdrb_ctrl_reg_map_top is
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
--            test_input : in std_logic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '0');
--            test_output : out std_logic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '0');
            reg_map_array_from_pins : in gdrb_ctrl_address_type := (others => (others => '0'));
            reg_map_array_to_pins : out gdrb_ctrl_address_type
            );
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
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            reg_map_array_from_pins : in gdrb_ctrl_address_type;
            reg_map_array_to_pins : out gdrb_ctrl_address_type
            );
end component;

signal reset_s : std_logic := '0';
signal reset_domain_cross_s : std_logic_vector(1 downto 0) := (others => '0');

-------Array of data spanning entire address range declared in 'spi_package'
signal spi_array_to_pins_s, spi_array_from_pins_s : gdrb_ctrl_address_type := (others => (others => '0')); -- From/to SPI interface
--signal reg_map_array_to_pins_s : gdrb_ctrl_address_type := (others => (others => '0'));  -- Intermediate signal for out port to pins
signal reg_map_array_internal_s : gdrb_ctrl_address_type := (others => (others => '0'));  -- Intermediate signal for out port to pins

begin

--Signal to output so that is can also be read
--reg_map_array_to_pins <= reg_map_array_to_pins_s;

--Domain cross asyn reset
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
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            reg_map_array_from_pins => spi_array_from_pins_s, -- : in gdrb_ctrl_address_type
            reg_map_array_to_pins => spi_array_to_pins_s -- : out gdrb_ctrl_address_type
            );


non_testbenching_gen : if not make_all_addresses_writeable_for_testing generate
--.    --Example of.....
--.    --Out pin (read/write over SPI)
--.    reg_map_array_to_pins(0) <= spi_array_to_pins_s(0);
--.    spi_array_from_pins_s(0) <= spi_array_to_pins_s(0);
--.    --Example of.....
--.    --In pin (read only over SPI)
--.    spi_array_from_pins_s(1) <= reg_map_array_from_pins(1);
--.    --Example of.....
--.    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
--.    spi_array_from_pins_s(3) <= spi_array_to_pins_s(3);
--.    --Example of.....
--.    --Internal constants (not pins - read only over SPI)
--.    spi_array_from_pins_s(to_integer(unsigned(MDRB_UES1Addr_addr_c)))    <= std_logic_vector(resize(unsigned(16#5555#),SPI_DATA_BITS)); 


--SENSOR_
    --In pin (read only over SPI)
    spi_array_from_pins_s(to_integer(unsigned(SENSOR_STATUS_ADDR_C))) <= reg_map_array_from_pins(to_integer(unsigned(SENSOR_STATUS_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(SENSOR_EDGE_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(SENSOR_EDGE_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(SENSOR_INT_MASK_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)));

--FAULT_
    --In pin (read only over SPI)
    spi_array_from_pins_s(to_integer(unsigned(FAULT_STATUS_ADDR_C))) <= reg_map_array_from_pins(to_integer(unsigned(FAULT_STATUS_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(FAULT_EDGE_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(FAULT_EDGE_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(FAULT_INT_MASK_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(FAULT_INT_MASK_ADDR_C)));

--MISC_
    --In pin (read only over SPI)
    spi_array_from_pins_s(to_integer(unsigned(MISC_STATUS_ADDR_C))) <= reg_map_array_from_pins(to_integer(unsigned(MISC_STATUS_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(MISC_EDGE_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(MISC_EDGE_ADDR_C)));
    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
    spi_array_from_pins_s(to_integer(unsigned(MISC_INT_MASK_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(MISC_INT_MASK_ADDR_C)));

--ENABLES_OUT
    --Out pin (read/write over SPI)
    reg_map_array_to_pins(to_integer(unsigned(ENABLES_OUT_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(ENABLES_OUT_ADDR_C)));
    spi_array_from_pins_s(to_integer(unsigned(ENABLES_OUT_ADDR_C))) <= spi_array_to_pins_s(to_integer(unsigned(ENABLES_OUT_ADDR_C)));

--UES
    --Internal constants (not pins - read only over SPI)-----UES_1_c
    spi_array_from_pins_s(to_integer(unsigned(MDRB_UES1Addr_addr_c)))    <= std_logic_vector(resize(unsigned(UES_1_c),SPI_DATA_BITS)); 
    --Internal constants (not pins - read only over SPI)-----UES_2_c
    spi_array_from_pins_s(to_integer(unsigned(MDRB_UES2Addr_addr_c)))    <= std_logic_vector(resize(unsigned(UES_2_c),SPI_DATA_BITS));

end generate non_testbenching_gen;


testbenching_gen : if make_all_addresses_writeable_for_testing generate
    spi_array_from_pins_s <= spi_array_to_pins_s;
end generate testbenching_gen;

end Behavioral;
