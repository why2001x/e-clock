library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity e_clock is
	port (
		clk_high, qd : in std_logic;                     --高频时钟脉冲，手动输入脉冲

		clr          : in std_logic;                     --全局重置

		set          : in std_logic_vector(2 downto 0);  --设置状态选中，高位到低位对应时分秒

		mode         : in std_logic_vector(2 downto 0);  --高位到低位对应闹钟开关，闹钟设置，时间设置

		h1, h0       : out std_logic_vector(3 downto 0); --BCD码，时的十位及个位
		m1, m0       : out std_logic_vector(3 downto 0); --BCD码，分的十位及个位
		s1           : out std_logic_vector(3 downto 0); --BCD码，秒的十位
		s0           : out std_logic_vector(6 downto 0); --七段码，秒的个位

		buzzer       : out std_logic                     --蜂鸣器

		--output test port--
		--clk_out : OUT std_logic
		--s0tmp : OUT std_logic_vector(3 DOWNTO 0);
		--crrtest : OUT std_logic;
	);
end e_clock;

architecture clock of e_clock is

	component divider --分频器
		port (
			clk_in  : in std_logic;
			clk_out : out std_logic
		);
	end component;

	component count_60 --60进制计数器
		port (
			clk, qd, clk_en : in std_logic;
			clr, set        : in std_logic;
			mode            : in std_logic;
			min_sec         : out std_logic_vector(7 downto 0);
			carry           : out std_logic
		);
	end component;

	component count_24 --24进制计数器
		port (
			clk, qd, clk_en : in std_logic;
			clr, set        : in std_logic;
			mode            : in std_logic;
			hour            : out std_logic_vector(7 downto 0);
			carry           : out std_logic
		);
	end component;

	component music --响铃
		port (
			clk              : in std_logic;
			mode             : in std_logic_vector(2 downto 0);
			hour, mint, secd : in std_logic_vector(7 downto 0);
			a_hour, a_mint   : in std_logic_vector(7 downto 0);
			buzzer           : out std_logic
		);
	end component;

	component led
		port (
			clk              : in std_logic;
			hour, mint, secd : in std_logic_vector(7 downto 0);
			a_hour, a_mint   : in std_logic_vector(7 downto 0);
			mode             : in std_logic_vector(1 downto 0);
			set              : in std_logic_vector(2 downto 0);
			h1, h0           : out std_logic_vector(3 downto 0);
			m1, m0           : out std_logic_vector(3 downto 0);
			s1               : out std_logic_vector(3 downto 0);
			s0               : out std_logic_vector(6 downto 0)
		);
	end component;

	signal clk              : std_logic;                    --1hz脉冲

	signal cs, cm, tmp      : std_logic;                    --cs秒->分进位，cm分->时进位，tmp填充弃置进位端口

	signal hour, mint, secd : std_logic_vector(7 downto 0); --时，分，秒
	signal a_hour, a_mint   : std_logic_vector(7 downto 0); --闹钟时，闹钟分

begin
	--分频--
	mod_div : divider port map(
		clk_in  => clk_high, --高频输入
		clk_out => clk       --1hz输出
	);

	--时间秒--
	mod_secd : count_60 port map(
		clk     => clk,
		qd      => qd,
		clk_en  => '1', --时间使能
		clr     => clr,
		set     => set(0),
		mode    => mode(0), --时间设置
		min_sec => secd,    --秒
		carry   => cs       --秒->分进位
	);

	--时间分--
	mod_mint : count_60 port map(
		clk     => cs, --秒->分进位作为输入
		qd      => qd,
		clk_en  => '1', --时间使能
		clr     => clr,
		set     => set(1),
		mode    => mode(0), --时间设置
		min_sec => mint,    --分
		carry   => cm       --分->时进位
	);

	--时间时--
	mod_hour : count_24 port map(
		clk    => cm, --分->时进位作为输入
		qd     => qd,
		clk_en => '1', --时间使能
		clr    => clr,
		set    => set(2),
		mode   => mode(0), --时间设置
		hour   => hour,    --时
		carry  => tmp      --时进位在当前版本并未应用在报时模块中，端口弃置
	);

	--整点报时及闹钟响铃--
	mod_music : music port map(
		clk    => clk_high, --高频时钟作为输入
		mode   => mode,
		hour   => hour,
		mint   => mint,
		secd   => secd,
		a_hour => a_hour,
		a_mint => a_mint,
		buzzer => buzzer
	);

	--闹钟分--
	mod_mint_alarm : count_60 port map(
		clk     => clk, --闹钟不使用此时钟，任意选择
		qd      => qd,
		clk_en  => '0', --闹钟状态时间使能取非
		clr     => clr,
		set     => set(1),
		mode    => mode(1), --闹钟设置
		min_sec => a_mint,  --闹钟分
		carry   => tmp      --闹钟状态取消进位，端口弃置
	);

	--闹钟时--
	mod_hour_alarm : count_24 port map(
		clk    => clk, --闹钟不使用此时钟，任意选择
		qd     => qd,
		clk_en => '0', --闹钟状态时间使能取非
		clr    => clr,
		set    => set(2),
		mode   => mode(1), --闹钟设置
		hour   => a_hour,  --闹钟时
		carry  => tmp      --闹钟状态取消进位，端口弃置
	);

	--显示输出控制--
	mod_led : led port map(
		clk    => clk,
		hour   => hour,
		mint   => mint,
		secd   => secd,
		a_hour => a_hour,
		a_mint => a_mint,
		mode   => mode(1 downto 0),
		set    => set,
		h1     => h1,
		h0     => h0,
		m1     => m1,
		m0     => m0,
		s1     => s1,
		s0     => s0
	);

	--output test port--
	--clk_out <= clk;
	--s0tmp <= secd(3 DOWNTO 0) WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
	--    "0000" when (mode(1 DOWNTO 0) = "10") ELSE
	--    secd(3 DOWNTO 0) OR blink;
	--crrtest <= cs;
end clock;