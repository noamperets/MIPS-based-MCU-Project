library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity freq_divider is
	port( clock, reset: in STD_LOGIC;
		  mclk2, mclk4, mclk8 : out STD_LOGIC);
end freq_divider;

architecture rtl of freq_divider is
	signal q_int : STD_LOGIC_VECTOR(31 downto 0);
begin
	process(clock, reset)
	begin
		if(reset ='1') then
			q_int <= (others => '0');
		elsif rising_edge(clock) then
			q_int <= q_int + 1;
		end if;
	end process;

mclk2 <= q_int(0);
mclk4 <= q_int(1);
mclk8 <= q_int(2);

end rtl;