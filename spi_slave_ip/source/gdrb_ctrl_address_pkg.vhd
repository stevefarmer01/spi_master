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
--constant WriteEnable_c      : std_logic := '0' ;
--constant ReadEnable_c       : std_logic := '1' ;
--constant LEDControlAddr_c   : std_logic_vector (3 downto 0) := "0000" ;
--constant SensorStatusAddr_c : std_logic_vector (3 downto 0) := "0001" ;
--constant SensorEdgeAddr_c   : std_logic_vector (3 downto 0) := "0010" ;
--constant IntMaskAddr_c      : std_logic_vector (3 downto 0) := "0011" ;
--constant FaultAddr_c        : std_logic_vector (3 downto 0) := "0100" ;
--constant MotionCont1Addr_c  : std_logic_vector (3 downto 0) := "0101" ;  -- Only to be used on the Commutation CPLD
--constant MotionCont2Addr_c  : std_logic_vector (3 downto 0) := "0110" ;  -- Only to be used on the Commutation CPLD
--constant MotionCont3Addr_c  : std_logic_vector (3 downto 0) := "0111" ;  -- Only to be used on the Commutation CPLD
--constant ScanLEDAddr_c      : std_logic_vector (3 downto 0) := "1000" ;
--constant OViewLEDAddr_c     : std_logic_vector (3 downto 0) := "1001" ;
--constant CPLDProgAddr_c     : std_logic_vector (3 downto 0) := "1010" ;
--constant MDRB_UES1Addr_c    : std_logic_vector (3 downto 0) := "1011" ;
--constant MDRB_UES2Addr_c    : std_logic_vector (3 downto 0) := "1100" ;
--constant COMMUT_UES1Addr_c  : std_logic_vector (3 downto 0) := "1101" ;  -- Only to be used on the Commutation CPLD
--constant COMMUT_UES2Addr_c  : std_logic_vector (3 downto 0) := "1110" ;  -- Only to be used on the Commutation CPLD



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.spi_package.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package gdrb_ctrl_address_pkg is
    
--.    constant gdrb_ctrl_example0_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#0#,SPI_ADDRESS_BITS));
--.    constant gdrb_ctrl_example1_addr_c : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#1#,SPI_ADDRESS_BITS));

    constant SENSOR_STATUS_ADDR_C   : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)       := std_logic_vector(to_unsigned(16#0#,SPI_ADDRESS_BITS));
    constant SENSOR_EDGE_ADDR_C     : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)       := std_logic_vector(to_unsigned(16#1#,SPI_ADDRESS_BITS));
    constant SENSOR_INT_MASK_ADDR_C   : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)     := std_logic_vector(to_unsigned(16#2#,SPI_ADDRESS_BITS));

    constant FAULT_STATUS_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)   := std_logic_vector(to_unsigned(16#3#,SPI_ADDRESS_BITS));
    constant FAULT_EDGE_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)     := std_logic_vector(to_unsigned(16#4#,SPI_ADDRESS_BITS));
    constant FAULT_INT_MASK_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0) := std_logic_vector(to_unsigned(16#5#,SPI_ADDRESS_BITS));

    constant MISC_STATUS_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)    := std_logic_vector(to_unsigned(16#6#,SPI_ADDRESS_BITS));
    constant MISC_EDGE_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#7#,SPI_ADDRESS_BITS));
    constant MISC_INT_MASK_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)  := std_logic_vector(to_unsigned(16#8#,SPI_ADDRESS_BITS));

    constant ENABLES_OUT_ADDR_C        : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)    := std_logic_vector(to_unsigned(16#9#,SPI_ADDRESS_BITS));

    constant MDRB_UES1Addr_addr_c    : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#B#,SPI_ADDRESS_BITS));
    constant MDRB_UES2Addr_addr_c    : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#C#,SPI_ADDRESS_BITS));



--    constant MotionCont1Addr_addr_c  : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#5#,SPI_ADDRESS_BITS));
--    constant MotionCont2Addr_addr_c  : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#6#,SPI_ADDRESS_BITS));
--    constant MotionCont3Addr_addr_c  : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#7#,SPI_ADDRESS_BITS));
--    constant ScanLEDAddr_addr_c      : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#8#,SPI_ADDRESS_BITS));
--    constant OViewLEDAddr_addr_c     : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#9#,SPI_ADDRESS_BITS));
--    constant CPLDProgAddr_addr_c     : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#A#,SPI_ADDRESS_BITS));
--    constant COMMUT_UES1Addr_addr_c  : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#D#,SPI_ADDRESS_BITS));
--    constant COMMUT_UES2Addr_addr_c  : std_logic_vector(SPI_ADDRESS_BITS-1 downto 0)      := std_logic_vector(to_unsigned(16#E#,SPI_ADDRESS_BITS));

    --UES register constants
    constant Position_c   : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#FF#,8));   -- U_don't_know_yet on the PCB
    constant VersionNo_c  : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#10#,8));   -- Revision 1.0
    constant UES_1_c      : std_logic_vector(15 downto 0) := Position_c & VersionNo_c;
    constant Day_c        : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(16#01#,8));   -- Release day,   1st
    constant Month_c      : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#2#,4));    -- Release month, Feb
    constant Year_c       : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(16#6#,4));    -- Release year,  2016
    constant UES_2_c      : std_logic_vector(15 downto 0) := Day_c & Month_c & Year_c;

end gdrb_ctrl_address_pkg;

package body gdrb_ctrl_address_pkg is

end;
