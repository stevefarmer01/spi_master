----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2016 11:03:20
-- Design Name: 
-- Module Name: gdrb_ctrl_address_pkg - Behavioral
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
-----Following copied from MDRB code mdrb_control.vhd......



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--use work.gdrb_dp_mux_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package gdrb_dp_mux_address_pkg is
    
--.    constant gdrb_ctrl_example0_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#0#,SPI_ADDRESS_BITS));
--.    constant gdrb_ctrl_example1_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#1#,SPI_ADDRESS_BITS));

    constant gdrb_dp_mux_status_addr_c         : natural := 16#0#;
    constant gdrb_dp_mux_line_time_0_addr_c         : natural := 16#1#;
    constant gdrb_dp_mux_line_time_1_addr_c         : natural := 16#2#;
    constant gdrb_dp_mux_control_addr_c         : natural := 16#3#;

    constant gdrb_dp_mux_crop_control_addr_c         : natural := 16#20#;
    constant gdrb_dp_mux_pattern_control_addr_c         : natural := 16#21#;


    constant gdrb_dp_mux_ues_position_addr_c   : natural := 16#C#;
    constant gdrb_dp_mux_ues_version_addr_c    : natural := 16#D#;
    constant gdrb_dp_mux_ues_day_addr_c        : natural := 16#E#;
    constant gdrb_dp_mux_ues_year_month_addr_c : natural := 16#F#;



    --status register constants
    constant identity_code_gdrb_c : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2#110#,3));  -- Type code of GDRB within Griffin system
    constant power_ok_c : std_logic_vector(0 downto 0) := std_logic_vector(to_unsigned(2#1#,1));    -- No power monitoring inputs in this FPGA and so power monitoring is always OK

    --UES register constants
    constant position_c   : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#FF#,8));   -- U_don't_know_yet on the PCB
    constant version_c  : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#10#,8));   -- Revision 1.0
--    constant UES_1_c      : std_logic_vector(15 downto 0) := Position_c & VersionNo_c;
    constant day_c        : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#24#,8));   -- Release day,  24
    constant month_c      : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#2#,4));    -- Release month, Feb
    constant year_c       : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#6#,4));    -- Release year,  2016
--    constant UES_2_c      : std_logic_vector(15 downto 0) := Day_c & Month_c & Year_c;

end gdrb_dp_mux_address_pkg;

package body gdrb_dp_mux_address_pkg is

end;
