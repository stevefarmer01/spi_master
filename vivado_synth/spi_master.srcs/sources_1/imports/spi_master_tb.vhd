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

entity spi_master_tb is
end spi_master_tb;

architecture behave of spi_master_tb is

    constant DATA_SIZE : integer   := 22;
    constant FIFO_REQ  : Boolean   := FALSE;

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
    type input_data_type is array (integer range 0 to 15) of std_logic_vector(DATA_SIZE - 1 downto 0);
    type delay_type is array (integer range 0 to 3) of std_logic_vector(7 downto 0);
    type period_type is array (integer range 0 to 3) of std_logic_vector(7 downto 0);
    type four_values is array (integer range 0 to 3) of std_logic_vector(1 downto 0);

    constant input_data : input_data_type := (std_logic_vector(to_unsigned(2#1111111111111111#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0000000000000001#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1000000000000000#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111111111111111#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0010101010101010#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0100110011001101#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111000011111111#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111111111111110#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0111111111110000#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0000111111110001#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111111111111111#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1000000000000000#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#0010101010101010#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111111111111111#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111000011100000#,DATA_SIZE)),
                                              std_logic_vector(to_unsigned(2#1111111111111110#,DATA_SIZE))
                                              );

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


begin

---reset and clocks
sys_rst_i <= '0'           after 10 * TIME_PERIOD_CLK;

clk_gen_proc : process
begin
    while not stop_clks loop
        wait for TIME_PERIOD_CLK/2;
        sys_clk_i <= not sys_clk_i;
    end loop;
    wait;
end process;


--.Induce fault to check test bench if desired
data_i_master_tx <= (data_i(data_i'HIGH downto 1) & '1') when induce_fault_master_tx_c else data_i;
--.Instantaneous check if tx/rx values agree
master_slave_match <= TRUE when data_i = o_data_slave else FALSE;
--.Latch the failure if when rx ready goes high and tx/rx values don't agree
latch_match_proc : process
begin
    wait until o_rx_ready_slave = '1';
    if not (data_i = o_data_slave) then
        master_to_slave_rx_match_latch <= FALSE;
    end if;
end process;

--------------------------Slave SPI DUT----------------------------
    spi_slave_inst : spi_slave
        generic map(
            DATA_SIZE => DATA_SIZE)
        port map(
        i_sys_clk      => sys_clk_i,       -- : in  std_logic;                                               -- system clock
        i_sys_rst      => sys_rst_i,       -- : in  std_logic;                                               -- system reset
        i_csn          => '0',             -- : in  std_logic;                                               -- chip select for SPI master
        i_data         => data_i_slave_tx, -- : in  std_logic_vector(15 downto 0);                           -- Input data
        i_wr           => wr_i,            -- : in  std_logic;                                               -- Active Low Write, Active High Read
        i_rd           => rd_i,            -- : in  std_logic;                                               -- Active Low Write, Active High Read
        o_data      => o_data_slave,       -- o_data     : out std_logic_vector(15 downto 0);  --output data
        o_tx_ready  => o_tx_ready_slave,   -- o_tx_ready : out std_logic;                                    -- Transmitter ready, can write another
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

--.Induce fault to check test bench if desired
data_i_slave_tx <= (data_i(data_i'HIGH downto 2) & "11") when induce_fault_slave_tx_c else data_i;
--.Instantaneous check if tx/rx values agree
slave_master_match <= TRUE when data_i = o_data_master else FALSE;
--.Latch the failure if when rx ready goes high and tx/rx values don't agree
latch_match_2_proc : process
begin
    wait until o_rx_ready_master = '1';
    if not (data_i = o_data_master) then
        slave_to_master_rx_match_latch <= FALSE;
    end if;
end process;

--------------------------MASTER SPI DUT----------------------------
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

    ss_i <= slave_csn_i(0) and slave_csn_i(1) and slave_csn_i(2) and slave_csn_i(3);


    main_control_proc : process
    begin
--.        wait for 100 * TIME_PERIOD_CLK;
--.        if FIFO_REQ = True then
--.            wr_i       <= '1';
--.            csn_i      <= '0';
--.            for i in 0 to 15 loop
--.                wait until rising_edge(sys_clk_i);
--.                data_i <= input_data(i);
--.            end loop;
--.            wr_i       <= '0';
--.            csn_i      <= '1';
--.        end if;

        wait for TIME_PERIOD_CLK*20; -- Wait for sys_rst_i to propagate through DUT

        ---for j in 0 to 3 loop
        for j in input_data_type'RANGE loop
            ---cpol_i          <= four_data(j)(1);
            ---cpha_i          <= four_data(j)(0);

            wait until rising_edge(sys_clk_i);
            spi_start_i     <= '0';

            if FIFO_REQ = False then
                data_i      <= input_data(j);
                wr_i        <= '1'; -- write new packet for master to tx
                wait until rising_edge(sys_clk_i);
                wr_i        <= '0';
            end if;


            ---for i in 0 to 3 loop
                ---clk_period_i   <= period_cycles(i);
                ---setup_cycles_i <= delay_cycles(i);
                ---hold_cycles_i  <= delay_cycles(i) + 7;
                tx2tx_cycles_i <= std_logic_vector(to_unsigned(16,tx2tx_cycles_i'LENGTH));
                ---slave_addr_i   <= four_data(i);
                ---lsb_first_i    <= four_data(i)(0);
                ---wait until rising_edge(sys_clk_i);


                wait until rising_edge(sys_clk_i);
                spi_start_i <= '1';

                wait until rising_edge(sys_clk_i);
                spi_start_i <= '0';

                wait until ss_i = '1'; -- packet has finished when slave select goes low (this ia an active low enable)

                wait until rising_edge(sys_clk_i);
                rd_i        <= '1';     -- read data rx'd by master
                wait until rising_edge(sys_clk_i);
                rd_i        <= '0'; 

                wait for to_integer(unsigned(tx2tx_cycles_i)) * TIME_PERIOD_CLK; -- wait tx to tx minimum period which is implemented in master's sclk_gen component

            ---end loop;
        end loop;
        stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
        wait;
    end process;

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
