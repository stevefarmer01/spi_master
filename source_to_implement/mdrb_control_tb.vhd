-------------------------------------------------------------------------
--
-- File name    :  E:\usr\microscan\AMIS\MDRB\design_definition\hdl\vhdl\mdrb_control_tb.vhd
-- Title        :  Mdrb_control_TB
-- Library      :  WORK
--              :  
-- Purpose      :  
--              : 
-- Created On   : 22/11/2005 13:16:00
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
-- Copyright 1997 (c) 
--
--  owns the sole copyright to this software. Under 
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
--  MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF
-- THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
-- PURPOSE.
-- ----------------------------------------------------------------------
-- Revision History :
-- ----------------------------------------------------------------------
--   Version No:| Author      :| Mod. Date :|    Changes Made:
--     v1.0     | Mdrb_control:| 22/11/2005:| Automatically Generated
-- ----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

ENTITY TestBench IS
END TestBench;

ARCHITECTURE HTWTestBench OF TestBench IS

COMPONENT mdrb_control
    PORT (
 
---- pragma synthesis_off
--      TDI               : in std_logic := '0';
--      TMS               : in std_logic := '0';
--      TCK               : in std_logic := '0';
--      TDO               : out std_logic := '0';
---- pragma synthesis_on
---- Serial
--      SDI               : in std_logic ;
--      SEN_BAR           : in std_logic ;
--      SCLK              : in std_logic ;
--      SDO               : out std_logic; 
--      CLK_10M_1         : in std_logic ;
--      PORESET_BAR       : in std_logic ;
--
--      SW_1_BAR          : in std_logic := '0';
--      SW_2_BAR          : in std_logic := '0';
--      SW_3_BAR          : in std_logic := '0';
--      SW_4_BAR          : in std_logic := '0';
--      LED_FLASHER       : in std_logic := '0';
--      LED_1             : out std_logic := '0';
--      LED_2             : out std_logic := '0';
--      LED_3             : out std_logic := '0';
--      LED_4             : out std_logic := '0';
--      S_FUSE_BLOWN      : in std_logic := '0';
--      X_FUSE_BLOWN      : in std_logic := '0';
--      CARR_FAULT_BAR    : in std_logic := '0';
--      VC_FAULT_BAR      : in std_logic := '0';
--      EPI_LED_FAULT     : in std_logic := '0';
--      TRANS_LED_FAULT   : in std_logic := '0';
--      A_FLAG            : in std_logic := '0';
--      B_FLAG            : in std_logic := '0';
--      C_FLAG            : in std_logic := '0';
--      D_FLAG            : in std_logic := '0';
--      E_FLAG            : in std_logic := '0';
--      X_DATUM           : in std_logic := '0';		
--      MDRB_INT          : out std_logic := '0';
--      PROG_DIS_BAR      : out std_logic := '0';
--      ILLUM_DAC_SYNC_BAR :out std_logic := '0';
--      ILLUM_ENABLE_BAR  : out std_logic := '0';
--      OVR_DAC_SYNC_BAR  : out std_logic := '0';
--      EPI_ENABLE_BAR    : out std_logic := '0';
--      TRANS_ENABLE_BAR  : out std_logic := '0';
--      DAC_SDI           : out std_logic := '0';
--      DAC_CLK           : out std_logic := '0';
--      MAIN_COVER_OPEN   : in std_logic := '0';
--      AUX_COVER_OPEN    : in std_logic := '0';
--      COVER_OPEN        : out std_logic := '0';
--      X_MDI             : in std_logic := '0';
--      CARR_SPISTEA_BAR  : in std_logic := '0';
--      CARR_DAC_LD_BAR   : out std_logic := '0';
--      VC_SPISTEA_BAR    : in std_logic := '0';
--      VC_DAC_LD_BAR     : out std_logic := '0';
--	  ILLUM_DAC_LD_BAR  : out std_logic := '0';
--	  OVR_DAC_LD_BAR    : out std_logic := '0'


      TDI               : in std_logic := '0' ;
      TMS               : in std_logic := '0' ;
      TCK               : in std_logic := '0' ;
      TDO               : out std_logic := '0' ;

      SDI               : in std_logic ;
      SEN_BAR           : in std_logic ;
      SCLK              : in std_logic ;
      SDO               : out std_logic; 
      CLK_10M_1         : in std_logic ;
      PORESET_BAR       : in std_logic ;
      SW_1_BAR          : in std_logic := '0' ;
      SW_2_BAR          : in std_logic := '0' ;
      SW_3_BAR          : in std_logic := '0' ;
      SW_4_BAR          : in std_logic := '0' ;
      LED_FLASHER       : in std_logic := '0' ;        
      LED_1             : out std_logic := '0' ;       
      LED_2             : out std_logic := '0' ;
      LED_3             : out std_logic := '0' ;
      LED_4             : out std_logic := '0' ;
      S_FUSE_BLOWN      : in std_logic := '0' ;        
      CARR_AMP_FAULT_BAR    : in std_logic := '0' ;    
      VC_FAULT_BAR      : in std_logic := '0' ;        
      EPI_LED_FAULT_BAR    : in std_logic := '0' ;     
      TRANS_LED_FAULT_BAR   : in std_logic := '0' ;    
      A_FLAG_BAR        : in std_logic := '0' ;
      B_FLAG_BAR        : in std_logic := '0' ;
      C_FLAG_BAR        : in std_logic := '0' ;
      D_FLAG_BAR        : in std_logic := '0' ;
      E_FLAG_BAR        : in std_logic := '0' ;
      X_DATUM_BAR       : in std_logic := '0' ;        
      MDRB_INT_BAR      : out std_logic := '0' ;
      PROG_EN_BAR       : out std_logic := '0' ;
      ILLUM_DAC_SYNC_BAR : out std_logic := '0' ;
      ILLUM_ENABLE_BAR  : out std_logic := '0' ;
      OVR_DAC_SYNC_BAR  : out std_logic := '0' ;
      EPI_ENABLE_BAR    : out std_logic := '0' ;
      TRANS_ENABLE_BAR  : out std_logic := '0' ;
      DAC_SDI           : out std_logic := '0' ;
      DAC_CLK           : out std_logic := '0' ;
      AUX_COVER_OPEN    : in std_logic := '0' ;
      COVER_OPEN        : out std_logic := '0' ;      
      X_MDI             : in std_logic := '0' ;
      SPARE1            : out std_logic := '0' ;   
      SPARE2            : out std_logic := '0' ;   
      SPARE3            : in std_logic := '0' ;    
      SPARE4            : in std_logic := '0' ;
      SPARE5            : in std_logic := '0' ;
      CARR_SPISTEA_BAR  : in std_logic := '0' ;
      CARR_DAC_LD_BAR   : out std_logic := '0' ;
      VC_SPISTEA_BAR    : in std_logic := '0' ;
      VC_DAC_LD_BAR     : out std_logic := '0' ;
      ILLUM_DAC_LD_BAR  : out std_logic := '0' ;
      OVR_DAC_LD_BAR    : out std_logic := '0' 

);
END COMPONENT;

