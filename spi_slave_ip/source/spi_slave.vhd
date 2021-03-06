

--   ==================================================================
--   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
--   ------------------------------------------------------------------
--   Copyright (c) 2013 by Lattice Semiconductor Corporation
--   ALL RIGHTS RESERVED 
--   ------------------------------------------------------------------
--
--   Permission:
--
--      Lattice SG Pte. Ltd. grants permission to use this code
--      pursuant to the terms of the Lattice Reference Design License Agreement. 
--
--
--   Disclaimer:
--
--      This VHDL or Verilog source code is intended as a design reference
--      which illustrates how these types of functions can be implemented.
--      It is the user's responsibility to verify their design for
--      consistency and functionality through the use of formal
--      verification methods.  Lattice provides no warranty
--      regarding the use or functionality of this code.
--
--   --------------------------------------------------------------------
--
--                  Lattice SG Pte. Ltd.
--                  101 Thomson Road, United Square #07-02 
--                  Singapore 307591
--
--
--                  TEL: 1-800-Lattice (USA and Canada)
--                       +65-6631-2000 (Singapore)
--                       +1-503-268-8001 (other locations)
--
--                  web: http://www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------------

---Modified so that any size 'DATA_SIZE' accepted instead of just 8 or 16, updated testbench 'spi_slave_tb.vhd' - SFarmer 20 Jan 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spi_slave is
    generic(
            DATA_SIZE  :     natural := 16;
            make_rx_data_happen_at_ss_n_high_edge : boolean := FALSE     -- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
            );
    port (
        i_sys_clk  : in  std_logic;  	-- system clock
        i_sys_rst  : in  std_logic;  	-- system reset
        i_csn      : in  std_logic;  	-- Slave Enable/select
        i_data     : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Input data
        i_wr       : in  std_logic;  	-- Active Low Write, Active High Read
        i_rd       : in  std_logic;  	-- Active Low Write, Active High Read
        o_data     : out std_logic_vector(DATA_SIZE - 1 downto 0);  --output data
        o_tx_ready : out std_logic;  	-- Transmitter ready, can write another 
  					-- data
        o_rx_ready : out std_logic;  	-- Receiver ready, can read data - this does not reset when i_wr asserted only when i_ssn goes low (new word coming from master)
        o_tx_error : out std_logic;  	-- Transmitter error
        o_rx_error : out std_logic;  	-- Receiver error

        i_cpol      : in std_logic;  	-- CPOL value - 0 or 1
        i_cpha      : in std_logic;  	-- CPHA value - 0 or 1 
        i_lsb_first : in std_logic;  	-- lsb first when '1' /msb first when 
  					-- '0'

        o_miso      : out std_logic;  	-- Slave output to Master
        i_mosi      : in  std_logic;  	-- Slave input from Master
        i_ssn       : in  std_logic;    -- Slave Slect Active low
        i_raw_ssn   : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
        i_sclk      : in  std_logic;  	-- Clock from SPI Master
        miso_tri_en : out std_logic;
	o_tx_ack    : out std_logic;
	o_tx_no_ack : out std_logic
        );

end spi_slave;

architecture rtl_arch of spi_slave is

    component edge_detect_domain_crossed is
        Port ( clk : in std_logic;
               signal_to_detect : in std_logic;
               signal_out : out std_logic;
               rising_edge_detected : out std_logic;
               falling_edge_detected : out std_logic
             );
    end component;

    signal data_in_reg_i            : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal rxdata_reg_i             : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal txdata_reg_i             : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal rx_shift_data_pos_sclk_i : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal rx_shift_data_neg_sclk_i : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');

    signal tx_error_i : std_logic := '0';
    signal rx_error_i : std_logic := '0';
    signal tx_ready_i : std_logic := '0';
    signal rx_ready_i : std_logic := '1'; -- Initialise this to 1 otherwise a rouge wrte of zero to address zero will happen from start-up

    signal miso_00_i, miso_01_i, miso_10_i, miso_11_i : std_logic := '0';

    signal rx_done_pos_sclk_i, rx_done_neg_sclk_i, rx_done_reg1_i, rx_done_reg2_i, rx_done_reg3_i : std_logic := '1';
    signal tx_done_pos_sclk_i, tx_done_neg_sclk_i, tx_done_reg1_i, tx_done_reg2_i, tx_done_reg3_i : std_logic := '0';
    signal rx_data_count_pos_sclk_i                                                               : std_logic_vector(5 downto 0) := (others => '0');
    signal rx_data_count_neg_sclk_i                                                               : std_logic_vector(5 downto 0) := (others => '0');
    signal tx_data_count_pos_sclk_i                                                               : std_logic_vector(5 downto 0) := (others => '0');
    signal tx_data_count_neg_sclk_i                                                               : std_logic_vector(5 downto 0) := (others => '0');

    signal data_valid_i : std_logic := '0';
    signal tx_done_pulse_i : std_logic := '0';
    signal tx_error_reg_1_i : std_logic := '0';
    signal rx_error_reg_1_i : std_logic := '0';
    signal i_sclk_rising_edge_s, i_sclk_falling_edge_s : std_logic := '0';

    signal i_ssn_rising_edge_s, i_ssn_falling_edge_s : std_logic := '0';
    signal i_ssn_s : std_logic := '0';

