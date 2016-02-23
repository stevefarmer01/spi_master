----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.02.2016 00:12:14
-- Design Name: 
-- Module Name: gdrb_testbench - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.multi_array_types_pkg.all;
use work.gdrb_ctrl_bb_pkg.ALL;


entity gdrb_testbench is
end gdrb_testbench;

architecture Behavioral of gdrb_testbench is

component gdrb_ctrl is
generic( testbench_mode : boolean := FALSE);
port
(
-- pragma translate_off
    --. JTAG i/f - 4
    TCK : in std_logic := '0';  -- this will be controled by Begalbone
    TMS : in std_logic := '0';  -- this will be controled by Begalbone
    TDI : in std_logic := '0';  -- this will be controled by Begalbone
    TDO : out std_logic := '0'; -- this will be controled by Begalbone this will go to TDI of gdrb_dig_pld_dpmux FPGA
-- pragma translate_on

-- pragma translate_off
    --Testbench only signals for begalbone SPI discrete pins testing
    bb_reg_map_array_from_pins : in mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
    bb_reg_map_array_to_pins : out mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
-- pragma translate_on

    ---Clk/Reset - 4
    CLK60M : in std_logic;
    FPGA_RESET : in std_logic := '0';       -- From Begalbone to control FPGA coming out of reset at right time
    FPGA_ENABLE_BAR : in std_logic := '1';      -- From Begalbone to tri-state all of FPGA's ports
    GDRB_RESET_BAR : in std_logic := '1';


    ---GHDB master SPI from GHDB to.....
    FOC_SDI : in std_logic := '0';
    FOC_SCLK : in std_logic := '0';
    FOC_SMODE_BAR : in std_logic := '1';
    FOC_SDO : out std_logic := '0';                 -- This will go back to GDPB via a pin on the camera link tx to GHDB
    ---......GDRB_DPMUX FPGA (straight through from FOC_xx ports unless there are issues)
    CISMUX_SDI : out std_logic := '0';
    cismux_sclk : out std_logic := '0';
    cismux_sdo : in std_logic := '0';
    cismux_sen_bar : out std_logic := '1';

    ---Begalbone master SPI....
    VC_SPI_CS : in std_logic := '0';
    VC_SPI_MOSI : in std_logic := '0';
    VC_SPI_SCLK : in std_logic := '0';
    VC_SPI_LDAC_BAR : in std_logic := '0';
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
    CIS_SPI_DOUT_AFE1  : in std_logic := '0';
    CIS_SPI_DOUT_AFE2  : in std_logic := '0';
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

    ------Register map pins-----.

    --Register Map Address - 0x0
    ---Motor Datum
    MOT1_DATUM : in std_logic := '0';
    MOT2_DATUM : in std_logic := '0';
    MOT3_DATUM : in std_logic := '0';
    MOT4_DATUM : in std_logic := '0';
    ---Cover detects
    FRONT_COVER_OPEN : in std_logic := '0';
    LEFT_COVER_OPEN : in std_logic := '0';
    RIGHT_COVER_OPEN : in std_logic := '0';
    SPARE_SENSOR : in std_logic := '0';
    ---Tray detects
    TRAY_SENS1 : in std_logic := '0';
    TRAY_SENS2 : in std_logic := '0';
    TRAY_SENS3 : in std_logic := '0';
    TRAY_SENS4 : in std_logic := '0';
    TRAY_GATE_DETECT : in std_logic := '0';
    ---Interlocks
    ILOCK1_OK_BAR : in std_logic := '0';  --changed 120216
    ILOCK2_OK_BAR : in std_logic := '0';  --changed 120216
    --Plus a global fault bit for Register 0x4------------------------------.
    
    --Register Map Address - 0x1
    --Detection of above Register

    --Register Map Address - 0x2
    --Interupt mask of above Register

    --Register Map Address - 0x3
    ---Fault detection discretes
    MOT1_FAULT_BAR : in std_logic := '0';
    MOT2_FAULT_BAR : in std_logic := '0';
    MOT3_FAULT_BAR : in std_logic := '0';
    MOT4_FAULT_BAR : in std_logic := '0';
    P12V_IN_FAULT_BAR : in std_logic := '0';
    P24V_FAULT : in std_logic := '0';
    HR_LED_PWR_FAULT_BAR : in std_logic := '0';
    TX_LED_PWR_FAULT_BAR : in std_logic := '0';
    RX_LED_PWR_FAULT_BAR : in std_logic := '0';
    VC_DRIVER_FAULT_BAR : in std_logic := '0';
    SOL_FAULT_BAR : in std_logic := '0';
    BB_FAULT : in std_logic := '0';

    --Register Map Address - 0x4
    --Detection of above Register

    --Register Map Address - 0x5
    --Interupt mask of above Register

    --Register Map Address - 0x6
    --Miscellaneous in discretes
    ---CIS PCB discretes
    CIS_HDB_SENSE_BAR : in std_logic := '0';
    ---GDRB to GHDB Discretes
    FOC_SENSE_BAR : in std_logic := '0';
    FOC_CONFIG : in std_logic := '0';
    ---On board discretes in
    HR_LED_SENSE_BAR : in std_logic := '0';
    CIS_TX_LED_SENSE_BAR : in std_logic := '0';
    UI_SENSE_BAR : in std_logic := '0';
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
end component;

component spi_master_tb_gdrb_ctrl_bb_wrap is
     generic(
            external_spi_slave_dut : boolean := false;
            make_all_addresses_writeable_for_testing : boolean := TRUE;
            DUT_TYPE : string := "write_and_then_read_an_address"
--            DUT_TYPE : string := "spi_reg_map_simple"
            );
    port(
            ---To DUT Slave SPI interface pins
            sclk : out STD_LOGIC;
            ss_n : out STD_LOGIC;
            mosi : out STD_LOGIC;
            miso : in STD_LOGIC;
            --All test finished
            stop_clks_to_dut : out boolean;
            --Discrete signals
            reg_map_array_from_pins : in mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins : out mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
        );
end component;

constant TIME_PERIOD_CLK : time                          := 16.67 ns;

signal   sys_clk_60m_s       : std_logic                     := '0';  -- system clock
signal   sys_rst_s      : std_logic                     := '1';  -- system reset

signal ghdb_master_sclk_s, ghdb_master_ss_n_s, ghdb_master_mosi_s, ghdb_master_miso_s : std_logic := '0';
signal ghdb_master_stop_clks_s : std_logic := '0';
signal bb_master_sclk_s, bb_master_ss_n_s, bb_master_mosi_s, bb_master_miso_s : std_logic := '0';
signal bb_master_stop_clks_s : boolean := FALSE;
signal stop_clks_S : boolean := FALSE;
signal trigger_another_reset_s : boolean := FALSE;

signal bb_reg_map_array_from_pins_s, bb_reg_map_array_to_pins_s : mem_array_t( 0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0) := (others => (others => '0')); -- From DUT pins and to DUT pins

begin

---reset and clocks
reset_proc : process
begin
    sys_rst_s <= '1';
    wait for 2 * TIME_PERIOD_CLK;
    sys_rst_s <= '0';
    wait until trigger_another_reset_s;
end process;

clk_gen_proc : process
begin
    while not stop_clks_S loop
        wait for TIME_PERIOD_CLK/2;
        sys_clk_60m_s <= not sys_clk_60m_s;
    end loop;
    wait;
end process;

begalbone_master_spi_bfm : spi_master_tb_gdrb_ctrl_bb_wrap
     generic map(
            external_spi_slave_dut => TRUE, -- : boolean := TRUE;
            make_all_addresses_writeable_for_testing => FALSE, -- : boolean := FALSE;
            DUT_TYPE => "input_vector_file_test" -- : string := "input_vector_file_test"
            )
    port map(
            --To DUT Slave SPI interface pins
            sclk => bb_master_sclk_s,                  -- : out STD_LOGIC;
            ss_n => bb_master_ss_n_s,                  -- : out STD_LOGIC;
            mosi => bb_master_mosi_s,                  -- : out STD_LOGIC;
            miso => bb_master_miso_s,                  -- : in STD_LOGIC;
            --All test finished
            stop_clks_to_dut => bb_master_stop_clks_s, -- : out boolean
            --Discrete signals
            reg_map_array_from_pins => bb_reg_map_array_to_pins_s, -- : in mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
            reg_map_array_to_pins => bb_reg_map_array_from_pins_s-- : out mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0)
        );