--  _TB;

 
-- pragma synthesis_off
      SIGNAL TDISignal               :  std_logic ;
      SIGNAL TMSSignal               :  std_logic ;
      SIGNAL TCKSignal               :  std_logic ;
      SIGNAL TDOSignal               :  std_logic ;
-- pragma synthesis_on
-- Serial
      SIGNAL SDISignal               :  std_logic ;
      SIGNAL SEN_BARSignal           :  std_logic ;
      SIGNAL SCLKSignal              :  std_logic ;
      SIGNAL SDOSignal               :  std_logic; 
-- Switch Inputs
      SIGNAL SW_1_BARSignal          :  std_logic ;
      SIGNAL SW_2_BARSignal          :  std_logic ;
      SIGNAL SW_3_BARSignal          :  std_logic ;
      SIGNAL SW_4_BARSignal          :  std_logic ;
-- LED Control Signal
      SIGNAL LED_FLASHERSignal       :  std_logic ;
      SIGNAL LED_1Signal             :  std_logic ;
      SIGNAL LED_2Signal             :  std_logic ;
      SIGNAL LED_3Signal             :  std_logic ;
      SIGNAL LED_4Signal             :  std_logic ;
-- Fault signals
      SIGNAL S_FUSE_BLOWNSignal      :  std_logic ;
      SIGNAL X_FUSE_BLOWNSignal      :  std_logic ;
      SIGNAL CARR_FAULT_BARSignal    :  std_logic ;
      SIGNAL VC_FAULT_BARSignal      :  std_logic ;
