-- Robin Debreuil, public domain
-- Test for MCP4921 DAC chip, fades in and out
-- wire SCK, MOSI, and CS as per datasheet

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DACFader is
	port(
         CLK  : IN  std_logic;
         SCK  : INOUT  std_logic;
         CS   : INOUT  std_logic;
         MOSI : INOUT  std_logic
		);
end DACFader;

architecture Behavioral of DACFader is	

	signal VALUE : std_logic_vector (11 downto 0);
	signal SEND : std_logic := '0';	
   signal CLK2  : std_logic;
	
	constant DELAY : integer := 2500;

begin
		dac0 : entity work.DAC(Behavioral) port map (CLK, CLK2, SCK, CS, MOSI, VALUE, SEND);
		
		process(CLK2)	
			variable counter : integer range 0 to 4095 := 0;
			variable delayCount : integer range 0 to DELAY := 0;
			variable direction : boolean := true;
		begin		
			if rising_edge(CLK2) then
			
				delayCount := delayCount + 1;
				
				if delayCount = DELAY then
					delayCount := 0;
					if direction then
						counter := counter + 1;
						if counter = 3500 then --4095 then
							direction := false;
						end if;
					else
						counter := counter - 1;
						if counter = 2300 then --0 then
							direction := true;
						end if;
					end if;
					
					VALUE <= std_logic_vector(to_unsigned(counter, 12));
					SEND <= '1';
				elsif CS = '0' then
					SEND <= '0';					
				end if;
				
			end if;
		end process;

end Behavioral;