begin

    o_tx_ready                <= tx_ready_i;
    o_rx_ready                <= rx_ready_i;
    o_tx_error                <= tx_error_i and (not tx_error_reg_1_i);
    o_rx_error                <= rx_error_i and (not rx_error_reg_1_i);

    --Domain cross and edge detect incoming SPI sckl
    i_sclk_edge_detect : edge_detect_domain_crossed
        Port map ( 
               clk => i_sys_clk,                              -- : in std_logic;
               signal_to_detect => i_sclk,                    -- : in std_logic;
               rising_edge_detected => i_sclk_rising_edge_s,  -- : out std_logic;
               falling_edge_detected => i_sclk_falling_edge_s -- : out std_logic
             );

-- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
gen_ss_n_high : if make_rx_data_happen_at_ss_n_high_edge generate
        i_ssn_edge_detect : edge_detect_domain_crossed
            Port map(
                   clk => i_sys_clk,                             -- : in std_logic;
                   signal_to_detect => i_ssn,                    -- : in std_logic;
                   signal_out => i_ssn_s,                        -- : out std_logic;
                   rising_edge_detected => i_ssn_rising_edge_s,  -- : out std_logic;
                   falling_edge_detected => i_ssn_falling_edge_s -- : out std_logic
                 );
end generate gen_ss_n_high;

-- When set to FALSE SPI rx data will be valid when all required bits have been recieved
gen_not_ss_n_high : if not make_rx_data_happen_at_ss_n_high_edge generate
        i_ssn_s <= i_ssn;
end generate gen_not_ss_n_high;


----------------------------------------------------------------------------------------------------
-- Data input latch process
-- Latched only when slave enabled, Transmitter ready and wr is high.
----------------------------------------------------------------------------------------------------
    
--    g1: if DATA_SIZE = 8 generate
--	o_data(15 downto 8) <= (others => '0');
--	o_data(7 downto 0) <= rxdata_reg_i;
--	 process(i_sys_clk, i_sys_rst)
--    begin
--        if(i_sys_rst = '1') then
--            data_in_reg_i     <= (others => '0');
--        elsif rising_edge(i_sys_clk) then
--            if (i_wr = '1' and i_csn = '0' and tx_ready_i = '1') then
--                data_in_reg_i <= i_data(7 downto 0);
--            end if;
--        end if;
--    end process;
--    end generate g1;
    
	o_data(DATA_SIZE-1 downto 0) <= rxdata_reg_i(DATA_SIZE-1 downto 0);
	process(i_sys_clk, i_sys_rst)
        variable wr_v0 : std_logic := '0';
    begin
        if(i_sys_rst = '1') then
            data_in_reg_i     <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            if (i_wr = '1' and tx_ready_i = '1' and i_csn = '0') or (wr_v0 = '0' and i_wr = '1' and i_csn = '0') then
                data_in_reg_i(DATA_SIZE-1 downto 0) <= i_data(DATA_SIZE-1 downto 0);
            end if;
            wr_v0 := i_wr;
        end if;
    end process;
    
    miso_tri_en               <= i_ssn_s;

