
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DAC_Test IS
END DAC_Test;
 
ARCHITECTURE behavior OF DAC_Test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DAC
    PORT(
         CLK : IN  std_logic;
         SCK : INOUT  std_logic;
         CS : OUT  std_logic;
         MOSI : OUT  std_logic;
         VALUE : IN  std_logic_vector(11 downto 0);
         SEND : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal VALUE : std_logic_vector(11 downto 0) := (others => '0');
   signal SEND : std_logic := '0';

	--BiDirs
   signal SCK : std_logic;

 	--Outputs
   signal CS : std_logic;
   signal MOSI : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DAC PORT MAP (
          CLK => CLK,
          SCK => SCK,
          CS => CS,
          MOSI => MOSI,
          VALUE => VALUE,
          SEND => SEND
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

      send <= '0';
      value <= "100000000001";
		wait for CLK_period*2;
		
      send <= '1';
		
   end process;

END;
