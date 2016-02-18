----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2016 08:56:18
-- Design Name: 
-- Module Name: spi_master_tb.vhd - Behavioral
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
-- This testbench is for testing a slave SPI interface which will be fitted intially into the Griffin GDRB board with the master in the Begalbone-ARM processor.
-- It has a protocol described in 'spi_package.vhd' and the GDRB paperwork, this can be changed and this tesbench and all supporting code should be able to cope
-- with any width address and data.
--
-- The slave interface (reg_map_proc) is tested via master SPI interface (spi_master_inst) using the 6 procedures declared in the architecture of this file.
-- The text input is done by process 'file_input_proc' and the text output by process 'file_output_proc'.
-- 
-- Testing of a real register map is done with the top level constants set to...
--    constant DUT_TYPE : string := "input_vector_file_test";
--    constant make_all_addresses_writeable_for_testing : boolean := FALSE;
-- ...this will allow parts of the register map to be either read/write, read only (constants) or read only (discrete input pins) as controlled in 'gdrb_ctrl_reg_map_top.vhd'
-- and 'spi_package.vhd'.
--
-- Testing is done via the input file 'input_test.txt', an example of this file is shown in 'input_test_example.txt' with comments.
-- Results are recorded in file 'output_test.txt', an example of this file is shown in 'output_test_example.txt' which is the results from 'input_test_example.txt'
-- with top level constans set to...
--    constant DUT_TYPE : string := "input_vector_file_test"; 
--    constant make_all_addresses_writeable_for_testing : boolean := TRUE;
-- ...and 'spi_package.vhd' set to....
--    constant SPI_ADDRESS_BITS : integer := 4;
--    constant SPI_DATA_BITS : integer := 16;
-- 
-- A simple read write test (no textio input file required) is accessed with the top level constants set to...
--    constant DUT_TYPE : string := "write_and_then_read_an_address";
--    constant make_all_addresses_writeable_for_testing : boolean := TRUE;
-- ....this may not be maintained during future development.
--
-- A test of how slow the DUT clk can be and still maintain the integrity of the SPI link is accessed with the top level constants set to...
--    constant DUT_TYPE : string := "spi_reg_map_simple";
--    constant make_all_addresses_writeable_for_testing : boolean := TRUE;
-- ..it will continue to run decreasing the DUT clk frequency until it detects an error.
-- This may not be maintained during future development.
--
----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---Next Tasks.....
---Report back pass/fail at end of sim - done
---Integrate register map - done
---Integrate text IO, maybe start with output rporting first - done
---Remove need package gdrb_ctrl_bb_pkg to be declared (bring in on generics or something)
---Add abilty to use HREAD or something to read non 4bit address/data widths from text file as they fail at the moment (might need a function to slice and dice)
---Look at way to use 'generic_spi_reg_map_top' instead of 'gdrb_ctrl_reg_map_top' by using input generics
---Improve python to include board testing by maybe expanding the dictionary in it to include using different .prj and xelab or take in generics
---Check speed tests still work
---Random seed testing option

--.    --Set sizes of data and addresse as required for particular application
--.    constant SPI_ADDRESS_BITS : integer := 4;
--.    constant SPI_DATA_BITS : integer := 16;
--.    constant DATA_SIZE : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1;                             -- Total data size = read/write bit + address + data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.gdrb_ctrl_bb_pkg.ALL;
--use work.gdrb_ctrl_bb_address_pkg.ALL;
use work.spi_board_select_pkg.ALL;
use work.multi_array_types_pkg.all;


entity spi_master_tb is
    generic(
            board_select : boolean := FALSE; -- Use generate statement - xxxxxx_gen : if not board_select generate xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx end generate;
            make_all_addresses_writeable_for_testing : boolean := TRUE;
            DUT_TYPE : string := "write_and_then_read_an_address"
            );
end spi_master_tb;

architecture behave of spi_master_tb is

    constant FIFO_REQ  : Boolean   := FALSE;

--.--.Test using  input file
--.    constant DUT_TYPE : string := "input_vector_file_test"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
--.    constant make_all_addresses_writeable_for_testing : boolean := FALSE; -- This allows entire register map read write access for testbench testing of a non-module specific register map

--.Test using  input file - DIAGNOSTICS AS IT HAS ALL ADDRESSES SET TO READ/WRITABLE via 'make_all_addresses_writeable_for_testing'

--.    constant DUT_TYPE : string := "input_vector_file_test"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures

--    constant make_all_addresses_writeable_for_testing : boolean := TRUE; -- This allows entire register map read write access for testbench testing of a non-module specific register map
--.Simple read write as an example - without textio
--    constant DUT_TYPE : string := "write_and_then_read_an_address"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board
--.    constant make_all_addresses_writeable_for_testing : boolean := TRUE; -- This allows entire register map read write access for testbench testing of a non-module specific register map
--.Full write/read test with a decreasing sclk frequency to DUT to check what frequency the SPI link will work down to

