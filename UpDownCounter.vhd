
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UpDownCounter is
	generic
	(
		min:integer;
		max:integer;
		delay:integer
	);
	port
	(
		CLK : IN std_logic;
		COUNTER_OUT : OUT integer := min
	);
	
end UpDownCounter;


architecture Behavioral of UpDownCounter is

begin
	process(CLK)
		variable counter : integer := min;
		variable delayCount : integer := 0;
		variable direction : boolean := true;
	begin
	
		if rising_edge(CLK) then
		
			delayCount := delayCount + 1;
			
			if delayCount = delay then
				COUNTER_OUT <= counter;	
				delayCount := 0;
				if direction then
					counter := counter + 1;
					if counter = max then 
						direction := false;
					end if;
				else
					counter := counter - 1;
					if counter = min then
						direction := true;
					end if;
				end if;
					
			end if;
			
		end if;
		
	end process;

end Behavioral;

