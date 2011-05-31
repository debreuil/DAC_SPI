
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.spi.ALL;


entity SPI_DAC is
	port
	(
		CLK : IN std_logic;
		BUSY: IN std_logic;
		VALUE: IN std_logic_vector (11 downto 0);
		ACK: IN std_logic; 
		
		REQUEST: OUT std_logic := '0'; 
		OUT_VALUE: OUT std_logic_vector (15 downto 0) := "ZZZZZZZZZZZZZZZZ"
	);
end SPI_DAC;

architecture Behavioral of SPI_DAC is

	type dacStates is (IDLE, REQUEST_BUS, VERIFY_BUS, SEND);
	signal current_state: dacStates := IDLE;
	signal next_state: dacStates;
	signal prev_value : std_logic_vector (11 downto 0) := "XXXXXXXXXXXX";
	
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
					if BUSY = '0' then
						prev_value <= VALUE;
						REQUEST <= '1';
						next_state <= VERIFY_BUS;
					end if;
					
				when VERIFY_BUS =>
					if ACK = '1' then
						next_state <= SEND;
					else
						next_state <= VERIFY_BUS;	-- someone else won, we must wait					
					end if;
					
				when SEND =>
						--OUT_VALUE <= IGNORE & BUFFERED & GAIN & ACTIVE & prev_value;
						REQUEST <= '0';
						next_state <= IDLE;
			end case;
			
			
		end if;
	end process;

	OUT_VALUE <= (IGNORE & BUFFERED & GAIN & ACTIVE & prev_value) when current_state=SEND else (others => 'Z');
	
end Behavioral;