--.    constant DUT_TYPE : string := "spi_reg_map_simple"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
--.    constant make_all_addresses_writeable_for_testing : boolean := TRUE; -- This allows entire register map read write access for testbench testing of a non-module specific register map

----------------these routines below are more diagnostics routine for initial designing of interface than an actual functional test and so shouldn't be run----------
--.Test actual register map
--.    constant DUT_TYPE : string := "gdrb_ctrl_reg_map_test"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
--.    constant make_all_addresses_writeable_for_testing : boolean := FALSE; -- This allows entire register map read write access for testbench testing of a non-module specific register map
--.    constant DUT_TYPE : string := "spi_slave"; -- Simple test of just the low level spi_slave.vhd
--.    constant DUT_TYPE : string := "spi_reg_map"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board

component spi_master_top
    generic(
        DATA_SIZE      :     integer := 16;
        FIFO_REQ       :     Boolean := True
        );
    port(
        i_sys_clk      : in  std_logic;  -- system clock
        i_sys_rst      : in  std_logic;  -- system reset
        i_csn          : in  std_logic;  -- chip select for SPI master
        i_data         : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
        i_wr           : in  std_logic;  -- Active Low Write, Active High Read
        i_rd           : in  std_logic;  -- Active Low Write, Active High Read
        o_data         : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
        o_tx_ready     : out std_logic;  -- Transmitter ready, can write another 
        o_rx_ready     : out std_logic;  -- Receiver ready, can read data
        o_tx_error     : out std_logic;  -- Transmitter error
        o_rx_error     : out std_logic;  -- Receiver error
        i_slave_addr   : in  std_logic_vector(1 downto 0);  -- Slave Address
        i_cpol         : in  std_logic;  -- CPOL value - 0 or 1
        i_cpha         : in  std_logic;  -- CPHA value - 0 or 1 
        i_lsb_first    : in  std_logic;  -- lsb first when '1' /msb first when 
        i_spi_start    : in  std_logic;  -- START SPI Master Transactions
        i_clk_period   : in  std_logic_vector(7 downto 0);  -- SCL clock period in terms of i_sys_clk
        i_setup_cycles : in  std_logic_vector(7 downto 0);  -- SPIM setup time  in terms of i_sys_clk
        i_hold_cycles  : in  std_logic_vector(7 downto 0);  -- SPIM hold time  in terms of i_sys_clk
        i_tx2tx_cycles : in  std_logic_vector(7 downto 0);  -- SPIM interval between data transactions in terms of i_sys_clk
        o_slave_csn    : out std_logic_vector(3 downto 0);  -- SPI Slave select (chip select) active low
        o_mosi         : out std_logic;  -- Master output to Slave
        i_miso         : in  std_logic;  -- Master input from Slave
        o_sclk         : out std_logic  -- Master clock
        );
end component;

component gdrb_ctrl_reg_map_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16
           );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to ss_n
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t(0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t(0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0)
            );
end component;

component spi_board_select_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
            SPI_BOARD_SEL_ADDR_BITS : integer := 4;
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
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t(0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t(0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0);
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
          );
end component;

constant DATA_SIZE : integer := DATA_SIZE_C+SPI_BOARD_SEL_ADDR_BITS;

signal stop_sim_on_fail : boolean := TRUE;
signal report_spi_access_type : string(1 to 10);

signal board_sel_to_spi, address_to_spi, address_of_port : natural := 0;
signal data_to_spi, data_of_port : natural := 16#AA#;
signal check_data_from_spi : natural := 16#AA#;

signal rx_data_from_spi : natural;
signal check_data_mask : natural := (2**DATA_SIZE)-1; -- Default to all '1's so that all bits of the result are checked unless mask set otherwise by input testing parameters

