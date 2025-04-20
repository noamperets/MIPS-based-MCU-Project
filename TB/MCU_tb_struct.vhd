-- VHDL Entity MIPS.MIPS_tb.symbol
--
-- Created:
--          by - kolaman.UNKNOWN (KOLAMAN-PC)
--          at - 09:22:45 17/02/2013
--

ENTITY MCU_tb IS
-- Declarations

END MCU_tb ;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

LIBRARY work;

ARCHITECTURE struct OF MCU_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL Instruction_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL PC              : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
   SIGNAL clock           : STD_LOGIC;
   SIGNAL reset           : STD_LOGIC;
   SIGNAL PC_ENA 		  : STD_LOGIC;
   SIGNAL SW			  : STD_LOGIC_VECTOR(7 downto 0):=(others => 'Z');
   SIGNAL LEDR			  : STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : STD_LOGIC_VECTOR(6 downto 0);
   SIGNAL output_signal, key1, key2, key3 : STD_LOGIC;


   -- Component Declarations
	Component MCU
		PORT( reset, clock, PC_ENA		: IN 	STD_LOGIC; 
			  SW					: IN STD_LOGIC_VECTOR(7 downto 0);
			  PC						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
			  Instruction_out			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
			  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0);
			  LEDR								 : OUT STD_LOGIC_VECTOR(7 downto 0);
			  output_signal  : out STD_LOGIC;
			  key1, key2, key3				: in STD_LOGIC
			  -- IFG_read, IE_read : out STD_LOGIC_VECTOR(7 downto 0);
			  -- TYPE_read : inout STD_LOGIC_VECTOR(7 downto 0);
			  -- BTCNT		: out STD_LOGIC_VECTOR(31 downto 0)
			  );
	END 	Component;


	Component MCU_tester 
	PORT( reset, clock, PC_ENA		: OUT 	STD_LOGIC; 
		  SW					: OUT STD_LOGIC_VECTOR(7 downto 0):=(others => 'Z');
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
END 	Component;

   -- Optional embedded configurations
   -- pragma synthesis_off
   -- FOR ALL : MCU USE ENTITY work.MCU;
   -- FOR ALL : MCU_tester USE ENTITY work.MCU_tester;
   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   U_0 : MCU
      PORT MAP (
         reset           => reset,
         clock           => clock,
		 PC_ENA			 => PC_ENA,
		 SW				 => SW,
         PC              => PC,
         Instruction_out => Instruction_out,
		 HEX0			 => HEX0,
		 HEX1			 => HEX1,
		 HEX2			 => HEX2,
		 HEX3			 => HEX3,
		 HEX4			 => HEX4,
		 HEX5			 => HEX5,
		 LEDR			 => LEDR,
		 output_signal	 => output_signal,
		 key1			 => key1,
		 key2			 => key2,
		 key3			 => key3
		 -- IFG_read		 => IFG_read,
		 -- IE_read		 => IE_read,
		 -- TYPE_read		 => TYPE_read,
		 -- BTCNT			 => BTCNT
      );
   U_1 : MCU_tester
      PORT MAP (
         reset           => reset,
         clock           => clock,
		 PC_ENA			 => PC_ENA,
		 SW				 => SW,
         PC              => PC,
         Instruction_out => Instruction_out,
		 HEX0			 => HEX0,
		 HEX1			 => HEX1,
		 HEX2			 => HEX2,
		 HEX3			 => HEX3,
		 HEX4			 => HEX4,
		 HEX5			 => HEX5,
		 LEDR			 => LEDR,
		 output_signal	 => output_signal,
		 key1			 => key1,
		 key2			 => key2,
		 key3			 => key3
		 -- IFG_read		 => IFG_read,
		 -- IE_read		 => IE_read,
		 -- TYPE_read		 => TYPE_read,
		 -- BTCNT			 => BTCNT
      );

END struct;
