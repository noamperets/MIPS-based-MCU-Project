library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GPIO is
    port(
        CS : in  STD_LOGIC_VECTOR(11 downto 0);
		A0	: in STD_LOGIC;
        MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC;
        data_bus    : in STD_LOGIC_VECTOR(31 downto 0);
		LEDR		: out STD_LOGIC_VECTOR(7 downto 0):=(others => 'Z');
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0);
		clock : in STD_LOGIC
    );
end entity GPIO;

architecture Behavioral of GPIO is

component HexDecoder IS
  PORT (  Binary		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		  Hex			: OUT STD_LOGIC_VECTOR(6 downto 0) );
end component;


    signal HEX0_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	signal HEX1_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	signal HEX2_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	signal HEX3_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	signal HEX4_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	signal HEX5_Binary : STD_LOGIC_VECTOR(3 downto 0):=(others => 'Z');
	
	signal Q_LEDR: std_logic_vector(7 downto 0):=(others => 'Z');
	
	
begin

process(clock)
			begin
				if falling_edge(clock) then --rising_edge(clock) then
					if Memwrite_out = '1' and CS(1) = '1' then
						LEDR <= data_bus(7 downto 0);
					end if;
					if Memwrite_out= '1' and CS(2)='1' and A0 ='0' then
						HEX0_Binary <= data_bus(3 downto 0);
					end if;
					if Memwrite_out= '1' and CS(2)='1' and A0 ='1' then
						HEX1_Binary <= data_bus(3 downto 0);
					end if;
					if Memwrite_out= '1' and CS(3)='1' and A0 ='0' then
						HEX2_Binary <= data_bus(3 downto 0);
					end if;
					if Memwrite_out= '1' and CS(3)='1' and A0 ='1' then
						HEX3_Binary <= data_bus(3 downto 0);
					end if;
					if Memwrite_out= '1' and CS(4)='1' and A0 ='0' then
						HEX4_Binary <= data_bus(3 downto 0);
					end if;
					if Memwrite_out= '1' and CS(4)='1' and A0 ='1' then
						HEX5_Binary <= data_bus(3 downto 0);
					end if;
				end if;
			end process;	
			
	-- Q_LEDR <= data_bus(7 downto 0) when Memwrite_out = '1' and CS(1) = '1';
	-- HEX0_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(2)='1' and A0 ='0';
	-- HEX1_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(2)='1' and A0 ='1';
	-- HEX2_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(3)='1' and A0 ='0';
	-- HEX3_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(3)='1' and A0 ='1';
	-- HEX4_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(4)='1' and A0 ='0';
	-- HEX5_Binary <= data_bus(3 downto 0) when Memwrite_out= '1' and CS(4)='1' and A0 ='1';


	Hexmap0 : HexDecoder port map(Binary => HEX0_Binary , Hex => Hex0);
	Hexmap1 : HexDecoder port map(Binary => HEX1_Binary , Hex => Hex1);
	Hexmap2 : HexDecoder port map(Binary => HEX2_Binary , Hex => Hex2);
	Hexmap3 : HexDecoder port map(Binary => HEX3_Binary , Hex => Hex3);
	Hexmap4 : HexDecoder port map(Binary => HEX4_Binary , Hex => Hex4);
	Hexmap5 : HexDecoder port map(Binary => HEX5_Binary , Hex => Hex5);
	
	--LEDR <= Q_LEDR;
	
	
	    -- process (CS, MemRead_out, Memwrite_out,A0, data_bus)
    -- begin
			-- if Memwrite_out = '1' and CS(1) = '1' then
					-- Q_LEDR <= data_bus(7 downto 0); -- Latch the value of D
			-- elsif Memwrite_out= '1' and CS(2)='1' then
				-- if A0 ='0' then
					-- HEX0_Binary <= data_bus(3 downto 0); -- HEX0
				-- elsif A0 = '1' then
					-- HEX1_Binary <= data_bus(3 downto 0); -- HEX1
				-- end if;
			-- elsif Memwrite_out= '1' and CS(3)='1' then
				-- if A0 ='0' then
					-- HEX2_Binary <= data_bus(3 downto 0); -- HEX2
				-- elsif A0='1' then
					-- HEX3_Binary <= data_bus(3 downto 0); -- HEX3
				-- end if;
			-- elsif Memwrite_out= '1' and CS(4)='1' then
				-- if A0 ='0' then
					-- HEX4_Binary <= data_bus(3 downto 0); -- HEX4
				-- elsif A0 = '1' then
					-- HEX5_Binary <= data_bus(3 downto 0); -- HEX5
				-- end if;
			 -- elsif MemRead_out = '1' and CS(7) = '1' then
					-- SW_to_bus <= SW;
					-- SW_disable <= "010";
				-- elsif GIE_read = '0' then
					-- SW_disable <= "100";
				-- else
					-- SW_disable <= "001";
			-- end if;
    -- end process;
end architecture Behavioral;
