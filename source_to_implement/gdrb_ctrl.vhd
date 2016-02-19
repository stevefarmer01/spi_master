-------------------------------------------------------------------------
--
-- File name    :  F:\usr\microscan\Griffin\GHDB\design_definition\hdl\vhdl\gdrb_ctrl.vhd
-- Title        :  Griffin GDRB control FPGA
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 25/11/2015 14:10:00
--              :
-- Comments     : 
--              : 
-- Assumptions  : none
-- Limitations  : none
-- Known Errors : none
-- Developers   : 
--              : 
-- Notes        :
-- ----------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------
-- Copyright 2005-2016 (c) FFEI LTD
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
-- Revision History :   DON'T FORGET TO UPDATE UES BELOW !!!                                                              
-- ----------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :|    Changes Made:
--   v0.0  | David Frith       :| 25/11/2015:| New issue based on dhdb3 dig_pld_ccd v2.2
--   v0.1  | David Frith       :| 07/01/2016:| Serial bus simulated
--   v2.2  | David Frith       :| 03/07/2015:| Avoided the runt pulse on PHI_RS_S1_F_BAR and PHI_RS_S2_F_BAR
--   v2.3  | Steve Farmer      :| 29/01/2016:| modified to work in GDRB board for Griffin
-- ----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gdrb_ctrl_bb_pkg.ALL;

use work.gdrb_ctrl_bb_address_pkg.ALL;

use work.multi_array_types_pkg.all;

use work.spi_board_select_pkg.ALL;

entity gdrb_ctrl is
port
(
-- pragma translate_off
    --. JTAG i/f - 4
    TCK : in std_logic;  -- this will be controled by Begalbone
    TMS : in std_logic;  -- this will be controled by Begalbone
    TDI : in std_logic;  -- this will be controled by Begalbone
    TDO : out std_logic; -- this will be controled by Begalbone this will go to TDI of gdrb_dig_pld_dpmux FPGA
-- pragma translate_on

    ---Clk/Reset - 4
    CLK60M : in std_logic;
    FPGA_RESET : in std_logic := '0';       -- From Begalbone to control FPGA coming out of reset at right time
    FPGA_ENABLE_BAR : in std_logic := '1';      -- From Begalbone to tri-state all of FPGA's ports
    GDRB_RESET_BAR : in std_logic := '1';


    ---GHDB master SPI from GHDB to.....
    FOC_SDI : in std_logic;
    FOC_SCLK : in std_logic;
    FOC_SMODE_BAR : in std_logic;
    FOC_SDO : out std_logic;                 -- This will go back to GDPB via a pin on the camera link tx to GHDB
    ---......GDRB_DPMUX FPGA (straight through from FOC_xx ports unless there are issues)
    CISMUX_SDI : out std_logic := '0';
    cismux_sclk : out std_logic := '0';
    cismux_sdo : in std_logic;
    cismux_sen_bar : out std_logic := '0';

    ---Begalbone master SPI....
    VC_SPI_CS : in std_logic;
    VC_SPI_MOSI : in std_logic;
    VC_SPI_SCLK : in std_logic;
    VC_SPI_LDAC_BAR : in std_logic;
    ---....to on-board Voice Coil DAC (straight through unless there are issues)
    VC_SPI_DAC_SYNC_BAR : out std_logic;
    vc_spi_dac_din : out std_logic;
    VC_SPI_DAC_SCLK : out std_logic;
    VC_SPI_DAC_LDAC_BAR : out std_logic;

    ---GHDB master SPI has access to CIS PCB.....
    CIS_SPI_SCLK : out std_logic := '0';
    CIS_SPI_DIN : out std_logic := '0';
    ---....AFE's and......
    CIS_SPI_CS_AFE1_BAR : out std_logic := '0'; -- CIS AFE's
    CIS_SPI_CS_AFE2_BAR : out std_logic := '0';
    CIS_SPI_DOUT_AFE1  : in std_logic;        
    CIS_SPI_DOUT_AFE2  : in std_logic;        
    ---.....Illumination DAC's
    CIS_ILLUM_DAC_SYNC1_BAR : out std_logic := '0';  -- CIS DAC's are read only -- These DAC's are the same part number as 'Begalbone SPI to illumination DAC's' below
    CIS_ILLUM_DAC_SYNC2_BAR : out std_logic := '0';
    CIS_ILLUM_DAC_LDAC_BAR : out std_logic := '0';         

    ---Another Begalbone master SPI....
    BB_CTRL_SPI_MISO : out std_logic;
    BB_CTRL_SPI_SCLK : in std_logic;
    BB_CTRL_SPI_MOSI : in std_logic;
    BB_CTRL_SPI_CS : in std_logic;
    ---which is de_muxed onto 4 SPI ports (3 external and 1 internal).....
    SPI_MUX0 : in std_logic := '0';
    SPI_MUX1 : in std_logic := '0';
    SPI_MUX2 : in std_logic := '0';
    SPI_MUX3 : in std_logic := '0';
    ---....one which goes to on-board illumination DAC's and.....
    ILLUM_DAC_SPI_LDAC_BAR : out std_logic := '1';
    ILLUM_DAC_SPI_SCLK : out std_logic := '1';
    illum_dac_spi_din : out std_logic := '1';
    ILLUM_DAC_SPI_SYNC1_BAR : out std_logic := '1';
    ILLUM_DAC_SPI_SYNC2_BAR : out std_logic := '1';
    ---....User Interface PCB
    UI_SPI_CS_BAR : out std_logic := '1';
    ui_spi_mosi : out std_logic := '1';
    ui_spi_miso : in std_logic := '1';
    UI_SPI_SCLK : out std_logic := '1';

--    ---Route through FPGA to tx illumination discretes
--    CIS_R_STROBE : in std_logic; --removed 120216
--    CIS_G_STROBE : in std_logic; --removed 120216
--    CIS_B_STROBE : in std_logic; --removed 120216
--    CIS_R_STROBE_ENABLE : out std_logic; --removed 120216
--    CIS_G_STROBE_ENABLE : out std_logic; --removed 120216
--    CIS_B_STROBE_ENABLE : out std_logic; --removed 120216

    ------Register map pins-----.

    --Register Map Address - 0x0
    ---Motor Datum
    MOT1_DATUM : in std_logic;
    MOT2_DATUM : in std_logic;
    MOT3_DATUM : in std_logic;
    MOT4_DATUM : in std_logic;
    ---Cover detects
    FRONT_COVER_OPEN : in std_logic;
    LEFT_COVER_OPEN : in std_logic;
    RIGHT_COVER_OPEN : in std_logic;
    SPARE_SENSOR : in std_logic;
    ---Tray detects
    TRAY_SENS1 : in std_logic;
    TRAY_SENS2 : in std_logic;
    TRAY_SENS3 : in std_logic;
    TRAY_SENS4 : in std_logic;
    TRAY_GATE_DETECT : in std_logic;
    ---Interlocks
    ILOCK1_OK_BAR : in std_logic;  --changed 120216
    ILOCK2_OK_BAR : in std_logic;  --changed 120216
    --Plus a global fault bit for Register 0x4------------------------------.
    
    --Register Map Address - 0x1
    --Detection of above Register

    --Register Map Address - 0x2
    --Interupt mask of above Register

    --Register Map Address - 0x3
    ---Fault detection discretes
    MOT1_FAULT_BAR : in std_logic;
    MOT2_FAULT_BAR : in std_logic;
    MOT3_FAULT_BAR : in std_logic;
    MOT4_FAULT_BAR : in std_logic;
    P12V_IN_FAULT_BAR : in std_logic;
    P24V_FAULT : in std_logic;
    HR_LED_PWR_FAULT_BAR : in std_logic;
    TX_LED_PWR_FAULT_BAR : in std_logic;
    RX_LED_PWR_FAULT_BAR : in std_logic;
    VC_DRIVER_FAULT_BAR : in std_logic;
    SOL_FAULT_BAR : in std_logic;
    BB_FAULT : in std_logic;

    --Register Map Address - 0x4
    --Detection of above Register

    --Register Map Address - 0x5
    --Interupt mask of above Register

    --Register Map Address - 0x6
    --Miscellaneous in discretes
    ---CIS PCB discretes
    CIS_HDB_SENSE_BAR : in std_logic;
    ---GDRB to GHDB Discretes
    FOC_SENSE_BAR : in std_logic := '0';
    FOC_CONFIG : in std_logic := '0';
    ---On board discretes in
    HR_LED_SENSE_BAR : in std_logic;
    CIS_TX_LED_SENSE_BAR : in std_logic;
    UI_SENSE_BAR : in std_logic;
    UI_INT_BAR : in std_logic := '0';

    X_OUT3 : in std_logic := '0'; --added 120216
    Y_OUT3 : in std_logic := '0'; --added 120216
    X_SETUP_ALT : in std_logic := '0'; --added 120216
    Y_SETUP_ALT : in std_logic := '0'; --added 120216
    Z_SETUP_ALT : in std_logic := '0'; --added 120216

    --Register Map Address - 0x7
    --Detection of above Register 0x1

    --Register Map Address - 0x8
    --Interupt mask of above Register 0x1

    --Register Map Address - 0x9
    --Enables
    MOT1_ENABLE_BAR : out std_logic := '0';
    MOT2_ENABLE_BAR : out std_logic := '0';
    MOT3_ENABLE_BAR : out std_logic := '0';
    MOT4_ENABLE_BAR : out std_logic := '0';
    VC_ENABLE_BAR : out std_logic := '0';    -- Voice Coil enable - Must set DAC to 0x800 before enabling VC PWM driver
    TRAY_SENSOR_EN : out std_logic := '0';
    CIS_RX_LED_ENABLE : out std_logic;  --changed 120216
    SOL_ENABLE : out std_logic := '0';
    INDEX_CAPTURE : out std_logic := '0';

    CIS_TX_LED_ENABLE : out std_logic; --added 120216

    X_CAL : out std_logic := '0'; --added 120216
    Y_CAL : out std_logic := '0'; --added 120216
    Z_CAL : out std_logic := '0'; --added 120216

    --Register Map Address - 0xA
    --Unused Register

    --Register Map Address - 0xB
    --Unused Register

    --Register Map Address - 0xC
    --Unused Register

    --Register Map Address - 0xD
    --Unused Register

    --Register Map Address - 0xE
    --UES Register 1
    --Read only

    --Register Map Address - 0xF
    --UES Register 2
    --Read only

    --Miscellaneous IN discretes
    ---Voice coil enable and interupt
    VC_INT : out std_logic := '0';     -- TBD
    ---Bob's boot problem fix
    SYS_RESET_BAR : inout std_logic;
    UBOOT_MUX : out std_logic := '0';
    ---Discretes out
    SENSOR_INT : out std_logic := '0'; -- Changed bits set
    ILOCK1_OPEN_BAR : out std_logic:= '0';
    ILOCK2_OPEN_BAR : out std_logic:= '0';

    ---Spare pins for....
    ---....Begalbone
    BB_CTRL_SPARE1 : inout std_logic;
    BB_CTRL_SPARE2 : inout std_logic;
    BB_CTRL_SPARE3 : inout std_logic;
    ---....gdrb_dpmux onboard FPGA
    GDRB_DPMUX_SPARE1 : inout std_logic := '0';
    GDRB_DPMUX_SPARE2 : inout std_logic := '0';
    GDRB_DPMUX_SPARE3 : inout std_logic := '0';
    --....CIS PCB
    CIS_HDB_SPARE1 : out std_logic := '0'

);



