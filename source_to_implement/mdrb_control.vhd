-------------------------------------------------------------------------
--
-- File name    :  E:\usr\microscan\AMIS\MDRB\design_definition\hdl\vhdl\mdrb_control.vhd
-- Title        :  AMIS Configuration CPLD
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 01/11/2005 10:12:36
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
-- Copyright 2006-2007 (c) FFEI LTD
--
-- FFEI LTD owns the sole copyright to this software. Under 
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
-- Revision History :	DON'T FORGET TO UPDATE UES BELOW !!!															  
-- ----------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :|    Changes Made:
--   v2.2 :| Robert Shalders   :| 01/03/13  :| Implementation of changes for new Illumination Board
--	 v2.1 :| David Frith	   :| 23/09/08  :| Added in SUPPLY_OK (MPM only) Move Copley status signal back to CARR_AMP_FAULT_BAR
--	 v2.0 :| David Frith	   :| 20/02/08  :| Added in the Copley status signal on A_FLAG
--	 v1.9 :| David Frith	   :| 19/02/08  :| Sorted out the polarity of the fault register
--	 v1.8 :| David Frith	   :| 18/02/08  :| Inverted the carriage enable and fault bits for the Copley Amp
--	 v1.7 :| David Frith	   :| 20/12/07  :| Added carriage and voice coil dac watchdogs
--	 v1.6 :| Bill Hawes		   :| 28/8/07   :| Fixed the typo in order of alocation of Sw1Edge_s - Sw4Edge_s to Bitshift_s(7) - Bitshift_s(10)
--   v1.5 :| Don Isik          :| 15/06/07  :| MDRB_INT polarity was wrong 
--   v1.4 :| Don Isik          :| 11/06/07  :| sensor/switch/fault/cover signals made same at reset, to prevent spurious edges 
--   v1.3 :| Don Isik          :| 08/06/07  :| Fix write access to edge register. 
--											:| CAR_DAC_LD_BAR not affected by reset, allowing Soft Resets via Carr DAC
--											:| Sensor Edge Detect reg bits toggled by software, allowing individual operation.
--   v1.2 :| Don Isik          :| 10/05/07  :| Double register VC and Carr SPISTEA signals.
--   v1.1 :| Don Isik          :| 02/05/07  :| Serial comms now armed prior to transfers then dis-armed.
--											:| UES Registers added. LED DACs disabled for read access 
--											:| LED DACs data now sent by the CPLD.
--   v1.0 :| Brandon Cox       :| 13/04/07  :| DAC_SYNC signals delayed enabling 16 valid clocks to DACs
--                                          :| ILLUM_ENABLE_BAR inverted to ensure LED off at reset
--   v0.9 :| Don Isik          :| 05/03/07  :| Fixed SDO from Commutation PAL
--   v0.8 :| Don Isik          :| 22/02/07  :| Reset DacAddress_s.  Commented out unused pins.
--   v0.7 :| Don Isik          :| 26/01/06  :| Changed order of SW4-1 bits in status register
--   v0.6 :| Don Isik          :| 25/01/06  :| PROG_EN~ bit controlled by Programme Enable Register
--   v0.5 :| Don Isik          :| 10/01/06  :| Added Spare pins. Remove X_Fuse. Invert Datum flags
--   v0.4 :| Don Isik          :| 22/11/05  :| Fixed LEDEnable
--   v0.3 :| Don Isik          :| 22/11/05  :| BitShift_s becomes (21 downto 0) was (20 downto 0)
--   v0.2 :| Don Isik          :| 21/11/05  :| IllumDacSync_s and OverVDacSync_s utilised 
--   v0.1 :| Don Isik          :| 18/11/05  :| Moved Stepper stuff to the Commutation PAL
--   v0.0 :| Don Isik          :| 01/11/05  :| Automatically Generated
-- ----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity mdrb_control is
port
(
 
-- pragma translate_off

      TDI               : in std_logic ;
      TMS               : in std_logic ;
      TCK               : in std_logic ;
      TDO               : out std_logic ;
-- pragma translate_on


-- Serial  (these are shared with the commutation CPLD
      SDI               : in std_logic ;
      SEN_BAR           : in std_logic ;
      SCLK              : in std_logic ;
      SDO               : out std_logic; 
-- Switch Inputs  (from HMI)
      SW_1_BAR          : in std_logic ;
      SW_2_BAR          : in std_logic ;
      SW_3_BAR          : in std_logic ;
      SW_4_BAR          : in std_logic ;
-- LED Control Signal (To HMI)
      LED_FLASHER       : in std_logic ;		-- Input from the LED flasher cct on the board
      LED_1             : out std_logic ;		-- LED drive outputs
      LED_2             : out std_logic ;
      LED_3             : out std_logic ;
      LED_4             : out std_logic ;
-- Fault signals
      S_FUSE_BLOWN      : in std_logic ;      	-- Stepper motor fuse
      CARR_AMP_FAULT_BAR    : in std_logic ;    -- Carriage electronics/motor fault
      VC_FAULT_BAR      : in std_logic ;      	-- Voice coil fault
      EPI_LED_FAULT_BAR    : in std_logic ;   	-- Epi LED fault
      TRANS_LED_FAULT_BAR   : in std_logic ;  	-- Transmission LED fault
-- Datum Flags
      A_FLAG_BAR        : in std_logic ;
      B_FLAG_BAR        : in std_logic ;
      C_FLAG_BAR        : in std_logic ;
      D_FLAG_BAR        : in std_logic ;
      E_FLAG_BAR        : in std_logic ;
      X_DATUM_BAR       : in std_logic ;		
-- Board Control
      MDRB_INT_BAR   	: out std_logic ;
      CLK_10M_1         : in std_logic ;
      PORESET_BAR       : in std_logic ;
      PROG_EN_BAR       : out std_logic ;
-- Illumination Control
      ILLUM_DAC_SYNC_BAR :out std_logic ;
      ILLUM_ENABLE_BAR  : out std_logic ;
      OVR_DAC_SYNC_BAR  : out std_logic ;
      EPI_ENABLE_BAR    : out std_logic ;
      TRANS_ENABLE_BAR  : out std_logic ;
      DAC_SDI           : out std_logic ;
      DAC_CLK           : out std_logic ;
--      MAIN_COVER_OPEN   : in std_logic ;
      AUX_COVER_OPEN    : in std_logic ;
      COVER_OPEN        : out std_logic ;      -- Main or Aux Cover is open 
      X_MDI             : in std_logic ;

	  SPARE1            : out std_logic ;   -- Used for WATCHDOG_CARR_ENABLE
	  SPARE2            : out std_logic ;   -- Used for WATCHDOG_VC_ENABLE
	  SPARE3            : in std_logic ;    -- Used for SUPPLY_OK

-- Spare signals not used
	  SPARE4            : in std_logic ;
	  SPARE5            : in std_logic ;

--NEW PINS
-- Carriage DAC signals
      CARR_SPISTEA_BAR  : in std_logic ;
      CARR_DAC_LD_BAR   : out std_logic ;
-- Voice Coil DAC signals
      VC_SPISTEA_BAR    : in std_logic ;
      VC_DAC_LD_BAR     : out std_logic ;
-- Scan Illumination DAC signals
	  ILLUM_DAC_LD_BAR  : out std_logic ;
-- Overview Illumination DAC signals
	  OVR_DAC_LD_BAR   	: out std_logic 

);

begin

end mdrb_control;

architecture behave of mdrb_control is

-- UES register constants
constant Position_c   : std_logic_vector(7 downto 0):="00010000";   --X"10";   -- U10 on the PCB
constant VersionNo_c  : std_logic_vector(7 downto 0):="00100010";   --X"22";   -- Revision 2.2
constant Day_c        : std_logic_vector(7 downto 0):="00001000";   --X"08";   -- Release day,   8th
constant Month_c      : std_logic_vector(3 downto 0):="0011";       --X"3";    -- Release month, March 
constant Year_c       : std_logic_vector(3 downto 0):="0011";       --X"3";    -- Release year,  2013

-- Edge detect write enable State Machine
Type EdgeWrEnType is (Idle, S0, S1, S2) ;
signal EdgeWrEnState_s  : EdgeWrEnType ;

-- VC_DAC_LD_BAR State Machine
Type VcDacType is (Idle, S0, S1, S2, S3) ;
signal VcDacState_s  : VcDacType ;

-- Illum_DAC_LD_BAR State Machine
Type IllumDacType is (Idle, S0, S1, S2, S3) ;
signal IllumDacState_s  : IllumDacType ;

-- Overview_DAC_LD_BAR State Machine
Type OverviewDacType is (Idle, S0, S1, S2, S3) ;
signal OverviewDacState_s  : OverviewDacType ;

-- SerialEnable State Machine
Type SerialEnableType is (Idle, SerialArm, SerialEn) ;
signal SerialEnableState_s  : SerialEnableType ;

-- Serial DAC State Machine
Type DacType is (Idle, SenLo1_s, SenLo2_s, SenHi_s,
                 DataW1, DataW2, DataW3, DisableSynch) ;
signal DacState_s  : DacType ;

signal EdgeWriteEnable_s : std_logic ;
signal SclkR_s           : std_logic ;
signal SclkRR_s          : std_logic ;
signal SenR_s            : std_logic ;
signal SenRR_s           : std_logic ;
signal SerialEnable_s    : std_logic ;		-- Serial enable generated internally
signal ResetSerialSM_s   : std_logic ;		-- Reset signal to serial state machines 
signal SdoEn_s           : std_logic ;		-- Enable for SDO output
signal SDO_s           	 : std_logic ;
signal LedFlashSlow_s    : std_logic ;
signal LedFlashFast_s    : std_logic ;
signal Led1_s            : std_logic ;
signal Led2_s            : std_logic ;
signal Led3_s            : std_logic ;
signal Led4_s            : std_logic ;
signal MdrbInt_s         : std_logic ;
-- LED Control Register signals
signal Led1FlRate_s      : std_logic ;
signal Led2FlRate_s      : std_logic ;
signal Led3FlRate_s      : std_logic ;
signal Led4FlRate_s      : std_logic ;
signal Led1FlOn_s        : std_logic ;
signal Led2FlOn_s        : std_logic ;
signal Led3FlOn_s        : std_logic ;
signal Led4FlOn_s        : std_logic ;
signal Led1Enable_s      : std_logic ;
signal Led2Enable_s      : std_logic ;
signal Led3Enable_s      : std_logic ;
signal Led4Enable_s      : std_logic ;
signal TransLedEnable_s  : std_logic ;
signal EpiLedEnable_s    : std_logic ;
signal ScanLedEnable_s   : std_logic ;
-- Sensor Status Register signals
signal AuxCover_s        : std_logic ;
signal MainCover_s       : std_logic ;
signal Sw1_s             : std_logic ;
signal Sw2_s             : std_logic ;
signal Sw3_s             : std_logic ;
signal Sw4_s             : std_logic ;
signal FAult_s           : std_logic ;
signal XSlideDatum_s     : std_logic ;
signal MotorADatum_s     : std_logic ;
signal MotorBDatum_s     : std_logic ;
signal MotorCDatum_s     : std_logic ;
signal MotorDDatum_s     : std_logic ;
signal MotorEDatum_s     : std_logic ;
-- Sensor Status edge Detect Register signals
signal AuxCoverEdge_s    : std_logic ;
signal MainCoverEdge_s   : std_logic ;
signal Sw1Edge_s         : std_logic ;
signal Sw2Edge_s         : std_logic ;
signal Sw3Edge_s         : std_logic ;
signal Sw4Edge_s         : std_logic ;
signal FAultEdge_s       : std_logic ;
signal XSlideDatumEdge_s : std_logic ;
signal MotorADatumEdge_s : std_logic ;
signal MotorBDatumEdge_s : std_logic ;
signal MotorCDatumEdge_s : std_logic ;
signal MotorDDatumEdge_s : std_logic ;
signal MotorEDatumEdge_s : std_logic ;
-- Sensor Status edge Detect CLOCK generator signals
signal AuxCoverR_s : std_logic ;
signal AuxCoverRR_s : std_logic ;
signal AuxCoverClkEn_s : std_logic ;
signal MainCoverR_s : std_logic ;
signal MainCoverRR_s : std_logic ;
signal MainCoverClkEn_s : std_logic ;
signal Sw1R_s : std_logic ;
signal Sw1RR_s : std_logic ;
signal Sw1ClkEn_s : std_logic ;
signal Sw2R_s : std_logic ;
signal Sw2RR_s : std_logic ;
signal Sw2ClkEn_s : std_logic ;
signal Sw3R_s : std_logic ;
signal Sw3RR_s : std_logic ;
signal Sw3ClkEn_s : std_logic ;
signal Sw4R_s : std_logic ;
signal Sw4RR_s : std_logic ;
signal Sw4ClkEn_s : std_logic ;
signal FAultR_s : std_logic ;
signal FAultRR_s : std_logic ;
signal FAultClkEn_s : std_logic ;
signal XSlideDatumR_s : std_logic ;
signal XSlideDatumRR_s : std_logic ;
signal XSlideDatumClkEn_s : std_logic ;
signal MotorEDatumR_s : std_logic ;
signal MotorEDatumRR_s : std_logic ;
signal MotorEDatumClkEn_s : std_logic ;
signal MotorDDatumR_s : std_logic ;
signal MotorDDatumRR_s : std_logic ;
signal MotorDDatumClkEn_s : std_logic ;
signal MotorCDatumR_s : std_logic ;
signal MotorCDatumRR_s : std_logic ;
signal MotorCDatumClkEn_s : std_logic ;
signal MotorBDatumR_s : std_logic ;
signal MotorBDatumRR_s : std_logic ;
signal MotorBDatumClkEn_s : std_logic ;
signal MotorADatumR_s : std_logic ;
signal MotorADatumRR_s : std_logic ;
signal MotorADatumClkEn_s : std_logic ;
-- Interrupt Mask Register signals
signal AuxCoverMsk_s    : std_logic ;
signal MainCoverMsk_s   : std_logic ;
signal Sw1Msk_s          : std_logic ;
signal Sw2Msk_s          : std_logic ;
signal Sw3Msk_s          : std_logic ;
signal Sw4Msk_s          : std_logic ;
signal FAultMsk_s        : std_logic ;
signal XSlideDatumMsk_s  : std_logic ;
signal MotorADatumMsk_s  : std_logic ;
signal MotorBDatumMsk_s  : std_logic ;
signal MotorCDatumMsk_s  : std_logic ;
signal MotorDDatumMsk_s  : std_logic ;
signal MotorEDatumMsk_s  : std_logic ;
-- Fault Register signals
signal TransLedFault_s     	: std_logic ;
signal EpiLedFault_s       	: std_logic ;
signal VoiceCoilFault_s    	: std_logic ;
signal CarriageFault_s     	: std_logic ;
signal SupplyFault_s     	: std_logic ;
signal SFuseBlown_s 		: std_logic ;
-- DAC signals
signal IllumDacSync_s 		: std_logic ;
signal OverVDacSync_s 		: std_logic ;
signal DacWrite_s 			: std_logic ;
signal DacAddress_s   		: std_logic_vector(3 downto 0) ;
signal DacData_s   			: std_logic_vector(15 downto 0) ;
signal VoiceCoilSpisteaR_s 	: std_logic ;
signal VoiceCoilSpisteaRR_s : std_logic ;
signal CarrSpisteaR_s 		: std_logic:='1' ;   -- These signals are not affected by CPLD Reset
signal CarrSpisteaRR_s 		: std_logic:='1' ;	 -- assign initial values for 
signal CarrSpisteaRRR_s 	: std_logic:='1' ;	 -- simulation purpose

-- CPLD Programme Enable Register signals
signal CPLDProgEn_s      	: std_logic ;
-- Scan LED Control Register signals
signal ScanLEDReg_s      	: std_logic_vector(15 downto 0) ;
-- Overview LED Control Register signals
signal OViewLEDReg_s     	: std_logic_vector(15 downto 0) ;
signal BitShift_s        	: std_logic_vector(21 downto 0) ; 
signal BitCount_s        	: std_logic_vector(3 downto 0) ; 	

constant WriteEnable_c      : std_logic := '0' ;
constant ReadEnable_c       : std_logic := '1' ;
constant LEDControlAddr_c   : std_logic_vector (3 downto 0) := "0000" ;
constant SensorStatusAddr_c : std_logic_vector (3 downto 0) := "0001" ;
constant SensorEdgeAddr_c   : std_logic_vector (3 downto 0) := "0010" ;
constant IntMaskAddr_c      : std_logic_vector (3 downto 0) := "0011" ;
constant FaultAddr_c   	    : std_logic_vector (3 downto 0) := "0100" ;
constant MotionCont1Addr_c  : std_logic_vector (3 downto 0) := "0101" ;  -- Only to be used on the Commutation CPLD
constant MotionCont2Addr_c  : std_logic_vector (3 downto 0) := "0110" ;  -- Only to be used on the Commutation CPLD
constant MotionCont3Addr_c  : std_logic_vector (3 downto 0) := "0111" ;  -- Only to be used on the Commutation CPLD
constant ScanLEDAddr_c      : std_logic_vector (3 downto 0) := "1000" ;
constant OViewLEDAddr_c     : std_logic_vector (3 downto 0) := "1001" ;
constant CPLDProgAddr_c     : std_logic_vector (3 downto 0) := "1010" ;
constant MDRB_UES1Addr_c    : std_logic_vector (3 downto 0) := "1011" ;
constant MDRB_UES2Addr_c    : std_logic_vector (3 downto 0) := "1100" ;
constant COMMUT_UES1Addr_c  : std_logic_vector (3 downto 0) := "1101" ;  -- Only to be used on the Commutation CPLD
constant COMMUT_UES2Addr_c  : std_logic_vector (3 downto 0) := "1110" ;  -- Only to be used on the Commutation CPLD

signal   WATCHDOG_CARR_ENABLE   : std_logic ;
signal   WATCHDOG_VC_ENABLE     : std_logic ;
signal   CarrDacPulsed_s        : std_logic ;
signal   VcDacPulsed_s          : std_logic ;
signal   CarrDacLdBar_s         : std_logic ;
signal   VcDacLdBar_s           : std_logic ;

signal   SUPPLY_OK              : std_logic ;
signal   MAIN_COVER_OPEN        : std_logic ; -- always 0 = Closed

begin

MAIN_COVER_OPEN <= '0' ; -- always closed

SPARE1 <= WATCHDOG_CARR_ENABLE ;
SPARE2 <= WATCHDOG_VC_ENABLE ;
SUPPLY_OK <= SPARE3 ;

LedFlashFast_s <= LED_FLASHER ;

LED_1 <= Led1_s ;
LED_2 <= Led2_s ;
LED_3 <= Led3_s ;
LED_4 <= Led4_s ;

ILLUM_ENABLE_BAR <= not ScanLedEnable_s ;
EPI_ENABLE_BAR 	 <= EpiLedEnable_s; -- new interlock controlled LED enable
TRANS_ENABLE_BAR <= TransLedEnable_s ;
PROG_EN_BAR <= CPLDProgEn_s ;   -- This bit is low if the CPLD is to be programmed
COVER_OPEN 	<= AuxCover_s or MainCover_s ;
AuxCover_s 	<= AUX_COVER_OPEN ;
MainCover_s <= MAIN_COVER_OPEN ;
Sw1_s 		<= SW_1_BAR ;
Sw2_s 		<= SW_2_BAR ;
Sw3_s 		<= SW_3_BAR ;
Sw4_s 		<= SW_4_BAR ;
--FAult_s 	<= S_FUSE_BLOWN or not CARR_FAULT_BAR or VC_FAULT_BAR or 
--               not EPI_LED_FAULT_BAR or not TRANS_LED_FAULT_BAR ;
Fault_s 	<= SFuseBlown_s or SupplyFault_s or CarriageFault_s or VoiceCoilFault_s or 
               EpiLedFault_s or TransLedFault_s ;
XSlideDatum_s <= not X_DATUM_BAR ;
MotorADatum_s <= not A_FLAG_BAR ;
MotorBDatum_s <= not B_FLAG_BAR ;
MotorCDatum_s <= not C_FLAG_BAR ;
MotorDDatum_s <= not D_FLAG_BAR ;
MotorEDatum_s <= not E_FLAG_BAR ;

TransLedFault_s 	<= not TRANS_LED_FAULT_BAR ;
EpiLedFault_s 		<= not EPI_LED_FAULT_BAR ;
VoiceCoilFault_s 	<= not VC_FAULT_BAR ;
CarriageFault_s 	<= not CARR_AMP_FAULT_BAR ;
SupplyFault_s       <= not SUPPLY_OK ;
---CarriageFault_s 	<= not A_FLAG_BAR ; -- temporary change for ECM's until the Copley status signal can be connected direct to the MDRB
SFuseBlown_s 		<= S_FUSE_BLOWN ;
MDRB_INT_BAR 		<= not MdrbInt_s ;
ILLUM_DAC_SYNC_BAR 	<= not IllumDacSync_s ;
OVR_DAC_SYNC_BAR   	<= not OverVDacSync_s ;

CARR_DAC_LD_BAR <= CarrDacLdBar_s ;
VC_DAC_LD_BAR <= VcDacLdBar_s ;

----------------------------------------------------------------------
-- SDO (Serial Data Out) Enable 
--
----------------------------------------------------------------------
Sdoprocess : process (SdoEn_s, CLK_10M_1, PORESET_BAR)
begin
    if PORESET_BAR = '0' then
         SDO <= 'Z';        
    elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then
      if SdoEn_s = '1' then 
         SDO <= SDO_s;         
      else 
         SDO <= 'Z';        
      end if;
    end if;
end process Sdoprocess ;


----------------------------------------------------------------------
-- Serial Comms Enable 
--
-- Enables serial comms when falling edge of SCLK is detected whilst SEN is high.
-- If SEN and SCLK are both high, then serial comms are disabled
--
-- Software should ensure that when no data is to be transfered on the Serial comms, 
-- both SEN and SCLK should be high
--
-- At the start of transfers, SCLK should go low first followed by SEN.
-- At the end of the transfer cycle, SEN should go high followed by SCLK
----------------------------------------------------------------------
serialenable : process (PORESET_BAR, CLK_10M_1)

begin

    if PORESET_BAR = '0' then
        SerialEnable_s <= '0' ;										-- Serial comms disabled
		ResetSerialSM_s <= '1' ;									-- Serial State Machines are in reset
        SerialEnableState_s    <= Idle ;                        

	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then

        case SerialEnableState_s is
        
	        when Idle =>
		    	SerialEnable_s <= '0' ;								-- Serial comms disabled
		    	ResetSerialSM_s <= '1' ;							-- Serial State Machines are in reset
	            if SenRR_s = '0'  then 								-- When SEN is high, look out for 
	                if SclkR_s = '0' and SclkRR_s = '1' then           -- falling edge of SCLK to arm serial comms
	                    SerialEnableState_s <= SerialArm ;
	                end if ;
	            end if ;

	        when SerialArm =>
		    	ResetSerialSM_s <= '0' ;							-- Serial State Machines are armed (out of reset)
	            if SclkRR_s = '0'  then 							-- When SCLK is low, look out for 
	                if SenR_s = '1' and SenRR_s = '0' then          -- falling edge of SEN to enable serial comms
	                    SerialEnableState_s <= SerialEn ;
	                end if ;
	            end if ;

	            if SclkRR_s = '1' and SenRR_s = '0'  then 			-- When SCLK and SEN are both high 
	                 SerialEnableState_s <= Idle ;              	-- then disable comms                
	            end if ;


	        when SerialEn =>
		    	SerialEnable_s <= '1' ;								-- Enable Serial comms
	            if SclkRR_s = '1' and SenRR_s = '0'  then 			-- When SCLK and SEN are both high 
	                 SerialEnableState_s <= Idle ;              	-- then disable comms                
	            end if ;

--        when others =>
        
        end case ;

    end if ;

end process serialenable ;	


----------------------------------------------------------------------
-- Serial DAC protocol handler
--
-- DAC addr DAC data and Read/Write status stored at the end of the 1st phase of serial transfer.
-- If a write request to an LED DAC is in progress, 16 bit stored DAC data is clock out by the CPLD state m/c.
-- whilst asserting the relevant SYNCH signal for the requested DAC.  
-- The data is transfered to the DAC, MSB first, on the falling edge of DAC_CLK which runs at 5MHz.
----------------------------------------------------------------------
serialdac : process (PORESET_BAR, CLK_10M_1, ResetSerialSM_s)

begin

    if PORESET_BAR = '0' or ResetSerialSM_s = '1' then      -- Reset comms during power on or outside the transfer window.
        DAC_SDI <= '0' ;
        DAC_CLK <= '1' ;
        IllumDacSync_s <= '0' ;
        OverVDacSync_s <= '0' ;
        DacState_s     <= Idle ;                        
        DacWrite_s 	   <= '0' ;
		DacAddress_s   <= (others => '0') ;
		DacData_s 	   <= (others => '0') ;
		BitCount_s 	   <= "1111" ;

	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then

        case DacState_s is
    
	        when Idle =>
	            DAC_SDI <= '0' ;
	            DAC_CLK <= '1' ;
	            IllumDacSync_s <= '0' ;
	            OverVDacSync_s <= '0' ;

	            if SenRR_s = '1' and SerialEnable_s = '1' then   -- If Serial comms is enabled and SEN active
	                DacState_s <= SenLo1_s ;					 -- 1st phase of the serial comms is in progress
	            else
	                DacState_s <= Idle ;
	            end if ;

	        when SenLo1_s =>						   -- 1st phase
	            if SenRR_s = '1'  then 
	                DacState_s <= SenLo1_s ;
	            else
	                DacAddress_s <= (BitShift_s(19 downto 16)) ;  -- Latch DAC Address
	                DacData_s 	 <= (BitShift_s(15 downto 0)) ;   -- Latch DAC Data
	                DacWrite_s 	 <= BitShift_s(20) ;              -- and Read/Write bit status
	                DacState_s 	 <= SenHi_s ;            
	            end if ;

	        when SenHi_s =>						        -- Mid phase
	            if SenRR_s = '0'  then 
	                DacState_s <= SenHi_s ;
	            else
	                DacState_s <= SenLo2_s ;       
	            end if ;

	        when SenLo2_s =>
	            if SenR_s = '1'  then 
		            if DacWrite_s = WriteEnable_c then					-- If a write cycle and....		    
			            if DacAddress_s = ScanLEDAddr_c  then 		  	-- Scan LED addressed
						   IllumDacSync_s <= '1' ;						-- Assert Illumination DAC Synch
			                DacState_s 	  <= DataW1 ;
							BitCount_s 	  <= "1111" ;					-- Initialise the bit count (no. of bits to send)
			            elsif DacAddress_s = OViewLEDAddr_c  then 	  	-- Overview LED addressed
						   OverVDacSync_s <= '1' ;						-- Assert Overview DAC Synch
			                DacState_s 	  <= DataW1 ;
							BitCount_s 	  <= "1111" ;					-- Initialise the bit count (no. of bits to send)
						else
			                DacState_s 	  <= Idle ;
					    end if ;
				    end if ;
			    end if ;

-- Start sending serial data to DACs

	        when DataW1 =>
	        	DAC_SDI      	<= DacData_s(15) ;						-- Assert DAC_SDI
	        	DAC_CLK    	    <= '1' ;								-- Assert DAC_CLK high				
		        DacState_s 	<= DataW2 ;	

	        when DataW2 =>
	        	DAC_CLK    		<= '0' ;								-- Assert TCK High
	      		DacData_s 		<= DacData_s(14 downto 0) & '0' ;		-- Shift serial data out
	      		BitCount_s 		<= unsigned(BitCount_s) - 1 ;			-- decrement bit count
				if BitCount_s = "0000" then
					DacState_s 	<= DataW3 ;								-- If all bits sent, then move on
				else
					DacState_s 	<= DataW1 ;								-- repeat if all bits not sent
				end if ;
-- Disable Clock
	        when DataW3 =>
	        	DAC_CLK    	<= '1' ;							
	            DacState_s 	<= DisableSynch ;
					
-- Disable DAC Synch
	        when DisableSynch =>
				 IllumDacSync_s <= '0' ;
				 OverVDacSync_s <= '0' ;
                 DacState_s 	  <= Idle ;
--         when others =>
    
	    end case ;

    end if ;

end process serialdac ;	


----------------------------------------------------------------------
-- MDRB serial protocol handler
----------------------------------------------------------------------
serial : process (PORESET_BAR, CLK_10M_1)

begin
    
   if (PORESET_BAR = '0') then --1
      SclkR_s    <= '0';
      SclkRR_s   <= '0';
      SenR_s     <= '0';
      SenRR_s    <= '0';
      SDO_s        <= '0';
      BitShift_s <= (others => '0') ;
      SdoEn_s    <= '0';
      Led4FlRate_s    <= '0';
      Led4FlOn_s      <= '0';
      Led4Enable_s    <= '0';
      Led3FlRate_s    <= '0';
      Led3FlOn_s      <= '0';
      Led3Enable_s    <= '0';
      Led2FlRate_s    <= '0';
      Led2FlOn_s      <= '0';
      Led2Enable_s    <= '0';
      Led1FlRate_s    <= '0';
      Led1FlOn_s      <= '0';
      Led1Enable_s     <= '0';
      TransLedEnable_s <= '0';
      EpiLedEnable_s  <= '0';
      ScanLedEnable_s <= '0';
      AuxCoverMsk_s   <= '0';
      MainCoverMsk_s  <= '0';
      Sw1Msk_s        <= '0';
      Sw2Msk_s        <= '0';
      Sw3Msk_s        <= '0';
      Sw4Msk_s        <= '0';
      FAultMsk_s      <= '0';
      XSlideDatumMsk_s    <= '0';
      MotorEDatumMsk_s    <= '0';
      MotorDDatumMsk_s    <= '0';
      MotorCDatumMsk_s    <= '0';
      MotorBDatumMsk_s    <= '0';
      MotorADatumMsk_s    <= '0';
      CPLDProgEn_s    <= '1';
      ScanLEDReg_s    <= (others => '0');
      OViewLEDReg_s   <= (others => '0');

       
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then --1
       
      SclkR_s  <= SCLK;
      SclkRR_s <= SclkR_s;
      SenR_s   <= not SEN_BAR;
      SenRR_s  <= SenR_s;
      SDO_s <= BitShift_s(16);
	  
	  if AuxCover_s = '1' then
	     EpiLedEnable_s <= '0';
	  end if;
	            
	  if SerialEnable_s = '1' then 						-- If Serial comms is enabled, then execute following
    
	      if (SclkR_s = '1') and (SclkRR_s = '0') and (SenRR_s = '1') then --2A
	          BitShift_s <= '0' & BitShift_s(19 downto 0) & To_UX01(SDI) ;
	      end if; --2A

	      if (SenRR_s = '1') and (SenR_s = '0') then

-- Write to MDRB Registers  

	         if (BitShift_s(20) = WriteEnable_c) then
          
	            case (BitShift_s(19 downto 16)) is
           
	               when LEDControlAddr_c =>
	                    SdoEn_s <= '1';
	                    Led4FlRate_s     <= Bitshift_s(14);
	                    Led4FlOn_s       <= Bitshift_s(13);
	                    Led4Enable_s     <= Bitshift_s(12);
	                    Led3FlRate_s     <= Bitshift_s(11);
	                    Led3FlOn_s       <= Bitshift_s(10);
	                    Led3Enable_s     <= Bitshift_s(9);
	                    Led2FlRate_s     <= Bitshift_s(8);
	                    Led2FlOn_s       <= Bitshift_s(7);
	                    Led2Enable_s     <= Bitshift_s(6);
	                    Led1FlRate_s     <= Bitshift_s(5);
	                    Led1FlOn_s       <= Bitshift_s(4);
	                    Led1Enable_s     <= Bitshift_s(3);
	                    TransLedEnable_s <= Bitshift_s(2);

						if AuxCover_s = '0' then
	                       EpiLedEnable_s <= Bitshift_s(1); -- Has to wait for interlock close
						end if;

	                    ScanLedEnable_s  <= Bitshift_s(0);

	               when SensorEdgeAddr_c =>		-- This is here just to provide the SDO feedback during writes
	                    SdoEn_s <= '1';			-- The data is latched in a separate process.
			   
	               when IntMaskAddr_c =>
			            SdoEn_s <= '1';
	                    AuxCoverMsk_s     <= Bitshift_s(12);
	                    MainCoverMsk_s    <= Bitshift_s(11);
	                    Sw4Msk_s          <= Bitshift_s(10);
	                    Sw3Msk_s          <= Bitshift_s(9);
	                    Sw2Msk_s          <= Bitshift_s(8);
	                    Sw1Msk_s          <= Bitshift_s(7);
	                    FAultMsk_s        <= Bitshift_s(6);
	                    XSlideDatumMsk_s  <= Bitshift_s(5);
	                    MotorEDatumMsk_s  <= Bitshift_s(4);
	                    MotorDDatumMsk_s  <= Bitshift_s(3);
	                    MotorCDatumMsk_s  <= Bitshift_s(2);
	                    MotorBDatumMsk_s  <= Bitshift_s(1);
	                    MotorADatumMsk_s  <= Bitshift_s(0);
                                                 
	               when ScanLEDAddr_c =>
			            SdoEn_s <= '1';
	                    ScanLEDReg_s(15 downto 0)      <= Bitshift_s(15 downto 0);
                
	               when OViewLEDAddr_c =>
			            SdoEn_s <= '1';
	                    OViewLEDReg_s(15 downto 0)     <= Bitshift_s(15 downto 0);
 
	               when CPLDProgAddr_c =>
			            SdoEn_s <= '1';
	                    CPLDProgEn_s <= Bitshift_s(0);

	               when others =>
			            SdoEn_s <= '0';
                
	            end case;

			 end if;
		
-- Read From MDRB Registers  

	         if (BitShift_s(20) = ReadEnable_c) then
          
	            case BitShift_s(19 downto 16) is
              
	               when LEDControlAddr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15) <=  '0' ;
	                    Bitshift_s(14) <= Led4FlRate_s ;
	                    Bitshift_s(13) <= Led4FlOn_s ;
	                    Bitshift_s(12) <= Led4Enable_s ;
	                    Bitshift_s(11) <= Led3FlRate_s ;
	                    Bitshift_s(10) <= Led3FlOn_s ;
	                    Bitshift_s(9)  <= Led3Enable_s ;
	                    Bitshift_s(8)  <= Led2FlRate_s ;
	                    Bitshift_s(7)  <= Led2FlOn_s ;
	                    Bitshift_s(6)  <= Led2Enable_s ;
	                    Bitshift_s(5)  <= Led1FlRate_s ;
	                    Bitshift_s(4)  <= Led1FlOn_s ;
	                    Bitshift_s(3)  <= Led1Enable_s ;
	                    Bitshift_s(2)  <= TransLedEnable_s ;
	                    Bitshift_s(1)  <= EpiLedEnable_s ; 
	                    Bitshift_s(0)  <= ScanLedEnable_s ;
              
	               when SensorStatusAddr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15) <= '0' ;
	                    Bitshift_s(14) <= '0' ;
	                    Bitshift_s(13) <= '0' ;
	                    Bitshift_s(12) <= AuxCover_s ;
	                    Bitshift_s(11) <= MainCover_s ;
	                    Bitshift_s(10) <= Sw4_s ;
	                    Bitshift_s(9)  <= Sw3_s ;
	                    Bitshift_s(8)  <= Sw2_s ;
	                    Bitshift_s(7)  <= Sw1_s ;
	                    Bitshift_s(6)  <= FAult_s ;
	                    Bitshift_s(5)  <= XSlideDatum_s ;
	                    Bitshift_s(4)  <= MotorEDatum_s ;
	                    Bitshift_s(3)  <= MotorDDatum_s ;
	                    Bitshift_s(2)  <= MotorCDatum_s ;
	                    Bitshift_s(1)  <= MotorBDatum_s ;
	                    Bitshift_s(0)  <= MotorADatum_s ;
 
	               when SensorEdgeAddr_c =>
			            SdoEn_s <= '1';             
	                    Bitshift_s(15) <= '0' ;
	                    Bitshift_s(14) <= '0' ;
	                    Bitshift_s(13) <= '0' ;
	                    Bitshift_s(12) <= AuxCoverEdge_s ;
	                    Bitshift_s(11) <= MainCoverEdge_s ;
	                    Bitshift_s(10) <= Sw4Edge_s ;
	                    Bitshift_s(9)  <= Sw3Edge_s ;
	                    Bitshift_s(8)  <= Sw2Edge_s ;
	                    Bitshift_s(7)  <= Sw1Edge_s ;
	                    Bitshift_s(6)  <= FAultEdge_s ;
	                    Bitshift_s(5)  <= XSlideDatumEdge_s ;
	                    Bitshift_s(4)  <= MotorEDatumEdge_s ;
	                    Bitshift_s(3)  <= MotorDDatumEdge_s ;
	                    Bitshift_s(2)  <= MotorCDatumEdge_s ;
	                    Bitshift_s(1)  <= MotorBDatumEdge_s ;
	                    Bitshift_s(0)  <= MotorADatumEdge_s ;

	               when IntMaskAddr_c =>
			            SdoEn_s <= '1';            
	                    Bitshift_s(15) <= '0' ;
	                    Bitshift_s(14) <= '0' ;
	                    Bitshift_s(13) <= '0' ;
	                    Bitshift_s(12) <= AuxCoverMsk_s ;
	                    Bitshift_s(11) <= MainCoverMsk_s ;
	                    Bitshift_s(10) <= Sw4Msk_s ;
	                    Bitshift_s(9)  <= Sw3Msk_s ;
	                    Bitshift_s(8)  <= Sw2Msk_s ;
	                    Bitshift_s(7)  <= Sw1Msk_s ;
	                    Bitshift_s(6)  <= FAultMsk_s ;
	                    Bitshift_s(5)  <= XSlideDatumMsk_s ;
	                    Bitshift_s(4)  <= MotorEDatumMsk_s ;
	                    Bitshift_s(3)  <= MotorDDatumMsk_s ;
	                    Bitshift_s(2)  <= MotorCDatumMsk_s ;
	                    Bitshift_s(1)  <= MotorBDatumMsk_s ;
	                    Bitshift_s(0)  <= MotorADatumMsk_s ;

	               when FaultAddr_c =>
			            SdoEn_s <= '1'; 
	                    Bitshift_s(15) <= '0' ;
	                    Bitshift_s(14) <= '0' ;
	                    Bitshift_s(13) <= '0' ;
	                    Bitshift_s(12) <= '0' ;
	                    Bitshift_s(11) <= '0' ;
	                    Bitshift_s(10) <= '0' ;
	                    Bitshift_s(9)  <= '0' ;
	                    Bitshift_s(8)  <= '0' ;
	                    Bitshift_s(7)  <= SupplyFault_s ;
	                    Bitshift_s(6)  <= TransLedFault_s ;
	                    Bitshift_s(5)  <= EpiLedFault_s ;
	                    Bitshift_s(4)  <= '0' ;
	                    Bitshift_s(3)  <= VoiceCoilFault_s ;
	                    Bitshift_s(2)  <= CarriageFault_s ;
	                    Bitshift_s(1)  <= '0' ;
	                    Bitshift_s(0)  <= SFuseBlown_s ;
              
	               when ScanLEDAddr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15 downto 0) <= ScanLEDReg_s(15 downto 0)  ;
              
	               when OViewLEDAddr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15 downto 0) <= OViewLEDReg_s(15 downto 0)  ;
              
	               when CPLDProgAddr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15) <= '0' ;
	                    Bitshift_s(14) <= '0' ;
	                    Bitshift_s(13) <= '0' ;
	                    Bitshift_s(12) <= '0' ;
	                    Bitshift_s(11) <= '0' ;
	                    Bitshift_s(10) <= '0' ;
	                    Bitshift_s(9)  <= '0' ;
	                    Bitshift_s(8)  <= '0' ;
	                    Bitshift_s(7)  <= '0' ;
	                    Bitshift_s(6)  <= '0' ;
	                    Bitshift_s(5)  <= '0' ;
	                    Bitshift_s(4)  <= '0' ;
	                    Bitshift_s(3)  <= '0' ;
	                    Bitshift_s(2)  <= '0' ;
	                    Bitshift_s(1)  <= '0' ;
	                    Bitshift_s(0)  <= CPLDProgEn_s ;

	               when MDRB_UES1Addr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15 downto 8) <= Position_c(7 downto 0)  ;
	                    Bitshift_s(7 downto 0)  <= VersionNo_c(7 downto 0)  ;
              
	               when MDRB_UES2Addr_c =>
			            SdoEn_s <= '1';
	                    Bitshift_s(15 downto 8) <= Day_c(7 downto 0)  ;
	                    Bitshift_s(7 downto 4)  <= Month_c(3 downto 0)  ;
	                    Bitshift_s(3 downto 0)  <= Year_c(3 downto 0)  ;

	               when others =>
			            SdoEn_s <= '0';
	            end case;
          
	         end if ;
	      end if;
	   end if;
   end if; --1
