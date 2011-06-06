
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
		ACK: IN std_logic;
		
		DEVICE_SIZE: OUT std_logic_vector (5 downto 0);
		DIRECTION : OUT std_logic;
		REQUEST: OUT std_logic;
		WRITE_BUFFER: OUT std_logic_vector (15 downto 0)
	);
end UpDownDAC;

architecture Behavioral of UpDownDAC is

	signal DAC_VALUE: std_logic_vector (11 downto 0);
	signal counterVal:integer range min to max := min;
		
begin

	dac : entity work.SPI_DAC(Behavioral) 
		port map 
		(
			CLK => CLK, 
			VALUE => DAC_VALUE, 
			ACK => ACK, 		
			DEVICE_SIZE => DEVICE_SIZE, 	
			DIRECTION => DIRECTION, 
			REQUEST => REQUEST, 
			WRITE_BUFFER => WRITE_BUFFER
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