begin

end gdrb_ctrl;

architecture behave of gdrb_ctrl is

component gdrb_ctrl_reg_map_top
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
           );
    Port (  
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            i_raw_ssn : in  std_logic;    -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol      : in std_logic := '0';                                -- CPOL value - 0 or 1
            cpha      : in std_logic := '0';                                -- CPHA value - 0 or 1
            lsb_first : in std_logic := '0';                                -- lsb first when '1' /msb first when
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            --Non-register map read/control bits
            interupt_flag : out std_logic := '0'
            );
end component;

component spi_board_select_top is
    generic ( 
            make_all_addresses_writeable_for_testing : boolean := FALSE; -- This is for testbenching only
            SPI_BOARD_SEL_ADDR_BITS : integer := 4;
            SPI_ADDRESS_BITS : integer := 4;
            SPI_DATA_BITS : integer := 16;
            MEM_ARRAY_T_INITIALISATION : mem_array_t
           );
    Port ( 
            clk : in std_logic;
            reset : in std_logic;
            ---Slave SPI interface pins
            sclk : in STD_LOGIC;
            ss_n : in STD_LOGIC;
            mosi : in STD_LOGIC;
            miso : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol      : in std_logic := '0';                                -- CPOL value - 0 or 1
            cpha      : in std_logic := '0';                                -- CPHA value - 0 or 1
            lsb_first : in std_logic := '0';                                -- lsb first when '1' /msb first when
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
          );
end component;

signal   Reset_s : std_logic ; -- was DHDB_RESET~ from DPMC

-- Digitiser type
constant Type_c       : std_logic_vector (2 downto 0) := "110" ;               -- 1=AHDB 2=DHDB 3=DHDB2 4=DHDB3 5=GDPB 6=GDRB

-- UES register constants
constant Position_c   : std_logic_vector(7 downto 0):="00000011";   --X"03";   -- U03 on the PCB
constant VersionNo_c  : std_logic_vector(7 downto 0):="00000001";   --X"00";   -- Revision 0.1
constant Day_c        : std_logic_vector(7 downto 0):="00000111";   --X"07";   -- Release day,   7th
constant Month_c      : std_logic_vector(3 downto 0):="0001";       --X"1";    -- Release month, Jan 
constant Year_c       : std_logic_vector(3 downto 0):="0110";       --X"6";    -- Release year,  2016

signal TransportClkCnt_s : std_logic_vector(18 downto 0) ; -- Transport Clock Counter (Counts down)

--Signals from serial process

signal LineLen_s     : std_logic_vector(18 downto 0);
signal SclkR_s  : std_logic ;
signal SclkRR_s  : std_logic ;
signal SenR_s  : std_logic ;
signal SenRR_s  : std_logic ;
signal SclkR3_s, SclkR4_s, SclkR5_s, SclkR6_s, SclkR7_s, SclkR8_s, SclkR9_s  : std_logic ;

signal BitShift_s  : std_logic_vector(18 downto 0) ;
signal BitCount_s  : std_logic_vector(4 downto 0) ;
signal BoardSelect_s  : std_logic_vector(3 downto 0) ;
signal Sdo_s : std_logic ;
signal SdoEn_s : std_logic ;
signal FocSdoEn_s : std_logic ;
signal A1SdoEn_s : std_logic ;
signal A2SdoEn_s : std_logic ;
signal Dac_s : std_logic ;
signal Rd_s : std_logic ;

signal Ok_s            : std_logic ;
signal FSense_s        : std_logic ;

signal EnableFocus_s   : std_logic ;
signal Agc1_s          : std_logic ;
signal Agc2_s          : std_logic ;
signal BlkClp1_s       : std_logic ;
signal BlkClp2_s       : std_logic ;
signal TDOSelBar_s     : std_logic ;

signal ISHP_AFE_1      : std_logic ;
signal ISHP_AFE_2      : std_logic ;
signal InternalClp_s   : std_logic ;
signal PulsedClp_s     : std_logic ;

---new signals
signal REG_MAP_SPI_CS_s : std_logic := '1';
signal REG_MAP_SPI_DO_s : std_logic := '1';
signal REG_MAP_SPI_DI_s : std_logic := '1';
signal REG_MAP_SPI_SCLK_s : std_logic := '1';

signal tray_test_vec : std_logic_vector(2 downto 0);
signal tray_test_vec_1 : std_logic_vector(1 downto 0);

---Old stuff
signal TP_CONFIG : std_logic := '0';      -- old sense pin to tell if GDHB is focus or image - need to get rid of this

---Schematic wrapper signals
signal BB_SPI_MUX_S : std_logic_vector(3 downto 0);
signal BB_SPARE : std_logic_vector(3 downto 1) := (others => 'Z');

signal reg_map_reset_s : std_logic := '0';

--Begalbone SPI register map discrete signals
signal reg_map_array_from_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
signal reg_map_array_to_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));

----Map input pins to reg_map_array_to_pins_s
--
signal sensor_status_bits_s, fault_status_bits_s, misc_status_bits_s : std_logic_vector(SPI_DATA_BITS-1 downto 0) := (others => '0');

----These need to be on the schematic pins......
signal CLK60M_S : std_logic;

begin
----These need to be on the schematic pins......
CLK60M_S <= TO_UX01(CLK60M);

---dummy code to prevent ports being optimized away
CISMUX_SDI <= cismux_sdo;

---dummy code to prevent ports being opitimized away
--CIS_RX_LED_ENABLE_BAR <= CIS_HDB_SENSE_BAR;
--CIS_HDB_SPARE1 <= '1' when CIS_HDB_SENSE_BAR = '1' else 'Z';
---CIS_HDB_SPARE2 <= '1' when CIS_HDB_SENSE_BAR = '1' else 'Z';


