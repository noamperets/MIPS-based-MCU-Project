						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegDst 		: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus4	: IN	STD_LOGIC_VECTOR( 9 downto 0);
			clock,reset	: IN 	STD_LOGIC;
			data_input_bus  : IN	STD_LOGIC_VECTOR(31 downto 0);
			GIE_read : OUT STD_LOGIC;
			INTR							: in STD_LOGIC;
			INTA		: out STD_LOGIC:='1';
			GIE			: out STD_LOGIC;
			check_if_ready		: in STD_LOGIC_VECTOR(1 downto 0);
			finish_timer_routine : out STD_LOGIC
			);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	signal count_routine	: STD_LOGIC_VECTOR(1 downto 0);

BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
					-- Read Register 1 Operation
	read_data_1 <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address
   write_register_address <= write_register_address_1 
			WHEN RegDst = "01"  			ELSE
			write_register_address_0 when RegDst="00" 
			else "11111" when (RegDst="10" and INTR='0' and check_if_ready /= "11") 
			else "11011" when (RegDst="10" and INTR='1') or check_if_ready ="11" 
			else (others => 'Z');--register_array(26)(0)='0') else (others => 'Z'); -- mux expand for jal WAS else "11111"
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( 31 DOWNTO 0 ) 
			WHEN ( MemtoReg = "00" ) 	ELSE 
			read_data when ( MemtoReg = "01" and ALU_result < 2048) or check_if_ready="10" 
			else data_input_bus when ( MemtoReg="01" and ALU_result >= 2048)--(ALU_result(11)='1' and ALU_result(4)='1' and ALU_result(3)='0' and ALU_result(2)='0')) 
			else (X"00000" & B"00" & (PC_plus4(9 DOWNTO 2) - 1) & "00") when check_if_ready="11" and (MemtoReg="10")
			else (X"00000" & B"00" & PC_plus4) when (MemtoReg="10") 
			else (others => 'Z'); -- write data mux expand
					-- Sign Extend 16-bits to 32-bits
    	Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN (Instruction_immediate_value(15) = '0' ) or (Instruction(31 downto 26)="001100") or (Instruction(31 downto 26)="001101") or (Instruction(31 downto 26)="001110") -- andi ori xori ZeroImm
		ELSE	X"FFFF" & Instruction_immediate_value;
	
		finish_timer_routine <= '1' when check_if_ready="11" else
								'0' when check_if_ready="10" and (MemtoReg="10");
		
		-- INTA			<= '0'	when	Instruction = x"03600008"
								-- ELSE	'0';			
		GIE_read <= register_array(26)(0); -- read GIE
		GIE		 <= register_array(26)(0);
		--with GIE_read select
		
		
		-- process(INTR)
		-- begin
			--WAIT UNTIL INTA'EVENT AND INTA='1'; --INTA'EVENT AND INTA = '1'; -- falling edge of INTAgag
				-- if rising_edge(INTR) THEN
				-- if Instruction = X"03600008" then -- if jr 27
					-- register_array(26)(0) <= '1'; -- GIE back to 1
				-- else
					-- register_array(26)(0) <= '0';-- CONV_INTEGER( "11010"))(0) <= '0';
				-- end if;
				-- end if;
		-- end PROCESS;
		
PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			INTA <= '1';
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
					-- Write back to register - don't write to register 0
		elsif Instruction = X"03600008" then -- if jr 27
					register_array(26)(0) <= '1'; -- GIE back to 1
					--INTA <= '0';
		elsif Instruction /= X"03600008" and INTR='1' then
					register_array(26)(0) <= '0';-- CONV_INTEGER( "11010"))(0) <= '0'
					-- register_array(27) <= X"000000"& (PC_plus4(9 DOWNTO 2) - 1);
					--INTA <= '1';
  		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address)) <= write_data;
		END IF;
		if INTR = '1' then
			INTA <= '0';
			--count_routine <= "11";
		ELSE
			INTA <= '1';
		-- elsif count_routine = "10" THEN
			-- INTA <= '1';
		-- ELSE
			-- count_routine <= count_routine  - 1;
		end if;
	END PROCESS;
END behavior;


