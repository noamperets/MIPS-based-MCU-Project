LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU_tester IS
	PORT( reset, clock, PC_ENA		: OUT 	STD_LOGIC; 
		  SW					: OUT STD_LOGIC_VECTOR(7 downto 0);
	 	  PC						: IN  STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
     	  Instruction_out			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
		  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : IN STD_LOGIC_VECTOR(6 downto 0);
		  LEDR								 : IN STD_LOGIC_VECTOR(7 downto 0);
		  output_signal  : IN STD_LOGIC;
		  key1, key2, key3				: out STD_LOGIC
		  -- IFG_read, IE_read : in STD_LOGIC_VECTOR(7 downto 0);
		  -- TYPE_read : inout STD_LOGIC_VECTOR(7 downto 0);
		  -- BTCNT		: in STD_LOGIC_VECTOR(31 downto 0)
		  );
END 	MCU_tester;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


ARCHITECTURE struct OF MCU_tester IS

   -- Architecture declarations

   -- Internal signal declarations


   -- ModuleWare signal declarations(v1.9) for instance 'U_0' of 'clk'
   SIGNAL mw_U_0clk : std_logic;
   SIGNAL mw_U_0disable_clk : boolean := FALSE;

   -- ModuleWare signal declarations(v1.9) for instance 'U_1' of 'pulse'
   SIGNAL mw_U_1pulse : std_logic :='0';
   SIGNAL PC_ENA_CONST: STD_LOGIC :='1';


BEGIN

   -- ModuleWare code(v1.9) for instance 'U_0' of 'clk'
   u_0clk_proc: PROCESS
   BEGIN
      WHILE NOT mw_U_0disable_clk LOOP
         mw_U_0clk <= '0', '1' AFTER 10 ns;
         WAIT FOR 20 ns;
      END LOOP;
      WAIT;
   END PROCESS u_0clk_proc;
   mw_U_0disable_clk <= TRUE AFTER 100 us; -- was 1000 ns      50M Clk
   clock <= mw_U_0clk;

   -- ModuleWare code(v1.9) for instance 'U_1' of 'pulse'
   reset <= mw_U_1pulse;
   u_1pulse_proc: PROCESS
   BEGIN
      mw_U_1pulse <= 
         '0',
         '1' AFTER 10 ns,
         '0' AFTER 60 ns;
      WAIT;
    END PROCESS u_1pulse_proc;

	PC_ENA <= PC_ENA_CONST;
   -- Instance port mappings.

stim_proc: process
			begin
			
				SW <= (others => '1'); -- initial value and start
				key1 <= '1';
				key2 <= '1';
				key3 <= '1';
				
				wait for 60 ns;
				wait for 10000 ns;-- 20 ns is the clock cycle, so lets do 50 clock cycles
				sw <= "00000001";	
				wait for 10000 ns;
				sw <= "00000010";	
				wait for 10000 ns;
				sw <= "00000100";
				key1 <= '0';
				--key2 <= '0';
				wait for 300 ns;
				key1 <= '1';
				--key2 <= '1';
				wait for 10000 ns;
				sw <= "00001000";	
				wait for 10000 ns;
				key2 <= '0';
				wait for 60 ns;
				key2 <= '1';
				sw <= "00010000";	
				wait for 10000 ns;
				sw <= "00100000";	
				wait for 10000 ns;
				key3 <= '0';
				wait for 60 ns;
				key3 <= '1';
				sw <= "01000000";	
				wait for 10000 ns;
				sw <= "10000000";	
				wait;
			end process;


END struct;