---Schematic wrapper code
BB_SPARE(1) <= BB_CTRL_SPARE1;
BB_SPARE(2) <= BB_CTRL_SPARE2;
BB_SPARE(3) <= BB_CTRL_SPARE3;
--dummy code to prevent ports being optimized away
BB_SPARE <= (others=> '0') when BB_SPARE(BB_SPARE'LOW) = '0' else (others=> 'Z');

---Tray detects dummy code
tray_test_vec <= ( CIS_SPI_DOUT_AFE1  & CIS_SPI_DOUT_AFE2 & GDRB_RESET_BAR );
VC_INT <= '1' when to_integer(unsigned(tray_test_vec)) = 0 else '0'; -- use unused inputs to prevent them being optimised away

tray_test_vec_1 <= ( FPGA_ENABLE_BAR & FPGA_RESET);
--GDRB_DPMUX_SPARE(GDRB_DPMUX_SPARE'LOW) <= '1' when to_integer(unsigned(tray_test_vec_1)) = 0 else 'Z'; -- use unused inputs to prevent them being optimised away
--GDRB_DPMUX_SPARE <= (others => '1') when (to_integer(unsigned(tray_test_vec)) + to_integer(unsigned(tray_test_vec_1))) = 0 else (others => 'Z'); -- use unused inputs to prevent them being optimised away

---Schematic wrapper code
GDRB_DPMUX_SPARE1 <= '1' when (to_integer(unsigned(tray_test_vec)) + to_integer(unsigned(tray_test_vec_1))) = 0 else 'Z'; -- use unused inputs to prevent them being optimised away
GDRB_DPMUX_SPARE2 <= '1' when (to_integer(unsigned(tray_test_vec)) + to_integer(unsigned(tray_test_vec_1))) = 0 else 'Z'; -- use unused inputs to prevent them being optimised away
GDRB_DPMUX_SPARE3 <= '1' when (to_integer(unsigned(tray_test_vec)) + to_integer(unsigned(tray_test_vec_1))) = 0 else 'Z'; -- use unused inputs to prevent them being optimised away

---Bob's boot problem fix
sys_reset_bar <= '1' when FPGA_RESET = '1' else 'Z';

---Straight thru connections
VC_SPI_DAC_SYNC_BAR <= VC_SPI_CS;
vc_spi_dac_din <= VC_SPI_MOSI;
VC_SPI_DAC_SCLK <= VC_SPI_SCLK;
VC_SPI_DAC_LDAC_BAR <= VC_SPI_LDAC_BAR;

--CIS_R_STROBE_ENABLE <= CIS_R_STROBE;
--CIS_G_STROBE_ENABLE <= CIS_G_STROBE;
--CIS_B_STROBE_ENABLE <= CIS_B_STROBE;


---Schematic wrapper code
BB_SPI_MUX_S(0) <= SPI_MUX0;
BB_SPI_MUX_S(1) <= SPI_MUX1;
BB_SPI_MUX_S(2) <= SPI_MUX2;
BB_SPI_MUX_S(3) <= SPI_MUX3;

---de_mux Begalbone master SPI i/f to various peripheral SPI's
beagalbone_mux_proc : process (BB_SPI_MUX_S, BB_CTRL_SPI_MOSI, BB_CTRL_SPI_CS, REG_MAP_SPI_DO_S, ui_spi_miso)
    constant reg_map_mux_c : integer := 0;
    constant illum_dac_0_mux_c : integer := 1;
    constant illum_dac_1_mux_c : integer := 2;
    constant ui_mux_c : integer := 3;
begin
    ---default values for outputs otherwise latch may be inferred
    REG_MAP_SPI_CS_S <= '1';
    ILLUM_DAC_SPI_LDAC_BAR <= '1';  ---check if this is right with AD5322ARM DAC datasheet
    ILLUM_DAC_SPI_SYNC1_BAR <= '1';  ---check if this is right with AD5322ARM DAC datasheet
    ILLUM_DAC_SPI_SYNC2_BAR <= '1';  ---check if this is right with AD5322ARM DAC datasheet
    UI_SPI_CS_BAR <= '1';

    case to_integer(unsigned(BB_SPI_MUX_S)) is

    when reg_map_mux_c => ---internal register map to this FPGA
        BB_CTRL_SPI_MISO <= REG_MAP_SPI_DO_S;
        REG_MAP_SPI_CS_S <= BB_CTRL_SPI_CS;

    when illum_dac_0_mux_c => ---Begalbone SPI to illumination DAC 0
        BB_CTRL_SPI_MISO <= BB_CTRL_SPI_MOSI;
        ILLUM_DAC_SPI_LDAC_BAR <= BB_CTRL_SPI_CS;  ---check if this is right with AD5322ARM DAC datasheet
        ILLUM_DAC_SPI_SYNC1_BAR <= BB_CTRL_SPI_CS;  ---check if this is right with AD5322ARM DAC datasheet

    when illum_dac_1_mux_c => ---Begalbone SPI to illumination DAC 1
        BB_CTRL_SPI_MISO <= BB_CTRL_SPI_MOSI;
        ILLUM_DAC_SPI_LDAC_BAR <= BB_CTRL_SPI_CS;  ---check if this is right with AD5322ARM DAC datasheet
        ILLUM_DAC_SPI_SYNC2_BAR <= BB_CTRL_SPI_CS;  ---check if this is right with AD5322ARM DAC datasheet

    when ui_mux_c =>   ---Begalbone SPI to User Interface
        BB_CTRL_SPI_MISO <= ui_spi_miso;
        UI_SPI_CS_BAR <= BB_CTRL_SPI_CS;

    when others => ---default to SPI inactive state
        BB_CTRL_SPI_MISO <= '0';

    end case;
end process;

---Do not de_mux sclks and mosi as these are masked at peripheral end of SPI by sen signals in de_mux above
REG_MAP_SPI_SCLK_S <= BB_CTRL_SPI_SCLK;
REG_MAP_SPI_DI_S <= BB_CTRL_SPI_MOSI;
ILLUM_DAC_SPI_SCLK <= BB_CTRL_SPI_SCLK;
illum_dac_spi_din <= BB_CTRL_SPI_MOSI;
UI_SPI_SCLK <= BB_CTRL_SPI_SCLK;
ui_spi_mosi <= BB_CTRL_SPI_MOSI;

---------------------------------------------------------------------------------
---------------------Register map SPI interface to BegalBone---------------------
---------------------------------------------------------------------------------
--reg_map_reset_s <= not GDRB_RESET_BAR; 
reg_map_reset_s <= '0';  --GDRB_RESET_BAR needs level converting or driving


gdrb_ctrl_bb_spi_reg_map_inst : gdrb_ctrl_reg_map_top
    generic map(
            make_all_addresses_writeable_for_testing => FALSE,      -- This is for testbenching only
            SPI_ADDRESS_BITS => SPI_ADDRESS_BITS,                   -- : integer := 4;
            SPI_DATA_BITS => SPI_DATA_BITS,                         -- : integer := 16
            MEM_ARRAY_T_INITIALISATION => mem_array_t_initalised    -- : mem_array_t
            )
    Port map(  
            clk => CLK60M_S,                                        -- : in std_logic;
            reset => reg_map_reset_s,                               -- : in std_logic;
            ---Slave SPI interface pins
            sclk => REG_MAP_SPI_SCLK_s,                             -- : in STD_LOGIC;
            ss_n => REG_MAP_SPI_CS_s,                               -- : in STD_LOGIC;
            i_raw_ssn => REG_MAP_SPI_CS_s,                          -- : in  std_logic;                                                                                          -- Slave Slect Active low - this is not masked by board select for Griffin protocol - for normal operation (not Griffin) connect this to i_ssn
            mosi => REG_MAP_SPI_DI_s,                               -- : in STD_LOGIC;
            miso => REG_MAP_SPI_DO_s,                               -- : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol => SPI_BB_CPOL,                                    -- : in std_logic := '0';                                                                                    -- CPOL value - 0 or 1
            cpha => SPI_BB_CPHA,                                    -- : in std_logic := '0';                                                                                    -- CPHA value - 0 or 1
            lsb_first => SPI_BB_LSB_FIRST,                          -- : in std_logic := '0';                                                                                    -- lsb first when '1' /msb first when
            --Discrete signals
            reg_map_array_from_pins => reg_map_array_from_pins_s,   -- : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins => reg_map_array_to_pins_s,       -- : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            --Non-register map read/control bits
            interupt_flag => SENSOR_INT                             -- : out std_logic := '0'
            );


----Map input pins to reg_map_array_to_pins_s
--
sensor_status_bits_s <= '0' & ILOCK2_OK_BAR & ILOCK1_OK_BAR & TRAY_GATE_DETECT & TRAY_SENS4 & TRAY_SENS3 & TRAY_SENS2 & TRAY_SENS1 & SPARE_SENSOR & RIGHT_COVER_OPEN & LEFT_COVER_OPEN & FRONT_COVER_OPEN & MOT4_DATUM & MOT3_DATUM & MOT2_DATUM & MOT1_DATUM;
fault_status_bits_s <= std_logic_vector(to_unsigned(0,4)) & BB_FAULT & SOL_FAULT_BAR & VC_DRIVER_FAULT_BAR & RX_LED_PWR_FAULT_BAR & TX_LED_PWR_FAULT_BAR & HR_LED_PWR_FAULT_BAR & P24V_FAULT & P12V_IN_FAULT_BAR & MOT4_FAULT_BAR & MOT3_FAULT_BAR & MOT2_FAULT_BAR & MOT1_FAULT_BAR;
misc_status_bits_s <= std_logic_vector(to_unsigned(0,4)) & Y_OUT3 & X_OUT3 & Z_SETUP_ALT & Y_SETUP_ALT & X_SETUP_ALT & CIS_HDB_SENSE_BAR & FOC_SENSE_BAR & FOC_CONFIG & HR_LED_SENSE_BAR & CIS_TX_LED_SENSE_BAR & UI_SENSE_BAR & UI_INT_BAR;

input_pins_proc : process(sensor_status_bits_s, fault_status_bits_s, misc_status_bits_s)
begin
    set_data(reg_map_array_from_pins_s, (to_integer(unsigned(SENSOR_STATUS_ADDR_C))), sensor_status_bits_s);
    set_data(reg_map_array_from_pins_s, (to_integer(unsigned(FAULT_STATUS_ADDR_C))), fault_status_bits_s);
    set_data(reg_map_array_from_pins_s, (to_integer(unsigned(MISC_STATUS_ADDR_C))), misc_status_bits_s);
end process;


----Map output pins to reg_map_array_to_pins_s
--
MOT1_ENABLE_BAR <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 0);
MOT2_ENABLE_BAR <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 1);
MOT3_ENABLE_BAR <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 2);
MOT4_ENABLE_BAR <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 3);
VC_ENABLE_BAR <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 4);
TRAY_SENSOR_EN <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 5);
--CIS_RX_LED_ENABLE_BAR <= reg_map_array_to_pins_s(to_integer(unsigned(ENABLES_OUT_ADDR_C)))(6); --removed 120216
SOL_ENABLE <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 7);
INDEX_CAPTURE <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 8);

