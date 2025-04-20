library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InterruptController is
    Port (
        clock          : in  STD_LOGIC;             -- Clock input
        reset          : in  STD_LOGIC;             -- Reset input
        CSgag          : in  STD_LOGIC_VECTOR(11 downto 0);  -- not(CS)
        BTrq           : in  STD_LOGIC;  -- BasicTimer interrupt request
        KEY1rq         : in  STD_LOGIC;  -- KEY1 interrupt request
		KEY2rq         : in  STD_LOGIC;  -- KEY2 interrupt request
		KEY3rq         : in  STD_LOGIC;  -- KEY3 interrupt request
		INTAgag        : in  STD_LOGIC;
		INTR           : out  STD_LOGIC := '0';
        databus        : in STD_LOGIC_VECTOR(31 downto 0);           
		A10			   : in  STD_LOGIC_VECTOR(1 downto 0); -- bit 01 from address
		GIE_read	   : in STD_LOGIC;
		interruptReg   : out STD_LOGIC_VECTOR(7 downto 0); -- IFG_read, IE_read, TYPE_read
		MemRead_out    : in  STD_LOGIC;
        Memwrite_out   : in  STD_LOGIC;
		--type_bus_ena   : out STD_LOGIC;
		finish_timer_routine : in STD_LOGIC
    );
end entity InterruptController;

architecture Behavioral of InterruptController is


--------- Signal Decleration ---------

    signal IFGreg : STD_LOGIC_VECTOR(7 downto 0);
	signal IEreg : STD_LOGIC_VECTOR(7 downto 0);
	signal TYPEreg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal irq_key_1, irq_key_2, irq_key_3, irq_bt : STD_LOGIC := '0';
	signal priority : STD_LOGIC_VECTOR(2 downto 0);
	signal pend, cnt_en, cnt_en_pend_down : STD_LOGIC;
	signal ifg2, ifg3, ifg4, ifg5 : STD_LOGIC;
	signal cnt_q : std_logic_vector (31 downto 0);
	signal prev, key1prev, key2prev, key3prev : STD_LOGIC;
	
