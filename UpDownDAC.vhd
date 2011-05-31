
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SPI.all;

entity UpDownDAC is
	generic
	(
		delay : integer := 2500;
		min 	: integer := 1000;
		max 	: integer := 1500
	);
	port
	(
		CLK : IN std_logic;
		BUSY: IN std_logic;
		ACK: IN std_logic;
		
		REQUEST: OUT std_logic;
		OUT_VALUE: OUT std_logic_vector (15 downto 0)
	);
end UpDownDAC;

architecture Behavioral of UpDownDAC is

	signal DAC_VALUE: std_logic_vector (11 downto 0);
	signal counterVal:integer;
		
begin

	dac : entity work.SPI_DAC(Behavioral) 
		port map 
		(
			CLK => CLK, 
			BUSY => BUSY, 
			VALUE => DAC_VALUE, 
			ACK => ACK, 
			REQUEST => REQUEST, 
			OUT_VALUE => OUT_VALUE
		);	
		
	udc : entity work.UpDownCounter(Behavioral)
		generic map
		(
			min => min,
			max => max,
			delay => delay
		)
		port map
		(
			CLK => CLK,
			COUNTER_OUT => counterVal
		);

	process(counterVal)
	begin
		DAC_VALUE <= std_logic_vector(to_unsigned(counterVal, DAC_VALUE'length));		
	end process;

end Behavioral;

