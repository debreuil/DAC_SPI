
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_ADC is
	port
	(
		CLK : IN std_logic;
		VALUE: OUT std_logic_vector (11 downto 0);
		ACK: IN std_logic; 		
		SAMPLE_ADC: IN std_logic; 
		
		DEVICE_SIZE: OUT std_logic_vector (5 downto 0) := (others => 'Z'); 
		DIRECTION: OUT std_logic := '0'; 
		REQUEST: OUT std_logic := '0'; 
		READ_BUFFER: IN std_logic_vector (14 downto 0)
	);
end SPI_ADC;

architecture Behavioral of SPI_ADC is

	type adcStates is (IDLE, VERIFY_BUS, SETUP, RECEIVE);
	signal current_state: adcStates := IDLE;
	signal next_state: adcStates;

begin

	process(CLK, ACK, SAMPLE_ADC, READ_BUFFER) 	
	
		begin		
		
		if rising_edge(CLK) then
		
			current_state <= next_state;
		
			case current_state is
				when IDLE =>
					if SAMPLE_ADC = '1' then
						REQUEST <= '1';
						next_state <= VERIFY_BUS;
					end if;
					
				when VERIFY_BUS =>
					if ACK = '1' then
						next_state <= SETUP;
					else
						next_state <= VERIFY_BUS;				
					end if;
					
				when SETUP =>
						REQUEST <= '0';
						next_state <= RECEIVE;						
					
				when RECEIVE =>
					if ACK = '0' then -- sample complete when ack toggled back to zero
						VALUE <= READ_BUFFER(11 downto 0);
						REQUEST <= '0';
						next_state <= IDLE;	
					else
						next_state <= RECEIVE;			
					end if;
			end case;
			
			
		end if;
	end process;

	--DEVICE_SIZE <= (others => 'Z'); 
	--DEVICE_SIZE <= std_logic_vector(to_unsigned(READ_BUFFER'high, READ_BUFFER'length)) when current_state=RECEIVE else (others => 'Z'); -- 15 bits
	DEVICE_SIZE <= "001110" when current_state=SETUP OR current_state=RECEIVE else (others => 'Z'); -- 16 bits

end Behavioral;

