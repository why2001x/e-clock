LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY e_clock IS
    PORT (
        clk, clk_high, qd : IN std_logic;
        --clk时钟脉冲，clk_high高频铃声脉冲，qd手动输入脉冲
        clr, set, mode : IN std_logic_vector(2 DOWNTO 0);
        --clr异步重置，set设置选中，高位到低位对应时分秒
        --mode（2）闹钟开关，mode（1）闹钟设置，mode（0）校时
        h1, h0, m1, m0, s1 : OUT std_logic_vector(3 DOWNTO 0);
        s0 : OUT std_logic_vector(6 DOWNTO 0);
        --时分秒的十位及个位，BCD码，秒个位七段码
        buzzer : OUT std_logic
        --蜂鸣器

        --output test port--
        --s0tmp : OUT std_logic_vector(3 DOWNTO 0);
        --crrtest : OUT std_logic;
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
    --cm分钟->时钟进位，cs秒钟->分钟进位，tmp填充弃置端口
    SIGNAL hour, mint, secd, a_hour, a_mint : std_logic_vector(7 DOWNTO 0);
    --hour时钟，mint分钟，secd秒钟，a_hour闹钟时钟，a_mint闹钟分钟
    SIGNAL secd7 : std_logic_vector(6 DOWNTO 0);
    --暂存秒钟个位BCD码->七段码
    SIGNAL blink : std_logic_vector(3 DOWNTO 0);
    --设置状态闪烁控制

BEGIN
    mod_secd : count_60 PORT MAP(
        clk, qd, set(0), clr(0), mode(0), '1',
        secd,
        cs
    );
    --秒模块，输入时钟1hz/qd，输出进位信号cs
    mod_mint : count_60 PORT MAP(
        cs, qd, set(1), clr(1), mode(0), '1',
        mint,
        cm
    );
    --分模块，输入时钟cs/qd，输出进位信号cm
    mod_hour : count_24 PORT MAP(
        cm, qd, set(2), clr(2), mode(0), '1',
        hour,
        tmp
    );
    --时模块，输入时钟cm/qd，输出进位信号弃置
    mod_music : music PORT MAP(
        clk_high,
        mode,
        hour, mint, secd, a_hour, a_mint,
        buzzer
    );
    --整点报时及闹钟响铃模块
    mod_mint_alarm : count_60 PORT MAP(
        clk, qd, set(1), clr(1), mode(1), '0',
        a_mint,
        tmp
    );
    --闹钟分设置模块，输入时钟qd，输出进位信号弃置
    mod_hour_alarm : count_24 PORT MAP(
        clk, qd, set(2), clr(2), mode(1), '0',
        a_hour,
        tmp
    );
    --闹钟时设置模块，输入时钟qd，输出进位信号弃置

    blink <= (clk, clk, clk, clk);
    --设置状态，假定显示灯输入为全1时，显示全灭，则将BCD与blink取或

    secd7 <= "1111110" WHEN (secd(3 DOWNTO 0) = "0000") ELSE
        "0110000" WHEN (secd(3 DOWNTO 0) = "0001") ELSE
        "1101101" WHEN (secd(3 DOWNTO 0) = "0010") ELSE
        "1111001" WHEN (secd(3 DOWNTO 0) = "0011") ELSE
        "0110011" WHEN (secd(3 DOWNTO 0) = "0100") ELSE
        "1011011" WHEN (secd(3 DOWNTO 0) = "0101") ELSE
        "1011111" WHEN (secd(3 DOWNTO 0) = "0110") ELSE
        "1110000" WHEN (secd(3 DOWNTO 0) = "0111") ELSE
        "1111111" WHEN (secd(3 DOWNTO 0) = "1000") ELSE
        "1111011" WHEN (secd(3 DOWNTO 0) = "1001") ELSE
        "0000000";
    --BCD码转七段码

    h1 <= hour(7 DOWNTO 4) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
        a_hour(7 DOWNTO 4) WHEN (mode(1 DOWNTO 0) = "10" AND set(2) = '0') ELSE
        a_hour(7 DOWNTO 4) OR blink WHEN (mode(1 DOWNTO 0) = "10" AND set(2) = '1') ELSE
        hour(7 DOWNTO 4);
    --四行分别对应：校时状态选中（闪烁），闹钟设置未选中，闹钟设置选中（闪烁），其余状态，后续同理
    h0 <= hour(3 DOWNTO 0) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
        a_hour(3 DOWNTO 0) WHEN (mode(1 DOWNTO 0) = "10" AND set(2) = '0') ELSE
        a_hour(3 DOWNTO 0) OR blink WHEN (mode(1 DOWNTO 0) = "10" AND set(2) = '1') ELSE
        hour(3 DOWNTO 0);
    m1 <= mint(7 DOWNTO 4) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(1) = '1') ELSE
        a_mint(7 DOWNTO 4) WHEN (mode(1 DOWNTO 0) = "10" AND set(1) = '0') ELSE
        a_mint(7 DOWNTO 4) OR blink WHEN (mode(1 DOWNTO 0) = "10" AND set(1) = '1') ELSE
        mint(7 DOWNTO 4);
    m0 <= mint(3 DOWNTO 0) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(1) = '1') ELSE
        a_mint(3 DOWNTO 0) WHEN (mode(1 DOWNTO 0) = "10" AND set(1) = '0') ELSE
        a_mint(3 DOWNTO 0) OR blink WHEN (mode(1 DOWNTO 0) = "10" AND set(1) = '1') ELSE
        mint(3 DOWNTO 0);
    s1 <= secd(7 DOWNTO 4) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
        "0000" WHEN (mode(1 DOWNTO 0) = "10") ELSE
        secd(7 DOWNTO 4);
    --秒钟没有闹钟设置，三行分别对应：校时状态选中（闪烁），闹钟设置，其余状态，后续同理
    s0 <= secd7(6 DOWNTO 0) OR blink WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
        "1111110" WHEN (mode(1 DOWNTO 0) = "10") ELSE
        secd7(6 DOWNTO 0); --正常显示
    --output test port--
    --s0tmp <= secd(3 DOWNTO 0) WHEN (mode(1 DOWNTO 0) = "01" AND set(2) = '1') ELSE
    --    "0000" when (mode(1 DOWNTO 0) = "10") ELSE
    --    secd(3 DOWNTO 0) OR blink;
    --crrtest <= cs;
END clock;