library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity led is
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
end led;

architecture led of led is

        signal blinkBCD : std_logic_vector(3 downto 0);
        signal blink7   : std_logic_vector(6 downto 0);
        signal secd7    : std_logic_vector(6 downto 0);

begin
        --输出显示控制--
        --1.秒个位BCD码转七段码--
        secd7 <=
                "1111110" when (secd(3 downto 0) = "0000") else
                "0110000" when (secd(3 downto 0) = "0001") else
                "1101101" when (secd(3 downto 0) = "0010") else
                "1111001" when (secd(3 downto 0) = "0011") else
                "0110011" when (secd(3 downto 0) = "0100") else
                "1011011" when (secd(3 downto 0) = "0101") else
                "1011111" when (secd(3 downto 0) = "0110") else
                "1110000" when (secd(3 downto 0) = "0111") else
                "1111111" when (secd(3 downto 0) = "1000") else
                "1111011" when (secd(3 downto 0) = "1001") else
                "0000000";

        --2.设置状态，假定BCD显示灯输入为全1时，熄灭，则将BCD与blinkBCD取或，假定七段显示灯输入全0时，熄灭，则将七段与blink7取与--
        blinkBCD <= (clk, clk, clk, clk);
        blink7   <= (not clk, not clk, not clk, not clk, not clk, not clk, not clk);

        --3.时/分输出赋值--
        h1       <=
                hour(7 downto 4) or blinkBCD when (mode(1 downto 0) = "01" and set(2) = '1') else --时间设置选中（闪烁）
                a_hour(7 downto 4) when (mode(1) = '1' and set(2) = '0') else                     --闹钟设置未选中
                a_hour(7 downto 4) or blinkBCD when (mode(1) = '1' and set(2) = '1') else         --闹钟设置选中（闪烁）
                hour(7 downto 4);                                                                 --其余状态
        h0 <=
                hour(3 downto 0) or blinkBCD when (mode(1 downto 0) = "01" and set(2) = '1') else
                a_hour(3 downto 0) when (mode(1) = '1' and set(2) = '0') else
                a_hour(3 downto 0) or blinkBCD when (mode(1) = '1' and set(2) = '1') else
                hour(3 downto 0);
        m1 <=
                mint(7 downto 4) or blinkBCD when (mode(1 downto 0) = "01" and set(1) = '1') else
                a_mint(7 downto 4) when (mode(1) = '1' and set(1) = '0') else
                a_mint(7 downto 4) or blinkBCD when (mode(1) = '1' and set(1) = '1') else
                mint(7 downto 4);
        m0 <=
                mint(3 downto 0) or blinkBCD when (mode(1 downto 0) = "01" and set(1) = '1') else
                a_mint(3 downto 0) when (mode(1) = '1' and set(1) = '0') else
                a_mint(3 downto 0) or blinkBCD when (mode(1) = '1' and set(1) = '1') else
                mint(3 downto 0);

        --4.秒输出赋值--
        s1 <=
                secd(7 downto 4) or blinkBCD when (mode(1 downto 0) = "01" and set(0) = '1') else --时间设置选中（闪烁）
                "0000" when (mode(1) = '1') else                                                  --无闹钟设置，强制置零
                secd(7 downto 4);                                                                 --其余状态
        s0 <=
                secd7(6 downto 0) and blink7 when (mode(1 downto 0) = "01" and set(0) = '1') else
                "1111110" when (mode(1) = '1') else
                secd7(6 downto 0);
end led;