signal   sys_clk_i       : std_logic                     := '0';  -- system clock
signal   sys_rst_i       : std_logic                     := '1';  -- system reset
signal   csn_i           : std_logic                     := '1';  -- SPI Master chip select
signal   data_i          : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');  -- Input data
signal   slave_data_i    : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');  -- Input data
signal   wr_i            : std_logic                     := '0';  -- Active Low Write, Active High Read
signal   rd_i            : std_logic                     := '0';  -- Active Low Write, Active High Read
signal   slave_addr_i    : std_logic_vector(1 downto 0)  := "00";  -- Slave Address
signal   spi_start_i     : std_logic                     := '0';  -- START SPI Master Transactions
signal   tx2tx_cycles_i  : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16,8));  -- SPIM interval between data transactions in terms of i_sys_clk
signal   slave_csn_i     : std_logic_vector(3 downto 0);  -- SPI Slave select (chip select) active low
signal   mosi_i          : std_logic                     := '0';  -- Master output to Slave
signal   miso            : std_logic                     := '1';  -- Master input from Slave
signal   sclk_i          : std_logic                     := '0';  -- Master clock
signal   ss_i            : std_logic;  -- Master
constant TIME_PERIOD_CLK : time                          := 10 ns;
shared variable cnt      : integer                       := 0;

    constant induce_fault_master_tx_c : boolean := FALSE;

    signal TIME_PERIOD_CLK_S : time := 10 ns;
    signal TIME_PERIOD_CLK_DUT_S : time := 16.67 ns;
    signal dut_sys_clk_i : std_logic := '0';
    signal dut_clk_ratio_to_testbench : integer := integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);
    signal stop_clks : boolean := FALSE;
    signal trigger_another_reset_s : boolean := FALSE;

    signal o_data_slave, o_data_master, data_i_master_tx, data_i_slave_tx : std_logic_vector(DATA_SIZE - 1 downto 0); 
    signal master_slave_match, slave_master_match : boolean := FALSE;
    signal master_to_slave_rx_match_latch, slave_to_master_rx_match_latch : boolean := TRUE;
    signal o_rx_ready_slave, o_tx_ready_slave : std_logic := '0';
    signal o_tx_ready_master, o_rx_ready_master : std_logic := '0';
    signal master_rx_activity : boolean := FALSE;
    signal slave_to_master_rx_match_latch_result, slave_to_master_tx_match_latch_result : boolean;
    signal test_0, test_1 : std_logic_vector(7 downto 0);

    ---Array of data spanning entire address range declared and initialised in 'spi_package' has offset to make i's contents different from that held in DUT
    --signal gdrb_ctrl_data_array_tb_s : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise_offset;
    signal discrete_reg_map_array_to_script_s, discrete_reg_map_array_from_script_s : mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0')); -- This may be safer but not as nice
    signal bs_discrete_reg_map_array_to_script_s, bs_discrete_reg_map_array_from_script_s : mem_array_t( 0 to (SPI_BOARD_SEL_PROTOCOL_ADDR_BITS**2)-1, SPI_BOARD_SEL_PROTOCOL_DATA_BITS-1 downto 0) := (others => (others => '0')); -- This may be safer but not as nice

    type command_t is (read_write_spi_cmd, read_port_cmd, write_port_cmd, print_comment_line);
    signal input_command_type : command_t;
    signal line_of_comments : string(1 to 99);


    procedure send_to_spi_master(
             constant read_write_to_spi : in std_logic;
             signal rx_data_from_spi : out natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic
         );
    
    procedure send_to_spi_master(
             constant read_write_to_spi : in std_logic;
             signal rx_data_from_spi : out natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic
         ) is
    begin
                        wait until rising_edge(sys_clk_i);
                        spi_start_i     <= '0';
                        
                        if board_select then
                            data_i      <= std_logic_vector(to_unsigned(board_sel_to_spi,SPI_BOARD_SEL_ADDR_BITS)) & read_write_to_spi & std_logic_vector(to_unsigned(address_to_spi,SPI_BOARD_SEL_PROTOCOL_ADDR_BITS)) & std_logic_vector(to_unsigned(data_to_spi,SPI_DATA_BITS)); -- send write data over SPI (just write all data to a fixed pattern and check it propergates thru array in reg map)
                        else
                            data_i      <= read_write_to_spi & std_logic_vector(to_unsigned(address_to_spi,SPI_ADDRESS_BITS)) & std_logic_vector(to_unsigned(data_to_spi,SPI_DATA_BITS)); -- send write data over SPI (just write all data to a fixed pattern and check it propergates thru array in reg map)
                        end if;
                        
                        wr_i        <= '1';    -- write data enable tx to master
                        wait until rising_edge(sys_clk_i);
                        wr_i        <= '0';
        
                        wait until rising_edge(sys_clk_i);
                        spi_start_i <= '1';     -- start sending of master SPI tx
                        wait until rising_edge(sys_clk_i);
                        spi_start_i <= '0';
        
                        wait until ss_i = '1'; -- packet has finished when slave select goes low (this ia an active low enable)
    
                        wait for to_integer(unsigned(tx2tx_cycles_i)) * TIME_PERIOD_CLK * dut_clk_ratio_to_testbench; -- wait tx to tx minimum period which is implemented in master's sclk_gen component
    
                        if board_select then
--                            rx_data_from_spi <= to_integer(unsigned(o_data_master(o_data_master'LEFT-SPI_BOARD_SEL_ADDR_BITS downto o_data_master'LEFT-SPI_BOARD_SEL_ADDR_BITS-(SPI_DATA_BITS-1)))); -- rx data by master SPI
                            rx_data_from_spi <= to_integer(unsigned(o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)))); -- rx data by master SPI
--                            rx_data_from_spi <= to_integer(unsigned(o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)))); -- rx data by master SPI
                        else
                            rx_data_from_spi <= to_integer(unsigned(o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)))); -- rx data by master SPI
                        end if;
        
                        wait until rising_edge(sys_clk_i);
                        rd_i        <= '1';     -- read data enable rx'd to master
                        wait until rising_edge(sys_clk_i);
                        rd_i        <= '0';
    end procedure send_to_spi_master;


    procedure check_result(
             signal rx_data_from_spi : inout natural;
             signal stop_clks : out boolean
        );

    procedure check_result(
             signal rx_data_from_spi : inout natural;
             signal stop_clks : out boolean
        ) is
        variable rx_and_expected_same : boolean := FALSE;
    begin

            if (((to_unsigned(rx_data_from_spi,DATA_SIZE)) and (to_unsigned(check_data_mask,DATA_SIZE))) = ((to_unsigned(check_data_from_spi,DATA_SIZE)) and (to_unsigned(check_data_mask,DATA_SIZE)))) then
                rx_and_expected_same := TRUE;
            else
                rx_and_expected_same := FALSE;
            end if;