dut_gdrb_ctrl : gdrb_ctrl
generic map
    ( 
        testbench_mode => TRUE -- : boolean := FALSE
    )
port map
(
    --Testbench only signals for begalbone SPI discrete pins testing
    bb_reg_map_array_from_pins => bb_reg_map_array_from_pins_s, -- : in mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);
    bb_reg_map_array_to_pins => bb_reg_map_array_to_pins_s, -- : out mem_array_t(0 to (2**SPI_ADDRESS_BITS)-1, SPI_DATA_BITS-1 downto 0);

    ---Clk/Reset - 4
    CLK60M => sys_clk_60m_s, -- : in std_logic;
    FPGA_RESET => sys_rst_s, -- : in std_logic := '0';       -- From Begalbone to control FPGA coming out of reset at right time
    FPGA_ENABLE_BAR => open, -- : in std_logic := '1';      -- From Begalbone to tri-state all of FPGA's ports
    GDRB_RESET_BAR => open, -- : in std_logic := '1';


--    ---GHDB master SPI from GHDB to.....
--    FOC_SDI => , -- : in std_logic;
--    FOC_SCLK => , -- : in std_logic;
--    FOC_SMODE_BAR => , -- : in std_logic;
--    FOC_SDO => , -- : out std_logic;                 -- This will go back to GDPB via a pin on the camera link tx to GHDB
--    ---......GDRB_DPMUX FPGA (straight through from FOC_xx ports unless there are issues)
--    CISMUX_SDI => , -- : out std_logic := '0';
--    cismux_sclk => , -- : out std_logic := '0';
--    cismux_sen_bar => , -- : out std_logic := '0';
--    cismux_sdo => , -- : in std_logic;
--
--    ---Begalbone master SPI....
--    VC_SPI_CS : in std_logic;
--    VC_SPI_MOSI : in std_logic;
--    VC_SPI_SCLK : in std_logic;
--    VC_SPI_LDAC_BAR : in std_logic;
--    ---....to on-board Voice Coil DAC (straight through unless there are issues)
--    VC_SPI_DAC_SYNC_BAR : out std_logic;
--    vc_spi_dac_din : out std_logic;
--    VC_SPI_DAC_SCLK : out std_logic;
--    VC_SPI_DAC_LDAC_BAR : out std_logic;
--
--    ---GHDB master SPI has access to CIS PCB.....
--    CIS_SPI_SCLK : out std_logic := '0';
--    CIS_SPI_DIN : out std_logic := '0';
--    ---....AFE's and......
--    CIS_SPI_CS_AFE1_BAR : out std_logic := '0'; -- CIS AFE's
--    CIS_SPI_CS_AFE2_BAR : out std_logic := '0';
--    CIS_SPI_DOUT_AFE1  : in std_logic;        
--    CIS_SPI_DOUT_AFE2  : in std_logic;        
--    ---.....Illumination DAC's
--    CIS_ILLUM_DAC_SYNC1_BAR : out std_logic := '0';  -- CIS DAC's are read only -- These DAC's are the same part number as 'Begalbone SPI to illumination DAC's' below
--    CIS_ILLUM_DAC_SYNC2_BAR : out std_logic := '0';
--    CIS_ILLUM_DAC_LDAC_BAR : out std_logic := '0';         

    ---Another Begalbone master SPI....
    BB_CTRL_SPI_MISO => bb_master_miso_s, -- : out std_logic;
    BB_CTRL_SPI_SCLK => bb_master_sclk_s, -- : in std_logic;
    BB_CTRL_SPI_MOSI => bb_master_mosi_s, -- : in std_logic;
    BB_CTRL_SPI_CS => bb_master_ss_n_s -- : in std_logic;
--    ---which is de_muxed onto 4 SPI ports (3 external and 1 internal).....
--    SPI_MUX0 : in std_logic := '0';
--    SPI_MUX1 : in std_logic := '0';
--    SPI_MUX2 : in std_logic := '0';
--    SPI_MUX3 : in std_logic := '0';
--    ---....one which goes to on-board illumination DAC's and.....
--    ILLUM_DAC_SPI_LDAC_BAR : out std_logic := '1';
--    ILLUM_DAC_SPI_SCLK : out std_logic := '1';
--    illum_dac_spi_din : out std_logic := '1';
--    ILLUM_DAC_SPI_SYNC1_BAR : out std_logic := '1';
--    ILLUM_DAC_SPI_SYNC2_BAR : out std_logic := '1';
--    ---....User Interface PCB
--    UI_SPI_CS_BAR : out std_logic := '1';
--    ui_spi_mosi : out std_logic := '1';
--    ui_spi_miso : in std_logic := '1';
--    UI_SPI_SCLK : out std_logic := '1';
);


end Behavioral;