CIS_TX_LED_ENABLE <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 9); --added 120216
X_CAL <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 10); --added 120216
Y_CAL <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 11); --added 120216
Z_CAL <= get_data_bit(reg_map_array_to_pins_s, (to_integer(unsigned(ENABLES_OUT_ADDR_C))), 12); --added 120216


---------------------------------------------------------------------------------
---------------------SPI interface from GHDB and to GDPB-------------------------
---------------------------------------------------------------------------------
gdrb_ctrl_ghdb_spi_reg_map_inst : spi_board_select_top
    generic map(
            make_all_addresses_writeable_for_testing => TRUE,                   -- This is for testbenching only
            SPI_BOARD_SEL_ADDR_BITS => SPI_BOARD_SEL_ADDR_BITS,                 -- : integer := 4;
            SPI_ADDRESS_BITS => SPI_BOARD_SEL_PROTOCOL_ADDR_BITS,               -- : integer := 4;
            SPI_DATA_BITS => SPI_BOARD_SEL_PROTOCOL_DATA_BITS,                  -- : integer := 16
            MEM_ARRAY_T_INITIALISATION => bs_mem_array_t_initalised_c           -- Function that populates this constant in 'gdrb_ctrl_bb_pkg'
            )
    Port map(  
            clk => CLK60M_S,                                                    -- : in std_logic;
            reset => reg_map_reset_s,                                           -- : in std_logic;
            ---Slave SPI interface pins
            sclk => TO_UX01(FOC_SCLK),                                          -- : in STD_LOGIC;
            ss_n => TO_UX01(FOC_SMODE_BAR),                                     -- : in STD_LOGIC;
            mosi => TO_UX01(FOC_SDI),                                           -- : in STD_LOGIC;
            miso => FOC_SDO,                                                    -- : out STD_LOGIC;
            --Low level SPI interface parameters
            cpol => SPI_BOARD_CPOL,                                             -- : in std_logic := '0';                                                                                    -- CPOL value - 0 or 1
            cpha => SPI_BOARD_CPHA,                                             -- : in std_logic := '0';                                                                                    -- CPHA value - 0 or 1
            lsb_first => SPI_BOARD_LSB_FIRST,                                   -- : in std_logic := '0';                                                                                    -- lsb first when '1' /msb first when
            --Discrete signals
            reg_map_array_from_pins => open,                                    -- : in mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0'));
            reg_map_array_to_pins => open                                       -- : out mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
            );


