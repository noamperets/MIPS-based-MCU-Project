				-- Top Level Structural Model for MCU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU IS

	PORT( reset, clock, PC_ENA		: IN 	STD_LOGIC; -- changed to rst and then reset <= not(rst)
		  SW					: IN STD_LOGIC_VECTOR(7 downto 0);
	 	  PC						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
     	  Instruction_out			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
		  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0);
		  LEDR								 : OUT STD_LOGIC_VECTOR(7 downto 0);
		  output_signal  : out STD_LOGIC;
		  key1, key2, key3				: in STD_LOGIC
		  );
END 	MCU;

ARCHITECTURE structure OF MCU IS

component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end component;


component MIPS IS

	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ):=(others => 'Z');
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=(others => 'Z');
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC :='Z';
		PC_ENA 							: IN 	STD_LOGIC;
		MemRead_out 				: OUT 	STD_LOGIC;
		data_input 					: in std_logic_vector(31 downto 0);
		GIE_read						: OUT STD_LOGIC;
		INTR							: in STD_LOGIC;
		INTA							: out STD_LOGIC;
		finish_timer_routine 			: out STD_LOGIC
		);
end component;

component Optimized_Address_Decoder is
    port(
        address_bus : in  STD_LOGIC_VECTOR(4 downto 0);
        CS          : out STD_LOGIC_VECTOR(11 downto 0)
    );
end component;

component GPIO is
    port(
        CS : in  STD_LOGIC_VECTOR(11 downto 0);
		A0	: in STD_LOGIC;
        MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC;
        data_bus    : in STD_LOGIC_VECTOR(31 downto 0);
		LEDR		: out STD_LOGIC_VECTOR(7 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0);
		clock : in STD_LOGIC
    );
end component;


component BasicTimer is
    Port (
        clock          : in  STD_LOGIC;             -- Clock input
        reset          : in  STD_LOGIC;             -- Reset input
		data_bus       : in  STD_LOGIC_VECTOR(31 downto 0);
        BTCTL_read          : out  STD_LOGIC_VECTOR(7 downto 0);  -- BT Control input (BTOUTEN in bit 6, BTHOLD in bit 5, BTSSEL in bit 3-4, BTIPx in bit 0-2)
        BTCCR0_read         : out  STD_LOGIC_VECTOR(31 downto 0);  -- BT Compare Register 0 (Clock cycle)
        BTCCR1_read         : out  STD_LOGIC_VECTOR(31 downto 0);  -- BT Compare Register 1 (Duty cycle)
        BTCNT_read          : out STD_LOGIC_VECTOR(31 downto 0);		
        output_signal  : out STD_LOGIC;             -- Output signal (based on duty cycle)
        Set_BTIFG      : out STD_LOGIC;             -- Output to select which bit to set BTIFG
		CS   : in  STD_LOGIC_VECTOR(11 downto 0); -- get address to compare
		MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC
    );
end component;

component InterruptController is
    Port (
        clock          : in  STD_LOGIC;             -- Clock input
        reset          : in  STD_LOGIC;             -- Reset input
        CSgag          : in  STD_LOGIC_VECTOR(11 downto 0);  -- not(CS)
        BTrq           : in  STD_LOGIC;  -- BasicTimer interrupt request
        KEY1rq         : in  STD_LOGIC;  -- KEY1 interrupt request
		KEY2rq         : in  STD_LOGIC;  -- KEY2 interrupt request
		KEY3rq         : in  STD_LOGIC;  -- KEY3 interrupt request
		INTAgag        : in  STD_LOGIC;
		INTR           : out  STD_LOGIC;
        databus        : in STD_LOGIC_VECTOR(31 downto 0);           
		A10			   : in  STD_LOGIC_VECTOR(1 downto 0); -- bit 01 from address
		GIE_read	   : in STD_LOGIC;
		interruptReg   : out STD_LOGIC_VECTOR(7 downto 0); --IFG_read, IE_read, TYPE_read : out STD_LOGIC_VECTOR(7 downto 0);
		MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC;
		finish_timer_routine : in STD_LOGIC
    );
end component;


---------------- signal declarations -----------------------

signal bus_IO: std_logic_vector(31 downto 0) :=(others=> 'Z'); -- default high Z
signal Q_LEDR: std_logic_vector(7 downto 0);
signal data_from_mips_to_per: STD_LOGIC_VECTOR(31 downto 0);
signal MIPS_data_enable: STD_LOGIC;
signal LEDR_en : STD_LOGIC;

signal CS : STD_LOGIC_VECTOR(11 downto 0);
signal CSnot : STD_LOGIC_VECTOR(11 downto 0);
signal MemRead_out, Memwrite_out : STD_LOGIC;
signal write_data_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );

