---------------------------------------------------------------------------------------------------
---Next Tasks.....
---Report back pass/fail at end of sim
---Integrate register map
---Integrate text IO, maybe start with output rporting first
---Random seed testing option

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spi_package.ALL;
use work.spi_package_diagnostics.ALL;

entity spi_master_tb is
end spi_master_tb;

architecture behave of spi_master_tb is

    constant FIFO_REQ  : Boolean   := FALSE;
--    constant DUT_TYPE : string := "write_and_then_read_an_address"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board
    constant DUT_TYPE : string := "spi_reg_map_simple"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board unsing simple read write proceedures
----------------these routines below are more diagnostics routine for initial designing of interface than an actual functional test and so shouldn't be run----------
--    constant DUT_TYPE : string := "spi_slave"; -- Simple test of just the low level spi_slave.vhd
--    constant DUT_TYPE : string := "spi_reg_map"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board

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

component reg_map_spi_slave is
    generic(
        DATA_SIZE  :     natural := 16);
    Port (  
            clk : std_logic;
            reset : std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC);
end component;




    signal   sys_clk_i       : std_logic                     := '0';  -- system clock
    signal   sys_rst_i       : std_logic                     := '1';  -- system reset
    signal   csn_i           : std_logic                     := '1';  -- SPI Master chip select
    signal   data_i          : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');  -- Input data
    signal   slave_data_i    : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');  -- Input data
    signal   wr_i            : std_logic                     := '0';  -- Active Low Write, Active High Read
    signal   rd_i            : std_logic                     := '0';  -- Active Low Write, Active High Read
    signal   spim_data_i     : std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
    signal   spim_tx_ready_i : std_logic                     := '0';  -- Transmitter ready, can write another 
    signal   spim_rx_ready_i : std_logic                     := '0';  -- Receiver ready, can read data
    signal   spim_tx_error_i : std_logic                     := '0';  -- Transmitter error
    signal   spim_rx_error_i : std_logic                     := '0';  -- Receiver error
    signal   slave_addr_i    : std_logic_vector(1 downto 0)  := "00";  -- Slave Address
    signal   cpol_i          : std_logic                     := '0';  -- CPOL value - 0 or 1
    signal   cpha_i          : std_logic                     := '0';  -- CPHA value - 0 or 1 
    signal   lsb_first_i     : std_logic                     := '0';  -- lsb first when '1' /msb first when 
    signal   spi_start_i     : std_logic                     := '0';  -- START SPI Master Transactions
    signal   clk_period_i    : std_logic_vector(7 downto 0);  -- SCL clock period in terms of i_sys_clk
    signal   setup_cycles_i  : std_logic_vector(7 downto 0);  -- SPIM setup time  in terms of i_sys_clk
    signal   hold_cycles_i   : std_logic_vector(7 downto 0);  -- SPIM hold time  in terms of i_sys_clk
    signal   tx2tx_cycles_i  : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16,8));  -- SPIM interval between data transactions in terms of i_sys_clk
    signal   slave_csn_i     : std_logic_vector(3 downto 0);  -- SPI Slave select (chip select) active low
    signal   mosi_i          : std_logic                     := '0';  -- Master output to Slave
    signal   miso_00_i       : std_logic                     := '1';  -- Master input from Slave
    signal   miso_01_i       : std_logic                     := '1';  -- Master input from Slave
    signal   miso_10_i       : std_logic                     := '1';  -- Master input from Slave
    signal   miso_11_i       : std_logic                     := '1';  -- Master input from Slave
    signal   miso            : std_logic                     := '1';  -- Master input from Slave
    signal   sclk_i          : std_logic                     := '0';  -- Master clock
    signal   ss_i            : std_logic;  -- Master
    signal   count           : integer                       := 0;
    constant TIME_PERIOD_CLK : time                          := 10 ns;
    shared variable cnt      : integer                       := 0;
    type delay_type is array (integer range 0 to 3) of std_logic_vector(7 downto 0);
    type period_type is array (integer range 0 to 3) of std_logic_vector(7 downto 0);
    type four_values is array (integer range 0 to 3) of std_logic_vector(1 downto 0);

    signal input_data_s : input_data_type;

    constant period_cycles : delay_type  := ( "00000100", "00001000", "00010000", "00100000");
    constant delay_cycles  : delay_type  := ( "00000111", "00001110", "00011000", "00110000");
    constant four_data     : four_values := ( "00", "10", "01", "11");

    signal stop_clks : boolean := FALSE;

    signal o_data_slave, o_data_master, data_i_master_tx, data_i_slave_tx : std_logic_vector(DATA_SIZE - 1 downto 0); 
    signal master_slave_match, slave_master_match : boolean := FALSE;
    signal master_to_slave_rx_match_latch, slave_to_master_rx_match_latch : boolean := TRUE;
    signal o_rx_ready_slave, o_tx_ready_slave : std_logic := '0';
    constant induce_fault_master_tx_c : boolean := FALSE;
    constant induce_fault_slave_tx_c : boolean := FALSE;
    signal o_tx_ready_master, o_rx_ready_master : std_logic := '0';
    signal master_rx_activity : boolean := FALSE;

    signal TIME_PERIOD_CLK_DUT_S : time                          := 50 ns;
    signal dut_sys_clk_i : std_logic := '0';
    signal dut_clk_ratio_to_testbench : integer := integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);
    signal TIME_PERIOD_CLK_S : time := 10 ns;

    ---Array of data spanning entire address range declared and initialised in 'spi_package' has offset to make i's contents different from that held in DUT
    signal gdrb_ctrl_data_array_tb_s : gdrb_ctrl_address_type := gdrb_ctrl_data_array_initalise_offset;

    signal slave_to_master_rx_match_latch_result, slave_to_master_tx_match_latch_result : boolean;
    signal test_0, test_1 : std_logic_vector(7 downto 0);
    signal trigger_another_reset_s : boolean := FALSE;

    signal rx_data_from_spi : natural;

    procedure send_to_spi_master(
             constant read_write_to_spi : in std_logic;
             constant address_to_spi : in natural;
             constant data_to_spi : in natural;
             signal rx_data_from_spi : out natural;
             signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
             signal spi_start_i : out std_logic;
             signal wr_i : out std_logic;
             signal rd_i : out std_logic
         );
    
    procedure send_to_spi_master(
             constant read_write_to_spi : in std_logic;
             constant address_to_spi : in natural;
             constant data_to_spi : in natural;
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


--------------------------Slave SPI DUT----------------------------
spi_master_gen : if DUT_TYPE = "spi_slave" generate

    --.Induce fault to check test bench if desired
    data_i_slave_tx <= (data_i(data_i'HIGH downto 2) & "11") when induce_fault_slave_tx_c else data_i;

    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE)
        port map(
        i_sys_clk      => sys_clk_i,       -- : in  std_logic;                                               -- system clock
        i_sys_rst      => sys_rst_i,       -- : in  std_logic;                                               -- system reset
        i_csn          => '0',             -- : in  std_logic;                                               -- chip select for SPI master
        i_data         => data_i_slave_tx, -- : in  std_logic_vector(15 downto 0);                           -- Input data
        i_wr           => wr_i,            -- : in  std_logic;                                               -- Active Low Write, Active High Read
        i_rd           => '0',             -- : in  std_logic;                                               -- Active Low Write, Active High Read
        o_data      => o_data_slave,       -- o_data     : out std_logic_vector(15 downto 0);  --output data
        o_tx_ready  => open,               -- o_tx_ready : out std_logic;                                    -- Transmitter ready, can write another
        o_rx_ready  => o_rx_ready_slave,   -- o_rx_ready : out std_logic;                                    -- Receiver ready, can read data
        o_tx_error  => open,               -- o_tx_error : out std_logic;                                    -- Transmitter error
        o_rx_error  => open,               -- o_rx_error : out std_logic;                                    -- Receiver error
        ---i_cpol      => i_cpol,          -- i_cpol      : in std_logic;                                    -- CPOL value - 0 or 1
        ---i_cpha      => i_cpha,          -- i_cpha      : in std_logic;                                    -- CPHA value - 0 or 1
        ---i_lsb_first => i_lsb_first,     -- i_lsb_first : in std_logic;                                    -- lsb first when '1' /msb first when
        i_cpol         => '0',             -- : in  std_logic;                                               -- CPOL value - 0 or 1
        i_cpha         => '0',             -- : in  std_logic;                                               -- CPHA value - 0 or 1
        i_lsb_first    => '0',             -- : in  std_logic;                                               -- lsb first when '1' /msb first when
        i_ssn       => ss_i,               -- i_ssn  : in  std_logic;                                        -- Slave Slect Active low
        i_mosi      => mosi_i,             -- i_mosi : in  std_logic;                                        -- Slave input from Master
        o_miso      => miso,               -- o_miso : out std_logic;                                        -- Slave output to Master
        i_sclk      => sclk_i,             -- i_sclk : in  std_logic;                                        -- Clock from SPI Master
        o_tx_ack    => open,               -- o_tx_ack : out std_logic;
        o_tx_no_ack => open                -- o_tx_no_ack : out std_logic
            );

    --.Instantaneous check if tx/rx values agree
    master_slave_match <= TRUE when data_i = o_data_slave else FALSE;
    --.Latch the failure if when rx ready goes high and tx/rx values don't agree
    latch_match_proc : process
    begin
        wait until o_rx_ready_slave = '1';
        if not (data_i = o_data_slave) then
            master_to_slave_rx_match_latch <= FALSE;
        else
            master_to_slave_rx_match_latch <= TRUE;
        end if;
    end process;

end generate spi_master_gen;


    --------------------------Register Map SPI DUT----------------------------
spi_reg_map_gen : if DUT_TYPE /= "spi_slave" generate

    reg_map_proc : reg_map_spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE --  :     natural := 16
            )
        Port map(  
                clk => dut_sys_clk_i, -- : std_logic;
                reset => sys_rst_i, -- : std_logic;
                ---Slave SPI interface pins
                sclk => sclk_i, -- : in STD_LOGIC;
                ss_n => ss_i, -- : in STD_LOGIC;
                mosi => mosi_i, -- : in STD_LOGIC;
                miso => miso -- : out STD_LOGIC
                );

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
            i_setup_cycles => "00000111",        -- : in  std_logic_vector(7 downto 0);                 -- SPIM setup time  in terms of i_sys_clk
            i_hold_cycles  => "00000111",        -- : in  std_logic_vector(7 downto 0);                 -- SPIM hold time  in terms of i_sys_clk
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


TIME_PERIOD_CLK_S <= TIME_PERIOD_CLK;

------------------------------Multiple write and read routine with decreasing DUT clk frequency which will exit simulation when it fail------------------------------.
spi_reg_map_test_simple_gen : if DUT_TYPE = "spi_reg_map_simple" generate
    main_control_proc : process
        variable slave_to_master_rx_match_latch_V : boolean := TRUE;
        variable slave_to_master_tx_match_latch_V : boolean := TRUE;
        variable tx_address_to_spi : natural := 0;
        variable tx_data_to_spi : natural := 0;
    begin
        while TRUE loop -- Will loop forever unless failure detected due to increaseing DUT frequency
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench; -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            --------Writing loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                tx_address_to_spi := i;
                tx_data_to_spi := i+16#10#;
                    send_to_spi_master('0', tx_address_to_spi, tx_data_to_spi, rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i);
            end loop;
            wait for TIME_PERIOD_CLK*2000;                             -- Wait to show a big gap in simulation waveform
            
            --------Reading loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                tx_address_to_spi := i;
                tx_data_to_spi := 16#55#;                                                          -- random value just to show that data in has no effect during a read
                for j in 0 to 1 loop                                                               -- need to send 2 packets to perform a read on SPI
                    send_to_spi_master('1', tx_address_to_spi, tx_data_to_spi, rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i);
                end loop;
                if rx_data_from_spi /= i+16#10# then
                    slave_to_master_rx_match_latch_V := FALSE;
                end if;
                assert not slave_to_master_rx_match_latch_V = FALSE
                    report "FAIL - Master SPI recieved different to expected" severity Note;
                assert not slave_to_master_tx_match_latch_V = FALSE
                    report "FAIL - Master SPI transmit error" severity Note;
                assert not master_rx_activity = FALSE
                    report "FAIL - Master SPI has had no receive activity" severity Note;
                assert not (slave_to_master_rx_match_latch_V = TRUE and master_rx_activity = TRUE) -- Check for correct data back and that there has actually been some data received
                    report "PASS - Master SPI recieved as expected" severity Note;
                if slave_to_master_rx_match_latch_V = FALSE or slave_to_master_tx_match_latch_V = FALSE then
                    stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
                    wait;
                end if;
            end loop;
            
            --------Erasing loop --------.
            for i in 0 to (SPI_ADDRESS_BITS**2)-1 loop
                tx_address_to_spi := i;
                tx_data_to_spi := 0;
                    send_to_spi_master('0', tx_address_to_spi, tx_data_to_spi, rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i);
            end loop;
            wait for TIME_PERIOD_CLK*2000; -- Wait to show a big gap in simulation waveform
        
        end loop;
        stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
        wait;
    end process;
end generate spi_reg_map_test_simple_gen;

------------------------------Simple single write read to help show how testbench works------------------------------.
spi_write_and_then_read_gen : if DUT_TYPE = "write_and_then_read_an_address" generate
    main_control_proc : process
        variable tx_address_to_spi : natural := 0;
        variable tx_data_to_spi : natural := 16#AA#;
    begin
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;                                                         -- Auto increment when loop this routine to check lowest clk frequency DUT can run at and still work this SPI interface
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);                                  -- Ratio for getting delays in testbench correct when DUT clk frequency is slowed down by line above

            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench;                                                     -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
            
            --------Writing loop --------.
            --tx_address_to_spi := 0;
            --tx_data_to_spi := 16#AA#;
            send_to_spi_master('0', tx_address_to_spi, tx_data_to_spi, rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a write
            
            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform
            
            --------Reading loop --------.
            --tx_address_to_spi := 0;
            --tx_data_to_spi := 16#00#;                                                                                    -- random value just to show that data in has no effect during a read
            for j in 0 to 1 loop                                                                                           -- need to send 2 packets to perform a read on SPI
            send_to_spi_master('1', tx_address_to_spi, tx_data_to_spi, rx_data_from_spi, data_i, spi_start_i, wr_i, rd_i); -- Do a read (twice due to nature of SPI interface)
            end loop;
            
            wait for TIME_PERIOD_CLK*2000;                                                                                 -- Wait to show a big gap in simulation waveform
        
            assert not (rx_data_from_spi /= tx_data_to_spi)                                                                -- Check for correct data back and that there has actually been some data received
                report "FAIL - Master SPI recieved different to expected" severity Note;
            assert not (rx_data_from_spi = tx_data_to_spi)                                                                 -- Check for correct data back and that there has actually been some data received
                report "PASS - Master SPI recieved as expected" severity Note;
        stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
        wait;
    end process;
end generate spi_write_and_then_read_gen;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------these routines below are more diagnostics routine for initial designing of interface than an actual functional test and so shouldn't be run----------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
spi_master_test_routine_gen : if DUT_TYPE = "spi_slave" generate
    main_control_proc : process
    begin
        while TRUE loop
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);

                --.Proceedure for testing low level spi_slave.vhd
                spi_main_test_loop (TIME_PERIOD_CLK => TIME_PERIOD_CLK_S, -- : in time;
                                                sys_clk_i => sys_clk_i, -- : in std_logic;
                                                spi_start_i => spi_start_i, -- : out std_logic;
                                                FIFO_REQ => FIFO_REQ, -- : in boolean := FALSE;
                                                input_data => input_data, -- : in input_data_type;
                                                ss_i => ss_i, -- : in std_logic;
                                                data_i => data_i, -- : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                                wr_i => wr_i, -- : out std_logic;
                                                tx2tx_cycles_i => tx2tx_cycles_i, -- : out std_logic_vector;
                                                rd_i => rd_i, -- : out std_logic
                                                stop_clks => stop_clks, -- : out boolean
                                                dut_clk_ratio_to_testbench => dut_clk_ratio_to_testbench, -- : in boolean
                                                slave_to_master_rx_match_latch => slave_to_master_rx_match_latch, -- : in boolean
                                                master_rx_activity => master_rx_activity, -- : integer
                                                single_test_run_only => FALSE -- : boolean
                                                 ); 

        end loop;
    end process;