--.            assert not rx_and_expected_same                                                                -- Check for correct data back and that there has actually been some data received
--.                report "FAIL - Master SPI recieved different to expected" severity note;
--.            assert rx_and_expected_same                                                                  -- Check for correct data back and that there has actually been some data received
--.                report "PASS - Master SPI recieved as expected" severity note;
            if (not rx_and_expected_same) and stop_sim_on_fail then 
                stop_clks <= TRUE; -- Stop simulation when a failure is detected when running tests which increment the DUT clk speed and will eventually fail to show the lowest DUT clk speed that SPI will still work at
            else
                stop_clks <= FALSE; 
            end if;

    end procedure check_result;


    procedure reg_map_rw_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         );

    procedure reg_map_rw_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         ) is
    begin
                --------Writing loop --------.
            send_to_spi_master('0', rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a write
            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform
            --------Reading loop --------.
            --for j in 0 to 1 loop                                                                                           -- need to send 2 packets to perform a read on SPI
            send_to_spi_master('1', rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a read (twice due to nature of SPI interface)
            --end loop;
            
            report_spi_access_type <= "WRITE READ";

            check_result(rx_data_from_spi, stop_clks);

            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform
        
    end procedure reg_map_rw_check;


    procedure reg_map_r_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         );

    procedure reg_map_r_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         ) is
    begin

            --------Reading loop --------.
            for j in 0 to 1 loop                                                                                           -- need to send 2 packets to perform a read on SPI
                send_to_spi_master('1', rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a read (twice due to nature of SPI interface)
            end loop;
            
            report_spi_access_type <= "READ SPI  ";

            check_result(rx_data_from_spi, stop_clks);

            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform

    end procedure reg_map_r_check;


    procedure reg_map_w_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         );

    procedure reg_map_w_check(
             signal rx_data_from_spi : inout natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic;
             signal report_spi_access_type : out string(1 to 10);
             signal stop_clks : out boolean
         ) is
    begin
                --------Writing loop --------.
            send_to_spi_master('0', rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a write

            report_spi_access_type <= "WRITE SPI ";

            check_result(rx_data_from_spi, stop_clks);

            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform

    end procedure reg_map_w_check;


begin

---reset and clocks
reset_proc : process
begin
    sys_rst_i <= '1';
    wait for 10 * TIME_PERIOD_CLK;
    sys_rst_i <= '0';
    wait until trigger_another_reset_s;
end process;

clk_gen_proc : process
begin
    while not stop_clks loop
        wait for TIME_PERIOD_CLK/2;
        sys_clk_i <= not sys_clk_i;
    end loop;
    wait;
end process;

clk_gen_dut_proc : process
begin
    while not stop_clks loop
        wait for TIME_PERIOD_CLK_DUT_S/2;
        dut_sys_clk_i <= not dut_sys_clk_i;
    end loop;
    wait;
end process;


--------------------------Register Map SPI DUT----------------------------.

spi_reg_map_gen : if not board_select generate

    reg_map_proc : gdrb_ctrl_reg_map_top
        generic map(
                make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing, -- :     natural := 16
                SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                 -- : integer := 4;
                SPI_DATA_BITS => SPI_DATA_BITS                        -- : integer := 16
                )
        Port map(  
                clk => dut_sys_clk_i,                                          -- : std_logic;
                reset => sys_rst_i,                                            -- : std_logic;
                ---Slave SPI interface pins
                sclk => sclk_i,                                                -- : in STD_LOGIC;
                ss_n => ss_i,                                                  -- : in STD_LOGIC;
                i_raw_ssn => ss_i,                                             -- : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to same signal as 'ss_n'
                mosi => mosi_i,                                                -- : in STD_LOGIC;
                miso => miso,                                                  -- : out STD_LOGIC;
                --Discrete signals
                reg_map_array_from_pins => discrete_reg_map_array_from_script_s, -- : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
                reg_map_array_to_pins => discrete_reg_map_array_to_script_s      -- : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0)
                );

end generate spi_reg_map_gen;

--------------------------Board Select Register Map SPI DUT----------------------------.
--    constant SPI_BOARD_SEL_PROTOCOL_ADDR_BITS : integer := 4;
--    constant SPI_BOARD_SEL_PROTOCOL_DATA_BITS : integer := 16;

