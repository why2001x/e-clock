LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY count_60 IS
    PORT (
        --clk输入脉冲，qd手动设置脉冲，set对应位设置状态，clr异步重置，mode区分闹钟和时间，clk_en时钟使能
        clk, qd, set, clr, mode, clk_en : IN std_logic;
        --分/秒BCD码
        min_sec : OUT std_logic_vector(7 DOWNTO 0);
        --进位输出
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
    --正常状态采用clk作为时钟，设置并选中状态采用qd作为时钟
    clkms <= qd WHEN (mode = '1' AND set = '1') ELSE
        clk WHEN (mode = '0');
	--正常状态且使能端使能，或为设置并选中状态时，允许时钟变化
    EN <= (mode AND set) OR (clk_en AND NOT mode);
	--分/秒低位
    lowbits : count_09 PORT MAP(
        aclr => clr,             --清零信号复位
        clk_en => EN,            --使能信号
        clock => clkms,          --分/秒模块时钟
        cout => carryL,          --低位进位
        q => t(3 DOWNTO 0)       --低位BCD输出
    );
	--分/秒高位
    highbits : count_05 PORT MAP(
        aclr => clr,             --清零信号复位
        clk_en => carryL AND EN, --使能信号且低位为9允许变化
        clock => clkms,          --分/秒模块时钟
        cout => carryH,          --高位进位
        q => t(6 DOWNTO 4)       --高位BCD输出（低3位）
    );
	--高位BCD输出（高1位）
    t(7) <= '0';
	--分/秒进位
    carry <= NOT (carryH AND carryL) AND NOT mode;
	--分/秒BCD码2组输出
    min_sec <= t;
END count_60;