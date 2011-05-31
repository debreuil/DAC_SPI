
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.SPI.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SPIMaster_test IS
END SPIMaster_test;
 
ARCHITECTURE behavior OF SPIMaster_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPIMaster
    PORT(
         CLK : IN  std_logic;
         MOSI : OUT  std_logic;
         DEVICES_CS : OUT  std_logic_vector(0 to DEVICE_COUNT - 1);
         BUSY : OUT  std_logic;
         REQUEST_DEVICE : INOUT integer range 0 to 3;
         VALUE : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal VALUE : std_logic_vector(15 downto 0) := (others => '0');

	--BiDirs
   --signal REQUEST_DEVICE : std_logic_vector(0 to 1);
   signal REQUEST_DEVICE : integer range 0 to 3;

 	--Outputs
   signal MOSI : std_logic;
   signal DEVICES_CS : std_logic_vector(0 to DEVICE_COUNT - 1);
   signal BUSY : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPIMaster PORT MAP (
          CLK => CLK,
          MOSI => MOSI,
          DEVICES_CS => DEVICES_CS,
          BUSY => BUSY,
          REQUEST_DEVICE => REQUEST_DEVICE,
          VALUE => VALUE
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
      wait for 10 ns;	

      wait for CLK_period*10;

		REQUEST_DEVICE <= 1;
      wait for CLK_period;
		VALUE <= "1000000000000001";
		REQUEST_DEVICE <= 0;

      wait;
   end process;

END;
