-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	PORT(	SIGNAL Instruction		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):= (others => 'Z');
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC;
        	SIGNAL Zero,jr_out 		: IN 	STD_LOGIC;
			SIGNAL Jump 			: IN 	STD_LOGIC;
			SIGNAL jr_alures		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
        	SIGNAL clock, reset,PC_ENA, INTR 	: IN 	STD_LOGIC;
			SIGNAL read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			SIGNAL data_input_from_bus	: in STD_LOGIC_VECTOR(7 downto 0);
			signal check_if_ready		: out STD_LOGIC_VECTOR(1 downto 0);
			signal GIE_read				: in STD_LOGIC
			);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
	SIGNAL Mem_Addr 		 : STD_LOGIC_VECTOR( 10 DOWNTO 0 );
	SIGNAL next_PC,next_PC_mid,next_PC_mid2 : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL jump_ad : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Inst_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
	signal enable_pc : STD_LOGIC:='1';
	signal check_ready	: STD_LOGIC_VECTOR(1 downto 0);
	
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 11,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\TestPrograms\ModelSim\test\DUT\Single_Cycle_MIPS\VHDL Quartus Interrupt FIN\program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> Inst_out);
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
		Instruction		<=  X"0C000000" when check_ready="11" else Inst_out; -- fetch jal on interrupt X"0C000000"
		
						-- send address to inst. memory address register
		Mem_Addr <= '0' & next_PC & "00";
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
				
		-- jump
		
		jump_ad( 1 DOWNTO 0 )  <= "00";
		jump_ad(27 downto 2)   <= X"0000" & "00" & read_data(9 downto 2) when check_ready = "11" else Inst_out( 25 downto 0);
		jump_ad(31 downto 28)  <= PC_plus_4(9 downto 6);
				
						-- Mux to select Branch Address or PC + 4        
		Next_PC_mid  <= X"00" WHEN Reset = '1' ELSE
			--read_data(7 downto 0) when check_ready = "11" and clock='1' else 
			Add_result  WHEN ( ( Branch = '1' ) AND ( Zero = '1' ) ) 
			ELSE   PC_plus_4( 9 DOWNTO 2 );
			
		next_PC_mid2  <= --read_data(7 downto 0) when check_ready = "10" and clock='1' else
						(jump_ad(9 downto 2)) when Jump = '1'
					else next_PC_mid;
					
		next_PC  <= ---next_PC when check_ready = "11"  else --read_data(7 downto 0) when check_ready = "11" and clock='1' else --INTR='1' else -- interrupt
					(jr_alures(9 downto 2)) when jr_out='1' else next_PC_mid2; -- was (7 downto 0) - 0x3000
			
		--enable_pc <= '0' when INTR='1';	
		
		
		
		
	PROCESS
		variable count_routine : STD_LOGIC_VECTOR(1 downto 0);
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
				IF reset = '1' THEN
					   PC( 9 DOWNTO 2) <= "00000000" ;
				 elsif PC_ENA = '1' then --and enable_pc='1' then
						PC( 9 DOWNTO 2 ) <= next_PC;
				END IF;

			if INTR = '1' THEN
				--enable_pc <= '0';
				count_routine := "11";
				check_if_ready <= "11";
				check_ready <= "11";
			else
				if count_routine = "11" THEN
					--enable_pc <= '1';
					count_routine := count_routine - 1;
					check_if_ready <= count_routine;
					check_ready <= count_routine;
				elsif count_routine /= 0 then
					count_routine := count_routine - 1;
					check_if_ready <= count_routine;
					check_ready <= count_routine;
				end if;
			end if;
			-- if count_routine /= 0 then
				-- count_routine := count_routine - 1;
				-- check_if_ready <= count_routine;
				-- check_ready <= count_routine;
			-- end if;
	END PROCESS;
END behavior;


