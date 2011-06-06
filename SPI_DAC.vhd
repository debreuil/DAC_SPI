
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.spi.ALL;


entity SPI_DAC is
	port
	(
		CLK : IN std_logic;
		VALUE: IN std_logic_vector (11 downto 0);
		ACK: IN std_logic; 
		
		DEVICE_SIZE: OUT std_logic_vector (5 downto 0) := (others => 'Z');
		DIRECTION: OUT std_logic := '1'; 
		REQUEST: OUT std_logic := '0'; 
		WRITE_BUFFER: OUT std_logic_vector (15 downto 0) := (others => '0')
	);
end SPI_DAC;

architecture Behavioral of SPI_DAC is

	type dacStates is (IDLE, REQUEST_BUS, VERIFY_BUS, SETUP, SEND);
	signal current_state: dacStates := IDLE;
	signal next_state: dacStates;
	signal prev_value : std_logic_vector (11 downto 0) := (others => 'X');
	
	constant IGNORE:std_logic := '0'; -- 0:use, 1:ignore
	constant BUFFERED:std_logic := '0'; -- 0:unbuffered, 1:buffered
	constant GAIN:std_logic := '1'; -- 0:2X, 1:1X
	constant ACTIVE:std_logic := '1'; -- 0:shutdown, 1:active

begin

	process(CLK, VALUE) 
	
	
		begin		
		
		if rising_edge(CLK) then
		
			current_state <= next_state;
		
			case current_state is
				when IDLE =>
					if VALUE /= prev_value then
						next_state <= REQUEST_BUS;
					end if;
					
				when REQUEST_BUS =>
					prev_value <= VALUE;
					REQUEST <= '1';
					next_state <= VERIFY_BUS;
					
				when VERIFY_BUS =>
					if ACK = '1' then
						next_state <= SETUP;
					else
						next_state <= VERIFY_BUS;				
					end if;
					
				when SETUP =>
						REQUEST <= '0';
						next_state <= SEND;			
					
				when SEND =>
						REQUEST <= '0';
						next_state <= IDLE;
			end case;
			
			
		end if;
	end process;

	WRITE_BUFFER <= (IGNORE & BUFFERED & GAIN & ACTIVE & prev_value) when current_state=SETUP OR current_state=SEND else (others => 'Z');
	--DEVICE_SIZE <= std_logic_vector(to_unsigned(WRITE_BUFFER'high, WRITE_BUFFER'length)) when current_state=SEND else (others => 'Z'); -- 16 bits
	DEVICE_SIZE <= "001111" when current_state=SETUP OR current_state=SEND else (others => 'Z'); -- 16 bits
	
end Behavioral;