-----original code from dp_mux FPGA in GHDB
--
--SDIProc: process (FOC_SDI, BitCount_s, Dac_s)
--begin
--    if (BitCount_s < "00111") and (Dac_s = '1') then
--        cis_spi_din <= '0' ; -- Load the DACs with 0 up to bit 5
--    else
--        cis_spi_din <= FOC_SDI ;
--    end if ;
--end process SDIProc ;
--
--SDOProc: process (SdoEn_s, SDO_s)
--begin
--    if SdoEn_s = '1' then
--        FOC_SDO <= SDO_s ;
--    else
--        FOC_SDO <= 'Z' ;
--    end if ;
--end process SDOProc ;
--
------------------------------------------------------------------------
---- Digitiser serial protocol handler
------------------------------------------------------------------------
--cis_serial : process (FPGA_RESET, CLK60M)
--    constant ImageAFE1_c           : std_logic_vector (3 downto 0) := "0001" ;
--    constant ImageAFE2_c           : std_logic_vector (3 downto 0) := "0010" ;
--    constant ImageDAC_c            : std_logic_vector (3 downto 0) := "0011" ;
--    constant FocusAFE1_c           : std_logic_vector (3 downto 0) := "0101" ;
--    constant FocusAFE2_c           : std_logic_vector (3 downto 0) := "0110" ;
--    constant FocusDAC_c            : std_logic_vector (3 downto 0) := "0111" ;
--    constant ImageWriteEnable_c    : std_logic_vector (6 downto 0) := "0000000" ;
--    constant ImageReadEnable_c     : std_logic_vector (6 downto 0) := "0000100" ;
--    constant FocusWriteEnable_c    : std_logic_vector (6 downto 0) := "0100000" ;
--    constant FocusReadEnable_c     : std_logic_vector (6 downto 0) := "0100100" ;
--    constant StatusAddress_c       : std_logic_vector (3 downto 0) := "0000" ;
--    constant LineTimeLowAddress_c  : std_logic_vector (3 downto 0) := "0010" ;
--    constant LineTimeHighAddress_c : std_logic_vector (3 downto 0) := "0001" ;
--    constant ControlAddress_c      : std_logic_vector (3 downto 0) := "0011" ;
--    constant UES1_c                : std_logic_vector (3 downto 0) := "1100" ;
--    constant UES2_c                : std_logic_vector (3 downto 0) := "1101" ;
--    constant UES3_c                : std_logic_vector (3 downto 0) := "1110" ;
--    constant UES4_c                : std_logic_vector (3 downto 0) := "1111" ;
--    constant Mode_c                : std_logic_vector (3 downto 0) := "0000" ;
--begin
--   if (FPGA_RESET = '1') then --1
--        SclkR_s <= '0' ;
--        SclkRR_s <= '0' ;
--        SclkR3_s <= '0' ;
--        SclkR4_s <= '0' ;
--        SclkR5_s <= '0' ;
--        SclkR6_s <= '0' ;
--        SclkR7_s <= '0' ;
--        SclkR8_s <= '0' ;
--        SclkR9_s <= '0' ;
--        SenR_s <= '0' ;
--        SenRR_s <= '0' ;
--        SDO_s <= '0' ;
--        BitShift_s <= (others => '0') ;
--        BitCount_s <= (others => '0') ;
--        SdoEn_s <= '1';
--        FocSdoEn_s <= '0' ;
--        A1SdoEn_s <= '0' ;
--        A2SdoEn_s <= '0' ;
--        Dac_s <= '0' ;
--        Rd_s <= '0' ;
--        CIS_SPI_SCLK <= '0' ;
--        CIS_SPI_CS_AFE1_BAR <= '1' ;
--        CIS_SPI_CS_AFE2_BAR <= '1' ;
--        CIS_ILLUM_DAC_SYNC1_BAR <= '1' ;
--        CIS_ILLUM_DAC_SYNC2_BAR <= '1' ;
--        --.LineLen_s <= "000001000001001000" ; --Default Line length = 259.15uS at 66MHz
--        LineLen_s <= "0000000011100101111" ; --Default Line length = 67uS at 60MHz
--        EnableFocus_s <= '0' ;
--        Agc1_s <= '0' ;
--        Agc2_s <= '0' ;
--        BlkClp1_s <= '0' ;
--        BlkClp2_s <= '0' ;
--        TDOSelBar_s <= '1' ;
--        PulsedClp_s <= '0' ;
--        Reset_s <= '0' ;
--    elsif rising_edge(CLK60M) then --1
--       
--        SclkR_s <= FOC_SCLK ;
--        SclkRR_s <= SclkR_s ;
--        SclkR3_s <= SclkRR_s ;
--        SclkR4_s <= SclkR3_s ;
--        SclkR5_s <= SclkR4_s ;
--        SclkR6_s <= SclkR5_s ;
--        SclkR7_s <= SclkR6_s ;
--        SclkR8_s <= SclkR7_s ;
--        SclkR9_s <= SclkR8_s ;
--        SenR_s <= not FOC_SMODE_BAR ;
--        SenRR_s <= SenR_s ;
--        
--        if FocSdoEn_s = '1' then
--            SDO_s <= FOC_SDI ;
--        elsif A1SdoEn_s = '1' then
--            SDO_s <= CIS_SPI_DOUT_AFE1  ;
--        elsif A2SdoEn_s = '1' then
--            SDO_s <= CIS_SPI_DOUT_AFE2  ;
--        else
--            SDO_s <= BitShift_s(8);
--        end if; --2
--        
--        if (SenR_s = '1') then
--            CIS_SPI_SCLK <= SclkRR_s ;
--            if (BitCount_s = "10011") and (Dac_s = '1') then
--                CIS_SPI_SCLK <= SclkRR_s and not (SclkR5_s and not SclkR6_s) and not (SclkR8_s and not SclkR9_s) ; -- Generate 2 extra clocks
--            end if;
--        end if;
--    
--        if (SenR_s = '0') then
--            BitCount_s <= (others => '0') ;
--        elsif (SclkR_s = '1') and (SclkRR_s = '0') and (BitCount_s < "11111") then
--            BitCount_s <= std_logic_vector(unsigned(BitCount_s) + 1) ;
--        end if;
--
--        if (SenRR_s = '0') then
--        --Set them both, we'll abort them later if not required
--            CIS_SPI_CS_AFE1_BAR <= FOC_SMODE_BAR ;
--            CIS_SPI_CS_AFE2_BAR <= FOC_SMODE_BAR ;
--            CIS_ILLUM_DAC_SYNC1_BAR <= '1' ;
--            CIS_ILLUM_DAC_SYNC2_BAR <= '1' ;
--        elsif (SclkR_s = '1') and (SclkRR_s = '0') and (SenR_s = '1') then --2A
--            BitShift_s <= BitShift_s(17 downto 0) & To_UX01(FOC_SDI) ;
--            if BitCount_s = "00001" then
--                if (BitShift_s(0) = '1') then 
--                   FocSdoEn_s <= '1' ; -- Enable the Focus SDO if the first serial bit is '1'
--                elsif TP_CONFIG = '1' then  
--                   FocSdoEn_s <= To_UX01(FOC_SDI) ; -- Enable the Focus SDO if the second serial bit is '1'
--                else
--                   FocSdoEn_s <= '0' ;
--                end if;   
--            end if;
--            if BitCount_s = "00011" then
--                CIS_SPI_CS_AFE1_BAR <= '1' ;  -- overloaded
--                CIS_SPI_CS_AFE2_BAR <= '1' ;  -- overloaded
--                A1SdoEn_s <= '0' ;      -- overloaded
--                A2SdoEn_s <= '0' ;      -- overloaded
--                Dac_s <= '0' ;          -- overloaded
--                CIS_ILLUM_DAC_SYNC1_BAR <= '1' ; -- overloaded
--                CIS_ILLUM_DAC_SYNC2_BAR <= '1' ; -- overloaded
--                if ((TP_CONFIG = '1') and (BoardSelect_s = ImageAFE1_c)) or ((TP_CONFIG = '0') and (BoardSelect_s = FocusAFE1_c)) then
--                --Keep enabled if selected
--                    CIS_SPI_CS_AFE1_BAR <= '0' ;
--                    A1SdoEn_s <= '1' ;
--                end if ;
--                if ((TP_CONFIG = '1') and (BoardSelect_s = ImageAFE2_c)) or ((TP_CONFIG = '0') and (BoardSelect_s = FocusAFE2_c)) then
--                --Keep enabled if selected
--                   CIS_SPI_CS_AFE2_BAR <= '0' ;
--                   A2SdoEn_s <= '1' ;
--                end if ;
--                if ((TP_CONFIG = '1') and (BoardSelect_s = ImageDAC_c)) or ((TP_CONFIG = '0') and (BoardSelect_s = FocusDAC_c)) then
--                   Dac_s <= '1' ;
--                end if ;
--            end if ;
--            if BitCount_s = "00100" then
--                Rd_s <= To_UX01(FOC_SDI) ;
--            end if ;
--            if BitCount_s = "00101" then
--                if Dac_s = '1' and (Rd_s = '0') then
--                    --Set them both, we'll abort them later if not required
--                    CIS_ILLUM_DAC_SYNC1_BAR <= '0' ;
--                    CIS_ILLUM_DAC_SYNC2_BAR <= '0' ;
--                end if ;
--            end if ;
--            if BitCount_s = "00110" then
--            --Use this address bit to determine which DAC write is aborted
--                if To_UX01(FOC_SDI) = '0' then
--                    CIS_ILLUM_DAC_SYNC2_BAR <= '1' ; -- clear this one early (abort)
--                else
--                    CIS_ILLUM_DAC_SYNC1_BAR <= '1' ; -- clear this one early (abort)
--                end if ;
--            end if ;
--        end if; --2A
--
--        if (SenRR_s = '1') and (SenR_s = '0') then --2B
--            if (TP_CONFIG = '1' and (BitShift_s(18 downto 12) = ImageWriteEnable_c)) or (TP_CONFIG = '0' and (BitShift_s(18 downto 12) = FocusWriteEnable_c)) then --3
--                SdoEn_s <= '1'; -- Continue driving the SDO if access was a write
--    
--                case BitShift_s(11 downto 8) is
--                  
--                   when LineTimeHighAddress_c =>
--                      LineLen_s(18 downto 11) <= Bitshift_s(7 downto 0);
--                    
--                   when LineTimeLowAddress_c =>
--                      LineLen_s(10 downto 3) <= Bitshift_s(7 downto 0);
--    
--                   when ControlAddress_c =>
--                      EnableFocus_s <= Bitshift_s(0) ;
--                      Agc1_s <= Bitshift_s(1) ;
--                      Agc2_s <= Bitshift_s(2) ;
--                      BlkClp1_s <= Bitshift_s(3) ;
--                      BlkClp2_s <= Bitshift_s(4) ;
--                      TDOSelBar_s <= Bitshift_s(5) ;
--                      PulsedClp_s <= Bitshift_s(6) ; 
--                      Reset_s <= Bitshift_s(7) ;
--                    
--                   when others =>
--                    
--                end case;
--            elsif (TP_CONFIG = '1' and (BitShift_s(18 downto 12) = ImageReadEnable_c)) or (TP_CONFIG = '0' and (BitShift_s(18 downto 12) = FocusReadEnable_c)) then --3
--                SdoEn_s <= '1'; -- Continue driving the SDO if access was a read
--              
--                case BitShift_s(11 downto 8) is
--                  
--                   when StatusAddress_c =>
--                      Bitshift_s(7 downto 0) <= Mode_c(3 downto 1) & FSense_s & Type_c & Ok_s  ;
--                  
--                   when LineTimeHighAddress_c =>
--                      Bitshift_s(7 downto 0) <= LineLen_s(18 downto 11);
--                             
--                   when LineTimelowAddress_c =>
--                      Bitshift_s(7 downto 0) <= LineLen_s(10 downto 3);
--                             
--                   when ControlAddress_c =>
--                      Bitshift_s(7 downto 0) <= "00000000" ;
--                      Bitshift_s(0) <= EnableFocus_s ;
--                      Bitshift_s(1) <= Agc1_s ;
--                      Bitshift_s(2) <= Agc2_s ;
--                      Bitshift_s(3) <= BlkClp1_s ;
--                      Bitshift_s(4) <= BlkClp2_s ;
--                      Bitshift_s(5) <= TDOSelBar_s ;
--                      Bitshift_s(6) <= PulsedClp_s ;
--                      Bitshift_s(7) <= Reset_s ;
--    
--                   when UES1_c =>
--                      Bitshift_s(7 downto 0) <= TP_CONFIG & Position_c(6 downto 0)  ;
--    
--                   when UES2_c =>
--                      Bitshift_s(7 downto 0) <= VersionNo_c(7 downto 0)  ;
--    
--                   when UES3_c =>
--                      Bitshift_s(7 downto 0) <= Day_c(7 downto 0)  ;
--    
--                   when UES4_c =>
--                      Bitshift_s(7 downto 4) <= Month_c(3 downto 0)  ;
--                      Bitshift_s(3 downto 0) <= Year_c(3 downto 0)  ;
--    
--                   when others =>
--                  
--                end case;
--            --.         CIS                                    Focus                                AFE2 or DAC                 AFE1
--            elsif (BitShift_s(18) = '1') or ((TP_CONFIG = '1') and (BitShift_s(17) = '1')) or (BitShift_s(16) = '1') or (BitShift_s(15) = '1') then 
--                SdoEn_s <= '1';
--            else
--                SdoEn_s <= '0'; -- Access for FPGA's so stop driving SDO
--            end if ; --3
--        end if; --2B
--    end if; --1
--end process;
--
end;

