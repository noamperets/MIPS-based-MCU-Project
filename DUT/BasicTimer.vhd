library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BasicTimer is
    Port (
        clock          : in  STD_LOGIC;             -- Clock input
        reset          : in  STD_LOGIC;             -- Reset input
		data_bus       : in  STD_LOGIC_VECTOR(31 downto 0);
        BTCTL_read          : out  STD_LOGIC_VECTOR(7 downto 0);  -- BT Control input (BTOUTEN in bit 6, BTHOLD in bit 5, BTSSEL in bit 3-4, BTIPx in bit 0-2)
        BTCCR0_read         : out  STD_LOGIC_VECTOR(31 downto 0);  -- BT Compare Register 0 (Clock cycle)
        BTCCR1_read         : out  STD_LOGIC_VECTOR(31 downto 0);  -- BT Compare Register 1 (Duty cycle)
        BTCNT_read          : out STD_LOGIC_VECTOR(31 downto 0);  -- Output current count value
        output_signal  : out STD_LOGIC;             -- Output signal (based on duty cycle)
        Set_BTIFG      : out STD_LOGIC;              -- Output to select which bit to set BTIFG
		CS   : in  STD_LOGIC_VECTOR(11 downto 0);
		MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC
    );
end entity BasicTimer;



architecture Behavioral of BasicTimer is

component freq_divider is
	port( clock, reset: in STD_LOGIC;
		  mclk2, mclk4, mclk8 : out STD_LOGIC);
end component;

    signal timer_cnt : STD_LOGIC_VECTOR(31 downto 0);  -- Timer counter signal
    signal BTIFG_sel : STD_LOGIC;  -- Selected BTIFG bit
    signal BTOUTEN, BTHOLD : STD_LOGIC;  -- BTOUTEN and BTHOLD signals
    signal BTCL0, BTCL1 : STD_LOGIC_VECTOR(31 downto 0):= (others => 'Z');  -- BT Compare Latches
	signal BTCTL_compare : STD_LOGIC_VECTOR(7 downto 0) := (others => 'Z'); -- BTCLT compare
    signal divider_counter : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal mclk2, mclk4, mclk8 : STD_LOGIC;
	signal clock_count : STD_LOGIC;
	
begin

	BTCCR0_read <= BTCL0;
	BTCCR1_read <= BTCL1;
	BTCTL_read <= BTCTL_compare;
	BTCNT_read <= timer_cnt;--BTCNT;
	
    -- Compare latches for clock cycle (BTCL0) and duty cycle (BTCL1)
    process (clock, reset)
    begin
        if reset = '1' then
            BTCL0 <= (others => '0'); -- Reset the compare latch for clock cycle to zero
            BTCL1 <= (others => '0'); -- Reset the compare latch for duty cycle to zero
			BTCTL_compare <= "00100000";
        elsif rising_edge(clock) then
            -- Load new values into the compare latches
			if CS(10) = '1' and Memwrite_out = '1' then -- choose BTCCR0
				BTCL0 <= data_bus; --BTCCR0;
			elsif CS(11) = '1' and Memwrite_out = '1' then -- choose BTCCR1
				BTCL1 <= data_bus; --BTCCR1;
			elsif CS(8) = '1' and Memwrite_out = '1' then -- choose BTCTL
				BTCTL_compare <= data_bus(7 downto 0); --BTCTL;
				BTOUTEN <= data_bus(6); --BTCTL(6);
				BTHOLD  <= data_bus(5); --BTCTL(5);
			end if;			
        end if;
    end process;

	freqdivMAP: freq_divider
		port map(clock => clock,
				 reset => reset,
				 mclk2 => mclk2,
				 mclk4 => mclk4,
				 mclk8 => mclk8
				 );


	with BTCTL_compare(4 downto 3) select clock_count <=
		clock	when "00",
		mclk2	when "01",
		mclk4 	when "10",
		mclk8 	when "11",
		'X'		when others;
	
	with BTCTL_compare(2 downto 0) select BTIFG_sel <=
		timer_cnt(25) when "111",
		timer_cnt(23) when "110",
		timer_cnt(19) when "101",
		timer_cnt(15) when "100",
		timer_cnt(11) when "011",
		timer_cnt(7)  when "010",
		timer_cnt(3)  when "001",
		timer_cnt(0)  when "000",
		'0'			  when others;
		
		
    process (reset, clock_count)--clock,divider_counter(0),divider_counter(1),divider_counter(2))
    begin
		if reset='1' then
			timer_cnt <= (others => '0');			
		elsif CS(9) = '1' and Memwrite_out = '1' then
			timer_cnt <= data_bus;		
		elsif BTHOLD = '1' then
				timer_cnt <= timer_cnt;  -- Hold the counter value
		elsif (clock_count'event and clock_count='1') then
				timer_cnt <= timer_cnt+1;
		end if;
             
                -- Check if timer_cnt is greater than or equal to BTCL0, then reset it to 0
        if timer_cnt >= BTCL0 and BTCL0 /=0 then
               timer_cnt <= (others => '0');
        end if;
    end process;

    -- Output signal based on duty cycle and BTOUTEN
    output_signal <= '1' when timer_cnt < BTCL1 and BTOUTEN='1' else '0';

    -- Output to select which bit to set BTIFG
    Set_BTIFG <= BTIFG_sel;

end architecture Behavioral;