end process serial ;


----------------------------------------------------------------------
-- MDRB Interrupts
----------------------------------------------------------------------

MdrbInt_s <= (AuxCoverEdge_s and AuxCoverMsk_s) or 
	         (MainCoverEdge_s and MainCoverMsk_s) or
			 (Sw1Edge_s and Sw1Msk_s) or
	         (Sw2Edge_s and Sw2Msk_s) or
			 (Sw3Edge_s and Sw3Msk_s) or 
			 (Sw4Edge_s and Sw4Msk_s) or
			 (FAultEdge_s and FAultMsk_s) or 
			 (XSlideDatumEdge_s and XSlideDatumMsk_s) or
			 (MotorEDatumEdge_s and MotorEDatumMsk_s) or 
			 (MotorDDatumEdge_s and MotorDDatumMsk_s) or
			 (MotorCDatumEdge_s and MotorCDatumMsk_s) or 
			 (MotorBDatumEdge_s and MotorBDatumMsk_s) or
			 (MotorADatumEdge_s and MotorADatumMsk_s) ;

  
----------------------------------------------------------------------
--  General Purpose LEDs
--
--  The 4 general purpose LEDs can be in one of 4 states: ON, OFF, Fast Flash or Slow Flash
--
--  The mode of operation is determined by the contents of the LED Control Register
----------------------------------------------------------------------

