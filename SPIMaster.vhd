	
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SPI.all;

entity SPIMaster is
	GENERIC (DEVICE_COUNT: integer);
	port
	(
		CLK : IN std_logic;		
		DATA : INOUT std_logic := '0';
		DEVICES_CS : OUT std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '1');		
		ACK_DEVICE: OUT std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');	
		
		DEVICE_SIZE : IN  std_logic_vector (5 downto 0); 
		DEVICE_DIRECTION : IN std_logic_vector(0 to DEVICE_COUNT - 1); -- '0' DAC (OUT) '1' ADC (IN)
		REQUEST_DEVICE: IN std_logic_vector(0 to DEVICE_COUNT - 1);
		TRANSMIT_BUFFER: IN std_logic_vector (31 downto 0);
		RECEIVE_BUFFER: OUT std_logic_vector (31 downto 0)	 := (others => '1')	
	);
end SPIMaster;

architecture Behavioral of SPIMaster is	

	type spiStates is (IDLE, SETUP, TIMEOUT, SEND, SENDING, RECEIVE, RECEIVING, COMPLETE);
	signal current_state: spiStates := IDLE;
	signal next_state: spiStates;
	
begin
		
	process (CLK, REQUEST_DEVICE, TRANSMIT_BUFFER, next_state) 
	
		variable reg : std_logic_vector (TRANSMIT_BUFFER'high downto 0);
		variable testBit : std_logic_vector (0 to DEVICE_COUNT - 1) := (0 => '1', others => '0');
	
		constant zeros : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
		constant maxWaitTime:integer := 20;
		variable timeoutCounter : integer range 0 to maxWaitTime := 0;	
		variable counter : integer range 0 to TRANSMIT_BUFFER'high := 0;	
				
	begin
	
		current_state <= next_state;
			
		if falling_edge(CLK) then
			
			case current_state is
			
				when IDLE => 
					DEVICES_CS <= (others => '1');
					testBit := testBit(1 to testBit'HIGH) & testBit(0);
					
					if (REQUEST_DEVICE AND testBit) /= zeros then 
						ACK_DEVICE <= testBit;
						timeoutCounter := maxWaitTime;
						next_state <= SETUP;
					else
						ACK_DEVICE <= zeros;
					end if;					
			
				when SETUP =>  
					timeoutCounter := timeoutCounter - 1;
					-- check if user has toggled bit off indicating they are ready to send
					if (REQUEST_DEVICE AND testBit) = zeros then 	
						if (DEVICE_DIRECTION AND testBit) = zeros then -- MISO
							next_state <= RECEIVE;
						else -- MOSI
							-- toggle bit off to reset that input slot
							reg := TRANSMIT_BUFFER;
							next_state <= SEND;
						end if;
					elsif timeoutCounter <= 0 then
						next_state <= TIMEOUT;
					end if;
								
				when RECEIVE => 
					counter := to_integer(unsigned(DEVICE_SIZE));
					DEVICES_CS <= NOT testBit;
					next_state <= RECEIVING;
			
				when RECEIVING =>							
					if counter = 0 then		
						next_state <= COMPLETE;
					else
						RECEIVE_BUFFER(counter - 1) <= DATA;	
						counter := counter - 1;	
					end if;
			
				when SEND => 
					counter := to_integer(unsigned(DEVICE_SIZE));
					DEVICES_CS <= NOT testBit;
					next_state <= SENDING;
			
				when SENDING =>							
					if counter = 0 then		
						next_state <= COMPLETE;
					else
						DATA <= reg(counter - 1);	
						counter := counter - 1;	
					end if;
			
				when TIMEOUT => 
					-- timed out, reset bit and return to idle
					ACK_DEVICE <= zeros;
					next_state <= IDLE;
					
				when COMPLETE =>
					DEVICES_CS <= (others => '1');
					ACK_DEVICE <= zeros;
					next_state <= IDLE;
				
				when others =>
				
			end case;
		end if;		
		
	end process;

end Behavioral;

