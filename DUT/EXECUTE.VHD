--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;


ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Branch 			: IN 	STD_LOGIC;
			Jump 			: IN 	STD_LOGIC;
			Zero, jr_out 	    : OUT	STD_LOGIC := 'Z';
			ALU_Result, jr_alures	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 ):=(others => 'Z');
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
--SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal jr 			:  	STD_LOGIC:='Z';
BEGIN
	Ainput <= Read_data_2 when (ALUop="0001" and (Function_opcode="000000" or Function_opcode="000010")) else Read_data_1; -- support sll,srl
						-- ALU input mux
	Binput <= Read_data_2 
		WHEN (( ALUSrc = '0' ) and (not(ALUop="0001" and (Function_opcode="000000" or Function_opcode="000010"))))
  		ELSE  Sign_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
	-- ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );-- all R format except sll, srl, jr (7 total)
	-- ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );-- slt, jr and all those who isn't R format (15 total)
	-- ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );-- beq, bne
	
	ALU_ctl <= ('0' &Function_opcode(3 DOWNTO 0)) when (ALUOp = "0001" and Function_opcode(5)='1') else -- add, sub, and, or, xor, move, slt
				('1' &Function_opcode(3 DOWNTO 0)) when (ALUOp = "0001" and (not Function_opcode(5))='1') else-- jr, sll, srl\
				"10111"	when ALUOp = "0010" else -- MUL
				"00000" when ALUOp = "0011" else -- sw or lw
				"00000"	when ALUOp = "0100" else -- addi
				"00100" when ALUOp = "0101" else -- andi
				"00101"	when ALUOp = "0110" else -- ori
				"00110" when ALUOp = "0111" else -- xori
				"11001"	when ALUOp = "1000" else -- lui
				"01010" when ALUOp = "1001" else -- slti
				"11100" when ALUOp = "1010" else -- beq
				"11101" when ALUOp = "1100" else -- bne
			--	"11110" when ALUOp = "1011"; -- j
				"11111" when ALUOp = "1101" else (others => 'Z'); -- jal
				
				
	jr <= '1' when ALU_ctl = "11000" else '0';			
	jr_out <= jr;			
	jr_alures <= ALU_output_mux when jr = '1' else (others => '0');			
	
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "111"  -- CHECK THIS
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput )
variable mul_res : STD_LOGIC_VECTOR( 63 DOWNTO 0 );
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input + B_input
		WHEN "00000" 	=>	ALU_output_mux 	<= Ainput + Binput; 
						-- ALU performs ALUresult = A_input - B_input
     	WHEN "00010" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs ALUresult = A_input and B_input
	 	WHEN "00100" 	=>	ALU_output_mux 	<= Ainput AND Binput;
						-- ALU performs ALUresult = A_input OR B_input
		WHEN "00101" 	=>	ALU_output_mux 	<= Ainput OR Binput; 
						-- ALU performs ALUresult = A_input XOR B_input
		WHEN "00110" 	=>	ALU_output_mux 	<= Ainput XOR Binput;
						-- ALU performs ALUresult = A_input  (move)
     	WHEN "00001" 	=>	ALU_output_mux 	<= std_logic_vector((unsigned(Ainput)) + (unsigned(Binput))); -- Ainput + Binput; -- 
						-- ALU performs set less then - slt
	 	WHEN "01010" 	=>	if Ainput>=Binput then  ALU_output_mux <= X"00000000" ;
								else ALU_output_mux <= (X"0000000" & B"000" &'1'); -- (others '0' +1)
								end if;
								
						-- ALU performs SLL
     	WHEN "10000" 	=>  ALU_output_mux 	<= std_logic_vector(shift_left (signed(Ainput), to_integer(unsigned(Binput(10 downto 6)))));
						-- ALU performs SRL	
		WHEN "10010" 	=>	ALU_output_mux 	<= std_logic_vector(shift_right(signed(Ainput), to_integer(unsigned(Binput(10 downto 6))))); 
						-- ALU performs JR
     	WHEN "11000" 	=>	ALU_output_mux 	<= Ainput;
		

						-- ALU performs ALUresult = A_input * B_input mul
		WHEN "10111" 	=>	mul_res := Ainput * Binput;
							ALU_output_mux 	<= mul_res(31 downto 0);
							
	
						-- ALU performs lui
		WHEN "11001" 	=>	ALU_output_mux 	<= std_logic_vector(shift_left (signed(Binput), 16)); 
			
						-- ALU performs BEQ	
		WHEN "11100" 	=>	ALU_output_mux 	<= Ainput - Binput; --צריך להוסיף עוד חלק לבראנצ'ים אבל זה יהיה בזיכרון
						-- ALU performs BNE
     	WHEN "11101" 	=>	 if ((Ainput - Binput) /= 0) then ALU_output_mux <= (others => '0');
							else ALU_output_mux <= (X"0000000" & B"000" &'1');
								end if;
		
						-- ALU performs JAL
     	WHEN "11111" 	=>	ALU_output_mux 	<= (others => '0');

 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