LEDDivide : process (PORESET_BAR, LED_FLASHER)

begin
    
   if (PORESET_BAR = '0') then
      LedFlashSlow_s    <= '0';
       
   elsif LED_FLASHER = '1' and LED_FLASHER'event then 
      LedFlashSlow_s <= not LedFlashSlow_s;
  
   end if;

end process LEDDivide ;


LED4 : process (CLK_10M_1, PORESET_BAR)

begin
    
   if (PORESET_BAR = '0') then
      Led4_s    <= '0';
       
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then 

      if Led4Enable_s = '0' then                                 -- LED disabled
         Led4_s <= '0'; 

      elsif Led4FlOn_s = '1' and Led4FlRate_s = '1' then         -- LED Enabled, fast flash
         Led4_s <= LedFlashFast_s; 

      elsif Led4FlOn_s = '1' and Led4FlRate_s = '0' then         -- LED Enabled, Slow flash
         Led4_s <= LedFlashSlow_s; 

      else Led4_s <= '1';                                        -- LED Enabled

      end if ;

   end if;

end process LED4 ;
 

LED3 : process (CLK_10M_1, PORESET_BAR)

begin
    
   if (PORESET_BAR = '0') then
      Led3_s    <= '0';
       
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then 

      if Led3Enable_s = '0' then                                 -- LED disabled
         Led3_s <= '0'; 

      elsif Led3FlOn_s = '1' and Led3FlRate_s = '1' then         -- LED Enabled, fast flash
         Led3_s <= LedFlashFast_s; 

      elsif Led3FlOn_s = '1' and Led3FlRate_s = '0' then         -- LED Enabled, Slow flash
         Led3_s <= LedFlashSlow_s; 

      else Led3_s <= '1';                                        -- LED Enabled

      end if ;

   end if;

