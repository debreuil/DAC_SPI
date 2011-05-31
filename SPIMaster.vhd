	
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SPI.all;

entity SPIMaster is
	port
	(
		CLK : IN std_logic;
		
		MOSI : OUT std_logic := '0';
		DEVICES_CS : OUT std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '1');
		BUSY: OUT std_logic := '0';
		ACK_DEVICE: OUT std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
		
		REQUEST_DEVICE: IN std_logic_vector(0 to DEVICE_COUNT - 1);
		VALUE: IN std_logic_vector (15 downto 0)		
	);
end SPIMaster;

architecture Behavioral of SPIMaster is	

	type spiStates is (IDLE, SETUP, TIMEOUT, SEND, SENDING, COMPLETE);
	signal current_state: spiStates := IDLE;
	signal next_state: spiStates;
	
begin
		
	process (CLK, REQUEST_DEVICE, VALUE) 
	
		variable reg : std_logic_vector (VALUE'length - 1 downto 0);
		variable testBit : std_logic_vector (0 to DEVICE_COUNT - 1) := (0 => '1', others => '0');
	
		constant zeros : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
		constant maxWaitTime:integer := 20;
		variable timeoutCounter : integer range 0 to maxWaitTime := 0;	
		variable counter : integer range 0 to VALUE'length := 0;	
				
	begin
	
		current_state <= next_state;
			
		if falling_edge(CLK) then
			
			case current_state is
			
				when IDLE => 
					DEVICES_CS <= (others => '1');
					testBit := testBit(1 to DEVICE_COUNT-1) & testBit(0);
					
					if (REQUEST_DEVICE AND testBit) /= zeros then 
						BUSY <= '1';
						ACK_DEVICE <= testBit;
						timeoutCounter := maxWaitTime;
						next_state <= SETUP;
					else
						BUSY <= '0';
						ACK_DEVICE <= zeros;
					end if;					
			
				when SETUP =>  
					timeoutCounter := timeoutCounter - 1;
					-- check if user has toggled bit off indicating they are ready to send
					if (REQUEST_DEVICE AND testBit) = zeros then 					
						-- toggle bit off to reset that input slot
						ACK_DEVICE <= zeros;
						next_state <= SEND;
						reg := VALUE;
					elsif timeoutCounter <= 0 then
						next_state <= TIMEOUT;
					end if;
			
				when TIMEOUT => 
					-- timed out, reset bit and return to idle
					ACK_DEVICE <= zeros;
					BUSY <= '0';
					next_state <= IDLE;
			
				when SEND => 
					counter := VALUE'length - 1;
					next_state <= SENDING;
					DEVICES_CS <= NOT testBit;
			
				when SENDING =>			
					reg := reg(reg'length - 2 downto 0) & '0';
					MOSI <= reg(reg'length - 1);
					
					if counter = 0 then		
						next_state <= COMPLETE;
					else
						counter := counter - 1;	
					end if;
			
				when COMPLETE =>
					DEVICES_CS <= (others => '1');
					next_state <= IDLE;
				
				when others =>
				
			end case;
		end if;
	end process;

end Behavioral;