begin
	
	-- IFG_read <= IFGreg;
	-- IE_read	 <= IEreg;
	-- TYPE_read <= TYPEreg;

	-- with A10 select
		-- interruptReg <= IFGreg when "01",
						-- IEreg  when "00",
						-- TYPEreg when "10",
						-- X"00" when others;
	
	-- with A10 select interruptReg <=
		-- IFGreg	when "01",
		-- IEreg	when "00",
		-- TYPEreg when "10",
		-- (others => '0')	when others;
	
	
    interruptReg <= IFGreg when (A10 = "01" and INTAgag = '0') else -- GIE_read = '1') else
                   IEreg  when (A10 = "00" and INTAgag = '0') else --and GIE_read = '1') else
                   TYPEreg when (A10 = "10" and INTAgag = '0') else --and GIE_read = '1') else
                   TYPEreg when INTAgag='1';--INTAgag = '1';-- and GIE_read = '0';
	-- process(INTAgag, clock)
	-- begin
		-- if falling_edge(INTAgag) THEN
			-- type_bus_ena <= '1';
		-- else
			-- type_bus_ena <= '0';
		-- end if;
	-- end process;
 	
		--INTR <= '0' when reset='1' else GIE_read and ((IEreg(5) and KEY3rq) or (IEreg(4) and KEY2rq) or (IEreg(3) and KEY1rq) or (BTrq and IEreg(2) and not(prev)));
		
		INTR <= '0' when reset='1' else GIE_read and ((IEreg(5) and (not(KEY3rq)) and key3prev) or (IEreg(4) and (not(KEY2rq)) and key2prev) or (IEreg(3) and (not(KEY1rq)) and key1prev) or (BTrq and IEreg(2) and not(prev)));
		
		
    process (clock,reset)--CSgag,A10, priority)
		variable IFG_temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
         if reset = '1' then
			IFGreg <= (others => '0');
			IEreg <= (others => '0');
			TYPEreg <= (others => '0');
			prev <= '0';
			key1prev <= '1';
			key2prev <= '1';
			key3prev <= '1';
		elsif rising_edge(clock) then
			
			if CSgag(5) = '1' and A10 = "00" and Memwrite_out='1' then
					IEreg <= "00" & databus(5 downto 0);
			elsif CSgag(5) = '1' and A10 = "01" and Memwrite_out='1' then
					IFGreg <= "00" & databus(5 downto 0);
					IFG_temp := "00" & databus(5 downto 0);
			elsif CSgag(5) = '1' and A10 = "10" and Memwrite_out='1' then
					TYPEreg(7 downto 5) <= "000";
					TYPEreg(4 downto 1) <= databus(4 downto 1); -- need to move TYPEx here
					TYPEreg(0) <= '0';
			-- elsif CSgag(5) = '1' and A10 = "00" and MemRead_out = '1' THEN -- read IE
					-- IE_read <= IEreg;
			-- elsif CSgag(5) = '1' and A10 = "01" and MemRead_out = '1' then -- read IFG
					-- IFG_read <= IFGreg;
			-- elsif CSgag(5) = '1' and A10 = "10" and MemRead_out = '1' then -- read TYPE
					-- TYPE_read <= TYPEreg;
			
			 end if;--else
			
			-- if BTrq ='1' and GIE_read =  '1' and prev='0' then
				-- IFGreg(2) <= '1';
			-- end if;
			-- if (KEY1rq = '1' or KEY2rq = '1' or KEY3rq = '1') and GIE_read =  '1' then 
				-- IFGreg(5 downto 3) <= (IEreg(5) and KEY3rq) & (IEreg(4) and KEY2rq) & (IEreg(3) and KEY1rq);
			-- end if;
			-- if INTAgag = '0' and IFGreg(2) = '1' and GIE_read =  '0' then
				-- IFGreg(2) <= '0';
			-- end if;
			-- if IFGreg(5 downto 2) /= "0000" and GIE_read =  '1' then 
						-- if 		IFGreg(2) = '1' then TYPEreg <= "00000100"; -- Timer --"00010000";
						-- elsif	IFGreg(3) = '1' then TYPEreg <= "00000101"; -- Key1
						-- elsif	IFGreg(4) = '1' then TYPEreg <= "00000110"; -- Key2
						-- elsif	IFGreg(5) = '1' then TYPEreg <= "00000111"; -- Key3
						-- end if;						
						-- INTR <= '1';
			-- else
				-- INTR <= '0';
			-- end if;
			-- if (KEY1rq = '1' or KEY2rq = '1' or KEY3rq = '1') then 
					-- IFGreg(5 downto 3) <= (IEreg(5) and KEY3rq) & (IEreg(4) and KEY2rq) & (IEreg(3) and KEY1rq);
					-- IFG_temp(5 downto 3) := (IEreg(5) and KEY3rq) & (IEreg(4) and KEY2rq) & (IEreg(3) and KEY1rq);
			-- end if;

			if KEY1rq='0' and IEreg(3)='1' and key1prev='1' then
				IFGreg(3) <= '1';
				IFG_temp(3) := '1';
			end if;
			
			if KEY2rq='0' and IEreg(4)='1' and key2prev='1' THEN
				IFGreg(4) <= '1';
				IFG_temp(4) := '1';
			end if;
			
			if KEY3rq='0' and IEreg(5)='1' and key3prev='1' THEN
				IFGreg(5) <= '1';
				IFG_temp(5) := '1';
			end if;
			
			if BTrq='1' and IEreg(2) = '1' and prev='0' then --and INTAgag='0' and finish_timer_routine='1' then-- irq_bt = '1' and IEreg(2) = '1' then -- and pend = '0' then
				IFGreg(2) <= '1';
				IFG_temp(2) := '1';
			end if;
				
								
			if INTAgag = '0' and IFGreg(2) = '1' and GIE_read =  '0' then
				IFGreg(2) <= '0';
				IFG_temp(2) := '0';
			end if;
								
			if IFG_temp(5 downto 2) /= "0000" then --IFGreg(5 downto 2) /= "0000" then -- pend = '0' and
						if 		IFG_temp(2) = '1' then TYPEreg <= "00000100"; -- Timer --"00010000";
						elsif	IFG_temp(3) = '1' then TYPEreg <= "00000101"; -- Key1
						elsif	IFG_temp(4) = '1' then TYPEreg <= "00000110"; -- Key2
						elsif	IFG_temp(5) = '1' then TYPEreg <= "00000111"; -- Key3
						end if;	
			end if;
			prev <= BTrq;
			key1prev <= KEY1rq;
			key2prev <= KEY2rq;
			key3prev <= KEY3rq;
		end if;		
				--if GIE_read =  '1' then

					-- if (KEY1rq = '1' or KEY2rq = '1' or KEY3rq = '1') and GIE_read =  '1' then 
						-- IFGreg(5 downto 3) <= (IEreg(5) and KEY3rq) & (IEreg(4) and KEY2rq) & (IEreg(3) and KEY1rq);
					-- end if;
					-- if BTrq='1' and IEreg(2) = '1' and GIE_read =  '1' and prev='0' then --and INTAgag='0' and finish_timer_routine='1' then-- irq_bt = '1' and IEreg(2) = '1' then -- and pend = '0' then
						-- IFGreg(2) <= '1';
					-- end if;
	
					
				
					-- if INTAgag = '0' and IFGreg(2) = '1' and GIE_read =  '0' then
						-- IFGreg(2) <= '0';
					-- end if;
					
					-- if IFGreg(5 downto 2) /= "0000" and GIE_read =  '1' then -- pend = '0' and
						-- if 		IFGreg(2) = '1' then TYPEreg <= "00000100"; -- Timer --"00010000";
						-- elsif	IFGreg(3) = '1' then TYPEreg <= "00000101"; -- Key1
						-- elsif	IFGreg(4) = '1' then TYPEreg <= "00000110"; -- Key2
						-- elsif	IFGreg(5) = '1' then TYPEreg <= "00000111"; -- Key3
						-- end if;						
						-- INTR <= '1';
					--else
						-- INTR <= '0';-- NEED TO CHECK
					--end if;
					
				--if GIE_read =  '0' then
				--	INTR <= '0';
					
				-- elsif GIE_read ='0' and prev='0' then
					-- type_bus_ena <= '1';
					-- prev <= '1';
				-- elsif GIE_read = '0' and prev ='1' THEN
						-- type_bus_ena <= '0';
				-- elsif GIE_read = '0' THEN
					-- case INTAgag is
						-- when '0' => interruptReg <= TYPEreg;
						-- when others => null;
					-- end case;
					
					
			--	end if;
				
			-- end if;	
			--prev <= BTrq;
        --end if;
    end process;