end process LED3 ;
 

LED2 : process (CLK_10M_1, PORESET_BAR)

begin
    
   if (PORESET_BAR = '0') then
      Led2_s    <= '0';
       
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then 

      if Led2Enable_s = '0' then                                 -- LED disabled
         Led2_s <= '0'; 

      elsif Led2FlOn_s = '1' and Led2FlRate_s = '1' then         -- LED Enabled, fast flash
         Led2_s <= LedFlashFast_s; 

      elsif Led2FlOn_s = '1' and Led2FlRate_s = '0' then         -- LED Enabled, Slow flash
         Led2_s <= LedFlashSlow_s; 

      else Led2_s <= '1';                                        -- LED Enabled

      end if ;

   end if;

end process LED2 ;
 

LED1 : process (CLK_10M_1, PORESET_BAR)

begin
    
   if (PORESET_BAR = '0') then
      Led1_s    <= '0';
       
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then 

      if Led1Enable_s = '0' then                                 -- LED disabled
         Led1_s <= '0'; 

      elsif Led1FlOn_s = '1' and Led1FlRate_s = '1' then         -- LED Enabled, fast flash
         Led1_s <= LedFlashFast_s; 

      elsif Led1FlOn_s = '1' and Led1FlRate_s = '0' then         -- LED Enabled, Slow flash
         Led1_s <= LedFlashSlow_s; 

      else Led1_s <= '1';                                        -- LED Enabled

      end if ;

   end if;

