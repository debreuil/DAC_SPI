
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DualDac_test IS
END DualDac_test;
 
ARCHITECTURE behavior OF DualDac_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DualDac
    PORT(
         SYSCLK : IN  std_logic;
         SCK : INOUT  std_logic;
         DATA : INOUT  std_logic;
         CS0 : OUT  std_logic;
         CS1 : OUT  std_logic;
         CS2 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal SYSCLK : std_logic := '0';

	--BiDirs
   signal SCK : std_logic;
   signal DATA : std_logic;

 	--Outputs
   signal CS0 : std_logic;
   signal CS1 : std_logic;
   signal CS2 : std_logic;

   -- Clock period definitions
   constant SYSCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DualDac PORT MAP (
          SYSCLK => SYSCLK,
          SCK => SCK,
          DATA => DATA,
          CS0 => CS0,
          CS1 => CS1,
          CS2 => CS2
        );

   -- Clock process definitions
   SYSCLK_process :process
   begin
		SYSCLK <= '0';
		wait for SYSCLK_period/2;
		SYSCLK <= '1';
		wait for SYSCLK_period/2;
   end process;
	
--   input_process :process
--   begin
--		DATA <= '0' when CS2 = '0' else 'Z';
--		wait for SYSCLK_period * 2;
--		DATA <= '1' when CS2 = '0' else 'Z';
--		wait for SYSCLK_period * 2;		
--   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		
		DATA <= '0'; 
      wait for 325 ns;

      -- insert stimulus here 

      wait;
   end process;


END;