end generate spi_master_test_routine_gen;


spi_reg_map_test_routine_gen : if DUT_TYPE = "spi_reg_map" generate
    main_control_proc : process
    begin
        while TRUE loop
            TIME_PERIOD_CLK_DUT_S <= TIME_PERIOD_CLK_DUT_S + 1 ns;
            dut_clk_ratio_to_testbench <= integer(TIME_PERIOD_CLK_DUT_S/TIME_PERIOD_CLK);

                spi_main_test_loop_reg_map (TIME_PERIOD_CLK => TIME_PERIOD_CLK_S, -- : in time;
                                                sys_clk_i => sys_clk_i, -- : in std_logic;
                                                spi_start_i => spi_start_i, -- : out std_logic;
                                                FIFO_REQ => FIFO_REQ, -- : in boolean := FALSE;
                                                ss_i => ss_i, -- : in std_logic;
                                                data_i => data_i, -- : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                                wr_i => wr_i, -- : out std_logic;
                                                tx2tx_cycles_i => tx2tx_cycles_i, -- : out std_logic_vector;
                                                rd_i => rd_i, -- : out std_logic
                                                stop_clks => stop_clks, -- : out boolean
                                                dut_clk_ratio_to_testbench => dut_clk_ratio_to_testbench, -- : in boolean
                                                --.slave_to_master_rx_match_latch => slave_to_master_rx_match_latch, -- : in boolean
                                                master_rx_activity => master_rx_activity, -- : integer
                                                o_data_master => o_data_master, -- : in std_logic_vector;
                                                slave_to_master_rx_match_latch => slave_to_master_rx_match_latch_result, -- : out boolean;
                                                slave_to_master_tx_match_latch => slave_to_master_tx_match_latch_result, -- : out boolean;
                                                single_test_run_only => FALSE, -- : boolean
                                                test_0 => test_0,
                                                test_1 => test_1
                                                 );
            ---Send reset to DUT as during transmitting to it this will write to it's internal reg map array and recieve test rely on it's power-on reset values 
            trigger_another_reset_s <= TRUE;
            wait for TIME_PERIOD_CLK;
            trigger_another_reset_s <= FALSE;
        end loop;
    end process;
end generate spi_reg_map_test_routine_gen;


end behave;