end process LED1 ;


----------------------------------------------------------------------
--  Edge Detect Clock Enable bits 
--
--  The Clock enables are set high for one CLK_10M_1 period when the 
--  corresponding signal changes state.  These bits are used in the
--  Edgedetect process for setting the edge detect bits high. 
----------------------------------------------------------------------

EdgeClk : process (PORESET_BAR, CLK_10M_1, AUX_COVER_OPEN, MAIN_COVER_OPEN, SW_1_BAR, SW_2_BAR, SW_3_BAR, SW_4_BAR,
				   FAult_s, XSlideDatum_s, MotorEDatum_s, MotorDDatum_s, MotorCDatum_s, MotorBDatum_s, MotorADatum_s)

begin
    
   if (PORESET_BAR = '0') then --1

      AuxCoverR_s       <= AUX_COVER_OPEN;
      AuxCoverRR_s      <= AUX_COVER_OPEN;
 	  AuxCoverClkEn_s   <= '0';
      MainCoverR_s      <= MAIN_COVER_OPEN;
      MainCoverRR_s     <= MAIN_COVER_OPEN;
 	  MainCoverClkEn_s  <= '0';
      Sw1R_s      		<= SW_1_BAR;
      Sw1RR_s     		<= SW_1_BAR;
 	  Sw1ClkEn_s  		<= '0';
      Sw2R_s     		<= SW_2_BAR;
      Sw2RR_s     		<= SW_2_BAR;
 	  Sw2ClkEn_s  		<= '0';
      Sw3R_s      		<= SW_3_BAR;
      Sw3RR_s     		<= SW_3_BAR;
 	  Sw3ClkEn_s  		<= '0';
      Sw4R_s      		<= SW_4_BAR;
      Sw4RR_s     		<= SW_4_BAR;
 	  Sw4ClkEn_s  		<= '0';
      FAultR_s    		<= FAult_s;
      FAultRR_s     	<= FAult_s;
 	  FAultClkEn_s  	<= '0';
      XSlideDatumR_s    <= XSlideDatum_s;
      XSlideDatumRR_s   <= XSlideDatum_s;
 	  XSlideDatumClkEn_s  <= '0';
      MotorEDatumR_s      <= MotorEDatum_s;
      MotorEDatumRR_s     <= MotorEDatum_s;
 	  MotorEDatumClkEn_s  <= '0';
      MotorDDatumR_s      <= MotorDDatum_s;
      MotorDDatumRR_s     <= MotorDDatum_s;
 	  MotorDDatumClkEn_s  <= '0';
      MotorCDatumR_s      <= MotorCDatum_s;
      MotorCDatumRR_s     <= MotorCDatum_s;
 	  MotorCDatumClkEn_s  <= '0';
      MotorBDatumR_s      <= MotorBDatum_s;
      MotorBDatumRR_s     <= MotorBDatum_s;
 	  MotorBDatumClkEn_s  <= '0';
      MotorADatumR_s      <= MotorADatum_s;
      MotorADatumRR_s     <= MotorADatum_s;
 	  MotorADatumClkEn_s  <= '0';

   elsif CLK_10M_1 = '1' and CLK_10M_1'event then --1