signal ALU_result_out : STD_LOGIC_VECTOR(31 downto 0);

signal en_combined : std_logic := '0';
signal not_en_combined : std_logic := '1';
signal SW_disable : STD_LOGIC_VECTOR(2 downto 0);-- := "01";
signal SW_temp : STD_LOGIC_VECTOR(31 downto 0);

signal BTCNT_temp  : STD_LOGIC_VECTOR(31 downto 0);

signal Set_BTIFG, KEY1rq, KEY2rq, KEY3rq, BTrq : STD_LOGIC := '0';
signal INTAgag : STD_LOGIC := '1';
signal INTR, GIE_read : STD_LOGIC;
signal bus_enable : STD_LOGIC;
signal key_1_not, key_2_not, key_3_not : STD_LOGIC;
signal SW_to_bus : STD_LOGIC_VECTOR(7 downto 0);
signal data_bus_timer, data_bus_IO, data_bus_interrupt : STD_LOGIC_VECTOR(31 downto 0);
signal BTCCR0_ena, BTCCR1_ena, BTCTL_ena, BTCNT_ena, SW_ena, IE_ena, IFG_ena, TYPE_ena, InterruptReg_ena, type_bus_ena,TYPEtoBUS_en : STD_LOGIC;
signal BTCCR0_read, BTCCR1_read, BTCNT_read : STD_LOGIC_VECTOR(31 downto 0);
signal BTCTL_read, IFG_read, IE_read, TYPE_read, interruptReg : STD_LOGIC_VECTOR(7 downto 0);
signal INTA, INTA_gag : STD_LOGIC;
signal finish_timer_routine : STD_LOGIC;

