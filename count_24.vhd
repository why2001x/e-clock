LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY count_24 IS
	PORT (
		clk, qd, set, clr, mode, clk_en : IN std_logic;
		--clk输入脉冲，qd手动设置脉冲，set对应位设置状态，clr异步重置，mode区分闹钟和时间，clk_en时钟使能
		hour : OUT std_logic_vector(7 DOWNTO 0);
		--时BCD码
		carry : OUT std_logic
		--进位输出
	);
END count_24;

ARCHITECTURE count_24 OF count_24 IS
	SIGNAL t : std_logic_vector(7 DOWNTO 0);
	SIGNAL clkh : std_logic;
	SIGNAL newday : std_logic;
	SIGNAL carryL : std_logic;
	SIGNAL carryH : std_logic;
	SIGNAL EN : std_logic;
BEGIN
	clkh <= qd WHEN (mode = '1' AND set = '1') ELSE
		clk WHEN (mode = '0');
	--正常状态采用clk作为时钟，设置并选中状态采用qd作为时钟
	EN <= (mode AND set) OR (clk_en AND NOT mode);
	newday <= t(5) AND t(2);
	lowbits : count_09 PORT MAP(
		aclr => clr OR newday,
		clk_en => EN,
		clock => clkh,
		cout => carryL,
		q => t(3 DOWNTO 0)
	);
	highbits : count_02 PORT MAP(
		aclr => clr OR newday,
		clk_en => carryL AND EN,
		clock => clkh,
		cout => carryH,
		q => t(5 DOWNTO 4)
	);
	t(6) <= '0';
	t(7) <= '0';
	carry <= NOT(carryH AND carryL) AND NOT mode;
	hour <= t;
END count_24;