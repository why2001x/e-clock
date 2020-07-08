library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Counters.all;

entity count_24 is
	port (
		clk, qd, clk_en : in std_logic;                     --输入脉冲，手动设置脉冲，时钟使能
		clr, set        : in std_logic;                     --异步重置，设置状态选中
		mode            : in std_logic;                     --时间/闹钟设置模式
		hour            : out std_logic_vector(7 downto 0); --时十位及个位BCD码
		carry           : out std_logic                     --进位输出
	);
end count_24;

architecture count_24 of count_24 is

	signal t      : std_logic_vector(7 downto 0);
	signal clkh   : std_logic; --输入/手动脉冲切换
	signal newday : std_logic; --作为24进制的检测信号
	signal carryL : std_logic;
	signal carryH : std_logic;
	signal EN     : std_logic;

begin

	clkh <= qd when (mode = '1' and set = '1') else --正常状态采用clk作为时钟，设置并选中状态采用qd作为时钟
		clk when (mode = '0');

	EN     <= (mode and set) or (clk_en and not mode); --正常状态且使能端使能，或为设置并选中状态时，允许时钟变化

	newday <= t(5) and t(2);                           --新的一天24:XX:XX->00:XX:XX

	--时低位--
	lowbits : count_09 port map(
		aclr   => clr or newday, --清零信号或新的一天复位
		clk_en => EN,            --使能信号
		clock  => clkh,          --时模块时钟
		cout   => carryL,        --低位进位
		q      => t(3 downto 0)  --低位BCD输出
	);

	--时高位--
	highbits : count_02 port map(
		aclr   => clr or newday, --清零信号或新的一天复位
		clk_en => carryL and EN, --使能信号且低位为9允许变化
		clock  => clkh,          --时模块时钟
		cout   => carryH,        --高位进位
		q      => t(5 downto 4)  --高位BCD输出（低2位）
	);

	t(7 downto 6) <= "00";                                --高位BCD输出（高2位）

	carry         <= not(carryH and carryL) and not mode; --时进位，时间/闹钟设置状态取消进位

	hour          <= t;                                   --时BCD码2组输出
end count_24;