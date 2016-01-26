---------------------------------------------------------------------------------------------------
---Next Tasks.....
---Report back pass/fail at end of sim
---Integrate register map
---Integrate text IO, maybe start with output rporting first
---Random seed testing option

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.spi_package.ALL;

entity spi_master_tb is
end spi_master_tb;

architecture behave of spi_master_tb is

    constant FIFO_REQ  : Boolean   := FALSE;
--    constant DUT_TYPE : string := "spi_slave"; -- Simple test of just the low level spi_slave.vhd
    constant DUT_TYPE : string := "spi_reg_map"; -- Test of a reg_map_spi_slave.vhd using the SPI protocol for cummunications between BegalBone(ARM) and GDRB board

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
    signal   tx2tx_cycles_i  : std_logic_vector(7 downto 0);  -- SPIM interval between data transactions in terms of i_sys_clk
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

--. from spi_package.vhd - for reference and so may be out of date
--.    constant SPI_ADDRESS_BITS : integer := 4;
--.    constant SPI_DATA_BITS : integer := 8;
--.    constant DATA_SIZE : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1; -- Total data size is address + data + read/write bit
--.    type gdrb_ctrl_address_type is array (integer range 0 to (SPI_ADDRESS_BITS**2)-1) of std_logic_vector(SPI_DATA_BITS-1 downto 0);

    procedure spi_main_test_loop_reg_map (signal TIME_PERIOD_CLK : in time;
                                    signal sys_clk_i : in std_logic;
                                    signal spi_start_i : out std_logic;
                                    constant FIFO_REQ : in boolean := FALSE;
                                    signal ss_i : in std_logic;
                                    signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                    signal wr_i : out std_logic;
                                    signal tx2tx_cycles_i : out std_logic_vector;
                                    signal rd_i : out std_logic;
                                    signal stop_clks : out boolean;
                                    signal dut_clk_ratio_to_testbench : integer;
                                    signal master_rx_activity : in boolean;
                                    signal o_data_master : in std_logic_vector;
                                    signal slave_to_master_rx_match_latch : out boolean;
                                    signal slave_to_master_tx_match_latch : out boolean;
                                    constant single_test_run_only : boolean;
                                    signal test_0, test_1 : out std_logic_vector
                                     );

    procedure spi_main_test_loop_reg_map (signal TIME_PERIOD_CLK : in time;
                                    signal sys_clk_i : in std_logic;
                                    signal spi_start_i : out std_logic;
                                    constant FIFO_REQ : in boolean := FALSE;
                                    signal ss_i : in std_logic;
                                    signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                    signal wr_i : out std_logic;
                                    signal tx2tx_cycles_i : out std_logic_vector;
                                    signal rd_i : out std_logic;
                                    signal stop_clks : out boolean;
                                    signal dut_clk_ratio_to_testbench : integer;
                                    signal master_rx_activity : in boolean;
                                    signal o_data_master : in std_logic_vector;
                                    signal slave_to_master_rx_match_latch : out boolean;
                                    signal slave_to_master_tx_match_latch : out boolean;
                                    constant single_test_run_only : boolean;
                                    signal test_0, test_1 : out std_logic_vector
                                     ) is 
        variable tx2tx_cycles_v : std_logic_vector(tx2tx_cycles_i'RANGE);
        variable slave_to_master_rx_match_latch_V : boolean := TRUE;
        variable slave_to_master_tx_match_latch_V : boolean := TRUE;
        constant read_write_bit_width : integer := 1;
    begin
    
            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench; -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
    
            --------Read only loop (reading initalised values of gdrb_ctrl_data_array_initalise array)--------.
            ---for j in 0 to 3 loop
            for j in gdrb_ctrl_data_array_initalise'RANGE loop
                ---cpol_i          <= four_data(j)(1);
                ---cpha_i          <= four_data(j)(0);
    
                wait until rising_edge(sys_clk_i);
                spi_start_i     <= '0';
    
                if FIFO_REQ = False then
                    data_i      <= '1' & std_logic_vector(to_unsigned(j,SPI_ADDRESS_BITS)) & std_logic_vector(to_unsigned(0,SPI_DATA_BITS)); -- dummy read/write bit, address, dummy write data
                    wr_i        <= '1'; -- write new packet for master to tx
                    wait until rising_edge(sys_clk_i);
                    wr_i        <= '0';
                end if;
    
    
                ---for i in 0 to 3 loop
                    ---clk_period_i   <= period_cycles(i);
                    ---setup_cycles_i <= delay_cycles(i);
                    ---hold_cycles_i  <= delay_cycles(i) + 7;
                    tx2tx_cycles_v := std_logic_vector(to_unsigned(16,tx2tx_cycles_i'LENGTH));
                    tx2tx_cycles_i <= tx2tx_cycles_v;
                    ---slave_addr_i   <= four_data(i);
                    ---lsb_first_i    <= four_data(i)(0);
                    ---wait until rising_edge(sys_clk_i);
    
    
                    wait until rising_edge(sys_clk_i);
                    spi_start_i <= '1';
    
                    wait until rising_edge(sys_clk_i);
                    spi_start_i <= '0';
    
                    wait until ss_i = '1'; -- packet has finished when slave select goes low (this ia an active low enable)

                    if j /= 0 then  -- Data received always one transmission behind that just transmitted due to nature of the way SPI works (data is sent at the same time it is being receieved)
                        if o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)) /= gdrb_ctrl_data_array_initalise(j-1) then -- Detect if rx data doesn't match data in reg map data_array
                            slave_to_master_rx_match_latch_V := FALSE;
                        end if;
                            test_0 <= o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1));
                            test_1 <= gdrb_ctrl_data_array_initalise(j-1);
                        slave_to_master_rx_match_latch <= slave_to_master_rx_match_latch_V;
                    end if;
    
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '1';     -- read data rx'd by master
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '0'; 
    
                    wait for to_integer(unsigned(tx2tx_cycles_v)) * TIME_PERIOD_CLK * dut_clk_ratio_to_testbench; -- wait tx to tx minimum period which is implemented in master's sclk_gen component
    
            end loop;
    
            --------Writing loop --------.
            ---for j in 0 to 3 loop
            for j in gdrb_ctrl_data_array_initalise'RANGE loop
                ---cpol_i          <= four_data(j)(1);
                ---cpha_i          <= four_data(j)(0);
    
                wait until rising_edge(sys_clk_i);
                spi_start_i     <= '0';
    
                if FIFO_REQ = False then
                    data_i      <= '0' & std_logic_vector(to_unsigned(j,SPI_ADDRESS_BITS)) & std_logic_vector(to_unsigned(16#FF#,SPI_DATA_BITS)); -- send write data over SPI (just write all data to a fixed pattern and check it propergates thru array in reg map)
                    wr_i        <= '1'; -- write new packet for master to tx
                    wait until rising_edge(sys_clk_i);
                    wr_i        <= '0';
                end if;
    
    
                ---for i in 0 to 3 loop
                    ---clk_period_i   <= period_cycles(i);
                    ---setup_cycles_i <= delay_cycles(i);
                    ---hold_cycles_i  <= delay_cycles(i) + 7;
                    tx2tx_cycles_v := std_logic_vector(to_unsigned(16,tx2tx_cycles_i'LENGTH));
                    tx2tx_cycles_i <= tx2tx_cycles_v;
                    ---slave_addr_i   <= four_data(i);
                    ---lsb_first_i    <= four_data(i)(0);
                    ---wait until rising_edge(sys_clk_i);
    
    
                    wait until rising_edge(sys_clk_i);
                    spi_start_i <= '1';
    
                    wait until rising_edge(sys_clk_i);
                    spi_start_i <= '0';
    
                    wait until ss_i = '1'; -- packet has finished when slave select goes low (this ia an active low enable)

                    wait for to_integer(unsigned(tx2tx_cycles_v)) * TIME_PERIOD_CLK * dut_clk_ratio_to_testbench; -- wait tx to tx minimum period which is implemented in master's sclk_gen component
    
                    if j /= 0 then  -- Data received always one transmission behind that just transmitted due to nature of the way SPI works (data is sent at the same time it is being receieved)
--.                        if std_logic_vector(to_unsigned(16#FF#,SPI_DATA_BITS)) /= gdrb_ctrl_data_array_initalise(j-1) then -- Detect if reg_map array was writen by previous write data sent over SPI---unable to do this because signal gdrb_ctrl_data_array_initalise is not global signal
--.                            slave_to_master_tx_match_latch_V := FALSE;
--.                        end if;
                        if std_logic_vector(to_unsigned(16#FF#,SPI_DATA_BITS)) /= o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1)) then -- Detect if rx data doesn't match data previous write data sent across SPI
                            slave_to_master_tx_match_latch_V := FALSE;
                        end if;
                            test_0 <= o_data_master(o_data_master'LEFT downto o_data_master'LEFT-(SPI_DATA_BITS-1));
                            test_1 <= gdrb_ctrl_data_array_initalise(j-1);
                        slave_to_master_tx_match_latch <= slave_to_master_tx_match_latch_V;
                        slave_to_master_rx_match_latch <= slave_to_master_rx_match_latch_V;
                    end if;
    
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '1';     -- read data rx'd by master
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '0'; 
    
            end loop;
            ---end loop;
    --.        stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
            assert not slave_to_master_rx_match_latch_V = FALSE
                report "FAIL - Master SPI recieved different to expected" severity Note;
            assert not slave_to_master_tx_match_latch_V = FALSE
                report "FAIL - Master SPI transmit error" severity Note;
            assert not master_rx_activity = FALSE
                report "FAIL - Master SPI has had no receive activity" severity Note;
            assert not (slave_to_master_rx_match_latch_V = TRUE and master_rx_activity = TRUE)    -- Check for correct data back and that there has actually been some data received
                report "PASS - Master SPI recieved as expected" severity Note;
            if slave_to_master_rx_match_latch_V = FALSE or slave_to_master_tx_match_latch_V = FALSE or single_test_run_only then
                stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
                wait;
            end if;
    
    end procedure spi_main_test_loop_reg_map;

begin

---reset and clocks
--sys_rst_i <= '0'           after 10 * TIME_PERIOD_CLK;

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
spi_reg_map_gen : if DUT_TYPE = "spi_reg_map" generate

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
            --.i_cpol         => cpol_i,         -- : in  std_logic;                                    -- CPOL value - 0 or 1
            --.i_cpha         => cpha_i,         -- : in  std_logic;                                    -- CPHA value - 0 or 1
            --.i_lsb_first    => lsb_first_i,    -- : in  std_logic;                                    -- lsb first when '1' /msb first when
            ---i_spi_start    => spi_start_i,    -- : in  std_logic;                                    -- START SPI Master Transactions
            ---i_clk_period   => clk_period_i,   -- : in  std_logic_vector(7 downto 0);                 -- SCL clock period in terms of i_sys_clk
            ---i_setup_cycles => setup_cycles_i, -- : in  std_logic_vector(7 downto 0);                 -- SPIM setup time  in terms of i_sys_clk
            ---i_hold_cycles  => hold_cycles_i,  -- : in  std_logic_vector(7 downto 0);                 -- SPIM hold time  in terms of i_sys_clk
            ---i_tx2tx_cycles => tx2tx_cycles_i, -- : in  std_logic_vector(7 downto 0);                 -- SPIM interval between data transactions in terms of i_sys_clk
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


--.    process
--.    begin
--.        for k in 0 to DATA_SIZE - 1 loop
--.            wait until rising_edge(spi_start_i );
--.            count        <= count + 1;
--.            slave_data_i <= input_data(count);
--.        end loop;  -- k
--.    end process;
--.
--.
--.    process
--.
--.    begin
--.        wait for 10 * TIME_PERIOD_CLK;
--.        cnt         := 0;
--.        wait until falling_edge(ss_i);
--.        miso_00_i <= '1';
--.        miso_01_i <= '1';
--.        miso_10_i <= '1';
--.        miso_11_i <= '1';
--.        if(cpol_i = '0') then
--.            if(cpha_i = '0') then
--.                cnt := DATA_SIZE - 1;
--.
--.                for i in DATA_SIZE - 1 downto 0 loop
--.                    if cnt >= 0 then
--.                        if(lsb_first_i = '1') then
--.                            miso_00_i <= slave_data_i(conv_integer(DATA_SIZE-cnt-1));
--.                        else
--.
--.                            miso_00_i <= slave_data_i(conv_integer(cnt));
--.                        end if;
--.                        wait until falling_edge(sclk_i);
--.                    end if;
--.
--.                    if cnt > 0 then
--.                        cnt := cnt - 1;
--.                    elsif cnt = 0 then
--.                        cnt := DATA_SIZE - 1;
--.                        miso_00_i <= '1';
--.                    end if;
--.
--.                end loop;
--.                if cnt = DATA_SIZE - 1 then
--.                    miso_00_i     <= '1';
--.                end if;
--.            else
--.                cnt     := 0;
--.                for i in DATA_SIZE - 1 downto 0 loop
--.                    wait until rising_edge(sclk_i);
--.                    if((lsb_first_i = '1')) then
--.                        miso_01_i <= slave_data_i(cnt);
--.                    else
--.                        miso_01_i <= slave_data_i(DATA_SIZE-cnt-1);
--.                    end if;
--.                    cnt := cnt+1;
--.                end loop;
--.
--.            end if;
--.        else
--.            if(cpha_i = '0') then
--.                cnt := 0;
--.                for i in DATA_SIZE - 1 downto 0 loop
--.                    if(lsb_first_i = '1') then
--.                        miso_10_i <= slave_data_i(cnt);
--.                    else
--.                        miso_10_i <= slave_data_i(DATA_SIZE-cnt-1);
--.                    end if;
--.
--.                    wait until rising_edge(sclk_i);
--.                    cnt := cnt+1;
--.                end loop;
--.
--.            else
--.                cnt     := 0;
--.                for i in DATA_SIZE - 1 downto 0 loop
--.                    wait until falling_edge(sclk_i);
--.                    if((lsb_first_i = '1')) then
--.                        miso_11_i <= slave_data_i(cnt);
--.                    else
--.                        miso_11_i <= slave_data_i(DATA_SIZE-cnt-1);
--.                    end if;
--.                    cnt := cnt+1;
--.                end loop;
--.
--.            end if;
--.        end if;
--.    end process;

--.    miso <= miso_00_i when (cpol_i = '0' and cpha_i = '0' and ss_i = '0') else
--.            miso_01_i when (cpol_i = '0' and cpha_i = '1' and ss_i = '0') else
--.            miso_10_i when (cpol_i = '1' and cpha_i = '0' and ss_i = '0') else
--.            miso_11_i when (cpol_i = '1' and cpha_i = '1' and ss_i = '0') else
--.            'Z';

end behave;