------------------------------------------------------------------------------------------------------------------------------------------------
---- Really old stuff below here 
------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------
---- Line phase state machine
------------------------------------------------------------------------
--LinePhase: process (Reset_s, PLD_CCD_CLK)
--
--
---- States for the Line phase state machine
--constant PreTransfer_c    : std_logic_vector (3 downto 0) := "0000" ; -- 0
--constant Transfer1_c      : std_logic_vector (3 downto 0) := "1000" ; -- 8
--constant Transfer2_c            : std_logic_vector (3 downto 0) := "1001" ; -- 9
----constant Transfer3_c          : std_logic_vector (3 downto 0) := "1010" ; -- 10
----constant Transfer4_c          : std_logic_vector (3 downto 0) := "1011" ; -- 11
----constant Transfer5_c          : std_logic_vector (3 downto 0) := "1100" ; -- 12
--constant PostTransfer_c  : std_logic_vector (3 downto 0) := "0010" ; -- 2
--constant InvalidPix_c    : std_logic_vector (3 downto 0) := "0011" ; -- 3
--constant AdcClmp_c       : std_logic_vector (3 downto 0) := "0100" ; -- 4
--constant RestOfLine_c    : std_logic_vector (3 downto 0) := "0101" ; -- 5
--
---- Count values for uPD8835 CCD timing.
---- Note count is in CCD clock periods minus 1. There are two pixels per CCD clock period.
-- 
--constant PreTransferLen_c  : std_logic_vector(7 downto 0) := "00011111" ;  -- 32 CCD transport Clock periods at start of line before transfer
--constant TransferLen1_c    : std_logic_vector(7 downto 0) := "00111111" ;  -- 64 CCD transport Clock periods during TG1 high
--constant PostTransferLen_c : std_logic_vector(7 downto 0) := "00011111" ;  -- 32 CCD transport Clock periods before transport clocks start
--constant TransferLen2_c    : std_logic_vector(7 downto 0) := "00000001" ;  -- 2 CCD transport Clock periods after transport clocks start
--constant InvalidPixLen_c   : std_logic_vector(7 downto 0) := "00010000" ;  -- 17 CCD transport clocks to ADC Clamp on black pixels 
--
---- Count value for LM98519 timing. 
--constant AdcClmpLen_c      : std_logic_vector(7 downto 0) := "00001011" ;  -- 12 transport clocks to clamp ADC over first 12 black pixels
--
--begin
--
--    if Reset_s = '1' then
--       LinePhase_s <= (others => '0') ;
--       TransportClkCnt_s <= (others => '0') ;
--       Clp_s <= '0' ;
--       TransportEn <= '0' ;
--       Tg1_s <= '0' ;
----       Tg2_s <= '1' ;
----     ForcePhi_s <= '0' ;
--       IDP_SYNC <= '0' ;
--       RDP_SYNC <= '0' ;
--       RRDP_SYNC <= '0' ;
--       F_LINE_SYNC_OUT_BAR_s <= '0' ;
--       
---- And all the rest
--
--    elsif PLD_CCD_CLK = '1' and PLD_CCD_CLK'event then
--       RDP_SYNC <= IDP_SYNC ;
--       RRDP_SYNC <= RDP_SYNC ;
--       if TransportClkCntEn_s = '1' then 
--          if TransportClkCnt_s = "0000000000000000000" then
--             case LinePhase_s is
--                when PreTransfer_c =>
--                   LinePhase_s <= Transfer1_c ;
--                   TransportClkCnt_s <= "00000000000" & TransferLen1_c ;
--                   Clp_s <= '0' ;
--                   TransportEn <= '0' ;
--                   Tg1_s <= '1' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '1' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when Transfer1_c =>
--                   LinePhase_s <= PostTransfer_c ;
--                   TransportClkCnt_s <= "00000000000" & PostTransferLen_c ;
--                   Clp_s <= '0' ;
--                   TransportEn <= '0' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '1' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when PostTransfer_c =>
--                   LinePhase_s <= Transfer2_c ;
--                   TransportClkCnt_s <= "00000000000" & TransferLen2_c ;
--                   Clp_s <= '0' ;
--                   TransportEn <= '1' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '1' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when Transfer2_c =>
--                   LinePhase_s <= InvalidPix_c ;
--                   TransportClkCnt_s <= "00000000000" & InvalidPixLen_c ;
--                   Clp_s <= '0' ;
--                   TransportEn <= '1' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '0' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when InvalidPix_c =>
--                   LinePhase_s <= AdcClmp_c ;
--                   TransportClkCnt_s <= "00000000000" & AdcClmpLen_c ;
--                   Clp_s <= '1' ;
--                   TransportEn <= '1' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '0' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when AdcClmp_c =>
--                   LinePhase_s <= RestOfLine_c ;
--                   TransportClkCnt_s <= LineLen_s ;
--                   Clp_s <= '0' ;
--                   TransportEn <= '1' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '0' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '1' ;
--
--                when RestOfLine_c =>
--                   LinePhase_s <= PreTransfer_c ;
--                   TransportClkCnt_s <= "00000000000" & PreTransferLen_c;
--                   Clp_s <= '0' ;
--                   TransportEn <= '0' ;
--                   Tg1_s <= '0' ;
----                     Tg2_s <= '1' ;
----                 ForcePhi_s <= '0' ;
--                   IDP_SYNC <= '0' ;
--                   F_LINE_SYNC_OUT_BAR_s <= '0' ;
--
--                when others =>
--             end case;
--          else
--             TransportClkCnt_s <= unsigned(TransportClkCnt_s) - 1 ;
--          
--          end if ;
--       end if ;
--    end if ;
--end process LinePhase ;
--
------------------------------------------------------------------------
---- Pixel phase state machine
------------------------------------------------------------------------
--PixelPhase: process (Reset_s, PLD_CCD_CLK)
--
--
--constant Rst_c         : std_logic_vector (2 downto 0) := "000" ; 
--constant Clmp_c        : std_logic_vector (2 downto 0) := "001" ; 
--constant Idle3_c       : std_logic_vector (2 downto 0) := "110" ;
--constant Idle4_c       : std_logic_vector (2 downto 0) := "111" ; 
--
--begin
--
--    if Reset_s = '1' then
--       PixelPhase_s <= Rst_c ;
--       TransportClkCntEn_s <= '0' ;
--       Phi1_s <= '1' ;
--       Phi2_s <= '0' ;
--       PhiRst_s <= '0' ;
--       Mclk_s <= '0' ;
--
---- And all the rest
--
--    elsif PLD_CCD_CLK = '0' and PLD_CCD_CLK'event then 
--
--       case PixelPhase_s is
--               
--          when Rst_c  =>                   
--             PixelPhase_s <= Clmp_c ;
--             TransportClkCntEn_s <= '0' ;
----             RTransportEn <= '1' ;
--             Phi1_s <= '1' ;
--             Phi2_s <= '0' ;
--             PhiRst_s <= '0' ;
--             Mclk_s <= '0' ; 
----               PhiTg_s <= '0' ;
--                    
--          when Clmp_c  =>
--             if TransportEn = '1' then  
--                PixelPhase_s <= Rst_c ;
--                TransportClkCntEn_s <= '1' ;
--                Phi1_s <= '0' ;
--                Phi2_s <= '1' ;
--                PhiRst_s <= '1' ;
--                Mclk_s <= '1' ;
----                  PhiTg_s <= '0' ;
--
--             else 
--                PixelPhase_s <= Idle3_c ;
--                TransportClkCntEn_s <= '1' ;
--                Phi1_s <= '1' ;
--                Phi2_s <= '0' ;
--                PhiRst_s <= '0' ;
--                Mclk_s <= '1' ;
----                  PhiTg_s <= ForcePhi_s ;
--             
--             end if ;
--
--          when Idle3_c  =>
--             PixelPhase_s <= Idle4_c ;
--             TransportClkCntEn_s <= '0' ;
----             RTransportEn <= '0' ;
--             Phi1_s <= '1' ;
--             Phi2_s <= '0' ;
--             PhiRst_s <= '0' ;
--             Mclk_s <= '0' ;
----               PhiTg_s <= ForcePhi_s ;
--            
--          when others =>
-- --                when Idle4_c  =>
--             if TransportEn = '1' then  
--                PixelPhase_s <= Rst_c ;
--                TransportClkCntEn_s <= '1' ;
--                Phi1_s <= '1' ;
--                Phi2_s <= '0' ;
--                PhiRst_s <= '1' ;
--                Mclk_s <= '1' ;
----                  PhiTg_s <= '0' ;
--
--             else 
--                PixelPhase_s <= Idle3_c ;
--                TransportClkCntEn_s <= '1' ;
--                Phi1_s <= '1' ;
--                Phi2_s <= '0' ;
--                PhiRst_s <= '0' ;
--                Mclk_s <= '1' ;
----                  PhiTg_s <= ForcePhi_s ;
--
--             end if ;            
--       end case;
--    end if ;
--end process PixelPhase ;

