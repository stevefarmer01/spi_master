---------------------------------------------------------------------------------------------------
---Next Tasks.....
---Report back pass/fail at end of sim
---Integrate register map
---Integrate text IO, maybe start with output rporting first
---Random seed testing option

--.        loop
--.
--. 
--.
--.            if endfile(cmdfile) then  -- Check EOF
--.
--.                assert false
--.
--.                    report "End of file encountered; exiting."
--.
--.                    severity NOTE;
--.
--.                exit;
--.
--.            end if;
--.
--. 
--.
--.            readline(cmdfile,line_in);     -- Read a line from the file
--.
--.            next when line_in'length = 0;  -- Skip empty lines

--.    --Set sizes of data and addresse as required for particular application
--.    constant SPI_ADDRESS_BITS : integer := 4;
--.    constant SPI_DATA_BITS : integer := 16;
--.    constant DATA_SIZE : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1;                             -- Total data size = read/write bit + address + data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.spi_package.ALL;
use work.spi_package_diagnostics.ALL;

use work.gdrb_ctrl_address_pkg.ALL;

entity spi_master_tb is
end spi_master_tb;

architecture behave of spi_master_tb is

    constant FIFO_REQ  : Boolean   := FALSE;

--.Test using  input file
    constant DUT_TYPE : string := "input_vector_file_test"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
    constant make_all_addresses_writeable_for_testing : boolean := FALSE;
--.Test actual register map
--.    constant DUT_TYPE : string := "gdrb_ctrl_reg_map_test"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
--.    constant make_all_addresses_writeable_for_testing : boolean := FALSE;
--.Simple read write as an example
--.    constant DUT_TYPE : string := "write_and_then_read_an_address"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board
--.    constant make_all_addresses_writeable_for_testing : boolean := TRUE;
--.Full write/read test with a decreasing sclk frequency to DUT to check what frequency th eSPI link will work down to
--.    constant DUT_TYPE : string := "spi_reg_map_simple"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
--.    constant make_all_addresses_writeable_for_testing : boolean := TRUE;

----------------these routines below are more diagnostics routine for initial designing of interface than an actual functional test and so shouldn't be run----------
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

component gdrb_ctrl_reg_map_top is
    generic ( make_all_addresses_writeable_for_testing : boolean := FALSE );
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
end component;

    signal stop_sim_on_fail : boolean := TRUE;
    signal report_spi_access_type : string(1 to 10);

    signal address_to_spi : natural := 0;
    signal data_to_spi : natural := 16#AA#;
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
--.    constant induce_fault_slave_tx_c : boolean := FALSE;

    signal TIME_PERIOD_CLK_S : time := 10 ns;
    signal TIME_PERIOD_CLK_DUT_S : time := 50 ns;
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

    signal discrete_reg_map_array_from_pins_s, discrete_reg_map_array_to_pins_s : gdrb_ctrl_address_type := (others => (others => '0'));


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
        
                        data_i      <= read_write_to_spi & std_logic_vector(to_unsigned(address_to_spi,SPI_ADDRESS_BITS)) & std_logic_vector(to_unsigned(data_to_spi,SPI_DATA_BITS)); -- send write data over SPI (just write all data to a fixed pattern and check it propergates thru array in reg map)
                        wr_i        <= '1';    -- write data enable tx to master
                        wait until rising_edge(sys_clk_i);
                        wr_i        <= '0';
        
                        wait until rising_edge(sys_clk_i);
                        spi_start_i <= '1';     -- start sending of master SPI tx
                        wait until rising_edge(sys_clk_i);
                        spi_start_i <= '0';
        
                        wait until ss_i = '1'; -- packet has finished when slave select goes low (this ia an active low enable)
    
                        wait for to_integer(unsigned(tx2tx_cycles_i)) * TIME_PERIOD_CLK * dut_clk_ratio_to_testbench; -- wait tx to tx minimum period which is implemented in master's sclk_gen component
    
                        rx_data_from_spi <= to_integer(unsigned(o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)))); -- rx data by master SPI
        
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
            --assert not (rx_data_from_spi /= check_data_from_spi)                                                                -- Check for correct data back and that there has actually been some data received
            assert not rx_and_expected_same                                                                -- Check for correct data back and that there has actually been some data received
                report "FAIL - Master SPI recieved different to expected" severity note;
            assert rx_and_expected_same                                                                  -- Check for correct data back and that there has actually been some data received
                report "PASS - Master SPI recieved as expected" severity note;
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
            
            --report_spi_access_type <= (others => ' ');
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
            
            --report_spi_access_type <= (others => ' ');
            report_spi_access_type <= "READ      ";

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

            --report_spi_access_type <= (others => ' ');
            report_spi_access_type <= "WRITE     ";

            check_result(rx_data_from_spi, stop_clks);

            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform

    end procedure reg_map_w_check;


