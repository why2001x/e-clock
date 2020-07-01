LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY count_24 IS
	PORT (
		clk, qd, set, clr, mode, clk_en : IN std_logic;
		hour : OUT std_logic_vector(7 DOWNTO 0);
		carry : OUT std_logic
	);
END count_24;

ARCHITECTURE count_24 OF count_24 IS
	SIGNAL t : std_logic_vector(7 DOWNTO 0);
	SIGNAL clkh : std_logic;
	SIGNAL newday: std_logic;
	SIGNAL carryL : std_logic;
   SIGNAL carryH : std_logic;
	SIGNAL EN : std_logic;
BEGIN
	clkh <= qd  WHEN (mode = '1' AND set = '1') ELSE
		     clk WHEN (mode = '0');
	EN <= (mode and set) or (clk_en and not mode);
	newday <= t(5) and t(2);
    lowbits: count_09 PORT MAP(
        aclr => clr or newday,
		  clk_en => EN,
        clock => clkh,
        cout => carryL,
        q => t(3 downto 0)
    );
    highbits: count_02 PORT MAP(
        aclr => clr or newday,
		  clk_en => carryL and EN,
        clock => clkh,
        cout => carryH,
        q => t(5 downto 4)
    );
	 t(6) <= '0';
	 t(7) <= '0';
	 carry <= not(carryH and carryL) and not mode;
	 
	--PROCESS (clkh, clr, mode)
	--BEGIN
		--IF (clr = '1') THEN
			--t <= "00000000";
		--ELSIF (rising_edge(clkh)) THEN
			--CASE t(3 DOWNTO 0) IS
				--WHEN "1001" => t(7 DOWNTO 4) <= t(7 DOWNTO 4) + 1;
					--t(3 DOWNTO 0) <= "0000";
				--WHEN "0011" =>
					--CASE t(7 DOWNTO 4) IS
						--WHEN "0010" => t <= "00000000";
						--WHEN OTHERS => t(3 DOWNTO 0) <= t(3 DOWNTO 0) + 1;
					--END CASE;
				--WHEN OTHERS => t(3 DOWNTO 0) <= t(3 DOWNTO 0) + 1;
			--END CASE;
			--IF (t = "00100011" AND mode = '0') THEN
				--carry <= '1';
			--ELSE
				--carry <= '0';
			--END IF;
		--END IF;
	--END PROCESS;
	hour <= t;
END count_24;