board_sel_spi_reg_map_gen : if board_select generate

    reg_map_proc : spi_board_select_top
        generic map(
                make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing, -- :     natural := 16
                SPI_BOARD_SEL_ADDR_BITS => SPI_BOARD_SEL_ADDR_BITS,                 -- : integer := 4;
                SPI_ADDRESS_BITS => SPI_BOARD_SEL_PROTOCOL_ADDR_BITS,                                              -- : integer := 4;
                SPI_DATA_BITS => SPI_BOARD_SEL_PROTOCOL_DATA_BITS,                                                 -- : integer := 16
                MEM_ARRAY_T_INITIALISATION => bs_mem_array_t_initalised_c -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
                )
        Port map(  
                clk => dut_sys_clk_i,                                          -- : std_logic;
                reset => sys_rst_i,                                            -- : std_logic;
                ---Slave SPI interface pins
                sclk => sclk_i,                                                -- : in STD_LOGIC;
                ss_n => ss_i,                                                  -- : in STD_LOGIC;
                mosi => mosi_i,                                                -- : in STD_LOGIC;
                miso => miso,                                                  -- : out STD_LOGIC;
                --Discrete signals
                reg_map_array_from_pins => bs_discrete_reg_map_array_from_script_s, -- : in mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
                reg_map_array_to_pins => bs_discrete_reg_map_array_to_script_s      -- : out mem_array_t( 0 to (SPI_ADDRESS_BITS**2)-1, SPI_DATA_BITS-1 downto 0)
                );

end generate board_sel_spi_reg_map_gen;


--------------------------MASTER SPI----------------------------.

