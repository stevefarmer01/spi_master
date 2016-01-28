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
            discrete_reg_map_array_from_pins : in gdrb_ctrl_address_type := (others => (others => '0'));
            discrete_reg_map_array_to_pins : out gdrb_ctrl_address_type
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
--signal gdrb_ctrl_data_array_s : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise;
signal gdrb_ctrl_data_array_s : gdrb_ctrl_address_type := (others => (others => '0'));

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

--Limit read writes as per those declared in gdrb_ctrl_address_pkg.vhd
reg_map_gen : if not make_all_addresses_writeable_for_testing generate

    ---Put write data receieved from SPI into reg map array
    spi_write_to_reg_map_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset_s = '1' then
                gdrb_ctrl_data_array_s <= gdrb_ctrl_data_array_initalise;                -- reset reg map array with a function (allows pre_loading of data values which could be useful for testing and operation)
            else
                ---Set values of read only registers if they are constants.....
            
                gdrb_ctrl_data_array_s(to_integer(unsigned(SensorStatusAddr_addr_c))) <= discrete_reg_map_array_from_pins(to_integer(unsigned(SensorStatusAddr_addr_c))); -- Read only --These have no constant value as they come from discrete pins
                --gdrb_ctrl_data_array_s(to_integer(unsigned(FaultAddr_addr_c)))        <= ; -- Read only --These have no constant value as they come from discrete pins
                gdrb_ctrl_data_array_s(to_integer(unsigned(MDRB_UES1Addr_addr_c)))    <= std_logic_vector(resize(unsigned(UES_1_c),SPI_DATA_BITS)); -- Read only
                gdrb_ctrl_data_array_s(to_integer(unsigned(MDRB_UES2Addr_addr_c)))    <= std_logic_vector(resize(unsigned(UES_2_c),SPI_DATA_BITS)); -- Read only
                --gdrb_ctrl_data_array_s(to_integer(unsigned(COMMUT_UES1Addr_addr_c)))  <= ; -- Read only --These have no constant value as they come from discrete pins
                --gdrb_ctrl_data_array_s(to_integer(unsigned(COMMUT_UES2Addr_addr_c)))  <= ; -- Read only --These have no constant value as they come from discrete pins
 
                if write_enable_from_spi_s = '1' then -- Write enable from SPI
                
                    case rx_address_s is


                    when LEDControlAddr_addr_c =>
                        gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when SensorStatusAddr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    when SensorEdgeAddr_addr_c =>
                        gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    when IntMaskAddr_addr_c =>
                        gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when FaultAddr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    when MotionCont1Addr_addr_c =>
                        gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when MotionCont2Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when MotionCont3Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when ScanLEDAddr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when OViewLEDAddr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    when CPLDProgAddr_addr_c =>
                        gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- This is a write and so update reg map array with data received
    
                    --.when MDRB_UES1Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    --.when MDRB_UES2Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    --.when COMMUT_UES1Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    --.when COMMUT_UES2Addr_addr_c =>
                    --.    gdrb_ctrl_data_array_s(to_integer(unsigned(rx_address_s))) <= rx_data_s; -- Read only
    
                    when others =>
    
                    end case;
                end if;
            end if;
        end if;
    end process;

end generate reg_map_gen;



discrete_reg_map_array_to_pins <= gdrb_ctrl_data_array_s;

------------------------------------------------------This is for testbenching only------------------------------------------------------------.
--Allows testbench to simple write and read to all addresses disregarding those specified in gdrb_ctrl_address_pkg.vhd
testbenching_gen : if make_all_addresses_writeable_for_testing generate
    
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

end generate testbenching_gen;


end Behavioral;
