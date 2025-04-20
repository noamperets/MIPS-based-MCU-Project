				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS

	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC :='Z';
		PC_ENA 							: IN 	STD_LOGIC;
		MemRead_out 				: OUT 	STD_LOGIC;
		data_input 						: in std_logic_vector(31 downto 0); -- Additional port to receive data from the bus
		GIE_read						: OUT STD_LOGIC;
		INTR							: in STD_LOGIC;
		INTA							: out STD_LOGIC;
		finish_timer_routine 			: out STD_LOGIC
		);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		Branch 				: IN 	STD_LOGIC;
        		Zero,jr_out			: IN 	STD_LOGIC;
        		Jump 				: IN 	STD_LOGIC;
				jr_alures		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_out 				: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		clock,reset, PC_ENA,INTR 	: IN 	STD_LOGIC;
				read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				data_input_from_bus	: in STD_LOGIC_VECTOR(7 downto 0);
				check_if_ready		: out STD_LOGIC_VECTOR(1 downto 0);
				GIE_read				: in STD_LOGIC
				);
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 			: IN 	STD_LOGIC;
				MemtoReg 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				RegDst 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Sign_extend 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus4			: IN	STD_LOGIC_VECTOR( 9 downto 0);
				clock, reset		: IN 	STD_LOGIC; 
				data_input_bus  	: IN	STD_LOGIC_VECTOR(31 downto 0);
				GIE_read : OUT STD_LOGIC;
				INTR							: in STD_LOGIC;
				INTA		: out STD_LOGIC;
				GIE			: out STD_LOGIC;
				check_if_ready		: in STD_LOGIC_VECTOR(1 downto 0);
				finish_timer_routine : out STD_LOGIC
				);
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ALUSrc 		: OUT 	STD_LOGIC;
				MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				RegWrite 	: OUT 	STD_LOGIC;
				MemRead 		: OUT 	STD_LOGIC;
				MemWrite 	: OUT 	STD_LOGIC;
				Branch, Jump		: OUT 	STD_LOGIC;
				ALUop 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				clock, reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC;
				Branch 				: IN 	STD_LOGIC;
				Jump 				: IN 	STD_LOGIC;
               	Zero, jr_out 		: OUT	STD_LOGIC;
               	ALU_Result, jr_alures		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
               	PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
               	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset,w_en,INTR			: IN 	STD_LOGIC;
				dataTYPE			: in STD_LOGIC_VECTOR(7 downto 0);
				input_read_data		: in STD_LOGIC_VECTOR(31 downto 0);
				check_if_ready		: in STD_LOGIC_VECTOR(1 downto 0));
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result , jr_alures		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch 			: STD_LOGIC;
	SIGNAL Jump 			: STD_LOGIC;
	signal RegDst 		    : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero, jr_out 	: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  3 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL not_INTA			: STD_LOGIC := '1';
	signal check_if_ready	: std_logic_vector(1 downto 0);
	signal GIE				: STD_LOGIC;

BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data WHEN MemtoReg = "01" ELSE ALU_result;
   Branch_out 		<= Branch;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
   
   MemRead_out		<= MemRead;
   --INTAgag			<= not(INTA);

					-- connect the 5 MIPS components   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				jr_out			=> jr_out,
				Jump 			=> Jump,
				jr_alures		=> jr_alures,
				PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset ,
				PC_ENA			=> PC_ENA,
				INTR			=> INTR,
				read_data		=> read_data,
				data_input_from_bus => data_input(7 downto 0),
				check_if_ready	=> check_if_ready,
				GIE_read		=> GIE);

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
				PC_plus4 		=> PC_plus_4,
        		clock 			=> clock,  
				reset 			=> reset,
				data_input_bus	=> data_input,
				GIE_read		=> GIE_read,
				INTR			=> INTR,
				INTA			=> INTA,
				GIE				=> GIE,
				check_if_ready	=> check_if_ready,
				finish_timer_routine => finish_timer_routine
				);


   CTL:   control
	PORT MAP ( 	Opcode 	=> Instruction( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				jump 			=> jump,
				ALUop 			=> ALUop,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Branch 			=> Branch,
				Jump 			=> Jump,
				Zero 			=> Zero,
				jr_out 			=> jr_out,
                ALU_Result		=> ALU_Result,
				jr_alures 			=> jr_alures,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset );

   MEM:  dmemory
	PORT MAP (	read_data 		=> read_data,
				address 		=> ALU_Result(10 DOWNTO 2) & "00",--jump memory address by 4
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
                clock 			=> clock,  
				reset 			=> reset,
				w_en			=> ALU_Result(11),
				INTR			=> INTR,
				dataTYPE		=> data_input(7 downto 0),
				input_read_data => data_input,
				check_if_ready	=> check_if_ready
				);
END structure;

