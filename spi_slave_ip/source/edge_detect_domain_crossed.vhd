----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.02.2016 00:20:41
-- Design Name: 
-- Module Name: edge_detect_domain_crossed - Behavioral
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

entity edge_detect_domain_crossed is
    Port ( clk : in std_logic;
           signal_to_detect : in std_logic;
           rising_edge_detected : out std_logic;
           falling_edge_detected : out std_logic
         );
end edge_detect_domain_crossed;

architecture Behavioral of edge_detect_domain_crossed is

    component level_change_domain is
        generic(number_of_domain_cross_regs : natural := 2);
        Port ( signal_in : in  STD_LOGIC;
               SystemClk : in  STD_LOGIC;
               signal_out : out  STD_LOGIC
               );
    end component;

    signal signal_to_detect_s : std_logic := '0';
    signal signal_to_detect_r0 : std_logic := '0';

begin

    level_change_domain_inst : level_change_domain
        generic map (
                     number_of_domain_cross_regs => 2 -- : natural := 2
                     )
        Port map (  
                  signal_in => signal_to_detect,   -- : in  STD_LOGIC;
                  SystemClk => clk,                -- : in  STD_LOGIC;
                  signal_out => signal_to_detect_s -- : out  STD_LOGIC
                  );

    reg_proc : process
    begin
        wait until rising_edge(clk);
        signal_to_detect_r0 <= signal_to_detect_s;
    end process;

    rising_edge_detected <= '1' when signal_to_detect_r0 = '0' and signal_to_detect_s = '1' else '0';
    falling_edge_detected <= '1' when signal_to_detect_r0 = '1' and signal_to_detect_s = '0' else '0';

end Behavioral;