-- Double register the SENSOR inputs
      XSlideDatumR_s  <= XSlideDatum_s ;
      XSlideDatumRR_s <= XSlideDatumR_s ;
      MotorEDatumR_s  <= MotorEDatum_s ;
      MotorEDatumRR_s <= MotorEDatumR_s ;
      MotorDDatumR_s  <= MotorDDatum_s ;
      MotorDDatumRR_s <= MotorDDatumR_s ;
      MotorCDatumR_s  <= MotorCDatum_s ;
      MotorCDatumRR_s <= MotorCDatumR_s ;
      MotorBDatumR_s  <= MotorBDatum_s ;
      MotorBDatumRR_s <= MotorBDatumR_s ;
      MotorADatumR_s  <= MotorADatum_s ;
      MotorADatumRR_s <= MotorADatumR_s ;
      AuxCoverR_s   <= AUX_COVER_OPEN;
      AuxCoverRR_s  <= AuxCoverR_s;
      MainCoverR_s  <= MAIN_COVER_OPEN;
      MainCoverRR_s <= MainCoverR_s;
      Sw1R_s    <= SW_1_BAR;
      Sw1RR_s   <= Sw1R_s;
      Sw2R_s    <= SW_2_BAR;
      Sw2RR_s   <= Sw2R_s;
      Sw3R_s    <= SW_3_BAR;
      Sw3RR_s   <= Sw3R_s;
      Sw4R_s    <= SW_4_BAR;
      Sw4RR_s   <= Sw4R_s;
      FAultR_s  <= FAult_s;
      FAultRR_s <= FAultR_s;

-- GENERATE A CLOCK ENABLE AT EACH EDGE FOR EACH SENSOR

-- Auxiliary Cover 
      if ((AuxCoverR_s = '1') and (AuxCoverRR_s = '0')) or   -- rising edge clock
         ((AuxCoverR_s = '0') and (AuxCoverRR_s = '1')) then -- falling edge clock
         AuxCoverClkEn_s  <= '1' ;
 	  else
         AuxCoverClkEn_s  <= '0' ;
      end if ;

-- Main Cover   
      if ((MainCoverR_s = '1') and (MainCoverRR_s = '0')) or   -- rising edge clock
         ((MainCoverR_s = '0') and (MainCoverRR_s = '1')) then -- falling edge clock
         MainCoverClkEn_s  <= '1' ;
 	  else
         MainCoverClkEn_s  <= '0' ;
      end if ;

-- SW_1_BAR   
      if ((Sw1R_s = '1') and (Sw1RR_s = '0')) or   -- rising edge clock
         ((Sw1R_s = '0') and (Sw1RR_s = '1')) then -- falling edge clock
         Sw1ClkEn_s  <= '1' ;
 	  else
         Sw1ClkEn_s  <= '0' ;
      end if ;

-- SW_2_BAR   
      if ((Sw2R_s = '1') and (Sw2RR_s = '0')) or   -- rising edge clock
         ((Sw2R_s = '0') and (Sw2RR_s = '1')) then -- falling edge clock
         Sw2ClkEn_s  <= '1' ;
 	  else
         Sw2ClkEn_s  <= '0' ;
      end if ;

-- SW_3_BAR   
      if ((Sw3R_s = '1') and (Sw3RR_s = '0')) or   -- rising edge clock
         ((Sw3R_s = '0') and (Sw3RR_s = '1')) then --- falling edge clock
         Sw3ClkEn_s  <= '1' ;
 	  else
         Sw3ClkEn_s  <= '0' ;
      end if ;

-- SW_4_BAR   
      if ((Sw4R_s = '1') and (Sw4RR_s = '0')) or   -- rising edge clock
         ((Sw4R_s = '0') and (Sw4RR_s = '1')) then -- falling edge clock
         Sw4ClkEn_s  <= '1' ;
 	  else
         Sw4ClkEn_s  <= '0' ;
      end if ;

-- Fault bit   
      if ((FAultR_s = '1') and (FAultRR_s = '0')) or   -- rising edge clock
         ((FAultR_s = '0') and (FAultRR_s = '1')) then -- falling edge clock
         FAultClkEn_s  <= '1' ;
 	  else
         FAultClkEn_s  <= '0' ;
      end if ;

-- XSlide Datum sensor
      if ((XSlideDatumR_s = '1') and (XSlideDatumRR_s = '0')) or  	 -- rising edge clock
         ((XSlideDatumR_s = '0') and (XSlideDatumRR_s = '1')) then   -- falling edge clock
         XSlideDatumClkEn_s  <= '1' ;
 	  else
         XSlideDatumClkEn_s  <= '0' ;
      end if ;

-- Motor E Datum sensor
      if ((MotorEDatumR_s = '1') and (MotorEDatumRR_s = '0')) or 	 -- rising edge clock
         ((MotorEDatumR_s = '0') and (MotorEDatumRR_s = '1')) then   -- falling edge clock
         MotorEDatumClkEn_s  <= '1' ;
 	  else
         MotorEDatumClkEn_s  <= '0' ;
      end if ;

-- Motor D Datum sensor
      if ((MotorDDatumR_s = '1') and (MotorDDatumRR_s = '0')) or 	 -- rising edge clock
         ((MotorDDatumR_s = '0') and (MotorDDatumRR_s = '1')) then   -- falling edge clock
         MotorDDatumClkEn_s  <= '1' ;
 	  else
         MotorDDatumClkEn_s  <= '0' ;
      end if ;

-- Motor C Datum sensor
      if ((MotorCDatumR_s = '1') and (MotorCDatumRR_s = '0')) or 	 -- rising edge clock
         ((MotorCDatumR_s = '0') and (MotorCDatumRR_s = '1')) then   -- falling edge clock
         MotorCDatumClkEn_s  <= '1' ;
 	  else
         MotorCDatumClkEn_s  <= '0' ;
      end if ;

-- Motor B Datum sensor
      if ((MotorBDatumR_s = '1') and (MotorBDatumRR_s = '0')) or 	 -- rising edge clock
         ((MotorBDatumR_s = '0') and (MotorBDatumRR_s = '1')) then   -- falling edge clock
         MotorBDatumClkEn_s  <= '1' ;
 	  else
         MotorBDatumClkEn_s  <= '0' ;
      end if ;

-- Motor A Datum sensor
      if ((MotorADatumR_s = '1') and (MotorADatumRR_s = '0')) or 	 -- rising edge clock
         ((MotorADatumR_s = '0') and (MotorADatumRR_s = '1')) then   -- falling edge clock
         MotorADatumClkEn_s  <= '1' ;
 	  else
         MotorADatumClkEn_s  <= '0' ;
      end if ;

   end if ;

