LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY count_60 IS
    PORT (
        clk, qd, set, clr, mode, clk_en : IN std_logic;
        min_sec : OUT std_logic_vector(7 DOWNTO 0);
        carry : OUT std_logic
    );
END count_60;

ARCHITECTURE count_60 OF count_60 IS
    SIGNAL t : std_logic_vector(7 DOWNTO 0);
    SIGNAL clkms : std_logic;
    SIGNAL carryL : std_logic;
    SIGNAL carryH : std_logic;
	 SIGNAL EN : std_logic;
BEGIN
    clkms <= qd  WHEN (mode = '1' AND set = '1') ELSE
             clk WHEN (mode = '0');
	 EN <= (mode and set) or (clk_en and not mode);
    lowbits: count_09 PORT MAP(
        aclr => clr,
		  clk_en => EN,
        clock => clkms,
        cout => carryL,
        q => t(3 downto 0)
    );
    highbits: count_05 PORT MAP(
        aclr => clr,
		  clk_en => carryL and EN,
        clock => clkms,
        cout => carryH,
        q => t(6 downto 4)
    );
	 t(7) <= '0';
	 carry <= not (carryH and carryL) and not mode;
	 
    --PROCESS (clkms, clr, mode)
    --BEGIN
        --IF (clr = '1') THEN
            --t <= "00000000";
        --ELSIF (rising_edge(clkms)) THEN
            --CASE t(3 DOWNTO 0) IS
                --WHEN "1001" =>
                    --CASE t(7 DOWNTO 4) IS
                        --WHEN "0101" => t <= "00000000";
                        --WHEN OTHERS => t(7 DOWNTO 4) <= t(7 DOWNTO 4) + 1;
                            --t(3 DOWNTO 0) <= "0000";
                    --END CASE;
                --WHEN OTHERS => t <= t + 1;
            --END CASE;
            --IF (t = "01011001" AND mode = '0') THEN
                --carry <= '1';
            --ELSE
                --carry <= '0';
            --END IF;
        --END IF;
    --END PROCESS;
    
    min_sec <= t;
END count_60;