--      SCAN_LED_FAULT    :  std_logic ;
      SIGNAL EPI_LED_FAULTSignal     :  std_logic ;
      SIGNAL TRANS_LED_FAULTSignal   :  std_logic ;
-- Datum Flags
      SIGNAL A_FLAGSignal            :  std_logic ;
      SIGNAL B_FLAGSignal            :  std_logic ;
      SIGNAL C_FLAGSignal            :  std_logic ;
      SIGNAL D_FLAGSignal            :  std_logic ;
      SIGNAL E_FLAGSignal            :  std_logic ;
      SIGNAL X_DATUMSignal           :  std_logic ;		
-- Board Control
      SIGNAL MDRB_INTSignal          :  std_logic ;
      SIGNAL CLK_10M_1Signal         :  std_logic ;
      SIGNAL PORESET_BARSignal       :  std_logic ;
      SIGNAL PROG_DIS_BARSignal      :  std_logic ;
-- Illumination Control
      SIGNAL ILLUM_DAC_SYNC_BARSignal :  std_logic ;
      SIGNAL ILLUM_ENABLE_BARSignal  :  std_logic ;
      SIGNAL OVR_DAC_SYNC_BARSignal  :  std_logic ;
      SIGNAL EPI_ENABLE_BARSignal    :  std_logic ;
      SIGNAL TRANS_ENABLE_BARSignal  :  std_logic ;
      SIGNAL DAC_SDISignal           :  std_logic ;
      SIGNAL DAC_CLKSignal           :  std_logic ;
      SIGNAL MAIN_COVER_OPENSignal   :  std_logic ;
      SIGNAL AUX_COVER_OPENSignal    :  std_logic ;
      SIGNAL COVER_OPENSignal        :  std_logic ;      -- Main or Aux Cover is open 
      SIGNAL X_MDISignal             :  std_logic ;
--NEW PINS
-- Carriage DAC signals
      SIGNAL CARR_SPISTEA_BARSignal  :  std_logic ;
      SIGNAL CARR_DAC_LD_BARSignal   :  std_logic ;
-- Voice Coil DAC signals
      SIGNAL VC_SPISTEA_BARSignal    :  std_logic ;
      SIGNAL VC_DAC_LD_BARSignal     :  std_logic ;
-- Scan Illumination DAC signals
	  SIGNAL ILLUM_DAC_LD_BARSignal  :  std_logic ;
-- Overview DAC signals
	  SIGNAL OVR_DAC_LD_BARSignal    :  std_logic ;

      signal BitShift_s        : std_logic_vector(21 downto 0) ; 



BEGIN
	




-- RESET
process

begin
		PORESET_BARSignal <= '0';
		wait for 20 ns;
		PORESET_BARSignal <= '1';
		wait;

end process ;


-- 10MHz clock
process
			  
begin
		CLK_10M_1Signal <= '1';
		wait for 5 ns;
		CLK_10M_1Signal <= '0';
		wait for 5 ns;

end process ;


-- LED Flasher

process
			  
begin
		LED_FLASHERSignal <= '1';
		wait for 150 ns;
		LED_FLASHERSignal <= '0';
		wait for 150 ns;

end process ;



-- Serial read and write
process
    