------------------------------------------------------------------------
---- CCD Control Output Assignement falling edge 
------------------------------------------------------------------------
--CcdClockOutputAssignement: process (Reset_s, PLD_CCD_CLK)
--
--begin
--    if Reset_s = '1' then
--     PHI_SH_BAR <= '1';
----       PhiRstRf_s <= '1';
--       Phi1Rf_s <= '1'; 
--       Phi2Rf_s <= '1';
--
--    elsif PLD_CCD_CLK = '0' and PLD_CCD_CLK'event then 
--       PHI_SH_BAR <= not Tg1_s after 4nS ;
----       PhiRstRf_s <=  PhiRst_s;
--       Phi1Rf_s <= Phi1_s ;
--       Phi2Rf_s <= Phi2_s ;
--      
--    end if;
--end process CcdClockOutputAssignement;

------------------------------------------------------------------------
---- CCD Control Output Assignement rising edge
------------------------------------------------------------------------
--CcdClockOutputAssignementFalling: process (Reset_s, PLD_CCD_CLK)
--
--begin
--    if Reset_s = '1' then
--       PhiRstRr_s <= '1';
----       PhiRstRrRr_s <= '1';
--       Phi1Rr_s <= '1'; 
----       Phi1RrRr_s <= '1';
--       Phi2Rr_s <= '1';
----       Phi2RrRr_s <= '1';
--
--    elsif PLD_CCD_CLK = '1' and PLD_CCD_CLK'event then
--       PhiRstRr_s <= PhiRst_s;
----       PhiRstRrRr_s <= PhiRstRr_s;
--       Phi1Rr_s <= Phi1_s;
----       Phi1RrRr_s <= Phi1Rr_s;
--       Phi2Rr_s <= Phi2_s;
----       Phi2RrRr_s <= Phi2Rr_s;
--
--    end if;
--end process CcdClockOutputAssignementFalling;

------------------------------------------------------------------------
---- Tristate
------------------------------------------------------------------------
--Tristate: process (--PhiRst_s, PhiRstRrRr_s, PhiRstRf_s, 
--                 PhiRstRr_s, 
--                 --Phi1_s, Phi1RrRr_s,
--                 --Phi2_s, Phi2RrRr_s,
--                 --PhiTg_s, PhiTgRR_s, 
--                 Phi1Rf_s, 
--                 Phi1Rr_s,
--                 Phi2Rf_s, 
--                 Phi2Rr_s,
--                 EnableFocus_s,
--                 PLD_CCD_CLK, 
--                 PHI_RS_S1_F_BAR, PHI_RS_S2_F_BAR, 
--                 PHI_CP_S1_F_BAR, PHI_CP_S2_F_BAR)
--
--begin
--
----PH1A_S1    
----    if (Phi1RrRr_s = '1' and Phi1_s = '0') and PhiTg_s = '0' and PhiTgRR_s = '0' then
--       PHI1A_S1_F_BAR <= 'Z';
--
----    else
----       PHI1A_S1_F_BAR <= not Phi1Rf_s;
--
----    end if;
----    if (Phi1RrRr_s = '0' and Phi1_s = '1') or PhiTg_s = '1' or PhiTgRR_s = '1' then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI1A_S1_BAR <= 'Z';
--
--    else
--       PHI1A_S1_BAR <= not (Phi1Rr_s and (PHI_CP_S1_F_BAR or Phi1Rf_s)) after 7nS ;
--
--    end if; 
--
----PH1A_S2    
----    if (Phi1RrRr_s = '1' and Phi1_s = '0') and PhiTg_s = '0' and PhiTgRR_s = '0' then
--       PHI1A_S2_F_BAR <= 'Z';
--
----    else
----       PHI1A_S2_F_BAR <= not Phi1RfS2_s;
--
----    end if;
----    if (Phi1RrRr_s = '0' and Phi1_s = '1') or PhiTg_s = '1' or PhiTgRR_s = '1' then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI1A_S2_BAR <= 'Z';
--
--    else
--       PHI1A_S2_BAR <= not (Phi1Rr_s and (PHI_CP_S2_F_BAR or Phi1Rf_s)) after 7nS ;
--
--    end if;
--
----PH2A_S1    
----    if (Phi2RrRr_s = '1' and Phi2_s = '0') or PhiTg_s = '1' or PhiTgRR_s = '1'  then
--       PHI2A_S1_F_BAR <= 'Z';
--
----    else
----       PHI2A_S1_F_BAR <= not Phi2Rf_s ;
--
----    end if;
----    if (Phi2RrRr_s = '0' and Phi2_s = '1') and PhiTg_s = '0' and PhiTgRR_s = '0' then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI2A_S1_BAR <= 'Z';
--
--    else
--       PHI2A_S1_BAR <= not (Phi2Rr_s or (Phi2Rf_s and not PHI_CP_S1_F_BAR)) after 7nS ;
--
--    end if;
--
----PH2A_S2    
----    if (Phi2RrRr_s = '1' and Phi2_s = '0') or PhiTg_s = '1' or PhiTgRR_s = '1' then
--       PHI2A_S2_F_BAR <= 'Z';
--
----    else
----       PHI2A_S2_F_BAR <= not Phi2RrS2_s;
--
----    end if;
----    if (Phi2RrRr_s = '0' and Phi2_s = '1') and PhiTg_s = '0' and PhiTgRR_s = '0' then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI2A_S2_BAR <= 'Z';
--
--    else
--       PHI2A_S2_BAR <= not (Phi2Rr_s or (Phi2Rf_s and not PHI_CP_S2_F_BAR)) after 7nS ;
--
--    end if; 
--
----PH2B_S1    
----    if (Phi2RrRr_s = '1' and Phi2_s = '0') or PhiTg_s = '1' or PhiTgRR_s = '1'  then
--       PHI_2B_S1_F_BAR <= 'Z';
--
----    else
----       PHI_2B_S1_F_BAR <= not Phi2Rf_s ;
--
----    end if;
----    if (Phi2RrRr_s = '0' and Phi2_s = '1') and PhiTg_s = '0' and PhiTgRR_s = '0' then
----       PHI_2B_S1_BAR <= 'Z';
--
----    else
--       PHI_2B_S1_BAR <= not (Phi2Rr_s or (Phi2Rf_s and not PHI_CP_S1_F_BAR)) after 7nS ;
--
----    end if;
--
----PH2B_S2    
----    if (Phi2RrRr_s = '1' and Phi2_s = '0') or PhiTg_s = '1' or PhiTgRR_s = '1'  then
--       PHI_2B_S2_F_BAR <= 'Z';
--
----    else
----       PHI_2B_S2_F_BAR <= not Phi2Rf_s ;
--
----    end if;
----    if (Phi2RrRr_s = '0' and Phi2_s = '1') and PhiTg_s = '0' and PhiTgRR_s = '0' then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI_2B_S2_BAR <= 'Z';
--
--    else
--       PHI_2B_S2_BAR <= not (Phi2Rr_s or (Phi2Rf_s and not PHI_CP_S2_F_BAR)) after 7nS ;
--
--    end if;
--
----PHI_RS_S1   
----    if (PhiRstRf_s = '1' or PhiRstRrRr_s = '1') then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI_RS_S1_F_BAR <= 'Z';
--
--    else
----       PHI_RS_S1_F_BAR <= not (PhiRstRr_s and PLD_CCD_CLK) after 7nS ;
--       PHI_RS_S1_F_BAR <= not (PhiRst_s and PLD_CCD_CLK) after 7nS ;
--
--    end if;
----    if (PhiRst_s = '1' or PhiRstRr_s = '1') then
--       PHI_RS_S1_BAR <= 'Z';
----
----    else
----       PHI_RS_S1_BAR <= not PhiRstRf_s;
----
----    end if; 
--
----PHI_RS_S2   
----    if (PhiRstRf_s = '1' or PhiRstRrRr_s = '1') then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI_RS_S2_F_BAR <= 'Z';
--
--    else
----       PHI_RS_S2_F_BAR <= not (PhiRstRr_s and PLD_CCD_CLK) after 7nS ;
--       PHI_RS_S2_F_BAR <= not (PhiRst_s and PLD_CCD_CLK) after 7nS ;
--
--    end if;
----    if (PhiRst_s = '1' or PhiRstRr_s = '1') then
--       PHI_RS_S2_BAR <= 'Z';
----
----    else
----       PHI_RS_S2_BAR <= not PhiRstRf_s;
----
----    end if; 
--
----PHI_CP_S1   
----    if (PhiRstRf_s = '1' or PhiRstRrRr_s = '1') then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI_CP_S1_F_BAR <= 'Z';
--
--    else
--       PHI_CP_S1_F_BAR <= not (PhiRstRr_s and (not PHI_RS_S1_F_BAR or not PLD_CCD_CLK)) after 7nS ;
--
--    end if;
----    if (PhiRst_s = '1' or PhiRstRr_s = '1') then
--       PHI_CP_S1_BAR <= 'Z';
----
----    else
----       PHI_CP_S1_BAR <= not PhiRstRf_s;
----
----    end if; 
--
----PHI_CP_S2   
----    if (PhiRstRf_s = '1' or PhiRstRrRr_s = '1') then
--  if EnableFocus_s = '1' then -- ensure pin feed back is used
--       PHI_CP_S2_F_BAR <= 'Z';
--
--    else
--       PHI_CP_S2_F_BAR <= not (PhiRstRr_s and (not PHI_RS_S2_F_BAR or not PLD_CCD_CLK)) after 7nS ;
--
--    end if;
----    if (PhiRst_s = '1' or PhiRstRr_s = '1') then
--       PHI_CP_S2_BAR <= 'Z';
----
----    else
----       PHI_CP_S2_BAR <= not PhiRstRf_s;
----
----    end if; 
--
--end process Tristate;

