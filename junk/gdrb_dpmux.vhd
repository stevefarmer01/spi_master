-------------------------------------------------------------------------
--
-- File name    :  F:\usr\SFarmer\Griffin\GDRB\design_definition\hdl\vhdl
-- Title        :  Daedalus DHDB3 Data Path Multiplexer
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 05/11/2012 12:00:00
--              :
-- Comments     : 
--              : 
-- Assumptions  : none
-- Limitations  : none
-- Known Errors : none
-- Developers   : 
--              : 
-- Notes        :
    --Below would be ideal way of handling multiple of rx instances. However, DesignView schematic tool doesn't understant the port array widths/generics and so......
    --SERDES_CLK : in rx_21_bit_clk_array(0 to number_of_rx_interfaces-1) ;       -- DS90CR218A - Digitiser 1 clock
    --SERDES_D : in rx_21_bit_data_array(0 to number_of_rx_interfaces-1) ;        -- DS90CR218A - Digitiser 1 data
    --AHDB_LINE_SYNC_BAR : in rx_21_bit_bit_array(0 to number_of_rx_interfaces-1) -- DS90CR218A - Digitiser 1 Start of Line (synced with data)                                                                           -- bit 21 of IC interface
    --....they are done long-hand above
-- ----------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------
-- Copyright 2012-2016 (c) FFEI LTD
--
-- FFEI Ltd owns the sole copyright to this software. Under 
-- international copyright laws you (1) may not make a copy of this software
-- except for the purposes of maintaining a single archive copy, (2) may not 
-- derive works herefrom, (3) may not distribute this work to others. These 
-- rights are provided for information clarification, other restrictions of 
-- rights may apply as well.
--
-- This is an unpublished work.
-- ----------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------
-- FFEI MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF
-- THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
-- PURPOSE.
-- ----------------------------------------------------------------------
-- Revision History :
-- ----------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :|    Changes Made:
--   v0.0  | David Frith       :| 07/11/2012:| Based on DHDB dig_pld_dp v0.1
--   v0.1  | David Frith       :| 02/05/2013:| Change reverted
--   v0.2  | David Frith       :| 03/05/2013:| Negative edge clock output to meet SERDES hold
--   v0.3  | David Frith       :| 14/05/2013:| Include BrightLineSyncBar_s in Fluo mode (timing)
--   v0.4  | Steve Farmer      :| 06/01/2016:| modified to work in GDRB board for Griffin
-- ----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE gdrb_dig_pld_pkg IS
    type rx_21_bit_clk_array is array (natural range <>) of std_logic;
--_    type rx_21_bit_data_array is array (natural range <>) of std_logic_vector(19 downto 0);
    type rx_21_bit_bit_array is array (natural range <>) of std_logic;
    type rx_21_bit_data_path_array is array (natural range <>) of std_logic_vector(31 downto 0);
END; 

USE work.gdrb_dig_pld_pkg.all;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gdrb_dpmux is
generic 
(
    number_of_rx_interfaces : integer := 2
);
port
(

-- pragma synthesis_off

    --. JTAG i/f
    TCK : in std_logic ;  -- this will be controled by Begalbone
    TMS : in std_logic ;  -- this will be controled by Begalbone
    TDI : in std_logic ;  -- this will be controled by Begalbone and come in from TDO of gdrb_ctrl FPGA
    TDO : out std_logic ; -- this will be controled by Begalbone
      
-- pragma synthesis_on

    ---Clk/Reset
    CLK60M : in std_logic ;
    CLK24M : in std_logic ;
    gdrb_reset_bar : in std_logic := '0';
    ---SPI i/f
    SCLK : in std_logic ;
    SDI : in std_logic ;
    SDO : out std_logic ;
    SEN_BAR : in std_logic ;
    ---Encoder Interpolators
    X_ENC_A : in std_logic;    
    X_ENC_B : in std_logic;    
    X_ENC_Z : in std_logic;
    Y_ENC_A : in std_logic;    
    Y_ENC_B : in std_logic;    
    Y_ENC_Z : in std_logic;
    Z_ENC_A : in std_logic;    
    Z_ENC_B : in std_logic;    
    Z_ENC_Z : in std_logic;
    ---rx stuff                                    -- Interface taken from amis_bufcon.vhd of E:\usr\microscan\AMIS\DPMC                  -- check SER1_QUAD_MODE, SERDES1_RISING_EDGE, and SER1_HIGH_V_SWING on DHDB tx IC - these are pull up/down resisters
    ---rx_0
    SERDES_CLK_0 : in std_logic;                   -- DS90CR218A - Digitiser 1 clock
    SERDES_D_0 : in std_logic_vector(19 downto 0); -- DS90CR218A - Digitiser 1 data
    SERDES_LINE_SYNC_0_BAR : in std_logic;         -- DS90CR218A - Digitiser 1 Start of Line (synced with data)                           -- bit 21 of IC interface
    ---rx_1
    SERDES_CLK_1 : in std_logic;                   -- DS90CR218A - Digitiser 1 clock
    SERDES_D_1 : in std_logic_vector(19 downto 0); -- DS90CR218A - Digitiser 1 data
    SERDES_LINE_SYNC_1_BAR : in std_logic;         -- DS90CR218A - Digitiser 1 Start of Line (synced with data)                           -- bit 21 of IC interface
    ---tx data
    DIG_DAT : out std_logic_vector(29 downto 0);   -- DS92LV3241TVS - bits 28 to 0
    LINE_SYNC_BAR : out std_logic ;                -- DS92LV3241TVS - bit 31 goes to LINE_SYNC_BAR
    ---tx discrete pin control signal 
    SER_BISTEN : out std_logic := '0';                   -- goes to discrete BITSEN pin 13 on DS92LV3241TVS
    ALT_SERDES1_CLK : out std_logic := '0';        -- included in case needed by hardware - goes to discrete pin 11 on DS92LV3241TVS
    TX_RESET_3V3_BAR : out std_logic := '1';       -- included in case needed by hardware - goes to discrete pin 12 on DS92LV3241TVS
    ---Discretes
    gdrb_dpmux_spare1 : in std_logic;
    gdrb_dpmux_spare2 : in std_logic;
    gdrb_dpmux_spare3 : in std_logic;
    HR_ILLUM_STROBE : in std_logic;                 -- Take strobe in and out just in case it needs modifying
    HR_ILLUM_STROBE_OUT : out std_logic;                 -- Take strobe in and out just in case it needs modifying
    CIS_LINE_SYNC_IN : in std_logic;                 -- Take CIS board line sync in and out just in case it needs modifying
    CIS_LINE_SYNC_OUT : out std_logic;                 -- Take CIS board line sync in and out just in case it needs modifying
    INDEX_CAPTURE : in std_logic := '0';            -- Set all camera link index's to known preset value
    CIS_HDB_SPARE2 : out std_logic := '0'           -- Spare connection to CIS board

);

