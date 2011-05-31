
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.SPI.all;

use IEEE.NUMERIC_STD.ALL;

entity DualDac is
	port
	(
		SYSCLK  : IN  std_logic;
		SCK  : INOUT  std_logic;
		MOSI : OUT  std_logic;
		CS0   : OUT  std_logic := '1';
		CS1   : OUT  std_logic := '1'
	);
end DualDac;

architecture Behavioral of DualDac is

	signal BUSY:std_logic;
	signal DEVICES_CS : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '1');
	signal SPI_VALUE: std_logic_vector (15 downto 0);
	--signal REQUEST_DEVICE : integer range 0 to DEVICE_COUNT - 1;
	signal REQUEST_DEVICE : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
	signal ACK_DEVICE : std_logic_vector(0 to DEVICE_COUNT - 1) := (others => '0');
	
begin

	clkDiv : entity work.ClockDivider(Behavioral) 
		generic map(DELAY => 2)
		port map (CLK => SYSCLK, CLK_OUT => SCK);	
					
	spiMaster : entity work.SPIMaster(Behavioral) 
		port map
		(
			CLK => SCK, 
			MOSI => MOSI,  
			DEVICES_CS => DEVICES_CS, 
			BUSY => BUSY, 
			ACK_DEVICE => ACK_DEVICE, 
			REQUEST_DEVICE => REQUEST_DEVICE, 
			VALUE => SPI_VALUE
		);		
		
	udd1 : entity work.UpDownDAC(Behavioral) 
		generic map
		(
			delay => 3000,
			min 	=> 1000,
			max 	=> 1500
		)
		port map
		(
			CLK => SCK, 
			BUSY => BUSY, 
			ACK => ACK_DEVICE(0), 
			REQUEST => REQUEST_DEVICE(0), 
			OUT_VALUE => SPI_VALUE
		);	
		
	udd2 : entity work.UpDownDAC(Behavioral) 
		generic map
		(
			delay => 2000,
			min 	=> 800,
			max 	=> 2100
		)
		port map
		(
			CLK => SCK, 
			BUSY => BUSY, 
			ACK => ACK_DEVICE(1), 
			REQUEST => REQUEST_DEVICE(1), 
			OUT_VALUE => SPI_VALUE
		);	


		CS0 <= DEVICES_CS(0);
		CS1 <= DEVICES_CS(1);
		 
end Behavioral;

