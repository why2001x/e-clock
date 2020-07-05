LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY music IS
    PORT (
        clk : IN std_logic;
        --高频铃声脉冲
        mode : IN std_logic_vector(2 DOWNTO 0);
        --mode（2）闹钟开关，mode（1）闹钟设置，mode（0）校时
        hour, mint, secd, a_hour, a_mint : IN std_logic_vector(7 DOWNTO 0);
        --时分秒，闹钟时分
        buzzer : OUT std_logic
        --蜂鸣器
    );
END music;

ARCHITECTURE music OF music IS
    SIGNAL cnt : std_logic_vector(1 DOWNTO 0);
    --计数器控制铃声频率，一方面作分频器，一方面作计数器
    SIGNAL state : std_logic;
    --蜂鸣器状态存储
BEGIN
    --本次实验采用了两种频率的铃音，由于仿真软件的限制，采用真实的人耳听力范围内的频率会导致仿真时间极短，因此仅用低频铃音作为示范
    PROCESS (clk, mode)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (mode(0) = '1' OR mode(1) = '1') THEN
                cnt <= "00";
                state <= '0';
            --设置状态关闭所有响铃
            ELSIF (mode(2) = '1' AND mint = a_mint AND hour = a_hour) THEN
                CASE cnt IS
                    WHEN "00" =>
                        cnt <= "11";
                        state <= NOT state;
                    WHEN OTHERS => cnt <= cnt - 1;
                END CASE;
            --闹钟匹配，将高频输入4分频得到铃音，持续一分钟或者手动关闭闹钟
            ELSIF (mint = "01011001" AND secd = "01011001") THEN
                cnt <= "11";
            --时钟即将变化，设置整点报时计数器
            ELSIF (cnt > 0) THEN
                cnt <= cnt - 1;
                state <= NOT state;
            --整点报时，将高频输入2分频并持续两个脉冲
            ELSE
                state <= '0';
            --无响铃事件重置计数器和状态
            END IF;
        END IF;
    END PROCESS;
    buzzer <= state;
END music;