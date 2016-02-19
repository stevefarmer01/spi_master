----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2016 15:29:08
-- Design Name: 
-- Module Name: gdrb_ctrl_reg_map - Behavioral
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

use IEEE.NUMERIC_STD.ALL;

use work.multi_array_types_pkg.ALL;     -- Multi-dimension array functions and procedures

--Application specific package
use work.gdrb_ctrl_bb_address_pkg.ALL;  -- Address constants 

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gdrb_ctrl_reg_map is
    generic ( 
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
           );
  Port (
          clk : in std_logic;
          --Discrete signals-Array of data spanning entire address range declared and initialised in 'package' for particular register map being implemented - (multi_array_types_pkg.vhd)
          --To/from pins of FPGA
          reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          --Non-register map read/control bits
          interupt_flag : out std_logic := '0';
          ---Array of data spanning entire address range declared and initialised in 'spi_package'
          spi_array_from_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          spi_array_to_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
          --Write enable and address to allow some write processing of internal FPGA register map (write bit toggling, etc)
          write_enable_from_spi : in std_logic := '0';
          write_addr_from_spi : in std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := (others => '0')
          );
end gdrb_ctrl_reg_map;

architecture Behavioral of gdrb_ctrl_reg_map is

--Application specific components
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

-------Application specific signals
--Array of data spanning entire address range
signal spi_array_to_pins_s, spi_array_from_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0')); -- From/to SPI interface

signal sensor_status_write_en_s : std_logic := '0';
signal sensor_interupt_flag_s : std_logic := '0';
signal sensor_status_s, sensor_edge_s, sensor_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
signal fault_status_s, fault_edge_s, fault_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
signal misc_status_s, misc_edge_s, misc_int_mask_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

signal fault_status_write_en_s : std_logic := '0';
signal fault_interupt_flag_s : std_logic := '0';

signal misc_status_write_en_s : std_logic := '0';
signal misc_interupt_flag_s : std_logic := '0';

signal diagnostics_interupts_data_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');
signal global_interupt_flag_s : std_logic := '0';

signal edge_detect_sensor_to_spi_s, edge_detect_fault_to_spi_s, edge_detect_status_to_spi_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

begin

