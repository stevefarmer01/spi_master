----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2016 15:14:34
-- Design Name: 
-- Module Name: spi_package - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package spi_package is

--.    constant DATA_SIZE : integer   := 13;
    constant SPI_ADDRESS_BITS : integer := 4;
    constant SPI_DATA_BITS : integer := 8;
    constant DATA_SIZE : integer   := SPI_ADDRESS_BITS+SPI_DATA_BITS+1; -- Total data size is address + data + read/write bit
   
    type input_data_type is array (integer range 0 to 15) of std_logic_vector(DATA_SIZE - 1 downto 0);
    constant input_data : input_data_type := (std_logic_vector(to_unsigned(2#0101010101010101#,DATA_SIZE)),
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

    type gdrb_ctrl_address_type is array (integer range 0 to (SPI_ADDRESS_BITS**2)-1) of std_logic_vector(SPI_DATA_BITS-1 downto 0);

    function initalise_gdrb_ctrl_data_array(data_start_value : natural ) return gdrb_ctrl_address_type;

    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type;

    procedure spi_main_test_loop (signal TIME_PERIOD_CLK : in time;
                                    signal sys_clk_i : in std_logic;
                                    signal spi_start_i : out std_logic;
                                    constant FIFO_REQ : in boolean := FALSE;
                                    constant input_data : in input_data_type;
                                    signal ss_i : in std_logic;
                                    signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                    signal wr_i : out std_logic;
                                    signal tx2tx_cycles_i : out std_logic_vector;
                                    signal rd_i : out std_logic;
                                    signal stop_clks : out boolean;
                                    signal dut_clk_ratio_to_testbench : integer;
                                    signal slave_to_master_rx_match_latch, master_rx_activity : in boolean;
                                    constant single_test_run_only : boolean
                                     );

end spi_package;

package body spi_package is

    function initalise_gdrb_ctrl_data_array(data_start_value : natural ) return gdrb_ctrl_address_type is
        variable gdrb_ctrl_data_array : gdrb_ctrl_address_type := (others => (others => '0'));
    begin
        for i in 0 to gdrb_ctrl_data_array'LEFT loop
            gdrb_ctrl_data_array(i) := std_logic_vector(to_unsigned(data_start_value+i,SPI_DATA_BITS));
        end loop;
        return gdrb_ctrl_data_array;
    end;

    constant gdrb_ctrl_data_array_initalise : gdrb_ctrl_address_type := initalise_gdrb_ctrl_data_array(0);

    procedure spi_main_test_loop (signal TIME_PERIOD_CLK : in time;
                                    signal sys_clk_i : in std_logic;
                                    signal spi_start_i : out std_logic;
                                    constant FIFO_REQ : in boolean := FALSE;
                                    constant input_data : in input_data_type;
                                    signal ss_i : in std_logic;
                                    signal data_i : out std_logic_vector(DATA_SIZE - 1 downto 0);
                                    signal wr_i : out std_logic;
                                    signal tx2tx_cycles_i : out std_logic_vector;
                                    signal rd_i : out std_logic;
                                    signal stop_clks : out boolean;
                                    signal dut_clk_ratio_to_testbench : integer;
                                    signal slave_to_master_rx_match_latch, master_rx_activity : in boolean;
                                    constant single_test_run_only : boolean
                                     ) is 
        variable tx2tx_cycles_v : std_logic_vector(tx2tx_cycles_i'RANGE);
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
    
            wait for TIME_PERIOD_CLK* 20 * dut_clk_ratio_to_testbench; -- Wait for sys_rst_i to propagate through DUT especially if DUT is running a much slower clock
    
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
    
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '1';     -- read data rx'd by master
                    wait until rising_edge(sys_clk_i);
                    rd_i        <= '0'; 
    
                    wait for to_integer(unsigned(tx2tx_cycles_v)) * TIME_PERIOD_CLK * dut_clk_ratio_to_testbench; -- wait tx to tx minimum period which is implemented in master's sclk_gen component
    
                ---end loop;
            end loop;
    --.        stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
            assert not slave_to_master_rx_match_latch = FALSE
                report "FAIL - Master SPI recieved different to expected" severity Note;
            assert not (slave_to_master_rx_match_latch = TRUE and master_rx_activity = TRUE)    -- Check for correct data back and that there has actually been some data received
                report "PASS - Master SPI recieved as expected" severity Note;
            if slave_to_master_rx_match_latch = FALSE or single_test_run_only then
                stop_clks <= TRUE;  ----------FINSHED SIMULATION----------.
                wait;
            end if;
    
    end procedure spi_main_test_loop;

end;