end process EdgeClk ;                                           
 
 


----------------------------------------------------------------------
-- Edge Detect Write Enable
--
-- This is necessary because the new method of resetting a pending interrupt is 
-- by toggling the edge detect bits.  Each serial write cosists of 2 cycles,
-- which means the edge detects bits will toggle twice and will effectively be unaltered at the
-- end of the second cycle.  This process only allows the register to be written at the end of the 1st cycle. 
----------------------------------------------------------------------
EdgeWriteEnable : process (PORESET_BAR, CLK_10M_1)                                           

begin    
    if PORESET_BAR = '0' then
       EdgeWrEnState_s    <= Idle ;                        
       EdgeWriteEnable_s    <= '0' ; 

	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then

       case EdgeWrEnState_s is
        
	       when Idle =>
	           EdgeWriteEnable_s  <= '0' ; 
	           if SerialEnable_s = '1'  then 
	              EdgeWrEnState_s <= S0 ;
	           end if ;

	       when S0 =>
	           if (SenRR_s = '1') and (SenR_s = '0') and (BitShift_s(20) = WriteEnable_c) then      
	               EdgeWrEnState_s   <= S1 ;
	           end if ;

	       when S1 =>
	           EdgeWriteEnable_s <= '1' ;
	           EdgeWrEnState_s <= S2 ;

	       when S2 =>
	           EdgeWriteEnable_s <= '0' ;
	           if SerialEnable_s = '0'  then 
	              EdgeWrEnState_s <= Idle ;
	           end if ;

--	       when others =>

	   end case ;

	end if ;

end process ;

    
      






----------------------------------------------------------------------
-- Edge Detect bits
--
-- The edge detect bits are set if the appropriate signal changes state.
-- Any set bit will generate the MDRB Interrupt, if the appropriate mask
-- bit is set.
--  
-- Software is able to toggle the edge detect bit status by writing a 1 for that bit.  If a bit is set, therefore,
-- it will generate an interrupt. Software will service that interrupt and write a '1' to that bit in the 
-- Edge Detect register, which will have the effect of toggling it, in this case to a '0'.  If the software writes a '0'
-- to any bit, then it's staus will be unchanged.  This mechanism ensures that only the interrupts which have been
-- serviced are cleared and that unserviced interrupts are not inadvertantly cleared.
----------------------------------------------------------------------
Edgedetect : process (PORESET_BAR, CLK_10M_1)                                           
                                                                                                            