------------------------------------------------------------------------
---- Test Data Generator
------------------------------------------------------------------------
--TestData: process (Reset_s, PLD_CCD_CLK)
--
--constant Reset_c            : std_logic_vector (4 downto 0) := "00000" ; -- 0
--constant TestLineCount1_c   : std_logic_vector (4 downto 0) := "00100" ; -- 1
--constant TestLineCount2_c   : std_logic_vector (4 downto 0) := "00101" ; -- 1
--constant TestLineCount3_c   : std_logic_vector (4 downto 0) := "00110" ; -- 1
--constant TestLineCount4_c   : std_logic_vector (4 downto 0) := "00111" ; -- 1
--constant Test551_c          : std_logic_vector (4 downto 0) := "01000" ; -- 1
--constant Test552_c          : std_logic_vector (4 downto 0) := "01001" ; -- 1
--constant Test553_c          : std_logic_vector (4 downto 0) := "01010" ; -- 1
--constant Test554_c          : std_logic_vector (4 downto 0) := "01011" ; -- 1
--constant TestAA1_c          : std_logic_vector (4 downto 0) := "01100" ; -- 1
--constant TestAA2_c          : std_logic_vector (4 downto 0) := "01101" ; -- 1
--constant TestAA3_c          : std_logic_vector (4 downto 0) := "01110" ; -- 1
--constant TestAA4_c          : std_logic_vector (4 downto 0) := "01111" ; -- 1
--constant TestFF1_c          : std_logic_vector (4 downto 0) := "10000" ; -- 1
--constant TestFF2_c          : std_logic_vector (4 downto 0) := "10001" ; -- 1
--constant TestFF3_c          : std_logic_vector (4 downto 0) := "10010" ; -- 1
--constant TestFF4_c          : std_logic_vector (4 downto 0) := "10011" ; -- 1
--constant Data_c             : std_logic_vector (4 downto 0) := "10100" ; -- 1
--
--constant Data155_c : std_logic_vector (1 downto 0) := "01" ; -- 1
--constant Data2AA_c : std_logic_vector (1 downto 0) := "10" ; -- 1
--
--begin
--    if Reset_s = '1' then
--       TestDataPhase_s <= (others => '0') ;
--       LineCnt_s <= (others => '0') ;
--       TestData_s <= (others => '0') ;
--       TestDataSel_s <= '0';
--
--     elsif PLD_CCD_CLK = '1' and PLD_CCD_CLK'event then
----      if DP_Mux = '1' then
--           case TestDataPhase_s is
--              when Reset_c =>
--                 TestData_s <= LineCnt_s ;
--                 TestDataSel_s <= '1' ;
--                 if IDP_SYNC = '0' then
--                    TestDataPhase_s <= TestLineCount2_c ;
--                 
--                 end if ;
--
--              when TestLineCount1_c =>
--                 TestDataPhase_s <= TestLineCount2_c ;
--                 TestData_s <= LineCnt_s ;
--                 TestDataSel_s <= '1' ;
--
--              when TestLineCount2_c =>
--                 TestDataPhase_s <= TestLineCount3_c ;
--                 TestData_s <= LineCnt_s ;
--                 TestDataSel_s <= '1' ;
--
--              when TestLineCount3_c =>
--                 TestDataPhase_s <= TestLineCount4_c ;
--                 TestData_s <= LineCnt_s ;
--                 TestDataSel_s <= '1' ;
--
--              when TestLineCount4_c =>
--                 TestDataPhase_s <= Test551_c ;
--                 TestData_s <= Data155_c ;
--                 TestDataSel_s <= '1' ;
--
--              when Test551_c =>
--                 TestDataPhase_s <= Test552_c ;
--                 TestData_s <= Data155_c ;
--                 TestDataSel_s <= '1';
--
--              when Test552_c =>
--                 TestDataPhase_s <= Test553_c ;
--                 TestData_s <= Data155_c ;
--                 TestDataSel_s <= '1';
--
--              when Test553_c =>
--                 TestDataPhase_s <= Test554_c ;
--                 TestData_s <= Data155_c ;
--                 TestDataSel_s <= '1';
--
--              when Test554_c =>
--                 TestDataPhase_s <= TestAA1_c ;
--                 TestData_s <= Data2AA_c ;
--                 TestDataSel_s <= '1';
--
--              when TestAA1_c =>
--                 TestDataPhase_s <= TestAA2_c ;
--                 TestData_s <= Data2AA_c ;
--                 TestDataSel_s <= '1';
--
--              when TestAA2_c =>
--                 TestDataPhase_s <= TestAA3_c ;
--                 TestData_s <= Data2AA_c ;
--                 TestDataSel_s <= '1';
--
--              when TestAA3_c =>
--                 TestDataPhase_s <= TestAA4_c ;
--                 TestData_s <= Data2AA_c ;
--                 TestDataSel_s <= '1';
--
--              when TestAA4_c =>
--                 TestDataPhase_s <= TestFF1_c ;
--                 TestData_s <= (others => '1') ;
--                 TestDataSel_s <= '1';
--
--              when TestFF1_c =>
--                 TestDataPhase_s <= TestFF2_c ;
--                 TestData_s <= (others => '1') ;
--                 TestDataSel_s <= '1';
--
--              when TestFF2_c =>
--                 TestDataPhase_s <= TestFF3_c ;
--                 TestData_s <= (others => '1') ;
--                 TestDataSel_s <= '1';
--
--              when TestFF3_c =>
--                 TestDataPhase_s <= TestFF4_c ;
--                 TestData_s <= (others => '1') ;
--                 TestDataSel_s <= '1';
--
--              when others =>
----              when TestFF4_c =>
--                 TestData_s <= (others => '0') ;
--                 TestDataSel_s <= '0';
--                 if IDP_SYNC = '1' then
--                    TestDataPhase_s <= Reset_c ;
--                    LineCnt_s <= unsigned(LineCnt_s) + 1 ;
--                 
--                 end if ;
--           end case;
----        end if ; -- dp sync
--     end if ; --reset
--end process TestData ;
