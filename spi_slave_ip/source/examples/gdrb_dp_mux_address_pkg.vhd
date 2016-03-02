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
    
    --Register map addresses for SPI interface
    constant gdrb_dp_mux_status_addr_c           : natural := 16#00#;
    constant gdrb_dp_mux_line_time_0_addr_c      : natural := 16#01#;
    constant gdrb_dp_mux_line_time_1_addr_c      : natural := 16#02#;
    constant gdrb_dp_mux_control_addr_c          : natural := 16#03#;

    constant gdrb_dp_mux_illumin_on_lo_addr_c    : natural := 16#04#;
    constant gdrb_dp_mux_illumin_on_hi_addr_c    : natural := 16#05#;

    constant gdrb_dp_mux_illumin_off_lo_addr_c   : natural := 16#06#;
    constant gdrb_dp_mux_illumin_off_hi_addr_c   : natural := 16#07#;

    constant gdrb_dp_mux_ues_position_addr_c     : natural := 16#0C#;
    constant gdrb_dp_mux_ues_version_addr_c      : natural := 16#0D#;
    constant gdrb_dp_mux_ues_day_addr_c          : natural := 16#0E#;
    constant gdrb_dp_mux_ues_year_month_addr_c   : natural := 16#0F#;

    constant gdrb_dp_mux_SkipPixels_0_Len_addr_c : natural := 16#10#;
    constant gdrb_dp_mux_SkipPixels_1_Len_addr_c : natural := 16#11#;
    constant gdrb_dp_mux_RealImage_0_Len_addr_c  : natural := 16#12#;
    constant gdrb_dp_mux_RealImage_1_Len_addr_c  : natural := 16#13#;

    constant gdrb_dp_mux_crop_control_addr_c     : natural := 16#20#;
    constant gdrb_dp_mux_pattern_control_addr_c  : natural := 16#21#;
    constant gdrb_dp_mux_front_porch_lo_addr_c   : natural := 16#24#;
    constant gdrb_dp_mux_front_porch_hi_addr_c   : natural := 16#25#;

    constant gdrb_dp_mux_dark_ref_lo_addr_c      : natural := 16#26#;
    constant gdrb_dp_mux_dark_ref_hi_addr_c      : natural := 16#27#;

    constant gdrb_dp_mux_back_porch_lo_addr_c    : natural := 16#28#;
    constant gdrb_dp_mux_back_porch_hi_addr_c    : natural := 16#29#;

    constant gdrb_dp_mux_dark_ref_value_0_addr_c : natural := 16#2C#;
    constant gdrb_dp_mux_dark_ref_value_1_addr_c : natural := 16#2D#;
    constant gdrb_dp_mux_dark_ref_value_2_addr_c : natural := 16#2E#;
    constant gdrb_dp_mux_dark_ref_value_3_addr_c : natural := 16#2F#;

    constant gdrb_dp_mux_image_value_0_addr_c    : natural := 16#30#;
    constant gdrb_dp_mux_image_value_1_addr_c    : natural := 16#31#;
    constant gdrb_dp_mux_image_value_2_addr_c    : natural := 16#32#;
    constant gdrb_dp_mux_image_value_3_addr_c    : natural := 16#33#;


    --status register constants
    constant identity_code_gdrb_c : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2#110#,3));  -- Type code of GDRB within Griffin system
    constant power_ok_c           : std_logic_vector(0 downto 0) := std_logic_vector(to_unsigned(2#1#,1));    -- No power monitoring inputs in this FPGA and so power monitoring is always OK

    --UES register constants
    constant position_c           : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#FF#,8));   -- U_don't_know_yet on the PCB
    constant version_c            : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#10#,8));   -- Revision 1.0
    constant day_c                : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#24#,8));   -- Release day,  24
    constant month_c              : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#2#,4));    -- Release month, Feb
    constant year_c               : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#6#,4));    -- Release year,  2016

end gdrb_dp_mux_address_pkg;

package body gdrb_dp_mux_address_pkg is

end;
