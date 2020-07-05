LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY count_60 IS
    PORT (
        clk, qd, set, clr, mode, clk_en : IN std_logic;
        --clk输入脉冲，qd手动设置脉冲，set对应位设置状态，clr异步重置，mode区分闹钟和时间，clk_en时钟使能
        min_sec : OUT std_logic_vector(7 DOWNTO 0);
        --分/秒BCD码
        carry : OUT std_logic
        --进位输出
    );
END count_60;

ARCHITECTURE count_60 OF count_60 IS
    SIGNAL t : std_logic_vector(7 DOWNTO 0);
    SIGNAL clkms : std_logic;
    SIGNAL carryL : std_logic;
    SIGNAL carryH : std_logic;
    SIGNAL EN : std_logic;
BEGIN
    clkms <= qd WHEN (mode = '1' AND set = '1') ELSE
        clk WHEN (mode = '0');
    --正常状态采用clk作为时钟，设置并选中状态采用qd作为时钟
    EN <= (mode AND set) OR (clk_en AND NOT mode);
    lowbits : count_09 PORT MAP(
        aclr => clr,
        clk_en => EN,
        clock => clkms,
        cout => carryL,
        q => t(3 DOWNTO 0)
    );
    highbits : count_05 PORT MAP(
        aclr => clr,
        clk_en => carryL AND EN,
        clock => clkms,
        cout => carryH,
        q => t(6 DOWNTO 4)
    );
    t(7) <= '0';
    carry <= NOT (carryH AND carryL) AND NOT mode;
    min_sec <= t;
END count_60;