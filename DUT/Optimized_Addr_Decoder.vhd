library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Optimized_Address_Decoder is
    port(
        address_bus : in  STD_LOGIC_VECTOR(4 downto 0);
        CS          : out STD_LOGIC_VECTOR(11 downto 0) 
    );
end entity Optimized_Address_Decoder;

architecture Behavioral of Optimized_Address_Decoder is
begin
    process (address_bus)
    begin
        case address_bus is
            when "10000" => -- 0x800 CS1
                CS <= "000000000010"; -- Chip Select for LEDR
            when "10001" => -- 0x804 CS2
                CS <= "000000000100"; -- Chip Select for HEX0
            when "10010" => -- 0x808 CS3
                CS <= "000000001000"; -- Chip Select for HEX2
            when "10011" => -- 0x80C CS4
                CS <= "000000010000"; -- Chip Select for HEX4
            when "10100" => -- 0x810 CS7
                CS <= "000010000000"; -- Chip Select for PORT_SW	
			when "11011" => -- CS Interrupt Controller 
				CS <= "000000100000"; -- CS5
			when "10101" => -- 0x814 Key1-3  
				CS <= "000001000000"; -- CS6
			when "10111" => -- 0x81C BTCTL
				CS <= "000100000000"; -- CS8
			when "11000" => -- 0x820 BTCNT
				CS <= "001000000000"; -- CS9
			when "11001" => -- 0x824 BTCCR0
				CS <= "010000000000"; -- CS10
			when "11010" => -- 0x828 BTCCR1
				CS <= "100000000000"; -- CS11
            -- Add more cases for other devices as needed
            when others =>
                CS <= "000000000000"; -- No Chip Select (all zeros) for unknown addresses
        end case;
    end process;
end architecture Behavioral;