----------------------------------------------------------------------------------------------------
-- Receive Data Register, mux it based on sampling
-- Data latched based on Rx Done signal
----------------------------------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if(i_sys_rst = '1') then
            rxdata_reg_i         <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            if (rx_done_reg1_i = '1' and rx_done_reg2_i = '0') then
                if ((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1')) then
                    rxdata_reg_i <= rx_shift_data_pos_sclk_i;
                else
                    rxdata_reg_i <= rx_shift_data_neg_sclk_i;
                end if;
            end if;
        end if;
    end process;

---------------------------------------------------------------------------------------------------
-- Re-register data to be transmitted
----------------------------------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if(i_sys_rst = '1') then
            txdata_reg_i <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            txdata_reg_i <= data_in_reg_i;
        end if;
    end process;

----------------------------------------------------------------------------
-- SPI Slave Receiver Section  		---------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--- MOSI Sampling : Sample at posedge of SCLK for 
--                  1. i_cpol=0 and i_cpha=0 
--                  2. i_cpol=1 and i_cpha=1 
----------------------------------------------------------------------------

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_shift_data_pos_sclk_i         <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            if i_sclk_rising_edge_s = '1' then
                if (i_ssn_s = '0' and ((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1'))) then
                    if (i_lsb_first = '1') then
                        rx_shift_data_pos_sclk_i <= i_mosi & rx_shift_data_pos_sclk_i(DATA_SIZE-1 downto 1);
                    else
                        rx_shift_data_pos_sclk_i <= rx_shift_data_pos_sclk_i(DATA_SIZE-2 downto 0) & i_mosi;
                    end if;
                end if;
            end if;
        end if;
    end process;

-- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
gen_ss_n_high_0 : if make_rx_data_happen_at_ss_n_high_edge generate
        process(i_sys_clk, i_sys_rst)
        begin
            if (i_sys_rst = '1') then
                rx_data_count_pos_sclk_i         <= (others => '0');
                rx_done_pos_sclk_i               <= '1';
            elsif rising_edge(i_sys_clk) then
                if i_ssn_rising_edge_s = '1' then
                    rx_data_count_pos_sclk_i <= (others => '0');
                    rx_done_pos_sclk_i       <= '1';
                else
                    if i_sclk_rising_edge_s = '1' then
                        if (i_ssn_s = '0' and ((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1'))) then
                            if (i_ssn_s = '0') then
                                rx_data_count_pos_sclk_i <= rx_data_count_pos_sclk_i + 1;
                                rx_done_pos_sclk_i       <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;
end generate gen_ss_n_high_0;

-- When set to FALSE SPI rx data will be valid when all required bits have been recieved
gen_not_ss_n_high_0 : if not make_rx_data_happen_at_ss_n_high_edge generate
        process(i_sys_clk, i_sys_rst)
        begin
            if (i_sys_rst = '1') then
                rx_data_count_pos_sclk_i         <= (others => '0');
                rx_done_pos_sclk_i               <= '1';
            elsif rising_edge(i_sys_clk) then
                if i_ssn_s = '1' then
                    rx_data_count_pos_sclk_i <= (others => '0');
                else
                    if i_sclk_rising_edge_s = '1' then
                        if (i_ssn_s = '0' and ((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1'))) then
                            if (rx_data_count_pos_sclk_i = DATA_SIZE - 1) then
    ----.                            rx_data_count_pos_sclk_i <= (others => '0');
                                rx_done_pos_sclk_i       <= '1';
                            elsif (i_ssn_s = '0') then
                                rx_data_count_pos_sclk_i <= rx_data_count_pos_sclk_i + 1;
                                rx_done_pos_sclk_i       <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;
end generate gen_not_ss_n_high_0;

----------------------------------------------------------------------------
--- MOSI Sampling : Sample at negedge of SCLK for
-- 1. i_cpol=1 and i_cpha=0
-- 2. i_cpol=0 and i_cpha=1
----------------------------------------------------------------------------

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_shift_data_neg_sclk_i         <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            if i_sclk_falling_edge_s = '1' then
                if (i_ssn_s = '0' and ((i_cpol = '1' and i_cpha = '0') or (i_cpol = '0' and i_cpha = '1'))) then
                    if (i_lsb_first = '1') then
                        rx_shift_data_neg_sclk_i <= i_mosi & rx_shift_data_neg_sclk_i(DATA_SIZE-1 downto 1);
                    else
                        rx_shift_data_neg_sclk_i <= rx_shift_data_neg_sclk_i(DATA_SIZE-2 downto 0) & i_mosi;
                    end if;
                end if;
            end if;
        end if;
    end process;

-- When set to TRUE SPI rx data will be valid when ss_n goes high (this will cause board select IP to fail but will allow other SPI configurations to work)
gen_ss_n_high_1 : if make_rx_data_happen_at_ss_n_high_edge generate
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_data_count_neg_sclk_i     <= (others => '0');
            rx_done_neg_sclk_i           <= '0';
        elsif rising_edge(i_sys_clk) then
            if i_ssn_rising_edge_s = '1' then
                rx_data_count_neg_sclk_i <= (others => '0');
                rx_done_neg_sclk_i       <= '1';
            else
                if i_sclk_falling_edge_s = '1' then
                    if (i_ssn_s = '0') then
                        rx_data_count_neg_sclk_i <= rx_data_count_neg_sclk_i + 1;
                        rx_done_neg_sclk_i       <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end generate gen_ss_n_high_1;

-- When set to FALSE SPI rx data will be valid when all required bits have been recieved
gen_not_ss_n_high_1 : if not make_rx_data_happen_at_ss_n_high_edge generate
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_data_count_neg_sclk_i     <= (others => '0');
            rx_done_neg_sclk_i           <= '0';
        elsif rising_edge(i_sys_clk) then
            if i_ssn_s = '1' then
                rx_data_count_neg_sclk_i <= (others => '0');
            else
                if i_sclk_falling_edge_s = '1' then
                    if (rx_data_count_neg_sclk_i = DATA_SIZE - 1) then
--                        rx_data_count_neg_sclk_i <= (others => '0');
                        rx_done_neg_sclk_i       <= '1';
                    elsif (i_ssn_s = '0') then
                        rx_data_count_neg_sclk_i <= rx_data_count_neg_sclk_i + 1;
                        rx_done_neg_sclk_i       <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end generate gen_not_ss_n_high_1;


----------------------------------------------------------------------------
-- SPI Slave Receiver Receive Done signal generator
-- This is based on CPOL and CPHA
----------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_done_reg1_i     <= '1';
            rx_done_reg2_i     <= '1';
            rx_done_reg3_i     <= '1';
        elsif rising_edge(i_sys_clk) then
--            if (i_ssn_s = '0' and ((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1'))) then
            if (((i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1'))) then
                rx_done_reg1_i <= rx_done_pos_sclk_i;
            else
                rx_done_reg1_i <= rx_done_neg_sclk_i;
            end if;
            rx_done_reg2_i     <= rx_done_reg1_i;
            rx_done_reg3_i     <= rx_done_reg2_i;
        end if;
    end process;
----------------------------------------------------------------------------------------------------
-- Receiver ready at the end of reception.
-- A valid receive data available at this time
----------------------------------------------------------------------------------------------------

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_ready_i     <= '1';
        elsif rising_edge(i_sys_clk) then
            if (rx_done_reg2_i = '1' and rx_done_reg3_i = '0') then
                rx_ready_i <= '1';
--            elsif (i_ssn_s = '1' and i_csn = '0') then
--                rx_ready_i <= '1';
	    elsif (i_ssn_s = '0' and i_csn = '0') then
                rx_ready_i <= '0';
            end if;
        end if;
    end process;

    
----------------------------------------------------------------------------------------------------
-- Receive error when external interface hasn't read previous data
-- A new data received, but last received data hasn't been read yet.
----------------------------------------------------------------------------------------------------
    
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            rx_error_i     <= '0';
        elsif rising_edge(i_sys_clk) then
            if(rx_ready_i = '0' and i_rd = '1' and i_csn = '0') then
                rx_error_i <= '1';
            elsif(i_rd = '1' and i_csn = '0') then
                rx_error_i <= '0';
            end if;
        end if;
    end process;

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
	    rx_error_reg_1_i <= '0';
	elsif rising_edge(i_sys_clk) then
	    rx_error_reg_1_i <= rx_error_i;
	end if;
    end process;

    
----------------------------------------------------------------------------
-- SPI Slave Transmitter section  				      ----
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- cpol=0 and cpha=0: data must be placed before rising edge of sclk  -------
----------------------------------------------------------------------------

    process(txdata_reg_i, tx_data_count_neg_sclk_i, i_lsb_first)
    begin
        if(i_lsb_first = '1') then
            miso_00_i <= txdata_reg_i(conv_integer(tx_data_count_neg_sclk_i));
        else
            miso_00_i <= txdata_reg_i(conv_integer(DATA_SIZE-tx_data_count_neg_sclk_i-1));
        end if;
    end process;


----------------------------------------------------------------------------
-- cpol=1 and cpha=0: data must be placed before falling edge of sclk  -------
----------------------------------------------------------------------------

    process(txdata_reg_i, tx_data_count_pos_sclk_i, i_lsb_first)
    begin
        if(i_lsb_first = '1') then
            miso_10_i <= txdata_reg_i(conv_integer(tx_data_count_pos_sclk_i));
        else
            miso_10_i <= txdata_reg_i(conv_integer(DATA_SIZE-tx_data_count_pos_sclk_i-1));
        end if;
    end process;

----------------------------------------------------------------------------
-- cpol=0 and cpha=1: data must be placed at rising edge of sclk  -------
----------------------------------------------------------------------------

    process (i_sys_clk, i_sys_rst)
    begin
        if i_sys_rst = '1' then
            miso_01_i     <= '1';
        elsif rising_edge(i_sys_clk) then
            if i_sclk_rising_edge_s = '1' then
                if(i_lsb_first = '1') then
                    miso_01_i <= txdata_reg_i(conv_integer(tx_data_count_pos_sclk_i));
                else
                    miso_01_i <= txdata_reg_i(conv_integer(DATA_SIZE-tx_data_count_pos_sclk_i-1));
                end if;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------
-- cpol=1 and cpha=1: data must be placed at falling edge of sclk  -------
----------------------------------------------------------------------------

    process (i_sys_clk, i_sys_rst)
    begin
        if i_sys_rst = '1' then
            miso_11_i     <= '1';
        elsif rising_edge(i_sys_clk) then
            if i_sclk_falling_edge_s = '1' then
                if(i_lsb_first = '1') then
                    miso_11_i <= txdata_reg_i(conv_integer(tx_data_count_neg_sclk_i));
                else
                    miso_11_i <= txdata_reg_i(conv_integer(DATA_SIZE-tx_data_count_neg_sclk_i-1));
                end if;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------
-- Tx count on falling edge of sclk for cpol=0 and cpha=0  -------
-- and cpol=1 and cpha=1  				   -------
----------------------------------------------------------------------------

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            tx_data_count_neg_sclk_i     <= (others => '0');
            tx_done_neg_sclk_i           <= '0';
        elsif rising_edge(i_sys_clk) then
            if i_raw_ssn = '1' then
                tx_data_count_neg_sclk_i <= (others => '0');
            else
                if i_sclk_falling_edge_s = '1' then
                    if (tx_data_count_neg_sclk_i = DATA_SIZE - 1) then
    --                    tx_data_count_neg_sclk_i <= (others => '0');          -- Only indicate a valid tx edge once until ssn has gone low again
                        tx_done_neg_sclk_i       <= '1';
                    elsif (i_raw_ssn = '0') then
                        tx_data_count_neg_sclk_i <= tx_data_count_neg_sclk_i + 1;
                        tx_done_neg_sclk_i       <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;


----------------------------------------------------------------------------
-- Tx count on rising edge of sclk for cpol=1 and cpha=0  -------
-- and cpol=0 and cpha=1  				  -------
----------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            tx_data_count_pos_sclk_i     <= (others => '0');
            tx_done_pos_sclk_i           <= '0';
        elsif rising_edge(i_sys_clk) then
            if i_raw_ssn = '1' then
                tx_data_count_pos_sclk_i <= (others => '0');
            else
                if i_sclk_rising_edge_s = '1' then
                    if (tx_data_count_pos_sclk_i = DATA_SIZE - 1) then
    --                    tx_data_count_pos_sclk_i <= (others => '0');                        -- Only indicate a valid tx edge once until ssn has gone low again
                        tx_done_pos_sclk_i       <= '1';
                    elsif (i_raw_ssn = '0') then
                        tx_data_count_pos_sclk_i <= tx_data_count_pos_sclk_i + 1;
                        tx_done_pos_sclk_i       <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

--Make this process syncronous because it can cause constraints to fail. However, this will reduce it's maximum SPI speed
--    process(i_raw_ssn, i_cpol, i_cpha, miso_00_i, miso_01_i, miso_10_i, miso_11_i)
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            o_miso     <= '0';
        elsif rising_edge(i_sys_clk) then
            if (i_raw_ssn = '0') then
                if (i_cpol = '0' and i_cpha = '0') then
                    o_miso <= miso_00_i;
                elsif (i_cpol = '0' and i_cpha = '1') then
                    o_miso <= miso_01_i;
                elsif (i_cpol = '1' and i_cpha = '0') then
                    o_miso <= miso_10_i;
                else
                    o_miso <= miso_11_i;
                end if;
            else
                o_miso     <= '0';
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------------------------
-- Transmit done generation
-- Muxed based on CPOL and CPHA
----------------------------------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            tx_done_reg1_i     <= '0';
            tx_done_reg2_i     <= '0';
            tx_done_reg3_i     <= '0';
        elsif rising_edge(i_sys_clk) then
            if (i_cpol = '0' and i_cpha = '0') or (i_cpol = '1' and i_cpha = '1') then
                tx_done_reg1_i <= tx_done_neg_sclk_i;
            else
                tx_done_reg1_i <= tx_done_pos_sclk_i;
            end if;
            tx_done_reg2_i     <= tx_done_reg1_i;
            tx_done_reg3_i     <= tx_done_reg2_i;
        end if;
    end process;

------------------------------------------------------------------------------------------------
-- Transmitter is ready at the end of Transmission
-- Transmitter ready goes low as soon as ssn goes low
------------------------------------------------------------------------------------------------

    tx_ready: process (i_sys_clk, i_sys_rst)
    begin  -- process tx_ready
	if i_sys_rst = '1' then  	-- asynchronous reset (active high)
	    tx_ready_i <= '1';
	elsif i_sys_clk'event and i_sys_clk = '1' then  -- rising clock edge
	    if (tx_done_reg2_i = '1' and tx_done_reg3_i = '0') then
		tx_ready_i <= '1';
	    elsif (i_ssn_s = '1' and i_csn = '0') then
		tx_ready_i <= '1';
	    elsif (i_csn = '0' and i_ssn_s = '0') then
                tx_ready_i <= '0';
	    end if;
	end if;
    end process tx_ready;

----------------------------------------------------------------------------------------------------
-- Transmitter error when a data is written while transmitter busy transmitting data
-- (busy when Tx Ready = 0)
----------------------------------------------------------------------------------------------------
    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
            tx_error_i     <= '0';
        elsif rising_edge(i_sys_clk) then
            if(tx_ready_i = '0' and i_wr = '1' and i_csn = '0') then
                tx_error_i <= '1';
            elsif(i_wr = '1' and i_csn = '0') then
                tx_error_i <= '0';
            end if;
        end if;
    end process;

    process(i_sys_clk, i_sys_rst)
    begin
        if (i_sys_rst = '1') then
	    tx_error_reg_1_i <= '0';
	elsif rising_edge(i_sys_clk) then
	    tx_error_reg_1_i <= tx_error_i;
	end if;
    end process;
    
----------------------------------------------------------------------------------------------------
-- Tx ACK
----------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------
    -- Data Valid in SPI slave interface
    ------------------------------------------------------------------------------------------------
    data_valid_proc: process (i_sys_clk, i_sys_rst)
    begin  -- process data_valid_proc
	if i_sys_rst = '1' then  		-- asynchronous reset (active high)
	    data_valid_i <= '0';
	elsif i_sys_clk'event and i_sys_clk = '1' then  -- rising clock edge
	    if (i_wr = '1' and i_ssn_s = '0') then
		  data_valid_i <= '1';
	    elsif tx_done_pulse_i = '1' then
		  data_valid_i <= '0';
	    elsif i_ssn_s = '1' then
		  data_valid_i <= '0';
	    end if;
	end if;
    end process data_valid_proc;

   
    tx_ack_proc: process (i_sys_clk, i_sys_rst)
    begin  -- process data_valid_proc
	if i_sys_rst = '1' then  		-- asynchronous reset (active high)
	    o_tx_ack <= '0';
	elsif i_sys_clk'event and i_sys_clk = '1' then  -- rising clock edge
	    if (i_ssn_s = '1' and data_valid_i = '1') then
		  o_tx_ack <= '0';
	    elsif tx_done_pulse_i = '1' and data_valid_i = '1' then
		  o_tx_ack <= '1';
	    else
		  o_tx_ack <= '0';
	    end if;
	end if;
    end process tx_ack_proc;

    tx_no_ack_proc: process (i_sys_clk, i_sys_rst)
    begin  -- process data_valid_proc
	if i_sys_rst = '1' then  		-- asynchronous reset (active high)
	    o_tx_no_ack <= '0';
	elsif i_sys_clk'event and i_sys_clk = '1' then  -- rising clock edge
	    if (i_ssn_s = '1' and data_valid_i = '1') then
		o_tx_no_ack <= '1';
	    elsif tx_done_reg3_i = '1' and data_valid_i = '1' then
		o_tx_no_ack <= '0';
	    else
		o_tx_no_ack <= '0';
	    end if;
	end if;
    end process tx_no_ack_proc;
    
    tx_done_pulse_i <= tx_done_reg2_i and (not tx_done_reg3_i);
    
end rtl_arch;
