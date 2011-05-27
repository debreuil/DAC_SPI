
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY DACFader_test IS
END DACFader_test;
 
ARCHITECTURE behavior OF DACFader_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DACFader
    PORT(
         CLK : IN  std_logic;
         SCK : INOUT  std_logic;
         CS : INOUT  std_logic;
         MOSI : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';

	--BiDirs
   signal SCK : std_logic;
   signal CS : std_logic;
   signal MOSI : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DACFader PORT MAP (
          CLK => CLK,
          SCK => SCK,
          CS => CS,
          MOSI => MOSI
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