--.    signal my_test_0, my_test_1 :natural := 0;
--.    signal my_test_01 :natural := 1;
--.    signal my_test_11 :natural := 0;
--.
--.    procedure my_test(
--.             signal my_test_1 : out natural -- declared in architecture and so only out parameters need declaring
--.        );
--.    procedure my_test(
--.             signal my_test_1 : out natural
--.        ) is
--.    begin
--.        my_test_1 <= my_test_0;
--.    end procedure ;



begin

--.my_proc : process
--.begin
--.    wait;
--.    my_test(my_test_1);
--.end process;
--.
--.my_proc1 : process
--.
--.    procedure my_test is -- declared in process and so only no parameters need declaring
--.    begin
--.        my_test_11 <= my_test_01;
--.    end procedure ;
--.
--.begin
--.    my_test;
--.    wait;
--.end process;


file_output_proc : process
    file F : text;
    variable L : line;
    variable status : file_open_status;
    variable rx_and_expected_same : boolean := FALSE;
    variable a_test_has_failed : boolean := FALSE;
begin
    FILE_OPEN(F, "..\..\..\output_test.txt", WRITE_MODE);
    if status /= open_ok then
        report "Failed to open file";
    else
        while not(stop_clks = TRUE) loop
            wait until stop_clks'transaction'event;
            if (stop_clks = TRUE) then exit; end if;

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

            WRITE (L, report_spi_access_type, left, 14);

            WRITE (L, string'("ADDRESS= "));
            HWRITE (L, std_logic_vector(to_unsigned(address_to_spi,SPI_ADDRESS_BITS)), left, 10);
            WRITE (L, string'("EXPECTED= "));
            HWRITE (L, std_logic_vector(to_unsigned(check_data_from_spi,SPI_DATA_BITS)), left, 10);
            WRITE (L, string'("MASKED= "));
            HWRITE (L, std_logic_vector(to_unsigned(check_data_mask,SPI_DATA_BITS)), left, 10);
            WRITE (L, string'("RECEIVED= "));
            HWRITE (L, std_logic_vector(to_unsigned(rx_data_from_spi,SPI_DATA_BITS)), left, 10);
            WRITE (L, string'("at time  "));
            WRITE (L, NOW, right, 16);
            WRITELINE (F, L);
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


--------------------------Register Map SPI DUT----------------------------
spi_reg_map_gen : if DUT_TYPE /= "spi_slave" generate

    reg_map_proc : gdrb_ctrl_reg_map_top
        generic map(
                make_all_addresses_writeable_for_testing => make_all_addresses_writeable_for_testing -- :     natural := 16
                )
        Port map(  
                clk => dut_sys_clk_i,                                                  -- : std_logic;
                reset => sys_rst_i,                                                    -- : std_logic;
                ---Slave SPI interface pins
                sclk => sclk_i,                                                        -- : in STD_LOGIC;
                ss_n => ss_i,                                                          -- : in STD_LOGIC;
                mosi => mosi_i,                                                        -- : in STD_LOGIC;
                miso => miso,                                                          -- : out STD_LOGIC;
                --Discrete signals
                discrete_reg_map_array_from_pins => discrete_reg_map_array_from_pins_s,-- : in gdrb_ctrl_address_type := (others => (others => '0'));
                discrete_reg_map_array_to_pins => discrete_reg_map_array_to_pins_s     -- : out gdrb_ctrl_address_type
                );

    discrete_reg_map_array_from_pins_s(to_integer(unsigned(SensorStatusAddr_addr_c))) <= std_logic_vector(to_unsigned(16#1#,SPI_DATA_BITS)); -- Read only --These have no constant value as they come from discrete pins


end generate spi_reg_map_gen;


--------------------------MASTER SPI DUT----------------------------

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


--.            address_to_spi <= 16#0#;
--.            data_to_spi <= 16#0#;
--.            check_data_from_spi <= 16#0#;
--.            check_data_mask <= 16#FFFF#; -- Check all bits back in rx reply
--.            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
    --signal rx_data_from_spi : natural;

--.            --------Writing --------.
--.            address_to_spi <= 16#0#;
--.            data_to_spi <= 16#5555#;
--.            check_data_from_spi <= 16#5555#;
--.            check_data_mask <= 16#0000#; -- Don't tend to check data back from a write
--.            reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

------------------------------Register Map tests using input file for vectors------------------------------.
input_vector_file_test_gen : if DUT_TYPE = "input_vector_file_test" generate

    file_input_proc : process
        file F : text;
        variable L : line;
        variable good : boolean;
        variable status : file_open_status;
        variable input_command_v : character;
--.        variable address_to_spi_v : natural := 0;
--.        variable data_to_spi_v : natural := 16#AA#;
--.        variable check_data_from_spi_v : natural := 16#AA#;
--.        variable check_data_mask_v : natural := (2**DATA_SIZE)-1; -- Default to all '1's so that all bits of the result are checked unless mask set otherwise by input testing parameters
        variable address_to_spi_v : natural := 0;
        variable data_to_spi_v : natural := 16#AA#;
        variable check_data_from_spi_v : natural := 16#AA#;
        variable check_data_mask_v : std_ulogic_vector(SPI_DATA_BITS - 1 downto 0) := (others => '1'); -- Default to all '1's so that all bits of the result are checked unless mask set otherwise by input testing parameters
    begin
        FILE_OPEN(status, F, "..\..\..\input_test.txt", READ_MODE);
        if status /= OPEN_OK then
            assert FALSE
                report "Failed to open file" severity failure;
        else
            stop_sim_on_fail <= FALSE;

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench;                                                     -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            while not ENDFILE(F) loop
                READLINE(F, L);
                wait for 10 ns;
                READ(L, input_command_v);
                READ(L, address_to_spi_v);
                READ(L, data_to_spi_v);
                READ(L, check_data_from_spi_v);
--                READ(L, check_data_mask_v, good);
                HREAD(L, check_data_mask_v, good);

--.            read(line_in,CI,good);     -- Read the CI input
--.

--.            assert good
--.
--.                report "Text I/O read error"
--.
--.                severity FAILURE;

 

                address_to_spi <= address_to_spi_v;
                data_to_spi <= data_to_spi_v;
                check_data_from_spi <= check_data_from_spi_v; 
--                check_data_mask <= ((check_data_mask_v));
                check_data_mask <= to_integer(unsigned(check_data_mask_v));


--.                address_to_spi <= 16#0000#;
--.                data_to_spi <= 16#0000#;
--.                check_data_from_spi <= 16#0000#; -- Don't tend to check data back from a write
--.                check_data_mask <= 16#0000#; -- Don't tend to check data back from a write

--            reg_map_w_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);
    
                wait for 10 ns;
            end loop;
            FILE_CLOSE(F);
        end if;
------------------------------FINSHED SIMULATION------------------------------.
        stop_clks <= TRUE;                                                                  -- Always stop simulator when all tests have completed
        wait;
    end process;

end generate input_vector_file_test_gen;


------------------------------Register Map specific test------------------------------.
gdrb_ctrl_reg_map_test_gen : if DUT_TYPE = "gdrb_ctrl_reg_map_test" generate

    stop_sim_on_fail <= FALSE;

    main_control_proc : process
    begin
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;                                                         -- Auto increment when loop this routine to check lowest clk frequency DUT can run at and still work this SPI interface
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);                                  -- Ratio for getting delays in testbench correct when DUT clk frequency is slowed down by line above

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench;                                                     -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            --Check initialised value
            address_to_spi <= 16#0#;
            data_to_spi <= 16#0#;
            check_data_from_spi <= 16#0#;
            check_data_mask <= 16#FFFF#; -- Check all bits back in rx reply
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check initialised value
            address_to_spi <= 16#1#;
            data_to_spi <= 16#0#;
            check_data_from_spi <= 16#1#;
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check initialised value
            address_to_spi <= 16#2#;
            data_to_spi <= 16#0#;
            check_data_from_spi <= 16#2#;
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check address can be written and read
            address_to_spi <= 16#0#;
            data_to_spi <= 16#AAAA#;
            check_data_from_spi <= 16#AAAA#;
            reg_map_rw_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check address can be written and read
            address_to_spi <= 16#2#;
            data_to_spi <= 16#5555#;
            check_data_from_spi <= 16#5555#;
            reg_map_rw_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check address can be written and read
            address_to_spi <= 16#3#;
            reg_map_rw_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            address_to_spi <= 16#5#;
            reg_map_rw_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);


            address_to_spi <= 16#A#;
            reg_map_rw_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check initialised value
            address_to_spi <= 16#B#;
            check_data_from_spi <= to_integer(unsigned(Position_c) & unsigned(VersionNo_c));
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

            --Check initialised value
            address_to_spi <= 16#C#;
            check_data_from_spi <= to_integer(unsigned(Day_c) & unsigned(Month_c) & unsigned(Year_c));
            reg_map_r_check(rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i, report_spi_access_type, stop_clks);

------------------------------FINSHED SIMULATION------------------------------.
        stop_clks <= TRUE;                                                                  -- Always stop simulator when all tests have completed
        wait;

    end process;
end generate gdrb_ctrl_reg_map_test_gen;



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
----------------these routines below are more diagnostics routine for testing full range of SPI rather than full specific module register map testing as the one above is----------.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
--------------------------Slave SPI DUT----------------------------.
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


--.------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
--.----------------these routines below are more diagnostics routine for initial designing of interface than an actual functional test and so shouldn't be run----------.
--.------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
--.--------------------------Slave SPI DUT----------------------------.
--.spi_master_gen : if DUT_TYPE = "spi_slave" generate
--.
--.    --.Induce fault to check test bench if desired
--.    data_i_slave_tx <= (data_i(data_i'HIGH downto 2) & "11") when induce_fault_slave_tx_c else data_i;
--.
--.    spi_slave_inst : spi_slave
--.        generic map(
--.            DATA_SIZE => DATA_SIZE)
--.        port map(
--.        i_sys_clk      => sys_clk_i,       -- : in  std_logic;                                               -- system clock
--.        i_sys_rst      => sys_rst_i,       -- : in  std_logic;                                               -- system reset
--.        i_csn          => '0',             -- : in  std_logic;                                               -- chip select for SPI master
--.        i_data         => data_i_slave_tx, -- : in  std_logic_vector(15 downto 0);                           -- Input data
--.        i_wr           => wr_i,            -- : in  std_logic;                                               -- Active Low Write, Active High Read
--.        i_rd           => '0',             -- : in  std_logic;                                               -- Active Low Write, Active High Read
--.        o_data      => o_data_slave,       -- o_data     : out std_logic_vector(15 downto 0);  --output data
--.        o_tx_ready  => open,               -- o_tx_ready : out std_logic;                                    -- Transmitter ready, can write another
--.        o_rx_ready  => o_rx_ready_slave,   -- o_rx_ready : out std_logic;                                    -- Receiver ready, can read data
--.        o_tx_error  => open,               -- o_tx_error : out std_logic;                                    -- Transmitter error
--.        o_rx_error  => open,               -- o_rx_error : out std_logic;                                    -- Receiver error
--.        ---i_cpol      => i_cpol,          -- i_cpol      : in std_logic;                                    -- CPOL value - 0 or 1
--.        ---i_cpha      => i_cpha,          -- i_cpha      : in std_logic;                                    -- CPHA value - 0 or 1
--.        ---i_lsb_first => i_lsb_first,     -- i_lsb_first : in std_logic;                                    -- lsb first when '1' /msb first when
--.        i_cpol         => '0',             -- : in  std_logic;                                               -- CPOL value - 0 or 1
--.        i_cpha         => '0',             -- : in  std_logic;                                               -- CPHA value - 0 or 1
--.        i_lsb_first    => '0',             -- : in  std_logic;                                               -- lsb first when '1' /msb first when
--.        i_ssn       => ss_i,               -- i_ssn  : in  std_logic;                                        -- Slave Slect Active low
--.        i_mosi      => mosi_i,             -- i_mosi : in  std_logic;                                        -- Slave input from Master
--.        o_miso      => miso,               -- o_miso : out std_logic;                                        -- Slave output to Master
--.        i_sclk      => sclk_i,             -- i_sclk : in  std_logic;                                        -- Clock from SPI Master
--.        o_tx_ack    => open,               -- o_tx_ack : out std_logic;
--.        o_tx_no_ack => open                -- o_tx_no_ack : out std_logic
--.            );
--.
--.    --.Instantaneous check if tx/rx values agree
--.    master_slave_match <= TRUE when data_i = o_data_slave else FALSE;
--.    --.Latch the failure if when rx ready goes high and tx/rx values don't agree
--.    latch_match_proc : process
--.    begin
--.        wait until o_rx_ready_slave = '1';
--.        if not (data_i = o_data_slave) then
--.            master_to_slave_rx_match_latch <= FALSE;
--.        else
--.            master_to_slave_rx_match_latch <= TRUE;
--.        end if;
--.    end process;
--.
--.end generate spi_master_gen;
--.
--.TIME_PERIOD_CLK_S <= TIME_PERIOD_CLK;
--.
--.spi_master_test_routine_gen : if DUT_TYPE = "spi_slave" generate
--.    main_control_proc : process
--.    begin
--.        while TRUE loop
--.            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
--.            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);
--.
--.                --.Proceedure for testing low level spi_slave.vhd - this only checks slave can receive, it doesn't check what it transmits back
--.                spi_main_test_loop (TIME_PERIOD_CLK => TIME_PERIOD_CLK_S, -- : in time;
--.                                                sys_clk_i => sys_clk_i, -- : in std_logic;
--.                                                spi_start_i => spi_start_i, -- : out std_logic;
--.                                                FIFO_REQ => FIFO_REQ, -- : in boolean := FALSE;
--.                                                input_data => input_data, -- : in input_data_type;
--.                                                ss_i => ss_i, -- : in std_logic;
--.                                                data_i => data_i, -- : out std_logic_vector(DATA_SIZE - 1 downto 0);
--.                                                wr_i => wr_i, -- : out std_logic;
--.                                                tx2tx_cycles_i => tx2tx_cycles_i, -- : out std_logic_vector;
--.                                                rd_i => rd_i, -- : out std_logic
--.                                                stop_clks => stop_clks, -- : out boolean
--.                                                dut_clk_ratio_to_testbench => dut_clk_ratio_to_testbench, -- : in boolean
--.                                                slave_to_master_rx_match_latch => slave_to_master_rx_match_latch, -- : in boolean
--.                                                master_rx_activity => master_rx_activity, -- : integer
--.                                                single_test_run_only => FALSE -- : boolean
--.                                                 ); 
--.
--.        end loop;
--.    end process;
--.end generate spi_master_test_routine_gen;
--.
--.
--.spi_reg_map_test_routine_gen : if DUT_TYPE = "spi_reg_map" generate
--.    main_control_proc : process
--.    begin
--.        while TRUE loop
--.            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
--.            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);
--.
--.                spi_main_test_loop_reg_map (TIME_PERIOD_CLK => TIME_PERIOD_CLK_S, -- : in time;
--.                                                sys_clk_i => sys_clk_i, -- : in std_logic;
--.                                                spi_start_i => spi_start_i, -- : out std_logic;
--.                                                FIFO_REQ => FIFO_REQ, -- : in boolean := FALSE;
--.                                                ss_i => ss_i, -- : in std_logic;
--.                                                data_i => data_i, -- : out std_logic_vector(DATA_SIZE - 1 downto 0);
--.                                                wr_i => wr_i, -- : out std_logic;
--.                                                tx2tx_cycles_i => tx2tx_cycles_i, -- : out std_logic_vector;
--.                                                rd_i => rd_i, -- : out std_logic
--.                                                stop_clks => stop_clks, -- : out boolean
--.                                                dut_clk_ratio_to_testbench => dut_clk_ratio_to_testbench, -- : in boolean
--.                                                --.slave_to_master_rx_match_latch => slave_to_master_rx_match_latch, -- : in boolean
--.                                                master_rx_activity => master_rx_activity, -- : integer
--.                                                o_data_master => o_data_master, -- : in std_logic_vector;
--.                                                slave_to_master_rx_match_latch => slave_to_master_rx_match_latch_result, -- : out boolean;
--.                                                slave_to_master_tx_match_latch => slave_to_master_tx_match_latch_result, -- : out boolean;
--.                                                single_test_run_only => FALSE, -- : boolean
--.                                                test_0 => test_0,
--.                                                test_1 => test_1
--.                                                 );
--.            ---Send reset to DUT as during transmitting to it this will write to it's internal reg map array and recieve test rely on it's power-on reset values 
--.            trigger_another_reset_s <= TRUE;
--.            wait for TIME_PERIOD_CLK;
--.            trigger_another_reset_s <= FALSE;
--.        end loop;
--.    end process;
--.end generate spi_reg_map_test_routine_gen;


end behave;
