----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2016 08:56:18
-- Design Name: 
-- Module Name: generic_spi_reg_map_top - Behavioral
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

use work.multi_array_types_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gdrb_dp_mux_reg_map_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This makes register map all read/write registers but none connected to FPGA pins
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
           );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            i_raw_ssn : in  std_logic;                                   -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol      : in std_logic := '0';                             -- CPOL value - 0 or 1
            cpha      : in std_logic := '0';                             -- CPHA value - 0 or 1
            lsb_first : in std_logic := '0';                             -- lsb first when '1' /msb first when
            --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
            reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
            );
end gdrb_dp_mux_reg_map_top;

architecture Behavioral of gdrb_dp_mux_reg_map_top is

component reg_map_spi_slave is
    generic(
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
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
            --Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
            reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi : out std_logic;
            write_addr_from_spi : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)
            );
end component;

component generic_reg_map is
--.    generic ( 
--.            SPI_ADDRESS_BITS : integer := 4;
--.            SPI_DATA_BITS : integer := 16;
--.            MEM_ARRAY_T_INITIALISATION : mem_array_t
--.           );
  Port (
          clk : in std_logic;
          --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
          --To/from pins of FPGA
          reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          ---Array of data spanning entire address range declared and initialised in 'spi_package'
          spi_array_from_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          spi_array_to_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
          );
end component;

--reg_map_inst : generic_reg_map is
----.    generic ( 
----.            SPI_ADDRESS_BITS : integer := 4;
----.            SPI_DATA_BITS : integer := 16;
----.            MEM_ARRAY_T_INITIALISATION : mem_array_t
----.           );
--  Port (
--          clk : in std_logic;
--          --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
--          --To/from pins of FPGA
--          reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
--          reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
--          ---Array of data spanning entire address range declared and initialised in 'spi_package'
--          spi_array_from_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
--          spi_array_to_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
--          );
--end component;

--Application specific component for mapping/processing SPI array and FPGA pins array together with application address map
component gdrb_dp_mux_reg_map
    generic ( 
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
           );
  Port (
          clk : in std_logic;
          --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
          reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          --Non-register map read/control bits
          --interupt_flag : out std_logic := '0';
          ---Array of data spanning entire address range declared and initialised in 'spi_package'
          spi_array_from_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          spi_array_to_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
          write_enable_from_spi : in std_logic := '0';
          write_addr_from_spi : in std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
          );
end component;

signal reset_s : std_logic := '0';
signal reset_domain_cross_s : std_logic_vector(1 downto 0) := (others => '0');
-------Array of data spanning entire address range
signal spi_array_to_pins_s, spi_array_from_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0); -- From/to SPI interface this is initialied in common IP file 'reg_map_spi_slave' by 'MEM_ARRAY_T_INITIALISATION'

signal write_enable_from_spi_s : std_logic := '0';
signal write_addr_from_spi_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');

constant mem_array_t_init_all_zeros_c : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));

begin

--Domain cross asyn reset
sync_reset_proc : process(clk)
begin
    if rising_edge(clk) then
        reset_domain_cross_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT-1 downto 0) & reset;
        reset_s <= reset_domain_cross_s(reset_domain_cross_s'LEFT);
    end if;
end process;

reg_map_spi_slave_inst : reg_map_spi_slave
    generic map(
            SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                    -- : integer := 4;
            SPI_DATA_BITS => SPI_DATA_BITS,                          -- : integer := 16
            MEM_ARRAY_T_INITIALISATION => MEM_ARRAY_T_INITIALISATION -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
--or        MEM_ARRAY_T_INITIALISATION => mem_array_t_init_all_zeros_c -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
            )
    Port map(  
            clk => clk,                                              -- : in std_logic;
            reset => reset_s,                                        -- : in std_logic;
            ---Slave SPI interface pins
            sclk => sclk,                                            -- : in STD_LOGIC;
            ss_n => ss_n,                                            -- : in STD_LOGIC;
            i_raw_ssn => i_raw_ssn,                                  -- : in  std_logic;                                                            -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi => mosi,                                            -- : in STD_LOGIC;
            miso => miso,                                            -- : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol => cpol,                                            -- : in std_logic := '0';                                                      -- CPOL value - 0 or 1
            cpha => cpha,                                            -- : in std_logic := '0';                                                      -- CPHA value - 0 or 1
            lsb_first => lsb_first,                                  -- : in std_logic := '0';                                                      -- lsb first when '1' /msb first when
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            reg_map_array_from_pins => spi_array_from_pins_s,        -- : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
            reg_map_array_to_pins => spi_array_to_pins_s,            -- : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi => write_enable_from_spi_s,        -- : out std_logic := '0';
            write_addr_from_spi => write_addr_from_spi_s             -- : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
            );


----Map array from/to SPI interface to itself to make read/write internal register map registers or to/from pins to create in/out discretes..
----..Map these to the actual pins required at the next level up where this components is instantiated
non_testbenching_gen : if not make_all_addresses_writeable_for_testing generate

  ----EXAMPLE OF - Application specific component for mapping/processing SPI array and FPGA pins array together with application address map
    application_inst : gdrb_dp_mux_reg_map
      generic map(
              SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                       -- : integer := 4;
              SPI_DATA_BITS => SPI_DATA_BITS,                             -- : integer := 16
              MEM_ARRAY_T_INITIALISATION => MEM_ARRAY_T_INITIALISATION    -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
              )
      Port map(
              clk => clk,                                                 -- : in std_logic;
              --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
              reg_map_array_from_pins => reg_map_array_from_pins,         -- : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
              reg_map_array_to_pins => reg_map_array_to_pins,             -- : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
              --Non-register map read/control bits
              --interupt_flag => interupt_flag,                             -- : out std_logic := '0'
              ---Array of data spanning entire address range declared and initialised in 'spi_package'
              spi_array_from_pins => spi_array_from_pins_s,               -- : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
              spi_array_to_pins => spi_array_to_pins_s,                   -- : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
              --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
              write_enable_from_spi => write_enable_from_spi_s,           -- : in std_logic := '0';
              write_addr_from_spi => write_addr_from_spi_s                -- : in std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
              );

end generate non_testbenching_gen;


--Vanilla register map (no register access to pins, not read only, no interupt/edge detection/processing)...
--...this will allow test with a decreasing sclk frequency to DUT to check what frequency the SPI link will work down to (currently about 9MHz depending on start frequency decimal places)
testbenching_gen : if make_all_addresses_writeable_for_testing generate

--    spi_array_from_pins_s <= spi_array_to_pins_s;
    set_all_data(spi_array_to_pins_s, spi_array_from_pins_s);

end generate testbenching_gen;


end Behavioral;