constant Read_c : std_logic := '1' ;
constant Write_c : std_logic := '0' ;
constant MdrbLedCntrl_c   : std_logic_vector (3 downto 0) := "0000" ; 
constant MdrbSensorStat_c : std_logic_vector (3 downto 0) := "0001" ; 
constant MdrbSensorEdge_c : std_logic_vector (3 downto 0) := "0010" ; 
constant MdrbIntMask_c    : std_logic_vector (3 downto 0) := "0011" ; 
constant MdrbFault_c      : std_logic_vector (3 downto 0) := "0100" ; 
constant MdrbMotCntrl1_c  : std_logic_vector (3 downto 0) := "0101" ; 
constant MdrbMotCntrl2_c  : std_logic_vector (3 downto 0) := "0110" ; 
constant MdrbMotCntrl3_c  : std_logic_vector (3 downto 0) := "0111" ; 
constant MdrbScanLed_c    : std_logic_vector (3 downto 0) := "1000" ; 
constant MdrbOview_c      : std_logic_vector (3 downto 0) := "1001" ; 
constant MdrbCpldProg_c   : std_logic_vector (3 downto 0) := "1010" ; 





constant DataAAAA_c     : std_logic_vector (15 downto 0) := "1010101010101010" ;
constant Data5555_c     : std_logic_vector (15 downto 0) := "0101010101010101" ; 
constant DataGP_c       : std_logic_vector (15 downto 0) := "0111101011110101" ; 
constant DataOViewDAC_c : std_logic_vector (15 downto 0) := "0000110010101100" ; 
--constant DataXX_c  : std_logic_vector (7 downto 0) := "XXXXXXXX" ;

variable I : INTEGER range 0 to 21 := 0;     

begin
    
 
-- -- Read CPLD line length low                                                     
--                                                                                  
-- Bitshift_s <='X' & Read_c & ChipSelectCpld_c & LineTimeLowAddress_c & DataXX_c ; 
-- SCLKSignal <= '0';                                                               
-- SEN_BARSignal <= '1';                                                            
-- wait for 100 ns;                                                                 
-- SEN_BARSignal <= '0';                                                            
--                                                                                  
-- For I in 15 downto 0 loop                                                        
-- SDISignal <= BitShift_s( I );                                                    
-- wait for 100 ns;                                                                 
-- SCLKSignal <= '1';                                                               
-- wait for 100 ns;                                                                 
-- SCLKSignal <= '0';                                                               
-- end loop;                                                                        
-- SEN_BARSignal <= '1';                                                            
 


-- Write MDRB LED Control Register

Bitshift_s <='0' & Write_c & MdrbLedCntrl_c & DataGP_c ;
SCLKSignal <= '0'; 
SEN_BARSignal <= '1';

-- toggle sckl low while sem deasserted
SCLKSignal <= '1';
wait for 100 ns;
SCLKSignal <= '0';

wait for 100 ns;
SEN_BARSignal <= '0'; 

For I in 21 downto 0 loop     
SDISignal <= BitShift_s( I ); 
wait for 100 ns;
SCLKSignal <= '1';
wait for 100 ns;
SCLKSignal <= '0';
end loop;
-- doi
wait for 20 ns;
-- doi
SEN_BARSignal <= '1';

-- doi
wait for 100 ns;
Bitshift_s <='0' & Write_c & MdrbLedCntrl_c & DataAAAA_c ;
SEN_BARSignal <= '0'; 

For I in 21 downto 0 loop     
SDISignal <= BitShift_s( I ); 
wait for 100 ns;
SCLKSignal <= '1';
wait for 100 ns;
SCLKSignal <= '0';
end loop;
wait for 20 ns;
SEN_BARSignal <= '1';


wait for 200 ns;

-- Write Oview DAC Register

Bitshift_s <='0' & Write_c & MdrbOview_c & DataOViewDAC_c ;
SCLKSignal <= '0'; 
SEN_BARSignal <= '1';
wait for 100 ns;
SEN_BARSignal <= '0'; 