signal data_from_per_to_mips : STD_LOGIC_VECTOR(31 downto 0);
--signal reset : STD_LOGIC;
begin


		--key_1_not <= not(key1); -- to be able to use them on rising_edge instead of falling_edge
		--key_2_not <= not(key2);
		--key_3_not <= not(key3);
		
		--reset <= not(rst);
		-- bus_enable 	<= Memwrite_out;-- and MemRead_out; --'1' when Memwrite_out= '1' and MemRead_out = '0' else '0';
		-- BTCCR0_ena 	<= CS(10) and MemRead_out; --'1' when CS(10) = '1' 	and MemRead_out = '1' else '0';
		-- BTCCR1_ena 	<= CS(11) and MemRead_out; --'1' when CS(11) = '1' 	and MemRead_out = '1' else '0';
		-- BTCTL_ena 	<= CS(8) and MemRead_out; --'1' when CS(8) = '1' 	and MemRead_out = '1' else '0';
		-- BTCNT_ena 	<= CS(9) and MemRead_out; --'1' when CS(9) = '1' 	and MemRead_out = '1' else '0';
		-- SW_ena 		<= CS(7) and MemRead_out; --'1' when CS(7) = '1' 	and MemRead_out = '1' else '0';
		-- InterruptReg_ena <= CS(5) and MemRead_out; --'1' when (CS(5) = '1' and MemRead_out = '1') else '0';
		
		-- TYPEtoBUS_en <= finish_timer_routine and not(INTA); --'1' when finish_timer_routine='1' and INTA='0' else '0';--falling_edge(INTA) else '0'; -- NEED ON FALLING EDGE OF INTAGAG
		
		INTA_gag <= not(INTA);

		data_from_per_to_mips <= (X"000000" & interruptReg) when (CS(5)='1' and MemRead_out='1') else
								 (X"000000" & BTCTL_read)	when CS(8)='1' and MemRead_out='1' else
								 BTCCR0_read  when CS(10)='1' and MemRead_out='1' else
								 BTCCR1_read  when CS(11)='1' and MemRead_out='1' else
								 BTCNT_read   when CS(9)='1' and MemRead_out='1'  else
								 (X"000000" & SW)	when CS(7)='1' and MemRead_out='1' else
								 (X"000000" & InterruptReg) when finish_timer_routine='1' and INTA='0';
								 
		
		
	-- TYPEintBUS: BidirPin
		-- generic map(width => 32)
		-- port map(
			-- Dout(31 downto 8) => X"000000",
            -- Dout(7 downto 0) => InterruptReg,
            -- en => TYPEtoBUS_en,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
		-- );
		
	ICmap : InterruptController
		port map(
			clock => clock,
			reset => reset,
			CSgag => CS,
			BTrq  => Set_BTIFG,
			KEY1rq => key1,--key_1_not,
			KEY2rq => key2,--key_2_not,
			KEY3rq => key3,--key_3_not,
			INTAgag => INTA_gag,
			INTR => INTR,
			databus => data_from_mips_to_per,
			A10 => ALU_result_out(1 downto 0),
			GIE_read => GIE_read,
			interruptReg => interruptReg,
			MemRead_out => MemRead_out,
			Memwrite_out => Memwrite_out,
			finish_timer_routine => finish_timer_routine
			);

	-- IRegBUS: BidirPin
		-- generic map(width => 32)
		-- port map(
			-- Dout(31 downto 8) => X"000000",
            -- Dout(7 downto 0) => InterruptReg,
            -- en => InterruptReg_ena,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
		-- );
		

	TimerMap : BasicTimer
		port map(
			clock => clock,
			reset => reset,
			data_bus => data_from_mips_to_per,
			BTCTL_read => BTCTL_read,
			BTCCR0_read => BTCCR0_read,
			BTCCR1_read => BTCCR1_read,
			BTCNT_read => BTCNT_read,
			output_signal => output_signal,
			Set_BTIFG => Set_BTIFG,
			CS => CS,
			MemRead_out => MemRead_out,
			Memwrite_out => Memwrite_out
		);
	
	
    -- BTCCR0BUS : BidirPin 
        -- generic map(width => 32)
        -- port map(
            -- Dout => BTCCR0_read,
            -- en => BTCCR0_ena,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
        -- );	

    -- BTCCR1BUS : BidirPin 
        -- generic map(width => 32)
        -- port map(
            -- Dout => BTCCR1_read,
            -- en => BTCCR1_ena,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
        -- );	

    -- BTCTLBUS : BidirPin 
        -- generic map(width => 32)
        -- port map(
			-- Dout(31 downto 8) => X"000000",
            -- Dout(7 downto 0) => BTCTL_read,
            -- en => BTCTL_ena,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
        -- );	

    -- BTCNTBUS : BidirPin 
        -- generic map(width => 32)
        -- port map(
            -- Dout => BTCNT_read,
            -- en => BTCNT_ena,
            -- Din => data_from_per_to_mips,
            -- IOpin => bus_IO
        -- );			
		
		
    -- CS7_SW : BidirPin -- SW
        -- generic map(width => 32)--8)
        -- port map(
            -- Dout(31 downto 8) => X"000000",
			-- Dout(7 downto 0)  => SW,--SW_to_bus, -- SW to bus
            -- en => SW_ena,
            -- Din => data_from_per_to_mips,--data_input, --data_bus , -- nothing from bus
            -- IOpin => bus_IO--(7 downto 0)
        -- );
		

	Decodermap: Optimized_Address_Decoder  -- <A11,A4,A3,A2>
    port map(
		address_bus(4) => ALU_result_out(11),
        address_bus(3) => ALU_result_out(5),
		address_bus(2) => ALU_result_out(4),
		address_bus(1) => ALU_result_out(3),
		address_bus(0) => ALU_result_out(2),
        CS          => CS
    );

	MIPSmap : MIPS
      PORT MAP (
         reset           => reset,
         clock           => clock,
         PC              => PC,
         ALU_result_out  => ALU_result_out, --ALU_result_out,
         read_data_1_out => open, --read_data_1_out,
         read_data_2_out => data_from_mips_to_per, -- DATA BUS
         write_data_out  => open,--write_data_out,
         Instruction_out => Instruction_out,
         Branch_out      => open, --Branch_out,
         Zero_out        => open, --Zero_out,
         Memwrite_out    => Memwrite_out,
         Regwrite_out    => open, --Regwrite_out,
		 PC_ENA			 => PC_ENA,
		 MemRead_out	=> MemRead_out,
		 data_input		=> data_from_per_to_mips,
		 GIE_read		=> GIE_read,
		 INTR			=> INTR,
		 INTA		=> INTA,
		 finish_timer_routine => finish_timer_routine
		 
      );
	  
	    -- MIPS_databus : BidirPin -- mips data bus
        -- generic map(width => 32)
        -- port map(
            -- Dout => data_from_mips_to_per, -- data to bus
            -- en => bus_enable,--SW_disable(0),--not_en_combined,
            -- Din => data_from_per_to_mips,--open,--data_input,--SW,--open, --data_bus , -- nothing from bus
            -- IOpin => bus_IO
        -- );
		
		
	  
	  GPOmap: GPIO
		port map(
			CS			=> CS,
			A0			=> ALU_result_out(0),
			MemRead_out => MemRead_out,
			Memwrite_out => Memwrite_out,
			data_bus    => data_from_mips_to_per ,
			LEDR		=> LEDR,
			HEX0 => HEX0,
			HEX1 => HEX1,
			HEX2 => HEX2,
			HEX3 => HEX3,
			HEX4 => HEX4,
			HEX5 => HEX5,
			clock => clock
		);
		
		
end structure;