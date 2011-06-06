
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.SPI.all;

use IEEE.NUMERIC_STD.ALL;

entity DualDac is
	port
	(
		SYSCLK  : IN  std_logic;
		SCK  : INOUT  std_logic;
		DATA : INOUT  std_logic;
		CS0   : OUT  std_logic;
		CS1   : OUT  std_logic;
		CS2   : OUT  std_logic
	);
end DualDac;

architecture Behavioral of DualDac is

	constant DEVICE_COUNT : integer := 3;
	signal DEVICES_CS : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '1');
	signal DEVICE_DIRECTION : std_logic_vector(0 to DEVICE_COUNT - 1);
	signal TRANSMIT_BUFFER: std_logic_vector (31 downto 0);
	signal RECEIVE_BUFFER : std_logic_vector(31 downto 0);
	signal REQUEST_DEVICE : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
	signal ACK_DEVICE : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
	signal DEVICE_SIZE : std_logic_vector (5 downto 0);
	
	signal ADC0_VALUE : std_logic_vector(11 downto 0);
	signal SAMPLE_ADC0 : std_logic := '1'; -- always sample ADC
	
	
begin

	clkDiv : entity work.ClockDivider(Behavioral) 
		generic map(DELAY => 2)
		port map (CLK => SYSCLK, CLK_OUT => SCK);	
					
	spiMaster : entity work.SPIMaster(Behavioral) 
		generic map(DEVICE_COUNT => DEVICE_COUNT)
		port map
		(
			CLK => SCK, 
			DATA => DATA,  
			DEVICES_CS => DEVICES_CS, 
			ACK_DEVICE => ACK_DEVICE, 
			DEVICE_SIZE => DEVICE_SIZE,
			DEVICE_DIRECTION => DEVICE_DIRECTION, 
			REQUEST_DEVICE => REQUEST_DEVICE, 
			TRANSMIT_BUFFER => TRANSMIT_BUFFER, 
			RECEIVE_BUFFER => RECEIVE_BUFFER
		);		
		
	udd1 : entity work.UpDownDAC(Behavioral) 
		generic map
		(
			delay => 5000,
			min 	=> 1000,
			max 	=> 1500
		)
		port map
		(
			CLK => SCK, 
			ACK => ACK_DEVICE(0), 
			DEVICE_SIZE => DEVICE_SIZE,
			DIRECTION => DEVICE_DIRECTION(0), 
			REQUEST => REQUEST_DEVICE(0), 
			WRITE_BUFFER => TRANSMIT_BUFFER(15 downto 0)
		);	
		
	udd2 : entity work.UpDownDAC(Behavioral) 
		generic map
		(
			delay => 8000,
			min 	=> 800,
			max 	=> 2100
		)
		port map
		(
			CLK => SCK, 
			ACK => ACK_DEVICE(1), 
			DEVICE_SIZE => DEVICE_SIZE,
			DIRECTION => DEVICE_DIRECTION(1), 
			REQUEST => REQUEST_DEVICE(1), 
			WRITE_BUFFER => TRANSMIT_BUFFER(15 downto 0) 
		);	
		
--	dac1 : entity work.SPI_DAC(Behavioral) 
--		port map 
--		(
--			CLK => SCK, 
--			VALUE => ADC0_VALUE, 
--			ACK => ACK_DEVICE(1), 		
--			DEVICE_SIZE => DEVICE_SIZE, 	
--			DIRECTION => DEVICE_DIRECTION(1), 
--			REQUEST => REQUEST_DEVICE(1), 
--			WRITE_BUFFER => TRANSMIT_BUFFER(15 downto 0) 
--		);	
		
	adc1 : entity work.SPI_ADC(Behavioral) 
		port map
		(
			CLK => SCK, 
			VALUE => ADC0_VALUE, --(11 downto 0)
			ACK => ACK_DEVICE(2), 
			DEVICE_SIZE => DEVICE_SIZE,
			SAMPLE_ADC => SAMPLE_ADC0, --std_logic
			DIRECTION => DEVICE_DIRECTION(2), 
			REQUEST => REQUEST_DEVICE(2), 
			READ_BUFFER => RECEIVE_BUFFER(14 downto 0) 
		);	


		CS0 <= DEVICES_CS(0);
		CS1 <= DEVICES_CS(1);
		CS2 <= DEVICES_CS(2);
		 
end Behavioral;