begin

end gdrb_dpmux;

architecture behave of gdrb_dpmux is

component gdrb_pll_dpmux
port(
    --Inputs
    CLKI     : in std_logic ;  
    CLKOP    : out std_logic
    );
end component;

component gdrb_asyncfifo32x4x32
    port (
        Data: in  std_logic_vector(31 downto 0); 
        WrClock: in  std_logic; 
        RdClock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        RPReset: in  std_logic; 
        Q: out  std_logic_vector(31 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic);
end component;

component gdrb_newtpg
port
(
    FpgaClk2x_s : in std_logic ;

    TpgRen_s : in std_logic ;
    TpgEmpty_s : out std_logic ;
    TpgUnderflow_s : out std_logic ;
    TpgData_s : out std_logic_vector(31 downto 0) ;

    RunIp_s : in std_logic ;
    PatternCon_s : in std_logic_vector(1 downto 0) ;            -- Reset the pattern counters
    RedPattern_s : in std_logic_vector(1 downto 0) ;            -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
    GreenPattern_s : in std_logic_vector(1 downto 0) ;          -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
    BluePattern_s : in std_logic_vector(1 downto 0) ;           -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
    FrontPorchLen_s : in std_logic_vector(8 downto 0) ;         -- Pixels between line synch and 1st dark reference
    DarkRefLen_s : in std_logic_vector(6 downto 0) ;            -- No. of dark reference pixels
    SkipPixelsLen_s : in std_logic_vector(13 downto 0) ;        -- No. of pixels between dark ref. and real image
    RealImageLen_s : in std_logic_vector(13 downto 0) ;         -- No. of real image pixels
    BackPorchLen_s : in std_logic_vector(13 downto 0) ;         -- No. of back porch pixels
    RedDarkRef_s : in std_logic_vector(9 downto 0) ; 
    GreenDarkRef_s : in std_logic_vector(9 downto 0) ; 
    BlueDarkRef_s : in std_logic_vector(9 downto 0) ; 
    RedImage_s : in std_logic_vector(9 downto 0) ; 
    GreenImage_s : in std_logic_vector(9 downto 0) ; 
    BlueImage_s : in std_logic_vector(9 downto 0) ;

    TpgWaitSync_s : out std_logic ;
    TpgLineSync_s : out std_logic
) ;
end component;

component gdrb_asyncfifo32x4096x32
    port (
    Data : in std_logic_vector(31 downto 0); 
    WrClock: in std_logic; 
    RdClock: in std_logic; 
    WrEn: in std_logic; 
    RdEn: in std_logic; 
    Reset: in std_logic; 
    RPReset: in std_logic; 
    Q : out std_logic_vector(31 downto 0); 
    Empty: out std_logic; 
    Full: out std_logic; 
    AlmostEmpty: out std_logic; 
    AlmostFull: out std_logic
);
end component;

--component gdrb_newdigif
--port
--(
--    DIGIF_DEBUG_DATA : out std_logic_vector(8 downto 0) ;         -- Debug only
--  Reverse_s : in std_logic ;
--  RunIp_s : in std_logic ;
--    IMAGE_TAP_BAR : in std_logic ;                              -- Image tap from DSP (allow data through)
--
--    DiagVV_s : in std_logic ;                                   -- Image tap from software
--    FluorOn_s : in std_logic ;                                  -- '0'=Off, '1'=On
--    FluorHi_s : in std_logic ;                                    -- '0'=Low (8 bit), '1'=High (12 bit)
--    Illumination_s : in std_logic_vector(1 downto 0) ;          -- "00"=off, "01"=on, "10"=pulsing
--    FrontPorchLen_s : in std_logic_vector(8 downto 0) ;         -- Pixels between line synch and 1st dark reference
--    DarkRefLen_s : in std_logic_vector(6 downto 0) ;            -- No. of dark reference pixels
--    SkipPixelsLen_s : in std_logic_vector(13 downto 0) ;        -- No. of pixels between dark ref. and real image
--    RealImageLen_s : in std_logic_vector(13 downto 0) ;         -- No. of real image pixels
--    IlluminationOn_s : in std_logic_vector(23 downto 0) ; 
--    IlluminationOff_s : in std_logic_vector(23 downto 0) ; 
--
---- SERDES I/F - Digitiser                                     
--    SERDES_CLK : in std_logic ;                                 -- Digitiser clock
--    SerdesClkEn_s : in std_logic ;                                 -- Digitiser clock enable
--    SERDES_D : in std_logic_vector(29 downto 0) ;               -- Digitiser data
--    DHDB_LINE_SYNC_BAR : in std_logic ;                         -- Digitiser Start of Line (synced with data)
--
--  ILLUM_STROBE : out std_logic ;                              -- Signal to pulse the LED's
--
--  DigRedData_s : out std_logic_vector(9 downto 0) ;
--  DigGreenData_s : out std_logic_vector(9 downto 0) ;
--  DigBlueData_s : out std_logic_vector(9 downto 0) ;
--  FluorData_s : out std_logic_vector(29 downto 0) ;
--  FluorLineSync_s  : out std_logic ;
--  DigInImage_s : out std_logic ;
--  DigAllowRen_s : out std_logic ;
--  DigFifoWen_s : out std_logic ;
--    DigFifoOverflow_s : in std_logic ;
--    LatchedDigFifoOverflow_s : out std_logic ;
--  DigWaitSync_s : out std_logic ;
--  DigLineSync_s : out std_logic ;
--  DigLifoWrAdd_s : out std_logic_vector(12 downto 0)
--);
--end component;

            --Interface taken from amis_bufcon.vhd of DPMC - E:\usr\microscan\AMIS\DPMC
component gdrb_digif
port
(
    Debug_s : out std_logic ;
    RunIp_s : in std_logic ;
    IMAGE_TAP_BAR : in std_logic ;                              -- Image tap from DSP (allow data through)
    DiagVV_s : in std_logic ;                                   -- Image tap from software
    FluorOn_s : in std_logic ;                                  -- '0'=Off, '1'=On
    FluorHi_s : in std_logic ;                                  -- '0'=Low (8 bit), '1'=High (12 bit)
    Illumination_s : in std_logic_vector(1 downto 0) ;          -- "00"=off, "01"=on, "10"=pulsing
    FrontPorchLen_s : in std_logic_vector(8 downto 0) ;         -- Pixels between line synch and 1st dark reference
    DarkRefLen_s : in std_logic_vector(6 downto 0) ;            -- No. of dark reference pixels
    SkipPixelsLen_s : in std_logic_vector(13 downto 0) ;        -- No. of pixels between dark ref. and real image
    RealImageLen_s : in std_logic_vector(13 downto 0) ;         -- No. of real image pixels
    IlluminationOn_s : in std_logic_vector(23 downto 0) ; 
    IlluminationOff_s : in std_logic_vector(23 downto 0) ; 
    SERDES_CLK : in std_logic ;                                 -- Digitiser clock
    SERDES_D : in std_logic_vector(19 downto 0) ;               -- Digitiser data
    AHDB_LINE_SYNC_BAR : in std_logic ;                         -- Digitiser Start of Line (synced with data)
    ILLUM_STROBE : out std_logic ;                              -- Signal to pulse the LED's
    DigRedData_s : out std_logic_vector(9 downto 0) ;
    DigGreenData_s : out std_logic_vector(9 downto 0) ;
    DigBlueData_s : out std_logic_vector(9 downto 0) ;
    FluorData_s : out std_logic_vector(19 downto 0) ;
    FluorLineSync_s  : out std_logic ;
    DigInImage_s : out std_logic ;
    DigFifoWen_s : out std_logic ;
    DigFifoOverflow_s : in std_logic ;
    LatchedDigFifoOverflow_s : out std_logic ;
    DigWaitSync_s : out std_logic ;
    DigLineSync_s : out std_logic
);
end component;

component gdrb_serial
port
(
     RESET_BAR : in std_logic ;
     CLK : in std_logic ;
     
     SDO : out std_logic ;
     SCLK : in std_logic ;
     SDI : in std_logic ;
     SEN_BAR : in std_logic ;
     LEFT : in std_logic ;
     MixedMode_s : out std_logic ;                     -- '0'=Off, '1'=On
     Illumination_s : out std_logic_vector(1 downto 0) ;                     -- '0'=Off, '1'=On
     FDSERDES_PD_BAR : out std_logic ;
     FDSERDES_REN : out std_logic ;
     SER_BISTEN : out std_logic ;
     FpgaReset_s : out std_logic ;
     FocusOn_s : out std_logic ;                     -- '0'=Off, '1'=On
     DiagVV_s : out std_logic ;                     -- '0'=Off, '1'=On
     PatternCon_s : out std_logic_vector(1 downto 0) ;   -- "00"=off, "01"=run TPG, "1x"=unused
     RedPattern_s : out std_logic_vector(1 downto 0) ;   -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
     GreenPattern_s : out std_logic_vector(1 downto 0) ; -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
     BluePattern_s : out std_logic_vector(1 downto 0) ;  -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
     FrontPorchLen_s : out std_logic_vector(8 downto 0) ;
     DarkRefLen_s : out std_logic_vector(6 downto 0) ;
     SkipPixelsLHSLen_s : out std_logic_vector(13 downto 0) ;
     SkipPixelsRHSLen_s : out std_logic_vector(13 downto 0) ;
     RealImageLHSLen_s : out std_logic_vector(13 downto 0) ; 
     RealImageRHSLen_s : out std_logic_vector(13 downto 0) ; 
     BackPorchLHSLen_s : out std_logic_vector(13 downto 0) ; 
     BackPorchRHSLen_s : out std_logic_vector(13 downto 0) ; 
     IlluminationOn_s : out std_logic_vector(23 downto 0) ; 
     IlluminationOff_s : out std_logic_vector(23 downto 0) ; 
     RedDarkRef_s : out std_logic_vector(9 downto 0) ; 
     GreenDarkRef_s : out std_logic_vector(9 downto 0) ; 
     BlueDarkRef_s : out std_logic_vector(9 downto 0) ; 
     RedImage_s : out std_logic_vector(9 downto 0) ; 
     GreenImage_s : out std_logic_vector(9 downto 0) ; 
     BlueImage_s : out std_logic_vector(9 downto 0) ;
     FocusOffset_s : out std_logic_vector(13 downto 0) ;
     FocusPixels_s : out std_logic_vector(13 downto 0) ;
     FocusLines_s : out std_logic_vector(6 downto 0)
);

end component;



signal RedData_s : std_logic_vector(9 downto 0) ;
signal GreenData_s : std_logic_vector(9 downto 0) ;
signal BlueData_s : std_logic_vector(9 downto 0) ;
signal TopRedData_s : std_logic_vector(2 downto 0) ;
signal TopGreenData_s : std_logic_vector(2 downto 0) ;
signal TopBlueData_s : std_logic_vector(2 downto 0) ;
signal FocusData_s : std_logic_vector(31 downto 0) ;
signal TestData_s : std_logic_vector(1 downto 0) ;
signal TestDataSel_s : std_logic ;
signal DPFocus_s : std_logic ;
signal BrightLineSyncBar_s : std_logic ;
signal RBrightLineSyncBar_s : std_logic ;
signal RRBrightLineSyncBar_s : std_logic ;
signal FocusLineSyncBar_s : std_logic ;
--signal iDIG_DAT : std_logic_vector(DIG_DAT'RANGE) ; 
signal iPLD_CLK      : std_logic;
signal One_s : std_logic ;
signal Zero_s : std_logic ;
signal DoubleZero_s : std_logic_vector(1 downto 0) ;

signal IMAGE_TAP_BAR : std_logic ;                              -- Image tap from DSP (allow data through)
signal DiagVV_s : std_logic ;

signal PatternCon_s : std_logic_vector(1 downto 0) ;   -- "00"=off, "01"=run TPG, "1x"=unused
signal RedPattern_s : std_logic_vector(1 downto 0) ;   -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
signal GreenPattern_s : std_logic_vector(1 downto 0) ; -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
signal BluePattern_s : std_logic_vector(1 downto 0) ;  -- "00"=0x00, "01"=0xFF, "10"=Inc, "11"=Fixed
signal FocusOn_s : std_logic ;                     -- '0'=Off, '1'=On
signal MixedMode_s : std_logic ;                     -- '0'=Off, '1'=On
signal Illumination_s : std_logic_vector(1 downto 0) ;
signal FpgaReset_s : std_logic ;                     -- '0'=Off, '1'=On
signal FrontPorchLen_s : std_logic_vector(8 downto 0) ;
signal DarkRefLen_s : std_logic_vector(6 downto 0) ;
signal SkipPixelsLHSLen_s : std_logic_vector(13 downto 0) ;
signal SkipPixelsRHSLen_s : std_logic_vector(13 downto 0) ;
signal RealImageLHSLen_s : std_logic_vector(13 downto 0) ; 
signal RealImageRHSLen_s : std_logic_vector(13 downto 0) ; 
signal BackPorchLHSLen_s : std_logic_vector(13 downto 0) ; 
signal BackPorchRHSLen_s : std_logic_vector(13 downto 0) ; 
signal IlluminationOn_s : std_logic_vector(23 downto 0) ; 
signal IlluminationOff_s : std_logic_vector(23 downto 0) ; 
signal RedDarkRef_s : std_logic_vector(9 downto 0) ; 
signal GreenDarkRef_s : std_logic_vector(9 downto 0) ; 
signal BlueDarkRef_s : std_logic_vector(9 downto 0) ; 
signal RedImage_s : std_logic_vector(9 downto 0) ; 
signal GreenImage_s : std_logic_vector(9 downto 0) ; 
signal BlueImage_s : std_logic_vector(9 downto 0) ;
signal FocusOffset_s : std_logic_vector(13 downto 0) ;
signal FocusPixels_s : std_logic_vector(13 downto 0) ;
signal FocusLines_s : std_logic_vector(6 downto 0) ;

signal muxedSERDES_D : std_logic_vector(29 downto 0) ;
signal muxedSerdesClken_s : std_logic ;
signal muxedSERDES_LINE_SYNC_BAR : std_logic ;
signal tpgSERDES_D : std_logic_vector(31 downto 0) ;
signal tpgSERDES_LINE_SYNC_BAR : std_logic ;

signal TpgWaitSync_s : std_logic ;
signal DigWaitSync_s : std_logic ;
signal DigLineSync_s : std_logic ;
signal WaitSync_s : std_logic ;
signal DIGIF_DEBUG_DATA : std_logic_vector(8 downto 0) ;

signal DigRedData_s : std_logic_vector(9 downto 0) ;
signal DigGreenData_s : std_logic_vector(9 downto 0) ;
signal DigBlueData_s : std_logic_vector(9 downto 0) ;
signal DigInImage_s : std_logic ;
signal DigFifoReset_s : std_logic := '0';
signal DigFifoEmpty_s : std_logic ;
signal DigFifoAEmpty_s : std_logic ;
signal DigFifoAFull_s : std_logic;                          -- Fifo almost full flag 
signal DigFifoFull_s : std_logic;                           -- Fifo full flag 
signal DigFifoData_s : std_logic_vector(31 downto 0) ;
signal DigFifoRen_s : std_logic ;
signal DigFifoWen_s : std_logic ;
signal DigFifoOverflow_s : std_logic ;
signal DigFifoValid_s : std_logic ;
signal DigFifoUnderflow_s : std_logic ;
signal ILatchedDigFifoOverflow_s : std_logic ;
signal LHSImprocRen_s : std_logic ;



signal iFD_CLK             : rx_21_bit_bit_array(0 to number_of_rx_interfaces-1);
signal SerdesClkEn_s       : rx_21_bit_bit_array(0 to number_of_rx_interfaces-1);
signal SerdesFifoData_s    : rx_21_bit_data_path_array(0 to number_of_rx_interfaces-1);
signal SerdesFifoEmpty_s   : rx_21_bit_bit_array(0 to number_of_rx_interfaces-1);
signal SerdesFifoOutData_s : rx_21_bit_data_path_array(0 to number_of_rx_interfaces-1);

constant output_instance_const : integer := 0;

signal test_count : integer range 0 to number_of_rx_interfaces-1 := 0;
signal test_SerdesFifoOutData_s : std_logic_vector(31 downto 0);
signal test_SerdesFifoOutData_reverse_s : std_logic_vector(test_SerdesFifoOutData_s'REVERSE_RANGE);
signal test_SerdesClkEn_s : std_logic;

type rx_21_bit_data_array is array (natural range <>) of std_logic_vector(SERDES_D_0'RANGE);
signal SERDES_CLK_S : std_logic_vector(0 to number_of_rx_interfaces-1) ;        -- DS90CR218A - Digitiser 1 clock
signal SERDES_D_S : rx_21_bit_data_array(0 to number_of_rx_interfaces-1) ;      -- DS90CR218A - Digitiser 1 data
signal AHDB_LINE_SYNC_BAR_S : std_logic_vector(0 to number_of_rx_interfaces-1); -- DS90CR218A - Digitiser 1 Start of Line (synced with data) -- bit 21 of IC interface

--signal test_vec : std_logic_vector(((Y_MQF_ENC_A_B_Z'LENGTH)*6)-1 downto 0);
signal test_vec : std_logic_vector(13 downto 0);

signal CLK_24_S, dummy_reg_out : std_logic := '0';
signal ALT_SERDES1_CLK_S : std_logic := '0';
            
begin

--Use unused inputs to prevent them being optimised away------START

--test_vec <= (X_ENC_A & Y_ENC_A & Z_ENC_A & X_MQF_ENC_A & Y_MQF_ENC_A & Z_MQF_ENC_A & X_ENC_B & Y_ENC_B & Z_ENC_B & X_MQF_ENC_B & Y_MQF_ENC_B & Z_MQF_ENC_B & X_ENC_Z & Y_ENC_Z & Z_ENC_Z & X_MQF_ENC_Z & Y_MQF_ENC_Z & Z_MQF_ENC_Z);          -- use unused inputs to prevent them being optimised away
--test_vec <= (X_ENC_A & Y_ENC_A & Z_ENC_A & X_ENC_B & Y_ENC_B & Z_ENC_B & X_ENC_Z & Y_ENC_Z & Z_ENC_Z);          -- use unused inputs to prevent them being optimised away
test_vec <= (X_ENC_A & Y_ENC_A & Z_ENC_A & X_ENC_B & Y_ENC_B & Z_ENC_B & X_ENC_Z & Y_ENC_Z & Z_ENC_Z & gdrb_dpmux_spare3 & gdrb_dpmux_spare2 & gdrb_dpmux_spare1 & gdrb_reset_bar & INDEX_CAPTURE);          -- use unused inputs to prevent them being optimised away

ALT_SERDES1_CLK_S <= '1' when to_integer(unsigned(test_vec)) = 0 else '0'; -- use unused inputs to prevent them being optimised away


--SPARE(SPARE'HIGH-1 downto SPARE'LOW) <= (others => '1') when to_integer(unsigned(test_vec)) = 0 else (others => 'Z'); -- use unused inputs to prevent them being optimised away
--
--dummy_proc : process
--begin
--    wait until rising_edge(CLK_24_S);
--    if to_integer(unsigned(SPARE)) = 0 then
--        dummy_reg_out <= not dummy_reg_out;
--    end if;
--end process;
--
--SPARE(SPARE'HIGH) <= '1' when dummy_reg_out = '1' else 'Z';
----Use unused inputs to prevent them being optimised away------END


pll_clk24: gdrb_pll_dpmux                                                                                             -- use unused inputs to prevent them being optimised away
port map(
    CLKI => CLK24M,
    CLKOP => CLK_24_S
);

--PRevents clk24m being stripped by DRC
clk_24_proc : process
begin
    wait until rising_edge(CLK_24_S);
    ALT_SERDES1_CLK <= ALT_SERDES1_CLK_S;
end process;

HR_ILLUM_STROBE_OUT <= hr_illum_strobe;
CIS_LINE_SYNC_OUT <= CIS_LINE_SYNC_IN;  -- this needs to be syncronous to CLK24M

--remap rx ports because DesignView schematic tool doesn't understant the port array widths/generics 
--rx_0
SERDES_CLK_S(0) <= SERDES_CLK_0;
SERDES_D_S(0) <= SERDES_D_0;
AHDB_LINE_SYNC_BAR_S(0) <= SERDES_LINE_SYNC_0_BAR;
--rx_1
SERDES_CLK_S(1) <= SERDES_CLK_1;
SERDES_D_S(1) <= SERDES_D_1;
AHDB_LINE_SYNC_BAR_S(1) <= SERDES_LINE_SYNC_1_BAR;

One_s <= '1' ;
Zero_s <= '0' ;
DoubleZero_s <= "00" ;

pll_clk60: gdrb_pll_dpmux 
port map(
    CLKI => CLK60M,
    CLKOP => iPLD_CLK
);


gen_rx_interfaces : for i in 0 to number_of_rx_interfaces-1 generate 

    SerdesClkEn_s(i) <= not SerdesFifoEmpty_s(i) ;

    --SerdesFifoData_s <= FD_LINE_SYNC_BAR & FD_LOCK & FD_DIG ;
    SerdesFifoData_s(i) <= std_logic_vector(to_unsigned(0,(SerdesFifoData_s(i)'LENGTH - 21))) & AHDB_LINE_SYNC_BAR_S(i) & SERDES_D_S(i) ;

-- remove PLL as fails to map as there are only 2 PLL's available and 3 are now needed
--    u2pll: gdrb_pll_dpmux 
--    port map(
--    --    CLKI=>FD_CLK,
--        CLKI => SERDES_CLK_S(i),
--      CLKOP => iFD_CLK(i)
--    );

iFD_CLK(i) <= SERDES_CLK_S(i);

    serdes_fifo: gdrb_asyncfifo32x4x32
    port map(
        Data => SerdesFifoData_s(i),   -- : in  std_logic_vector(31 downto 0);
        WrClock => iFD_CLK(i),         -- : in  std_logic;
        RdClock => iPLD_CLK,           -- : in  std_logic;
        WrEn => One_s,                 -- : in  std_logic;
        RdEn => SerdesClkEn_s(i),      -- : in  std_logic;
        Reset => DigFifoReset_s,       -- : in  std_logic;
        RPReset => DigFifoReset_s,     -- : in  std_logic;
        Q => SerdesFifoOutData_s(i),   -- : out  std_logic_vector(31 downto 0);
        Empty => SerdesFifoEmpty_s(i), -- : out  std_logic;
        full => open                   -- : out  std_logic);
    --    underflow => Serdes1FifoUnderflow_s
      );

end generate;

-- make a count to mux rx inputs from generate statement otherwise unused ones will be optomised away
test_count_proc : process(gdrb_reset_bar, iPLD_CLK)
begin
    if gdrb_reset_bar = '0' then
        test_count <= 0;
    elsif rising_edge(iPLD_CLK) then
        if test_count = number_of_rx_interfaces-1 then
            test_count <= 0;
        else
            test_count <= test_count + 1;
        end if;
    end if;
end process;
-- mux and or reverse range to prevent optimisation of input pins 15-19 optimised away on both rx inputs
gen_reverse : for i in test_SerdesFifoOutData_reverse_s'RANGE generate
    test_SerdesFifoOutData_reverse_s(i) <= SerdesFifoOutData_s(test_count)(i);
end generate;

test_SerdesFifoOutData_s <= SerdesFifoOutData_s(test_count) or test_SerdesFifoOutData_reverse_s when to_integer(unsigned(SerdesFifoOutData_s(test_count)(16 downto 15))) = 0 else (others => '0');

test_SerdesClkEn_s <= SerdesClkEn_s(test_count);

unewtpgLHS: gdrb_newtpg
port map(
    FpgaClk2x_s => iPLD_CLK,
    TpgRen_s => One_s,
    TpgEmpty_s => open,
    TpgUnderflow_s => open,
    TpgData_s => tpgSERDES_D,
    RunIp_s => FocusOn_s,
    PatternCon_s => PatternCon_s,
    RedPattern_s => RedPattern_s,
    GreenPattern_s => GreenPattern_s,
    BluePattern_s => BluePattern_s,
    FrontPorchLen_s => FrontPorchLen_s,
    DarkRefLen_s => DarkRefLen_s,
    SkipPixelsLen_s => SkipPixelsLHSLen_s,
    RealImageLen_s => RealImageLHSLen_s,
    BackPorchLen_s => BackPorchLHSLen_s,
    RedDarkRef_s => RedDarkRef_s,
    GreenDarkRef_s => GreenDarkRef_s,
    BlueDarkRef_s => BlueDarkRef_s,
    RedImage_s => RedImage_s,
    GreenImage_s => GreenImage_s,
    BlueImage_s => BlueImage_s,
    TpgWaitSync_s => TpgWaitSync_s,
    TpgLineSync_s => tpgSERDES_LINE_SYNC_BAR
) ;

-- Input tpg mux
IpTpgMux: process(PatternCon_s, tpgSERDES_D, tpgSERDES_LINE_SYNC_BAR, TpgWaitSync_s, 
                        test_SerdesClkEn_s, test_SerdesFifoOutData_s, DigWaitSync_s)

begin
    if (PatternCon_s(0) = '1') then
        muxedSerdesClkEn_s      <= '1' ;
        muxedSERDES_D               <= tpgSERDES_D(29 downto 0) ;
        muxedSERDES_LINE_SYNC_BAR   <= tpgSERDES_LINE_SYNC_BAR ;
        WaitSync_s <= TpgWaitSync_s ;

    else
        muxedSerdesClkEn_s      <= test_SerdesClkEn_s ;
        muxedSERDES_D               <= test_SerdesFifoOutData_s(29 downto 0) ;
--        muxedSERDES_LINE_SYNC_BAR   <= SerdesFifoOutData_s(31) ;
        muxedSERDES_LINE_SYNC_BAR   <= test_SerdesFifoOutData_s(20) ;
        WaitSync_s <= DigWaitSync_s ;

    end if ;
end process; 

--udigif: gdrb_newdigif 
--port map(
--    DIGIF_DEBUG_DATA => DIGIF_DEBUG_DATA,
--    Reverse_s => One_s,
--    RunIp_s => FocusOn_s,
--    IMAGE_TAP_BAR => IMAGE_TAP_BAR,
--    DiagVV_s => DiagVV_s,
--    FluorOn_s => Zero_s ,
--    FluorHi_s => Zero_s ,
--    Illumination_s => DoubleZero_s,
--    FrontPorchLen_s => FrontPorchLen_s,
--    DarkRefLen_s => DarkRefLen_s,
--    SkipPixelsLen_s => SkipPixelsLHSLen_s,
--    RealImageLen_s => RealImageLHSLen_s,
--    IlluminationOn_s => IlluminationOn_s,
--    IlluminationOff_s => IlluminationOff_s,
--    SERDES_CLK => iPLD_CLK,
--    SerdesClkEn_s => muxedSerdesClkEn_s,
--    SERDES_D => muxedSERDES_D,
--    DHDB_LINE_SYNC_BAR => muxedSERDES_LINE_SYNC_BAR,
--    ILLUM_STROBE => open,
--    DigRedData_s => DigRedData_s,
--    DigGreenData_s => DigGreenData_s,
--    DigBlueData_s => DigBlueData_s,
--    FluorData_s => open,
--    FluorLineSync_s => open,
--    DigInImage_s => DigInImage_s,
--    DigAllowRen_s => open,
--    DigFifoWen_s => DigFifoWen_s,
--    DigFifoOverflow_s => DigFifoOverflow_s,
--    LatchedDigFifoOverflow_s => ILatchedDigFifoOverflow_s,
--    DigWaitSync_s => DigWaitSync_s,
--    DigLineSync_s => DigLineSync_s,
--    DigLifoWrAdd_s => open
--);

-- below ports were missing from component 'gdrb_digif'
--udigif: gdrb_newdigif 
--port map(
--    Reverse_s => One_s,
--    SerdesClkEn_s => muxedSerdesClkEn_s,
--    DigAllowRen_s => open,
--    DigLifoWrAdd_s => open
--);

udigif : gdrb_digif 
port map(
    Debug_s => open,                                       -- : out std_logic ;
    RunIp_s => FocusOn_s,                                  -- : in std_logic ;
    IMAGE_TAP_BAR => IMAGE_TAP_BAR,                        -- : in std_logic ;                      -- Image tap from DSP (allow data through)
    DiagVV_s => DiagVV_s,                                  -- : in std_logic ;                      -- Image tap from software
    FluorOn_s => Zero_s ,                                  -- : in std_logic ;                      -- '0'=Off, '1'=On
    FluorHi_s => Zero_s ,                                  -- : in std_logic ;                      -- '0'=Low (8 bit), '1'=High (12 bit)
    Illumination_s => DoubleZero_s,                        -- : in std_logic_vector(1 downto 0) ;   -- "00"=off, "01"=on, "10"=pulsing
    FrontPorchLen_s => FrontPorchLen_s,                    -- : in std_logic_vector(8 downto 0) ;   -- Pixels between line synch and 1st dark reference
    DarkRefLen_s => DarkRefLen_s,                          -- : in std_logic_vector(6 downto 0) ;   -- No. of dark reference pixels
    SkipPixelsLen_s => SkipPixelsLHSLen_s,                 -- : in std_logic_vector(13 downto 0) ;  -- No. of pixels between dark ref. and real image
    RealImageLen_s => RealImageLHSLen_s,                   -- : in std_logic_vector(13 downto 0) ;  -- No. of real image pixels
    IlluminationOn_s => IlluminationOn_s,                  -- : in std_logic_vector(23 downto 0) ;
    IlluminationOff_s => IlluminationOff_s,                -- : in std_logic_vector(23 downto 0) ;
    SERDES_CLK => iPLD_CLK,                                -- : in std_logic ;                      -- Digitiser clock
    SERDES_D => muxedSERDES_D(SERDES_D_S(0)'RANGE),        -- : in std_logic_vector(19 downto 0) ;  -- Digitiser data
    AHDB_LINE_SYNC_BAR => muxedSERDES_LINE_SYNC_BAR,       -- : in std_logic ;                      -- Digitiser Start of Line (synced with data)
    ILLUM_STROBE => open,                                  -- : out std_logic ;                     -- Signal to pulse the LED's
    DigRedData_s => DigRedData_s,                          -- : out std_logic_vector(9 downto 0) ;
    DigGreenData_s => DigGreenData_s,                      -- : out std_logic_vector(9 downto 0) ;
    DigBlueData_s => DigBlueData_s,                        -- : out std_logic_vector(9 downto 0) ;
    FluorData_s => open,                                   -- : out std_logic_vector(19 downto 0) ;
    FluorLineSync_s => open,                               -- : out std_logic ;
    DigInImage_s => DigInImage_s,                          -- : out std_logic ;
    DigFifoWen_s => DigFifoWen_s,                          -- : out std_logic ;
    DigFifoOverflow_s => DigFifoOverflow_s,                -- : in std_logic ;
    LatchedDigFifoOverflow_s => ILatchedDigFifoOverflow_s, -- : out std_logic ;
    DigWaitSync_s => DigWaitSync_s,                        -- : out std_logic ;
    DigLineSync_s => DigLineSync_s                         -- : out std_logic
);

DigFifoData_s <=    '0' & DigInImage_s &
        DigRedData_s &
        DigGreenData_s & 
        DigBlueData_s after 1 nS ;

digfifo : gdrb_asyncfifo32x4096x32
port map (
    Data => DigFifoData_s,
    WrClock => iPLD_CLK,    
    RdClock => iPLD_CLK,
    WrEn => DigFifoWen_s,
    RdEn => LHSImProcRen_s,
    Reset => DigFifoReset_s,
    RPReset => DigFifoReset_s,
    Q => FocusData_s,
    Empty => DigFifoEmpty_s,
    Full => DigFifoFull_s,
    AlmostEmpty => DigFifoAEmpty_s,
    AlmostFull => DigFifoAFull_s
--  overflow => DigFifoOverflow_s,
--  underflow => DigFifoUnderflow_s,
);

userial : gdrb_serial
port map (
    RESET_BAR => gdrb_reset_bar,
    CLK => iPLD_CLK,
    SDO => SDO,                     -- bit 29 this will be connected on the PCB SDO pin
    SCLK => SCLK,
    SDI => SDI,
    SEN_BAR => SEN_BAR,
    --.    LEFT => LEFT,
    LEFT => Zero_s,             -- not needed as the 2 FPGA's on the GDRB are distincly different
    MixedMode_s => MixedMode_s,
    Illumination_s => Illumination_s,
    --.    FDSERDES_PD_BAR => FDSERDES_PD_BAR,
    --.    FDSERDES_REN => FDSERDES_REN,
    FDSERDES_PD_BAR => open, -- not used on this design for DS90CR218A rx IC
    FDSERDES_REN => open,    -- pin not available on DS90CR218A rx IC
    SER_BISTEN => SER_BISTEN,
    FpgaReset_s => FpgaReset_s,
    FocusOn_s => FocusOn_s,
    DiagVV_s => DiagVV_s,
    PatternCon_s => PatternCon_s,
    RedPattern_s => RedPattern_s,
    GreenPattern_s => GreenPattern_s,
    BluePattern_s => BluePattern_s,
    FrontPorchLen_s => FrontPorchLen_s,
    DarkRefLen_s => DarkRefLen_s,
    SkipPixelsLHSLen_s => SkipPixelsLHSLen_s,
    SkipPixelsRHSLen_s => SkipPixelsRHSLen_s,
    RealImageLHSLen_s => RealImageLHSLen_s, 
    RealImageRHSLen_s => RealImageRHSLen_s, 
    BackPorchLHSLen_s => BackPorchLHSLen_s, 
    BackPorchRHSLen_s => BackPorchRHSLen_s, 
    IlluminationOn_s => IlluminationOn_s, 
    IlluminationOff_s => IlluminationOff_s, 
    RedDarkRef_s => RedDarkRef_s, 
    GreenDarkRef_s => GreenDarkRef_s, 
    BlueDarkRef_s => BlueDarkRef_s, 
    RedImage_s => RedImage_s, 
    GreenImage_s => GreenImage_s, 
    BlueImage_s => BlueImage_s,
    FocusOffset_s => FocusOffset_s,
    FocusPixels_s => FocusPixels_s,
    FocusLines_s => FocusLines_s
);

----------------------------------------------------------------------
-- Data Mutiplexer
----------------------------------------------------------------------
InReg: process (gdrb_reset_bar, iPLD_CLK)

begin
       
    if iPLD_CLK = '1' and iPLD_CLK'event then
---Input registers
--.        RedData_s <= RD_DIG ;
--.        GreenData_s <= GD_DIG ;
--.        BlueData_s <= BD_DIG ;
--.        TopRedData_s <= RedData_s(9 downto 7) ; -- Top three bits were registered in the DHDB3 so mimic here
--.        TopGreenData_s <= GreenData_s(9 downto 7) ; -- Top three bits were registered in the DHDB3 so mimic here
--.        TopBlueData_s <= BlueData_s(9 downto 7) ; -- Top three bits were registered in the DHDB3 so mimic here
--.        BrightLineSyncBar_s <= DP_SYNC ;
--.        RBrightLineSyncBar_s <= BrightLineSyncBar_s ;
--.        RRBrightLineSyncBar_s <= RBrightLineSyncBar_s ;
--.        FocusLineSyncBar_s <= AHDB_LINE_SYNC_BAR ;
--.        DPFocus_s <= DP_FOCUS ;
--.        TestDataSel_s <= TD_DIG(2) and CONFIG ;
--.        TestData_s <= TD_DIG(1 downto 0) ;
        TestDataSel_s <= '0' and '0';
        TestData_s <= "00";
--.        DIG_DAT <= iDIG_DAT ;
    end if; --clk
end process InReg ;

----------------------------------------------------------------------
-- Data Mutiplexer
----------------------------------------------------------------------
DataMux: process (gdrb_reset_bar, iPLD_CLK)

begin

    if gdrb_reset_bar = '0' then
--       iDIG_DAT <= (others => '0') ;
       DIG_DAT <= (others => '0') ;
       LINE_SYNC_BAR <= '1';
       
    elsif iPLD_CLK = '0' and iPLD_CLK'event then
--       if DPFocus_s = '1' then 
--          if BrightLineSyncBar_s = '0' then
--             LINE_SYNC_BAR <= FocusLineSyncBar_s ;
--             iDIG_DAT <= FocusData_s(29 downto 0) ;  
--
--          end if; --BrightLineSyncBar_s
--       elsif TestDataSel_s = '1' then 
--          LINE_SYNC_BAR <= RRBrightLineSyncBar_s ;
--          iDIG_DAT <= TestData_s & TestData_s & TestData_s & TestData_s & TestData_s &
--                     TestData_s & TestData_s & TestData_s & TestData_s & TestData_s &
--                     TestData_s & TestData_s & TestData_s & TestData_s & TestData_s ;  
--
--       else  
--          LINE_SYNC_BAR <= RRBrightLineSyncBar_s ;
--          iDIG_DAT <= TopRedData_s & RedData_s(6 downto 0) & TopGreenData_s & GreenData_s(6 downto 0) & TopBlueData_s & BlueData_s(6 downto 0) ;
--                    
--       end if; --DP Fluor
       if TestDataSel_s = '1' then 
            LINE_SYNC_BAR <= RRBrightLineSyncBar_s ;
--.            DIG_DAT <= TestData_s & TestData_s & TestData_s & TestData_s & TestData_s &
--.                       TestData_s & TestData_s & TestData_s & TestData_s & TestData_s &
--.                       TestData_s & TestData_s & TestData_s & TestData_s & TestData_s ;
            DIG_DAT <= (others => TestData_s(0));
        else  
--            LINE_SYNC_BAR <= FocusData_s(20) ;
            DIG_DAT <= FocusData_s(DIG_DAT'RANGE) ;  
            ---SDO_DAT <= FocusData_s(30) ;         -- bit 30 this will be connected on the PCB SDO pin
            LINE_SYNC_BAR <= FocusData_s(31) ;
       end if;
    end if; --reset
end process DataMux ;


end;
