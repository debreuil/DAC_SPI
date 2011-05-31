-- Robin Debreuil, public domain
-- Generic clock divider
-- Set DELAY param to an even number, 
-- clock will have the falling edge at midpoint

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockDivider is
	GENERIC (DELAY: integer := 16 );
	PORT 
	( 
		CLK : in  STD_LOGIC;
		CLK_OUT : out  STD_LOGIC := '0'
	);
end ClockDivider;

architecture Behavioral of ClockDivider is
	
begin	
	
	process(CLK)
	
		variable counter : integer range 0 to DELAY := 0;
		
		begin
		
			if(CLK'event AND CLK='1') then
				counter := counter + 1;
				if counter = DELAY / 2 then
					CLK_OUT <= '0';
				elsif counter = DELAY then
					counter := 0;
					CLK_OUT <= '1';
				end if;
				
			end if;
	end process;
	
end Behavioral;

