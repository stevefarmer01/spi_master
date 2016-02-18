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

--use work.gdrb_ctrl_bb_address_pkg.ALL;  -- Address constants used in non_testbenching_gen if 'make_all_addresses_writeable_for_testing' set to FALSE

use work.multi_array_types_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generic_spi_reg_map_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
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
            --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
            reg_map_array_from_pins : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
            );
end generic_spi_reg_map_top;

architecture Behavioral of generic_spi_reg_map_top is

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
            --Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
            reg_map_array_from_pins : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi : out std_logic;
            write_addr_from_spi : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)
            );
end component;

component reg_map_edge_interupt is
    generic (
             reg_width : positive := 16
             );
    Port ( 
          clk : in std_logic;
          status_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          edge_detect_toggle_en : in std_logic := '0';
          edge_detect_toggle_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          edge_detect_reg : out std_logic_vector(reg_width-1 downto 0) := (others => '0');
          interupt_mask_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          interupt_flag : out std_logic := '0'
          );
end component;


signal reset_s : std_logic := '0';
signal reset_domain_cross_s : std_logic_vector(1 downto 0) := (others => '0');
-------Array of data spanning entire address range
signal spi_array_to_pins_s, spi_array_from_pins_s : mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0')); -- From/to SPI interface

signal write_enable_from_spi_s : std_logic := '0';
signal write_addr_from_spi_s : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0');

constant mem_array_t_init_all_zeros_c : mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));


--signal sensor_status_write_en_s : std_logic := '0';
--signal sensor_interupt_flag_s : std_logic := '0';
--signal sensor_status_s, sensor_edge_s, sensor_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
--signal fault_status_s, fault_edge_s, fault_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
--signal misc_status_s, misc_edge_s, misc_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
--
--signal fault_status_write_en_s : std_logic := '0';
--signal fault_interupt_flag_s : std_logic := '0';
--
--signal misc_status_write_en_s : std_logic := '0';
--signal misc_interupt_flag_s : std_logic := '0';
--
--signal diagnostics_interupts_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
--signal global_interupt_flag_s : std_logic := '0';
--
--signal edge_detect_sensor_to_spi_s, edge_detect_fault_to_spi_s, edge_detect_status_to_spi_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');



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
    generic map(
            SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,             -- : integer := 4;
            SPI_DATA_BITS => SPI_DATA_BITS,                   -- : integer := 16
            MEM_ARRAY_T_INITIALISATION => MEM_ARRAY_T_INITIALISATION -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
            )
    Port map(  
            clk => clk,                                       -- : in std_logic;
            reset => reset_s,                                 -- : in std_logic;
            ---Slave SPI interface pins
            sclk => sclk,                                     -- : in STD_LOGIC;
            ss_n => ss_n,                                     -- : in STD_LOGIC;
            i_raw_ssn => i_raw_ssn,                           -- : in  std_logic;                                                            -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi => mosi,                                     -- : in STD_LOGIC;
            miso => miso,                                     -- : out STD_LOGIC;
            ---Array of data spanning entire address range declared and initialised in 'spi_package'
            reg_map_array_from_pins => spi_array_from_pins_s, -- : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0)
            reg_map_array_to_pins => spi_array_to_pins_s,     -- : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
            write_enable_from_spi => write_enable_from_spi_s, -- : out std_logic := '0';
            write_addr_from_spi => write_addr_from_spi_s      -- : out std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
            );


----Map array from/to SPI interface to itself to make read/write internal register map registers or to/from pins to create in/out discretes..
----..Map these to the actual pins required at the next level up where this components is instantiated
non_testbenching_gen : if not make_all_addresses_writeable_for_testing generate

