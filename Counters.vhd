library ieee;
use ieee.std_logic_1164.all;

--	COMPONENT count_0X IS                           --该计数器为0-X循环
--		PORT (
--			aclr, clk_en, clock : IN STD_LOGIC;     --异步复位/时钟使能/时钟输入
--			cout : OUT STD_LOGIC;                   --进位输出
--			q : OUT STD_LOGIC_VECTOR (W-1 DOWNTO 0) --输出宽度为W位
--		);
--	END COMPONENT;

package Counters is

	component count_02 is
		port (
			aclr, clk_en, clock : in STD_LOGIC;
			cout                : out STD_LOGIC;
			q                   : out STD_LOGIC_VECTOR (1 downto 0)
		);
	end component;

	component count_05 is
		port (
			aclr, clk_en, clock : in STD_LOGIC;
			cout                : out STD_LOGIC;
			q                   : out STD_LOGIC_VECTOR (2 downto 0)
		);
	end component;

	component count_09 is
		port (
			aclr, clk_en, clock : in STD_LOGIC;
			cout                : out STD_LOGIC;
			q                   : out STD_LOGIC_VECTOR (3 downto 0)
		);
	end component;

end Counters;