begin                                                                                                         
   if PORESET_BAR = '0' then                                                                                 
   	  AuxCoverEdge_s    <= '0' ;                                                                          
	  MainCoverEdge_S   <= '0' ;                                                                          
	  Sw1Edge_s         <= '0' ;                                                                          
	  Sw2Edge_s         <= '0' ;                                                                          
	  Sw3Edge_s         <= '0' ;                                                                          
	  Sw4Edge_s         <= '0' ;                                                                          
	  FAultEdge_s       <= '0' ;                                                                          
	  XSlideDatumEdge_s <= '0' ;                                                                          
	  MotorEDatumEdge_s <= '0' ;                                                                          
	  MotorDDatumEdge_s <= '0' ;                                                                          
	  MotorCDatumEdge_s <= '0' ;                                                                          
	  MotorBDatumEdge_s <= '0' ;                                                                          
	  MotorADatumEdge_s <= '0' ;                                                                          

   elsif (CLK_10M_1'EVENT and CLK_10M_1 = '1') then                                                      

   	  if AuxCoverClkEn_s = '1' then                      
	     AuxCoverEdge_s <= '1' ;                     -- AuxCoverEdge set because edge detected
	  end if ;

	  if MainCoverClkEn_s = '1' then                      
	     MainCoverEdge_s <= '1' ;                    -- MainCoverEdge set because edge detected
	  end if ;
                                                                                                        
	  if Sw1ClkEn_s = '1' then                      
	     Sw1Edge_s <= '1' ;                          -- Sw1Edge set because edge detected
	  end if ;
                                                                                                        
	  if Sw2ClkEn_s = '1' then                      
	     Sw2Edge_s <= '1' ;                          -- SW2Edge set because edge detected
	  end if ;
                                                                                                        
	  if Sw3ClkEn_s = '1' then                      
	     Sw3Edge_s <= '1' ;                          -- SW3Edge set because edge detected
	  end if ;
                                                                                                        
	  if Sw4ClkEn_s = '1' then                      
	     Sw4Edge_s <= '1' ;                          -- Sw4Edge set because edge detected
	  end if ;
                                                                                                        
	  if FAultClkEn_s = '1' then                      
	     FAultEdge_s <= '1' ;                        -- FAultEdge set because edge detected
	  end if ;
                                                                                                        
	  if XSlideDatumClkEn_s = '1' then                      
	     XSlideDatumEdge_s <= '1' ;                  -- XSlideDatumEdge set because edge detected
	  end if ;
                                                                                                        
	  if MotorEDatumClkEn_s = '1' then                      
	     MotorEDatumEdge_s <= '1' ;                  -- MotorEDatumEdge set because edge detected
	  end if ;
                                                                                                        
	  if MotorDDatumClkEn_s = '1' then                      
	     MotorDDatumEdge_s <= '1' ;                  -- MotorDDatumEdge set because edge detected
	  end if ;
                                                                                                        
	  if MotorCDatumClkEn_s = '1' then                      
	     MotorCDatumEdge_s <= '1' ;                  -- MotorCDatumEdge set because edge detected
	  end if ;
                                                                                                        
	  if MotorBDatumClkEn_s = '1' then                      
	     MotorBDatumEdge_s <= '1' ;                  -- MotorBDatumEdge set because edge detected
	  end if ;
                                                                                                        
	  if MotorADatumClkEn_s = '1' then                      
	     MotorADatumEdge_s <= '1' ;                  -- MotorADatumEdge set because edge detected
	  end if ;

	  if EdgeWriteEnable_s = '1' then      

	     case (BitShift_s(19 downto 16)) is

	        when SensorEdgeAddr_c =>

			   if Bitshift_s(0) = '1' then                      
			      MotorADatumEdge_s <= not MotorADatumEdge_s ;      -- Toggle MotorADatumEdge
			   end if ;

			   if Bitshift_s(1) = '1' then                      
			      MotorBDatumEdge_s <= not MotorBDatumEdge_s ;      -- Toggle MotorBDatumEdge
			   end if ;

			   if Bitshift_s(2) = '1' then                      
			      MotorCDatumEdge_s <= not MotorCDatumEdge_s ;      -- Toggle MotorCDatumEdge
			   end if ;

			   if Bitshift_s(3) = '1' then                      
			      MotorDDatumEdge_s <= not MotorDDatumEdge_s ;      -- Toggle MotorDDatumEdge
			   end if ;

			   if Bitshift_s(4) = '1' then                      
			      MotorEDatumEdge_s <= not MotorEDatumEdge_s ;      -- Toggle MotorEDatumEdge
			   end if ;

			   if Bitshift_s(5) = '1' then                      
			      XSlideDatumEdge_s <= not XSlideDatumEdge_s ;      -- Toggle XSlideDatumEdge_s
			   end if ;

			   if Bitshift_s(6) = '1' then                      
			      FAultEdge_s <= not FAultEdge_s ;      			-- Toggle FAultEdge_s
			   end if ;

			   if Bitshift_s(7) = '1' then                      
			      Sw1Edge_s <= not Sw1Edge_s ;      			-- Toggle Sw1Edge_s
			   end if ;

			   if Bitshift_s(8) = '1' then                      
			      Sw2Edge_s <= not Sw2Edge_s ;      			-- Toggle Sw2Edge_s
			   end if ;

			   if Bitshift_s(9) = '1' then                      
			      Sw3Edge_s <= not Sw3Edge_s ;      			-- Toggle Sw3Edge_s
			   end if ;

			   if Bitshift_s(10) = '1' then                      
			      Sw4Edge_s <= not Sw4Edge_s ;      			-- Toggle Sw4Edge_s
			   end if ;

			   if Bitshift_s(11) = '1' then                      
			      MainCoverEdge_s <= not MainCoverEdge_s ;      -- Toggle MainCoverEdge_s
			   end if ;

			   if Bitshift_s(12) = '1' then                      
			      AuxCoverEdge_s <= not AuxCoverEdge_s ;      	-- Toggle AuxCoverEdge_s
			   end if ;        

            when others => null ;

         end case ;

   	  end if ;	 

   end if ;
                                                                                                            
end process Edgedetect ;                                                                                     
                                                                                                                


----------------------------------------------------------------------
--  Load DAC Data for Voice Coil, Illumination and Overview DACs
--
-- The LD pulse is generated automatically after the rising edge of the SPISTEA signal.
--
----------------------------------------------------------------------

-- Double resister (synchronise) the VC_SPISTEA_BAR signal

VcSpisteaSynch : process (PORESET_BAR, CLK_10M_1)

begin    
   if (PORESET_BAR = '0') then
      VoiceCoilSpisteaR_s	<= '0';
      VoiceCoilSpisteaRR_s 	<= '0';  	     
   elsif CLK_10M_1 = '1' and CLK_10M_1'event then       
      VoiceCoilSpisteaR_s  <= VC_SPISTEA_BAR;
      VoiceCoilSpisteaRR_s <= VoiceCoilSpisteaR_s;  
   end if ;    
end process VcSpisteaSynch ; 

-- Generate Load signal after the rising edge of the SPISTEA signal
-- for the Voice Coil DAC

VcDacstate : process (PORESET_BAR, CLK_10M_1)

begin

    if PORESET_BAR = '0' then
        VcDacState_s    <= Idle ;                        
        VcDacLdBar_s   <= '1' ;

	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then

        case VcDacState_s is
        
        when Idle =>
            VcDacLdBar_s   <= '1' ;

            if VoiceCoilSpisteaRR_s = '0'  then 
               VcDacState_s <= S0 ;
			else
                VcDacState_s <= Idle ;
            end if ;

        when S0 =>
            if VoiceCoilSpisteaRR_s = '0'  then 
               VcDacState_s <= S1 ;
			else
                VcDacState_s <= Idle ;       -- if de-asserted then false
            end if ;

        when S1 =>
            if VoiceCoilSpisteaRR_s = '0'  then 
               VcDacState_s <= S1 ;          
			else
                VcDacState_s <= s2 ;       -- until VC_SPISTEA_BAR de-asserted
            end if ;

        when S2 =>
               VcDacState_s <= S3 ;          

        when S3 =>
               VcDacLdBar_s   <= '0' ;        -- assert VC_DAC_LD_BAR 
               VcDacState_s <= Idle ;      

        when others =>
               VcDacState_s <= Idle ;
        
        end case ;

    end if ;

end process VcDacstate ;	



  -- Generate ILLUM_DAC_LD_BAR pulse after the rising edge of the ILLUM_DAC_SYNC_BAR signal     
  -- for the Scan Illumination DAC                                                              
                                                                                                
IllumDacstate : process (PORESET_BAR, CLK_10M_1)                                              
                                                                                                
begin                                                                                         
                                                                                                
    if PORESET_BAR = '0' then                                                                 
        IllumDacState_s    <= Idle ;                                                          
        ILLUM_DAC_LD_BAR   <= '1' ;                                                           
                                                                                                
 	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then                                         
                                                                                                
        case IllumDacState_s is                                                               
                                                                                                
        when Idle =>                                                                          
            ILLUM_DAC_LD_BAR   <= '1' ;                                                       
                                                                                                
            if IllumDacSync_s = '1'  then                                                     
                 IllumDacState_s <= S0 ;                                                        
  			else                                                                              
                  IllumDacState_s <= Idle ;                                                     
              end if ;                                                                          
                                                                                                
        when S0 =>                                                                            
            if IllumDacSync_s = '1'  then                                                     
               IllumDacState_s <= S1 ;                                                        
  			else                                                                              
                IllumDacState_s <= Idle ;       -- if de-asserted then false                  
            end if ;                                                                          
                                                                                                
        when S1 =>                                                                            
            if IllumDacSync_s = '1'  then                                                     
               IllumDacState_s <= S1 ;                                                        
  			else                                                                              
                IllumDacState_s <= s2 ;       -- until ILLUM_DAC_SYNC_BAR de-asserted         
            end if ;                                                                          
                                                                                                
        when S2 =>                                                                            
               IllumDacState_s <= S3 ;                                                        
                                                                                                
        when S3 =>                                                                            
               ILLUM_DAC_LD_BAR   <= '0' ;        -- assert ILLUM_DAC_LD_BAR                  
               IllumDacState_s <= Idle ;                                                      
                                                                                                
  --        when others =>                                                                      
                                                                                                
        end case ;                                                                            
                                                                                               
    end if ;                                                                                  
                                                                                                
end process IllumDacstate ;	                                                                  
                                                                                                                                                                                             
                                                                                                                                                                                              
  -- Generate OVR_DAC_LD_BAR pulse after the rising edge of the OVR_DAC_SYNC_BAR signal         
  -- for the Overview DAC                                                                       
                                                                                                
OverviewDacState : process (PORESET_BAR, CLK_10M_1)                                           
                                                                                                
begin                                                                                         
                                                                                                
    if PORESET_BAR = '0' then                                                                 
        OverviewDacState_s    <= Idle ;                                                       
        OVR_DAC_LD_BAR   <= '1' ;                                                             
                                                                                               
  	elsif (CLK_10M_1 ='1') and (CLK_10M_1'EVENT) then                                         
                                                                                                
        case OverviewDacState_s is                                                            
                                                                                                
        when Idle =>                                                                          
            OVR_DAC_LD_BAR   <= '1' ;                                                         
                                                                                                
            if OverVDacSync_s = '1'  then                                                     
               OverviewDacState_s <= S0 ;                                                     
  			else                                                                              
                OverviewDacState_s <= Idle ;                                                  
            end if ;                                                                          
                                                                                                
        when S0 =>                                                                            
            if OverVDacSync_s = '1'  then                                                     
               OverviewDacState_s <= S1 ;                                                     
  			else                                                                              
                OverviewDacState_s <= Idle ;       -- if de-asserted then false               
            end if ;                                                                          
                                                                                              
        when S1 =>                                                                            
            if OverVDacSync_s = '1'  then                                                     
               OverviewDacState_s <= S1 ;                                                     
  			else                                                                              
               OverviewDacState_s <= s2 ;       -- until OVR_DAC_SYNC_BAR de-asserted        
            end if ;                                                                          
                                                                                                
        when S2 =>                                                                            
               OverviewDacState_s <= S3 ;                                                     
                                                                                                
        when S3 =>                                                                            
               OVR_DAC_LD_BAR   <= '0' ;        -- assert OVR_DAC_LD_BAR                      
               OverviewDacState_s <= Idle ;                                                   
                                                                                                
--        when others =>                                                                      
                                                                                                
        end case ;                                                                            
                                                                                              
    end if ;                                                                                  
                                                                                                
end process OverviewDacState ;	                                                              
                                                                                                


---------------------------------------------------------------------
--  Load DAC Data for the Carriage DAC.
--
-- The LD pulse is generated automatically after the rising edge of the SPISTEA signal.
--
-- NOTE:  This is different to the process used for the other DACs in that it does not use the CPLD Reset signal.
--        The Carriage DAC is written to by the DSP to generate the Soft Reset signal, which, as well as the PORESET, controls
--        the CPLD Reset and  allows the software to reset the CPLDs on the MDRB.  
--        The CARR_DAC_LD_BAR signal therefore must not be affected by the CPLD Reset
--         
----------------------------------------------------------------------

-- Double resister (synchronise) the SPISTEA signal.
-- NOTE:  The signals are not affected by the CPLD Reset.  

CarrSpisteaSynch : process (CLK_10M_1)

begin    
	if CLK_10M_1 = '1' and CLK_10M_1'event then       
      CarrSpisteaR_s   <= CARR_SPISTEA_BAR;
      CarrSpisteaRR_s  <= CarrSpisteaR_s;   
      CarrSpisteaRRR_s <= CarrSpisteaRR_s;   
   end if ;    
end process CarrSpisteaSynch ; 

-- Generate Load signal after the rising edge of the SPISTEA signal

CarrDacLdBar_s   <= not (CarrSpisteaRR_s and (not CarrSpisteaRRR_s)) ;        -- assert CARR_DAC_LD_BAR 

---------------------------------------------------------------------
--
-- Watchdog processes to disable amplifiers if they are no longer receiving DAC writes.
-- Unfortunately the enables are in the other PAL so this PAL sends across the enable signals via the SPARE signals.
-- LED_FLASHER is used as a suitable low speed watchdog timer.
-- Using the DAC_LD signals ensures that a transition is necessary to avoid watchdog timeouts.
-- Worst case timeout is 2x LED_FLASHER period
--
---------------------------------------------------------------------

CarrDac : process (CarrDacLdBar_s, LED_FLASHER)

begin
    
   if (CarrDacLdBar_s = '0') then
      CarrDacPulsed_s    <= '1';
       
   elsif LED_FLASHER = '1' and LED_FLASHER'event then 
      CarrDacPulsed_s    <= '0';
  
   end if;

end process CarrDac ;

CarrWatchDog : process (CarrDacPulsed_s, LED_FLASHER)

begin
    
   if (CarrDacPulsed_s = '1') then
	   WATCHDOG_CARR_ENABLE <= '1' ;
       
   elsif LED_FLASHER = '1' and LED_FLASHER'event then 
	   WATCHDOG_CARR_ENABLE <= '0' ;
	     
   end if;

end process CarrWatchDog ;

VcDac : process (VcDacLdBar_s, LED_FLASHER)

begin
    
   if (VcDacLdBar_s = '0') then
      VcDacPulsed_s    <= '1';
       
   elsif LED_FLASHER = '1' and LED_FLASHER'event then 
      VcDacPulsed_s    <= '0';
  
   end if;

end process VcDac ;

VcWatchDog : process (VcDacPulsed_s, LED_FLASHER)

begin
    
   if (VcDacPulsed_s = '1') then
	   WATCHDOG_VC_ENABLE <= '1' ;
       
   elsif LED_FLASHER = '1' and LED_FLASHER'event then 
	   WATCHDOG_VC_ENABLE <= '0' ;
	     
   end if;

end process VcWatchDog ;

end;

