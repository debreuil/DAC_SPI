-- Robin Debreuil, public domain
-- For interfacing with the MCP4921 DAC chip using SPI @ 16MHz
-- Set value to send in VALUE
-- Send it by clicking SEND high

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity DAC is
	port(
		CLK: in std_logic;
		CLK2: inout std_logic;
		SCK: out std_logic;
		CS: out std_logic;
		MOSI: out std_logic;
		VALUE: in std_logic_vector (11 downto 0);
		SEND: in std_logic
	);
end DAC;

architecture behavioral of DAC is

	signal SENDING : std_logic := '0';
	signal reg : std_logic_vector (15 downto 0);
	
	constant DELAY:integer := 2; -- 32 MHz / 2 == 16 MHz
	
	constant IGNORE:std_logic := '0'; -- 0:use, 1:ignore
	constant BUFFERED:std_logic := '0'; -- 0:unbuffered, 1:buffered
	constant GAIN:std_logic := '1'; -- 0:2X, 1:1X
	constant ACTIVE:std_logic := '1'; -- 0:shutdown, 1:active
	
begin


	clkDiv : entity work.ClockDivider(Behavioral) 
					generic map(DELAY => DELAY)
					port map (CLK, CLK2);		
	
	process(CLK2, SEND) 
	
	variable counter : integer range 0 to 15 := 0;	
	
	begin
	
		if falling_edge(CLK2) then
		
			if SEND = '1' then	
				reg <= IGNORE & BUFFERED & GAIN & ACTIVE & VALUE;
				counter := 0;	
				CS <= '0';
				SENDING <= '1';	
				
			elsif SENDING = '1' then				
					reg <= reg(14 downto 0) & '0';
					
					if counter = 15 then		
						counter := 0;	
						CS <= '1';
						SENDING <= '0'; 
					else
						counter := counter + 1;	
					end if;
			end if;			
		end if;
		
	end process;
	
	SCK <= CLK2 AND SENDING;
	MOSI <= reg(15);
	
end behavioral;


