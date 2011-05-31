library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package SPI is	
	
	constant DEVICE_COUNT : integer := 2;
	--type SPI_DEVICES is array(0 to DEVICE_COUNT) of std_logic;
	--type SPI_DEVICES is std_logic_vector(0 to DEVICE_COUNT);
	
	--type SPI_DEVICES is ARRAY (natural RANGE <>) of std_logic;
	
--	type spi_devices is 
--	record
--		CS0 : std_logic;
--		CS1 : std_logic;
--	end record;

   --signal SCK  : std_logic;
   --signal MOSI : std_logic;
	
end SPI;
