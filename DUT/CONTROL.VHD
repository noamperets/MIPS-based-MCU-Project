		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	RegWrite 	: OUT 	STD_LOGIC := 'Z';
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC := 'Z';
	Branch, Jump		: OUT 	STD_LOGIC := 'Z';
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq, addi, mul, andi, ori, xori, lui, bne, slti, j, jal,I_format	: STD_LOGIC;
	--SIGNAL  opcode_function	: STD_LOGIC_VECTOR(5 downto 0) is Instruction(5 downto 0);
	--SIGNAl  Opcode			: STD_LOGIC_VECTOR(5 downto 0) is Instruction;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';-- add, sub, and, or, xor, sll, srl, addu(move), slt, jr
	addi        <=  '1'  WHEN  Opcode = "001000"  ELSE '0';
	mul         <=  '1'  WHEN  Opcode = "011100"  ELSE '0';
	andi        <=  '1'  WHEN  Opcode = "001100"  ELSE '0';
	ori         <=  '1'  WHEN  Opcode = "001101"  ELSE '0';
	xori        <=  '1'  WHEN  Opcode = "001110"  ELSE '0';
	lui         <=  '1'  WHEN  Opcode = "001111"  ELSE '0';
	slti        <=  '1'  WHEN  Opcode = "001010"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
   	bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
   	j      	    <=  '1'  WHEN  Opcode = "000010"  ELSE '0';
   	jal         <=  '1'  WHEN  Opcode = "000011"  ELSE '0';
	
	I_format    <=  addi or andi or ori or xori or lui or slti;
  	RegDst    	<=  "01" when ((R_format or mul)='1') else
					"00" when ((I_format or lw)='1')else
					"10" when (jal='1') else
					"11"; --(others=> 'Z'); -- 'X' according to theory, 'Z' is better, sw, branch.bne or beq, j
					
 	ALUSrc  	<=  '0' when  ((R_format or mul or bne or beq)='1') else
					'1' when ((I_format or lw or sw)='1') else
					'Z'; -- (opcode!=0) &&(opcode!=BEQ) &&(opcode!=BNE) j
 
	MemtoReg 	<=  "00" when  ((R_format or mul or I_format)='1') else
					"01" when (lw='1') else
					"10" when (jal='1') else
					"11";--(others=> 'Z'); -- sw, bne or beq, j  WAS (others=> 'Z')
					
  	RegWrite 	<=  '1' when  ((R_format or mul or lw or I_format or jal)='1') else
					'0' when ((sw or bne or beq or j)='1');-- else
					--'Z'; --R_format OR Lw or lui; -- (opcode!=SW) &&(opcode!=Bxx all the branches) &&(opcode!=j) &&(opcode!=jr)
					
  	MemRead 	<=  '0' when  ((R_format or mul or I_format or sw or bne or beq or j or jal)='1') else
					'1' when (lw='1') else
					'Z';
					
   	MemWrite 	<=  '0' when  ((R_format or mul or I_format or lw or bne or beq or j or jal)='1') else
					'1' when (sw='1') else
					'Z';
					
	Jump	    <=  '0' when  ((R_format or mul or I_format or lw or sw or bne or beq)='1') else
					'1' when ((j or jal)='1') else
					'Z';
					
 	Branch      <=  '0' when  ((R_format or mul or I_format or lw or sw)='1') else -- maybe not
					'1' when ((bne or beq)='1') else
					'Z'; --j
	
	ALUOp       <=  "0001" when R_format='1'else
					"0010" when mul='1' else
				    "0011" when ((lw or sw)='1') else
					"0100" when addi='1' else
					"0101" when andi='1' else
					"0110" when ori='1' else
					"0111" when xori='1' else
					"1000" when lui='1' else
					"1001" when slti='1' else
					"1010" when beq='1' else
					--"1011" when j else
					"1100" when bne='1' else
					"1101" when jal='1' else (others=> 'Z');
					
	-- ALUOp( 1 ) 	<=  R_format;
	-- ALUOp( 0 ) 	<=  Beq or j; 

   END behavior;