----------------------- BasicTimer Interrupt	
	
	-- process(BTrq, reset)--,IFGreg(2))
	-- begin
		-- if reset = '1' or IFGreg(2) = '0' then
			-- irq_bt <= '0';
		-- elsif (BTrq='1') then -- rising_edge(BTrq)) then --(rising_edge(BTrq)) then -- and pend = '0') then
			-- if IEreg(2) = '1' and GIE_read = '1' then
				-- irq_bt <= '1';
			-- end if;
		-- end if;
		-- if rising_edge(BTrq) then
			-- irq_bt <= '1';
		-- elsif INTAgag = '0' then
			-- irq_bt <= '0';
		-- end if;
	-- end process;

------------------------	
		-- process(KEY1rq)
	-- begin
			-- if falling_edge(KEY1rq) then
				-- irq_key_1 <= '1';
			-- elsif INTAgag = '0' then
				-- irq_key_1 <= '0';
			-- end if;
	-- end process;
	
		-- process(KEY2rq)
	-- begin
			-- if falling_edge(KEY2rq) then
				-- irq_key_2 <= '1';
			-- elsif INTAgag = '0' then
				-- irq_key_2 <= '0';
			-- end if;
	-- end process;
	
		-- process(KEY3rq)
	-- begin
			-- if falling_edge(KEY3rq) then
				-- irq_key_3 <= '1';
			-- elsif INTAgag = '0' then
				-- irq_key_3 <= '0';
			-- end if;
	-- end process;


	-- process(clock, reset)
	-- begin
		-- if rising_edge(clock) and CSgag(5) = '0' then
			-- IFGreg <= "00" & (IEreg(5) and irq_key_3) & (IEreg(4) and irq_key_2) & (IEreg(3) and irq_key_1) & (IEreg(2) and irq_bt) & "00";
		-- end if;
	-- end process;
	-- ifg2 <= (IEreg(2) and irq_bt);
	-- ifg3 <= (IEreg(3) and irq_key_1);
	-- ifg4 <= (IEreg(4) and irq_key_2);
	-- ifg5 <= (IEreg(5) and irq_key_3);
	--IFGreg <= "00" & ifg5 & ifg4 & ifg3 & ifg2 & "00";
	--IFGreg <= "00" & (IEreg(5) and irq_key_3) & (IEreg(4) and irq_key_2) & (IEreg(3) and irq_key_1) & (IEreg(2) and irq_bt) & "00" when (CSgag(5) = '0' and A10 /= "01");
	
	-- INTR <= GIE_read and ((IEreg(2) and irq_bt) or (IEreg(3) and irq_key_1) or (IEreg(4) and irq_key_2) or (IEreg(5) and irq_key_3)); 

	-- process (clock) -- button delay, check later if neccessary
    -- begin
		-- if (rising_edge(clock)) then 
			-- if reset ='1' 	then	
				-- pend <= '0';
				-- cnt_q <= x"00000000";
				-- cnt_en_pend_down <= '0';
				
			-- elsif pend = '0' AND IFGreg(5 downto 2) /= "0000" then	
				-- pend <= '1';
				
			-- end if;
			
			-- if cnt_en = '1' then
				-- cnt_q <= cnt_q + 1;
			-- end if;
			
			-- if cnt_q(7) = '1' then -- 23
					-- pend <= '0';
					-- cnt_q   <= x"00000000";
					-- cnt_en_pend_down <= '1';
			-- end if;
			
			-- if cnt_en_pend_down = '1' then
					-- cnt_q   <= x"00000000";
					-- cnt_en_pend_down <= '0';
			-- end if;
			
			-- IF	TYPEreg = "00000100" and INTAgag = '0' THEN
				-- pend <= '0';
			-- end if;
			
		-- end if;
    -- end process;


	
end architecture Behavioral;
