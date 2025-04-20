library ieee;
use ieee.std_logic_1164.all;
-----------------------------------------------------------------
entity BidirPinBasic is
	port(   writePin: in 	std_logic_vector(31 downto 0);
			readPin:  out 	std_logic_vector(31 downto 0);
			bidirPin: inout std_logic_vector(31 downto 0)
	);
end BidirPinBasic;

architecture comb of BidirPinBasic is
begin 

	readPin  <= bidirPin;
	bidirPin <= writePin;
	
end comb;
