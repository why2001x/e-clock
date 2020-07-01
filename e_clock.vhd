LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY e_clock IS
    PORT (
        clk, qd : IN std_logic;
        --mode（2）闹钟开关，mode（1）闹钟设置，mode（0）校时
        clr, set, mode : IN std_logic_vector(2 DOWNTO 0);
        h1, h0, m1, m0, s1, s0 : OUT std_logic_vector(3 DOWNTO 0);
        ah, am : OUT std_logic_vector(7 DOWNTO 0);
		  crrtest: out std_logic;
        buzzer : OUT std_logic
    );
END e_clock;

ARCHITECTURE clock OF e_clock IS
    COMPONENT count_60
        PORT (
            clk, qd, set, clr, mode, clk_en : IN std_logic;
            min_sec : OUT std_logic_vector(7 DOWNTO 0);
            carry : OUT std_logic
        );
    END COMPONENT;
    COMPONENT count_24
        PORT (
            clk, qd, set, clr, mode, clk_en : IN std_logic;
            hour : OUT std_logic_vector(7 DOWNTO 0);
            carry : OUT std_logic
        );
    END COMPONENT;
    COMPONENT music
        PORT (
            clk : IN std_logic;
            mode : IN std_logic_vector(2 DOWNTO 0);
            hour, mint, secd, a_hour, a_mint : IN std_logic_vector(7 DOWNTO 0);
            buzzer : OUT std_logic
        );
    END COMPONENT;
    SIGNAL cm, cs, tmp : std_logic;
    SIGNAL hour, mint, secd, a_hour, a_mint : std_logic_vector(7 DOWNTO 0);
BEGIN
    mod1 : count_60 PORT MAP(clk, qd, set(0), clr(0), mode(0), '1', secd, cs);
    mod2 : count_60 PORT MAP(cs, qd, set(1), clr(1), mode(0), '1', mint, cm);
    mod3 : count_24 PORT MAP(cm, qd, set(2), clr(2), mode(0), '1', hour, tmp);
    mod4 : music PORT MAP(clk, mode, hour, mint, secd, a_hour, a_mint, buzzer);
    mod5 : count_60 PORT MAP(clk, qd, set(1), clr(1), mode(1), '0', a_mint, tmp);
    mod6 : count_24 PORT MAP(clk, qd, set(2), clr(2), mode(1), '0', a_hour, tmp);
    h1 <= hour(7 DOWNTO 4) WHEN (mode(0) = '0' OR set(2) = '0') ELSE
        hour(7 DOWNTO 4) OR (clk, clk, clk, clk);
    h0 <= hour(3 DOWNTO 0) WHEN (mode(0) = '0' OR set(2) = '0') ELSE
        hour(3 DOWNTO 0) OR (clk, clk, clk, clk);
    m1 <= mint(7 DOWNTO 4) WHEN (mode(0) = '0' OR set(1) = '0') ELSE
        mint(7 DOWNTO 4) OR (clk, clk, clk, clk);
    m0 <= mint(3 DOWNTO 0) WHEN (mode(0) = '0' OR set(1) = '0') ELSE
        mint(3 DOWNTO 0) OR (clk, clk, clk, clk);
    s1 <= secd(7 DOWNTO 4) WHEN (mode(0) = '0' OR set(0) = '0') ELSE
        secd(7 DOWNTO 4) OR (clk, clk, clk, clk);
    s0 <= secd(3 DOWNTO 0) WHEN (mode(0) = '0' OR set(0) = '0') ELSE
        secd(3 DOWNTO 0) OR (clk, clk, clk, clk);
    ah <= a_hour;
    am <= a_mint;
	 crrtest <= cs;
END clock;