----Example of how to connect the 2 unconstained multi-dimensional arrays that make up this parameteriseable 'SPI/register map' block of IP.
----There is one array for the interfacing to the outside world via the SPI interface inside 'reg_map_spi_slave.vhd' (spi_array_from/to_pins_s) and
----another for connecting to the pins of the FPGA for discrete input/outputs on the ports of this file (reg_map_array_from/to_pins).
----These 2 arrays can be connected to themselves and/or each other to perform one of the 5 following tasks...
------1/ In pin (read only over SPI - from FPGA pin)
------2/ Internal read/write register (read/write over SPI)
------3/ Out pin (read/write over SPI - to FPGA pin)
------4/ Internal read only register (read only over SPI from FPGA register)
------5/ Internal constants (read only over SPI from constant in vhdl package)
----Due to the nature of unconstrained multi-dimensional arrays in sub vhdl-2008 functions are needed to access slices (these are in 'multi_array_types_pkg.vhd').
----The 2 most useful are 'get_data' function for reading from the arrays and 'set_data' procedure for writing to the arrays.
----Also, due to the 'longest status prefix' rule of vhdl all of the 'set_data' on a particular array have to be used inside a process so that you don't get multiple
----drivers on the same signals.....
----
---------  --Process to write/read to array into SPI interface
---------  process(spi_array_to_pins, reg_map_array_from_pins, edge_detect_sensor_to_spi_s, diagnostics_interupts_data_s)
---------  begin
---------      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(SENSOR_STATUS_ADDR_C)))); -- In pin (read only over SPI from FPGA pin)
---------      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)), get_data(spi_array_to_pins, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)))); -- Internal read/write register (read/write over SPI)
---------      set_data(spi_array_from_pins_s, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins,to_integer(unsigned(ENABLES_OUT_ADDR_C))));          -- Out pin (read/write over SPI)
---------      set_data(spi_array_from_pins_s, to_integer(unsigned(DIAGNOSTICS_INTERUPTS_ADDR_C)), diagnostics_interupts_data_s);                                          -- Internal read only register (read only over SPI from FPGA register)
---------      set_data(spi_array_from_pins_s, to_integer(unsigned(MDRB_UES2Addr_addr_c)), std_logic_vector(resize(unsigned(UES_2_c),SPI_DATA_BITS)));                     -- Internal constants (read only over SPI from constant in vhdl package)
---------  end process;
---------  --Process to write to array connected to output pins of FPGA on top level
---------  process(spi_array_to_pins)
---------  begin
---------      set_data(reg_map_array_to_pins, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins,to_integer(unsigned(ENABLES_OUT_ADDR_C))));          --Out pin (write to pins)
---------  end process;
----
----...the registers for spi_array_from_pins_s/spi_array_to_pins is in 'spi_write_to_reg_map_proc' of 'reg_map_spi_slave.vhd' this is initialised (default values)
----by MEM_ARRAY_T_INITIALISATION which is set-up in the register map specific package such as 'gdrb_ctrl_bb_pkg.vhd' which is also where the widths for the SPI data and
----address are specified. Addresses for the registers are held in a package such as 'gdrb_ctrl_bb_address_pkg.vhd' and used in this block.
----For debug top level generic make_all_addresses_writeable_for_testing can be used to make the register all read/write.
----To detect writes on the SPI interface and hence allow some write access processing of the registers such as bit toggles for interupt style registers there are
----the ports 'write_addr_from_spi' and 'write_enable_from_spi' avaiable.
  

  --Process to write to array connected to output pins of FPGA on top level
  process(spi_array_to_pins)
  begin
      set_data(reg_map_array_to_pins, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins,to_integer(unsigned(ENABLES_OUT_ADDR_C))));          --Out pin (write to pins)
  end process;
  
  --Process to write to array into SPI interface
  process(spi_array_to_pins, reg_map_array_from_pins, edge_detect_sensor_to_spi_s, edge_detect_fault_to_spi_s, edge_detect_status_to_spi_s, diagnostics_interupts_data_s)
  begin
      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(SENSOR_STATUS_ADDR_C)))); -- In pin (read only over SPI from FPGA pin)
      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_EDGE_ADDR_C)), edge_detect_sensor_to_spi_s);                                                     -- Internal read/write register (Edge detected and so processed by component sensor_status_edge_interupt_inst)
      set_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)), get_data(spi_array_to_pins, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C)))); -- Internal read/write register (read/write over SPI)
      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(FAULT_STATUS_ADDR_C))));   -- In pin (read only over SPI from FPGA pin)
      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_EDGE_ADDR_C)), edge_detect_fault_to_spi_s);                                                       -- Internal read/write register (Edge detected and so processed by component fault_status_edge_interupt_inst)
      set_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_INT_MASK_ADDR_C)), get_data(spi_array_to_pins, to_integer(unsigned(FAULT_INT_MASK_ADDR_C))));   -- Internal read/write register (read/write over SPI)
      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_STATUS_ADDR_C)), get_data(reg_map_array_from_pins, to_integer(unsigned(MISC_STATUS_ADDR_C))));     -- In pin (read only over SPI from FPGA pin)
      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_EDGE_ADDR_C)), edge_detect_status_to_spi_s);                                                       -- Internal read/write register (Edge detected and so processed by component misc_status_edge_interupt_inst)
      set_data(spi_array_from_pins_s, to_integer(unsigned(MISC_INT_MASK_ADDR_C)), get_data(spi_array_to_pins, to_integer(unsigned(MISC_INT_MASK_ADDR_C))));     -- Internal read/write register (read/write over SPI)
      set_data(spi_array_from_pins_s, to_integer(unsigned(ENABLES_OUT_ADDR_C)), get_data(spi_array_to_pins,to_integer(unsigned(ENABLES_OUT_ADDR_C))));          -- Out pin (read/write over SPI)
      set_data(spi_array_from_pins_s, to_integer(unsigned(DIAGNOSTICS_INTERUPTS_ADDR_C)), diagnostics_interupts_data_s);                                          -- Internal read only register (read only over SPI from FPGA register)
      set_data(spi_array_from_pins_s, to_integer(unsigned(MDRB_UES1Addr_addr_c)), std_logic_vector(resize(unsigned(UES_1_c),SPI_DATA_BITS)));                     -- Internal constants (read only over SPI from constant in vhdl package)
      set_data(spi_array_from_pins_s, to_integer(unsigned(MDRB_UES2Addr_addr_c)), std_logic_vector(resize(unsigned(UES_2_c),SPI_DATA_BITS)));                     -- Internal constants (read only over SPI from constant in vhdl package)
  end process;