------.    --Example of.....
------.    --Out pin (read/write over SPI)
------.    reg_map_array_to_pins(0) <= spi_array_to_pins_s(0);
------.    spi_array_from_pins_s(0) <= spi_array_to_pins_s(0);
------.    --Example of.....
------.    --In pin (read only over SPI)
------.    spi_array_from_pins_s(1) <= reg_map_array_from_pins(1);
------.    --Example of.....
------.    --Internal read/write register (not pins - read/write over SPI)--use a process to manipulate data back to spi if necessary
------.    spi_array_from_pins_s(3) <= spi_array_to_pins_s(3);
------.    --Example of.....
------.    --Internal constants (not pins - read only over SPI)
------.    spi_array_from_pins_s(to_integer(unsigned(MDRB_UES1Addr_addr_c)))    <= std_logic_vector(resize(unsigned(16#5555#),SPI_DATA_BITS)); 
--
--
--  --Process to write to array connected to output pins of FPGA on top level
--  process(spi_array_to_pins_s)
--  begin
--      set_data(reg_map_array_to_pins, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins_s,to_integer(unsigned(ENABLES_OUT_ADDR_C))));--Out pin (write to pins)
--  end process;
--  
--  --Process to write to array into SPI interface
--  process(spi_array_to_pins_s, reg_map_array_from_pins, edge_detect_sensor_to_spi_s, edge_detect_fault_to_spi_s, edge_detect_status_to_spi_s, diagnostics_interupts_data_s)
--  begin
--      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(SENSOR_STATUS_ADDR_C)))); -- In pin (read only over SPI from FPGA pin)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_EDGE_ADDR_C)), edge_detect_sensor_to_spi_s);                                                     -- Internal read/write register (Edge detected and so processed by component sensor_status_edge_interupt_inst)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)), get_data(spi_array_to_pins_s, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)))); -- Internal read/write register (read/write over SPI)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(FAULT_STATUS_ADDR_C))));   -- In pin (read only over SPI from FPGA pin)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_EDGE_ADDR_C)), edge_detect_fault_to_spi_s);                                                       -- Internal read/write register (Edge detected and so processed by component fault_status_edge_interupt_inst)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_INT_MASK_ADDR_C)), get_data(spi_array_to_pins_s, to_integer(unsigned(FAULT_INT_MASK_ADDR_C))));   -- Internal read/write register (read/write over SPI)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(MISC_STATUS_ADDR_C))));     -- In pin (read only over SPI from FPGA pin)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_EDGE_ADDR_C)), edge_detect_status_to_spi_s);                                                       -- Internal read/write register (Edge detected and so processed by component misc_status_edge_interupt_inst)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_INT_MASK_ADDR_C)), get_data(spi_array_to_pins_s, to_integer(unsigned(MISC_INT_MASK_ADDR_C))));     -- Internal read/write register (read/write over SPI)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins_s,to_integer(unsigned(ENABLES_OUT_ADDR_C))));          -- Out pin (read/write over SPI)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(DIAGNOSTICS_INTERUPTS_ADDR_C)), diagnostics_interupts_data_s);                                          -- Internal read only register (read only over SPI from FPGA register)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(MDRB_UES1Addr_addr_c)), std_logic_vector(resize(unsigned(UES_1_c),SPI_DATA_BITS)));                     -- Internal constants (read only over SPI from constant in vhdl package)
--      set_data(spi_array_from_pins_s, to_integer(unsigned(MDRB_UES2Addr_addr_c)), std_logic_vector(resize(unsigned(UES_2_c),SPI_DATA_BITS)));                     -- Internal constants (read only over SPI from constant in vhdl package)
--  end process;
--
--
------Start of Interupt and edge detectection for SENSOR_STATUS_ADDR_C, SENSOR_EDGE_ADDR_C and SENSOR_INT_MASK_ADDR_C
--    sensor_status_write_en_s <= '1' when write_enable_from_spi_s = '1' and (write_addr_from_spi_s = SENSOR_EDGE_ADDR_C) else '0';
--    
--    sensor_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_STATUS_ADDR_C)));   -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    sensor_edge_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(SENSOR_EDGE_ADDR_C)));         -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    sensor_int_mask_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C))); -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--
--    sensor_status_edge_interupt_inst : reg_map_edge_interupt
--        generic map (
--                    reg_width => SPI_DATA_BITS                                                             -- : positive := 16
--                 )
--        Port map( 
--                    clk => clk,                                                                            -- : in std_logic;
--                    status_reg => sensor_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
--                    edge_detect_toggle_en => sensor_status_write_en_s,                                     -- : in std_logic;
--                    edge_detect_toggle_reg => sensor_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
--                    --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(SENSOR_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
--                    edge_detect_reg => edge_detect_sensor_to_spi_s,                                        -- : out std_logic_vector(reg_width-1 downto 0);
--                    interupt_mask_reg => sensor_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
--                    interupt_flag => sensor_interupt_flag_s                                                -- : out std_logic := '0'
--                    );
--    
------Start of Interupt and edge detectection for FAULT_STATUS_ADDR_C, FAULT_EDGE_ADDR_C and FAULT_INT_MASK_ADDR_C
--    fault_status_write_en_s <= '1' when write_enable_from_spi_s = '1' and (write_addr_from_spi_s = FAULT_EDGE_ADDR_C) else '0';
--
--    fault_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_STATUS_ADDR_C)));     -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    fault_edge_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(FAULT_EDGE_ADDR_C)));           -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    fault_int_mask_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(FAULT_INT_MASK_ADDR_C)));   -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    
--    fault_status_edge_interupt_inst : reg_map_edge_interupt
--        generic map (
--                  reg_width => SPI_DATA_BITS                                                            -- : positive := 16
--                 )
--        Port map( 
--                  clk => clk,                                                                           -- : in std_logic;
--                  status_reg => fault_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
--                  edge_detect_toggle_en => fault_status_write_en_s,                                     -- : in std_logic;
--                  edge_detect_toggle_reg => fault_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
--                  --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(FAULT_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
--                  edge_detect_reg => edge_detect_fault_to_spi_s,                                        -- : out std_logic_vector(reg_width-1 downto 0);
--                  interupt_mask_reg => fault_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
--                  interupt_flag => fault_interupt_flag_s                                                -- : out std_logic := '0'
--                  );
--    
------Start of Interupt and MISC detectection for MISC_STATUS_ADDR_C, MISC_EDGE_ADDR_C and MISC_INT_MASK_ADDR_C
--    misc_status_write_en_s <= '1' when write_enable_from_spi_s = '1' and (write_addr_from_spi_s = MISC_EDGE_ADDR_C) else '0';
--    
--    misc_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(MISC_STATUS_ADDR_C)));       -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    misc_edge_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(MISC_EDGE_ADDR_C)));             -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    misc_int_mask_s <= get_data(spi_array_to_pins_s, to_integer(unsigned(MISC_INT_MASK_ADDR_C)));     -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
--    
--    misc_status_edge_interupt_inst : reg_map_edge_interupt
--        generic map (
--                  reg_width => SPI_DATA_BITS                                                           -- : positive := 16
--                  )
--        Port map( 
--                  clk => clk,                                                                          -- : in std_logic;
--                  status_reg => misc_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
--                  edge_detect_toggle_en => misc_status_write_en_s,                                     -- : in std_logic;
--                  edge_detect_toggle_reg => misc_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
--                  --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(MISC_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
--                  edge_detect_reg => edge_detect_status_to_spi_s,                                      -- : out std_logic_vector(reg_width-1 downto 0);
--                  interupt_mask_reg => misc_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
--                  interupt_flag => misc_interupt_flag_s                                                -- : out std_logic := '0'
--                  );
--    
--
--    --And various interupt detect register outputs together for testbench testing/diagnostics
--    global_interupt_flag_s <= sensor_interupt_flag_s or fault_interupt_flag_s or misc_interupt_flag_s;
--    interupt_flag <= global_interupt_flag_s;
--    
--    diagnostics_interupts_data_s(0) <= sensor_interupt_flag_s;
--    diagnostics_interupts_data_s(1) <= fault_interupt_flag_s;
--    diagnostics_interupts_data_s(2) <= misc_interupt_flag_s;
--    diagnostics_interupts_data_s(diagnostics_interupts_data_s'LEFT) <= global_interupt_flag_s;


end generate non_testbenching_gen;


--Only for testbenchin a vanilla DUT (no register access to pins, not read only, no interupt/edge detection/processing)...
--...this will allow test with a decreasing sclk frequency to DUT to check what frequency the SPI link will work down to (currently about 20MHz depending on start frequency decimal places)
testbenching_gen : if make_all_addresses_writeable_for_testing generate

    spi_array_from_pins_s <= spi_array_to_pins_s;
--    set_all_data(spi_array_to_pins_s, spi_array_from_pins_s);

end generate testbenching_gen;


end Behavioral;