--.Induce fault to check test bench if desired
data_i_master_tx <= (data_i(data_i'HIGH downto 1) & '1') when induce_fault_master_tx_c else data_i;

    spi_master_inst : spi_master_top
        generic map(
            DATA_SIZE      => DATA_SIZE,         -- :     integer := 16;
            FIFO_REQ       => FIFO_REQ           -- :     Boolean := True
            )
        port map(
            i_sys_clk      => sys_clk_i,         -- : in  std_logic;                                    -- system clock
            i_sys_rst      => sys_rst_i,         -- : in  std_logic;                                    -- system reset
            i_csn          => '0',               -- : in  std_logic;                                    -- chip select for SPI master
            i_data         => data_i_master_tx,  -- : in  std_logic_vector(15 downto 0);                -- Input data
            i_wr           => wr_i,              -- : in  std_logic;                                    -- Active Low Write, Active High Read
            i_rd           => rd_i,              -- : in  std_logic;                                    -- Active Low Write, Active High Read
            o_data         => o_data_master,     -- : out std_logic_vector(15 downto 0);  --output data
            o_tx_ready     => o_tx_ready_master, -- : out std_logic;                                    -- Transmitter ready, can write another
            o_rx_ready     => o_rx_ready_master, -- : out std_logic;                                    -- Receiver ready, can read data
            o_tx_error     => open,              -- : out std_logic;                                    -- Transmitter error
            o_rx_error     => open,              -- : out std_logic;                                    -- Receiver error
            i_slave_addr   => slave_addr_i,      -- : in  std_logic_vector(1 downto 0);                 -- Slave Address
            i_cpol         => '0',               -- : in  std_logic;                                    -- CPOL value - 0 or 1
            i_cpha         => '0',               -- : in  std_logic;                                    -- CPHA value - 0 or 1
            i_lsb_first    => '0',               -- : in  std_logic;                                    -- lsb first when '1' /msb first when
            i_spi_start    => spi_start_i,       -- : in  std_logic;                                    -- START SPI Master Transactions
            i_clk_period   => "01100100",        -- : in  std_logic_vector(7 downto 0);                 -- SCL clock period in terms of i_sys_clk
            i_setup_cycles => "00011111",        -- : in  std_logic_vector(7 downto 0);                 -- SPIM setup time  in terms of i_sys_clk
            i_hold_cycles  => "00011111",        -- : in  std_logic_vector(7 downto 0);                 -- SPIM hold time  in terms of i_sys_clk
            i_tx2tx_cycles => tx2tx_cycles_i,        -- : in  std_logic_vector(7 downto 0);                 -- SPIM interval between data transactions in terms of i_sys_clk
            o_slave_csn    => slave_csn_i,       -- : out std_logic_vector(3 downto 0);                 -- SPI Slave select (chip select) active low
            o_mosi         => mosi_i,            -- : out std_logic;                                    -- Master output to Slave
            i_miso         => miso,              -- : in  std_logic;                                    -- Master input from Slave
            o_sclk         => sclk_i             -- : out std_logic;                                    -- Master clock
            );

--.Instantaneous check if tx/rx values agree
slave_master_match <= TRUE when data_i = o_data_master else FALSE;
--.Latch the failure if when rx ready goes high and tx/rx values don't agree
latch_match_2_proc : process
begin
    wait until o_rx_ready_master = '1';
    master_rx_activity <= TRUE; -- show that there have been some master data recieved (shows link has been active)
    if not (data_i = o_data_master) then
        slave_to_master_rx_match_latch <= FALSE;
    end if;
end process;

ss_i <= slave_csn_i(0) and slave_csn_i(1) and slave_csn_i(2) and slave_csn_i(3);






duff_gen : if not board_select generate

end generate;

--------------------------------------------------------.
--------------------------Inputs------------------------.
--------------------------------------------------------.
------------------------------Register Map tests using input file for vectors------------------------------.
input_vector_file_test_gen : if DUT_TYPE = "input_vector_file_test" generate

    file_input_proc : process
        file F : text;
        variable L : line;
        variable good : boolean;
        variable status : file_open_status;
        variable input_command_v : string(1 to 4);
        variable board_sel_to_spi_v : std_logic_vector(SPI_BOARD_SEL_ADDR_BITS - 1 downto 0) := (others => '0');
        variable address_to_spi_v, address_of_port_v : std_logic_vector(SPI_ADDRESS_BITS - 1 downto 0) := (others => '1');
        variable bs_address_to_spi_v, bs_address_of_port_v : std_logic_vector(SPI_BOARD_SEL_PROTOCOL_ADDR_BITS - 1 downto 0) := (others => '1');
        variable data_to_spi_v, data_of_port_v : std_logic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '1');
        variable check_data_from_spi_v : std_logic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '1');
        variable check_data_mask_v : std_logic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '1'); -- Default to all '1's so that all bits of the result are checked unless mask set otherwise by input testing parameters
        variable line_of_comments_v : string(1 to line_of_comments'LENGTH) := (others => ' ');
    begin
        FILE_OPEN(status, F, "..\input_test.txt", READ_MODE);
        if status /= OPEN_OK then
            assert FALSE
                report "Failed to open file" severity failure;
        else
            stop_sim_on_fail <= FALSE;                                                                                     -- Do not exit on fail as we want complete file IO output showing fails (set to true when doing clk speed tests (will exit when fail detected))

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench;                                                     -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            while not ENDFILE(F) loop
                READLINE(F, L);
                next when L'LENGTH = 0;                                                     -- Skip empty lines
                READ(L, input_command_v);
                if input_command_v = "####"  then                                           -- Comment
                    input_command_type <= print_comment_line;

                    line_of_comments_v := (others => ' ');
                    if (L'LENGTH < line_of_comments_v'LENGTH) then
                        READ(L, line_of_comments_v(1 to L'LENGTH));
                    end if;
                    line_of_comments <= line_of_comments_v;
                    stop_clks <= FALSE; 
                    wait for 0 ns;  -- Allow stop_clks to get to file_output_proc process
                elsif input_command_v = "Read" or input_command_v = "Writ"  then            -- Read or Write command

                    input_command_type <= read_write_spi_cmd;

                    if board_select then
                        HREAD(L, board_sel_to_spi_v, good);
                        assert good report "Text input file format read error" severity FAILURE;
                        board_sel_to_spi <= to_integer(unsigned(board_sel_to_spi_v));
                        HREAD(L, bs_address_to_spi_v, good);
                        assert good report "Text input file format read error" severity FAILURE;
                        address_to_spi <= to_integer(unsigned(bs_address_to_spi_v));
                    end if;

                    if not board_select then
                        HREAD(L, address_to_spi_v, good);
                        assert good report "Text input file format read error" severity FAILURE;
                        address_to_spi <= to_integer(unsigned(address_to_spi_v));
                    end if;

                    HREAD(L, data_to_spi_v, good);
                    assert good report "Text input file format read error" severity FAILURE;
                    HREAD(L, check_data_from_spi_v, good);
                    assert good report "Text input file format read error" severity FAILURE;
                    HREAD(L, check_data_mask_v, good);
                    assert good report "Text input file format read error" severity FAILURE;
                    data_to_spi <= to_integer(unsigned(data_to_spi_v));
                    check_data_from_spi <= to_integer(unsigned(check_data_from_spi_v));
                    check_data_mask <= to_integer(unsigned(check_data_mask_v));
                    if input_command_v = "Read" then
                        reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
                    elsif input_command_v = "Writ"  then
                        reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
                    end if;
                
                elsif input_command_v = "RdPo" or input_command_v = "WrPo"  then            -- Read or Write command

                    if input_command_v = "RdPo" then
                        input_command_type <= read_port_cmd;
                    else
                        input_command_type <= write_port_cmd;
                    end if;

                    HREAD(L, address_of_port_v, good);
                    assert good report "Text input file format read error" severity FAILURE;
                    HREAD(L, data_of_port_v, good);
                    assert good report "Text input file format read error" severity FAILURE;
                    if input_command_v = "RdPo" then
                        --Do nothing, check results in textio output
                    elsif input_command_v = "WrPo" then
--                        discrete_reg_map_array_from_script_s(to_integer(unsigned(address_of_port_v))) <= data_of_port_v;
                        set_data(discrete_reg_map_array_from_script_s, (to_integer(unsigned(address_of_port_v))), data_of_port_v);  -- put data from pins into array for pins to SPI interface
                    end if;
                    address_of_port <= to_integer(unsigned(address_of_port_v));
                    data_of_port <= to_integer(unsigned(data_of_port_v));
                    stop_clks <= FALSE; 
                    wait for 10 ns;  -- Allow Read Port and Write Port commands to get to file_output_proc if these are last commands in input_test.txt;
                else
                    assert false report "Text input file format read error" severity FAILURE;
                end if;
    
                --wait for 10 ns;
            end loop;
            FILE_CLOSE(F);
        end if;
------------------------------FINSHED SIMULATION------------------------------.
--    wait for 100 ns;                                                                     -- Wait for any commands above to filter through to textio output file 

        stop_clks <= TRUE;                                                                  -- Always stop simulator when all tests have completed
        wait;
    end process;

end generate input_vector_file_test_gen;


---------------------------------------------------------.
--------------------------Outputs------------------------.
---------------------------------------------------------.
file_output_proc : process
    file F : text;
    variable L : line;
    variable status : file_open_status;
    variable rx_and_expected_same : boolean := FALSE;
    variable a_test_has_failed : boolean := FALSE;
begin
    FILE_OPEN(F, "..\output_test.txt", WRITE_MODE);
    if status /= open_ok then
        report "Failed to open file";
    else
        --while not(stop_clks = TRUE) loop
        while TRUE loop
            wait until stop_clks'transaction'event;
            if (stop_clks = TRUE) then
--                if stop_sim_on_fail then 
--                    a_test_has_failed := TRUE;  -- Force a fail assert when doing clk speed tests which are run with - 'stop_sim_on_fail = TRUE@
--                end if;
--                exit; 
                --When not doing DUT speed tests then exit loop here to prevent a rogue result line being printed into the result text file
                if not stop_sim_on_fail then 
                    exit; 
                end if;
            end if;
            if input_command_type = read_write_spi_cmd then
                if (((to_unsigned(rx_data_from_spi,DATA_SIZE)) and (to_unsigned(check_data_mask,DATA_SIZE))) = ((to_unsigned(check_data_from_spi,DATA_SIZE)) and (to_unsigned(check_data_mask,DATA_SIZE)))) then
                    rx_and_expected_same := TRUE;
                else
                    rx_and_expected_same := FALSE;
                end if;
    
                if not rx_and_expected_same then
                    WRITE (L, string'("ERROR "), left, 6);
                    a_test_has_failed := TRUE;
                else
                    WRITE (L, string'("PASS  "), left, 6);
                end if;
    
                WRITE (L, report_spi_access_type, left, 12);
    
                if board_select then
                    WRITE (L, string'("Board Select Address = "));
                    HWRITE (L, std_logic_vector(to_unsigned(board_sel_to_spi,SPI_BOARD_SEL_ADDR_BITS)), left, 10);
                    WRITE (L, string'("Address = "));
                    HWRITE (L, std_logic_vector(to_unsigned(address_to_spi,SPI_BOARD_SEL_PROTOCOL_ADDR_BITS)), left, 10);
                end if;
                if not board_select then --SPI_BOARD_SEL_PROTOCOL_ADDR_BITS
                    WRITE (L, string'("Address = "));
                    HWRITE (L, std_logic_vector(to_unsigned(address_to_spi,SPI_ADDRESS_BITS)), left, 10);
                end if;
                WRITE (L, string'("Write Data = "));
                HWRITE (L, std_logic_vector(to_unsigned(data_to_spi,SPI_DATA_BITS)), left, 10);
                WRITE (L, string'("Expected data = "));
                HWRITE (L, std_logic_vector(to_unsigned(check_data_from_spi,SPI_DATA_BITS)), left, 10);
                WRITE (L, string'("Read data = "));
                HWRITE (L, std_logic_vector(to_unsigned(rx_data_from_spi,SPI_DATA_BITS)), left, 10);
                WRITE (L, string'("Read mask = "));
                HWRITE (L, std_logic_vector(to_unsigned(check_data_mask,SPI_DATA_BITS)), left, 12);
                WRITE (L, string'("at time  "));
                WRITE (L, NOW, right, 16);
                WRITELINE (F, L);
            elsif input_command_type = read_port_cmd or input_command_type = write_port_cmd then
                if (input_command_type = write_port_cmd) then
                    WRITE (L, string'("PASS  "), left, 6);
                    WRITE (L, string'("Write Pins"), left, 12);
--                elsif (input_command_type = read_port_cmd) and (to_integer(unsigned(discrete_reg_map_array_to_script_s(address_of_port))) = data_of_port) then -- causes annoying - Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
                elsif (input_command_type = read_port_cmd) and (to_integer(unsigned(get_data(discrete_reg_map_array_to_script_s, address_of_port))) = data_of_port) then -- causes annoying - Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
                    WRITE (L, string'("PASS  "), left, 6);
                    WRITE (L, string'("Read Pins"), left, 12);
                else
                    WRITE (L, string'("ERROR "), left, 6);
                    WRITE (L, string'("Read Port"), left, 12);
                    a_test_has_failed := TRUE;
                end if;
    
                WRITE (L, string'("Address = "));
                HWRITE (L, std_logic_vector(to_unsigned(address_of_port,SPI_ADDRESS_BITS)), left, 10);
                WRITE (L, string'("Data = "));
                HWRITE (L, std_logic_vector(to_unsigned(data_of_port,SPI_DATA_BITS)), left, 10);

                if (input_command_type = read_port_cmd) then
                    WRITE (L, string'("Read data = "));
--                    HWRITE (L, std_logic_vector(to_unsigned(to_integer(unsigned(discrete_reg_map_array_to_script_s(address_of_port))), SPI_DATA_BITS)), left, 10); -- causes annoying - Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
                    HWRITE (L, std_logic_vector(to_unsigned(to_integer(unsigned(get_data(discrete_reg_map_array_to_script_s, address_of_port))), SPI_DATA_BITS)), left, 10); -- causes annoying - Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
                end if;

                WRITELINE (F, L);
            elsif input_command_type = print_comment_line then
                WRITE (L, string'("####"));
                WRITE (L, line_of_comments);
                WRITELINE (F, L);
            end if;
            --When DUT speed tests fail then exit loop here to allow the fail that caused the exit to be output into the results text file
            if stop_sim_on_fail and stop_clks then 
                exit; 
            end if;
        end loop;
            if a_test_has_failed then
                WRITE (L, string'("Error - There have been one or more ERRORS, search the text above for the word ERROR"));
            else
                WRITE (L, string'("Pass - All test completed with no fails"));
            end if;
            WRITELINE (F, L);
        FILE_CLOSE(F);
    end if;

    assert not a_test_has_failed                                                                     -- ...this to stop simulation in modelsim not as nice but effective (probably due to us using old modelsim version 6.6)
        report "Error - There have been one or more ERRORS" severity failure;
    assert a_test_has_failed                                                                     -- ...this to stop simulation in modelsim not as nice but effective (probably due to us using old modelsim version 6.6)
        report "Pass - All test completed with no fails" severity failure;
                                                                          -- Always stop simulator when al tests have completed - this works for ISIM but not modelsim and so use...
    wait;
end process;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
----------------these routines below are more diagnostics routine for testing full range of SPI rather than full specific module register map testing as the one above is----------.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.

--------------------------------------------------------.
--------------------------Inputs------------------------.
--------------------------------------------------------.
------------------------------Simple single write read to help show how testbench works------------------------------.
spi_write_and_then_read_gen : if DUT_TYPE = "write_and_then_read_an_address" generate
    main_control_proc : process
    begin
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;                                                         -- Auto increment when loop this routine to check lowest clk frequency DUT can run at and still work this SPI interface
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);                                  -- Ratio for getting delays in testbench correct when DUT clk frequency is slowed down by line above

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench;                                                     -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            --------Writing --------.
            address_to_spi <= 16#0#;
            data_to_spi <= 16#5555#;
            check_data_from_spi <= 16#5555#;
            check_data_mask <= 16#0000#; -- Don't tend to check data back from a write
            reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --------Reading --------.
            check_data_mask <= 16#FFFF#; -- Check data back from a read
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

------------------------------FINSHED SIMULATION------------------------------.
            stop_clks <= TRUE;                                                                  -- Always stop simulator when al tests have completed - this works for ISIM but not modelsim and so use...

    end process;
end generate spi_write_and_then_read_gen;



--------------------------------------------------------.
--------------------------Inputs------------------------.
--------------------------------------------------------.
------------------------------Multiple write and read routine with decreasing DUT clk frequency which will exit simulation when it eventually fails------------------------------.
spi_reg_map_test_simple_gen : if DUT_TYPE = "spi_reg_map_simple" generate
    main_control_proc : process
        variable slave_to_master_rx_match_latch_V : boolean := TRUE;
        variable slave_to_master_tx_match_latch_V : boolean := TRUE;
    begin

        while TRUE loop                                                                         -- Will loop forever unless failure detected due to increaseing DUT frequency
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench; -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            --------Writing loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                address_to_spi <= i;
                data_to_spi <= i+16#10#;                            -- tx data that will be checked
                check_data_mask <= 16#0000#; -- Don't tend to check data back from a write
                    reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
            end loop;
            wait for TIME_PERIOD_CLK*2000;                             -- Wait to show a big gap in simulation waveform
            
            --------Reading loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                address_to_spi <= i;
                data_to_spi <= 16#55#;                                                          -- random value just to show that data in has no effect during a read
                check_data_mask <= 16#FFFF#;
                check_data_from_spi <= i+16#10#;
                    reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
            end loop;
            
            --------Erasing loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                address_to_spi <= i;
                data_to_spi <= 0;
                check_data_mask <= 16#0000#; -- Don't tend to check data back from a write
                    reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
            end loop;

            wait for TIME_PERIOD_CLK*2000; -- Wait to show a big gap in simulation waveform
        
        end loop;

        wait;
    end process;
end generate spi_reg_map_test_simple_gen;


end behave;