----Start of Interupt and edge detectection for SENSOR_STATUS_ADDR_C, SENSOR_EDGE_ADDR_C and SENSOR_INT_MASK_ADDR_C
    sensor_status_write_en_s <= '1' when write_enable_from_spi = '1' and (write_addr_from_spi = SENSOR_EDGE_ADDR_C) else '0';
    
    sensor_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(SENSOR_STATUS_ADDR_C)));   -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    sensor_edge_s <= get_data(spi_array_to_pins, to_integer(unsigned(SENSOR_EDGE_ADDR_C)));         -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    sensor_int_mask_s <= get_data(spi_array_to_pins, to_integer(unsigned(SENSOR_INT_MASK_ADDR_C))); -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"

    sensor_status_edge_interupt_inst : reg_map_edge_interupt
        generic map (
                    reg_width => SPI_DATA_BITS                                                             -- : positive := 16
                 )
        Port map( 
                    clk => clk,                                                                            -- : in std_logic;
                    status_reg => sensor_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
                    edge_detect_toggle_en => sensor_status_write_en_s,                                     -- : in std_logic;
                    edge_detect_toggle_reg => sensor_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
                    --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(SENSOR_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
                    edge_detect_reg => edge_detect_sensor_to_spi_s,                                        -- : out std_logic_vector(reg_width-1 downto 0);
                    interupt_mask_reg => sensor_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
                    interupt_flag => sensor_interupt_flag_s                                                -- : out std_logic := '0'
                    );
    
----Start of Interupt and edge detectection for FAULT_STATUS_ADDR_C, FAULT_EDGE_ADDR_C and FAULT_INT_MASK_ADDR_C
    fault_status_write_en_s <= '1' when write_enable_from_spi = '1' and (write_addr_from_spi = FAULT_EDGE_ADDR_C) else '0';

    fault_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(FAULT_STATUS_ADDR_C)));     -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    fault_edge_s <= get_data(spi_array_to_pins, to_integer(unsigned(FAULT_EDGE_ADDR_C)));           -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    fault_int_mask_s <= get_data(spi_array_to_pins, to_integer(unsigned(FAULT_INT_MASK_ADDR_C)));   -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    
    fault_status_edge_interupt_inst : reg_map_edge_interupt
        generic map (
                  reg_width => SPI_DATA_BITS                                                            -- : positive := 16
                 )
        Port map( 
                  clk => clk,                                                                           -- : in std_logic;
                  status_reg => fault_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
                  edge_detect_toggle_en => fault_status_write_en_s,                                     -- : in std_logic;
                  edge_detect_toggle_reg => fault_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
                  --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(FAULT_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
                  edge_detect_reg => edge_detect_fault_to_spi_s,                                        -- : out std_logic_vector(reg_width-1 downto 0);
                  interupt_mask_reg => fault_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
                  interupt_flag => fault_interupt_flag_s                                                -- : out std_logic := '0'
                  );
    
----Start of Interupt and MISC detectection for MISC_STATUS_ADDR_C, MISC_EDGE_ADDR_C and MISC_INT_MASK_ADDR_C
    misc_status_write_en_s <= '1' when write_enable_from_spi = '1' and (write_addr_from_spi = MISC_EDGE_ADDR_C) else '0';
    
    misc_status_s <= get_data(spi_array_from_pins_s, to_integer(unsigned(MISC_STATUS_ADDR_C)));       -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    misc_edge_s <= get_data(spi_array_to_pins, to_integer(unsigned(MISC_EDGE_ADDR_C)));             -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    misc_int_mask_s <= get_data(spi_array_to_pins, to_integer(unsigned(MISC_INT_MASK_ADDR_C)));     -- The addition of these doesn't effect simulation results but stops a vivado compiler warning- "globally static expression"
    
    misc_status_edge_interupt_inst : reg_map_edge_interupt
        generic map (
                  reg_width => SPI_DATA_BITS                                                           -- : positive := 16
                  )
        Port map( 
                  clk => clk,                                                                          -- : in std_logic;
                  status_reg => misc_status_s,                                                         -- : in std_logic_vector(reg_width-1 downto 0);
                  edge_detect_toggle_en => misc_status_write_en_s,                                     -- : in std_logic;
                  edge_detect_toggle_reg => misc_edge_s,                                               -- : in std_logic_vector(reg_width-1 downto 0);
                  --.edge_detect_reg => spi_array_from_pins_s(to_integer(unsigned(MISC_EDGE_ADDR_C))), -- : out std_logic_vector(reg_width-1 downto 0);
                  edge_detect_reg => edge_detect_status_to_spi_s,                                      -- : out std_logic_vector(reg_width-1 downto 0);
                  interupt_mask_reg => misc_int_mask_s,                                                -- : in std_logic_vector(reg_width-1 downto 0);
                  interupt_flag => misc_interupt_flag_s                                                -- : out std_logic := '0'
                  );
    

    --And various interupt detect register outputs together for testbench testing/diagnostics
    global_interupt_flag_s <= sensor_interupt_flag_s or fault_interupt_flag_s or misc_interupt_flag_s;
    interupt_flag <= global_interupt_flag_s;
    
    diagnostics_interupts_data_s(0) <= sensor_interupt_flag_s;
    diagnostics_interupts_data_s(1) <= fault_interupt_flag_s;
    diagnostics_interupts_data_s(2) <= misc_interupt_flag_s;
    diagnostics_interupts_data_s(diagnostics_interupts_data_s'LEFT) <= global_interupt_flag_s;

--output ports that need to be read and so have intermidiate signals

spi_array_from_pins <= spi_array_from_pins_s;

end Behavioral;
