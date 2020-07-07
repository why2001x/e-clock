LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--	COMPONENT count_0X IS                           --该计数器为0-X循环
--		PORT (
--			aclr, clk_en, clock : IN STD_LOGIC;     --异步复位/时钟使能/时钟输入
--			cout : OUT STD_LOGIC;                   --进位输出
--			q : OUT STD_LOGIC_VECTOR (W-1 DOWNTO 0) --输出宽度为W位
--		);
--	END COMPONENT;

PACKAGE Counters IS

	COMPONENT count_02 IS
		PORT (
			aclr, clk_en, clock : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT count_05 IS
		PORT (
			aclr, clk_en, clock : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT count_09 IS
		PORT (
			aclr, clk_en, clock : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		);
	END COMPONENT;

END Counters;