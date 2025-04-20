						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
        	address 			: IN 	STD_LOGIC_VECTOR( 10 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset,w_en,INTR			: IN 	STD_LOGIC;
			dataTYPE			: in STD_LOGIC_VECTOR(7 downto 0);
			input_read_data		: in STD_LOGIC_VECTOR(31 downto 0);
			check_if_ready		: in STD_LOGIC_VECTOR(1 downto 0)
			);
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock : STD_LOGIC;
SIGNAL allow_access : STD_LOGIC;
signal address_b : STD_LOGIC_VECTOR(10 downto 0);
SIGNAL  read_date_intern	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

BEGIN

	allow_access <= '1' when (w_en='0' and Memwrite='1') else '0';--or (w_en='1' and MemRead='1') else '0'; --'1' when address < 512 AND (memwrite = '1');
	address_b <= '0' & dataTYPE & "00" when check_if_ready = "11" else address; -- address when INTR ='0' else '0' & dataTYPE
	
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => 11,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\TestPrograms\ModelSim\test\DUT\Single_Cycle_MIPS\VHDL Quartus Interrupt FIN\dmemory.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => allow_access,
		clock0 => write_clock,
		address_a => address_b, --address,
		data_a => write_data,
		q_a => read_data);--read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
		
		
		--read_data <= read_date_intern when w_en='0' else input_read_data;
		
END behavior;