For I in 21 downto 0 loop     
SDISignal <= BitShift_s( I ); 
wait for 100 ns;
SCLKSignal <= '1';
wait for 100 ns;
SCLKSignal <= '0';
end loop;
-- doi
wait for 20 ns;
-- doi
SEN_BARSignal <= '1';

-- doi
wait for 100 ns;
Bitshift_s <='0' & Write_c & MdrbLedCntrl_c & DataOViewDAC_c ;
SEN_BARSignal <= '0'; 

For I in 21 downto 0 loop     
SDISignal <= BitShift_s( I ); 
wait for 100 ns;
SCLKSignal <= '1';
wait for 100 ns;
SCLKSignal <= '0';
end loop;
wait for 20 ns;
SEN_BARSignal <= '1';





wait;

end process ;    






    U1 : mdrb_control
		PORT MAP (
---                      TDI => TDISignal,
---		          TMS => TMSSignal,
---		          TCK => TCKSignal,
---		          TDO => TDOSignal,
		          SDI => SDISignal,
		          SEN_BAR => SEN_BARSignal,
		          SCLK => SCLKSignal,
		          SDO => SDOSignal,
--		          SW_1_BAR => SW_1_BARSignal,
--		          SW_2_BAR => SW_2_BARSignal,
--		          SW_3_BAR => SW_3_BARSignal,
--		          SW_4_BAR => SW_4_BARSignal,
--		          LED_FLASHER => LED_FLASHERSignal,
--		          LED_1 => LED_1Signal,
--		          LED_2 => LED_2Signal,
--		          LED_3 => LED_3Signal,
--		          LED_4 => LED_4Signal,
--		          S_FUSE_BLOWN => S_FUSE_BLOWNSignal,
--		          X_FUSE_BLOWN => X_FUSE_BLOWNSignal,
--		          CARR_FAULT_BAR => CARR_FAULT_BARSignal,
--		          VC_FAULT_BAR => VC_FAULT_BARSignal,
--		          EPI_LED_FAULT => EPI_LED_FAULTSignal,
--		          TRANS_LED_FAULT => TRANS_LED_FAULTSignal,
--		          A_FLAG => A_FLAGSignal,
--		          B_FLAG => B_FLAGSignal,
--		          C_FLAG => C_FLAGSignal,
--		          D_FLAG => D_FLAGSignal,
--		          E_FLAG => E_FLAGSignal,
--		          X_DATUM => X_DATUMSignal,
--		          MDRB_INT => MDRB_INTSignal,
		          CLK_10M_1 => CLK_10M_1Signal,
		          PORESET_BAR => PORESET_BARSignal
--		          PROG_DIS_BAR => PROG_DIS_BARSignal,
--		          ILLUM_DAC_SYNC_BAR => ILLUM_DAC_SYNC_BARSignal,
--		          ILLUM_ENABLE_BAR => ILLUM_ENABLE_BARSignal,
--		          OVR_DAC_SYNC_BAR => OVR_DAC_SYNC_BARSignal,
--		          EPI_ENABLE_BAR => EPI_ENABLE_BARSignal,
--		          TRANS_ENABLE_BAR => TRANS_ENABLE_BARSignal,
--		          DAC_SDI => DAC_SDISignal,
--		          DAC_CLK => DAC_CLKSignal,
--		          MAIN_COVER_OPEN => MAIN_COVER_OPENSignal,
--		          AUX_COVER_OPEN => AUX_COVER_OPENSignal,
--		          COVER_OPEN => COVER_OPENSignal,
--		          X_MDI => X_MDISignal,
--		          CARR_SPISTEA_BAR => CARR_SPISTEA_BARSignal,
--		          CARR_DAC_LD_BAR => CARR_DAC_LD_BARSignal,
--		          VC_SPISTEA_BAR => VC_SPISTEA_BARSignal,
--		          VC_DAC_LD_BAR => VC_DAC_LD_BARSignal,
--		          ILLUM_DAC_LD_BAR => ILLUM_DAC_LD_BARSignal,
--		          OVR_DAC_LD_BAR => OVR_DAC_LD_BARSignal
);
END HTWTestBench;













