library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity music is
	port (
		clk              : in std_logic;                    --高频铃声脉冲
		mode             : in std_logic_vector(2 downto 0); --高位到低位对应闹钟开关，闹钟设置，时间设置
		hour, mint, secd : in std_logic_vector(7 downto 0); --时分秒
		a_hour, a_mint   : in std_logic_vector(7 downto 0); --闹钟时分
		buzzer           : out std_logic                    --蜂鸣器
	);
end music;

architecture music of music is

	signal state : std_logic;                    --蜂鸣器状态寄存
	signal cnt   : std_logic_vector(1 downto 0); --计数器控制铃声频率，一方面作分频器，一方面作计数器

begin
	--本次实验采用了两种频率的铃音，由于仿真软件的限制，采用真实的人耳听力范围内的频率会导致仿真时间极短，因此仅用低频铃音作为示范
	process (clk, mode)
	begin
		if (clk'event and clk = '1') then
			if (mode(0) = '1' or mode(1) = '1') then --时间/闹钟设置状态蜂鸣器休眠
				cnt   <= "00";
				state <= '0';
			elsif (mode(2) = '1' and mint = a_mint and hour = a_hour) then --闹钟匹配，将高频输入4分频得到铃音，持续一分钟或者手动关闭闹钟
				case cnt is
					when "00" =>
						cnt                <= "11";
						state              <= not state;
					when others => cnt <= cnt - 1;
				end case;
			elsif (mint = "01011001" and secd = "01011001") then --分秒均为59且未处于设置状态，时即将变化，设置整点报时计数器
				cnt <= "11";
			elsif (cnt > 0) then --整点报时，将高频输入2分频并持续两个脉冲
				cnt   <= cnt - 1;
				state <= not state;
			else --无响铃事件重置计数器和状态
				state <= '0';
			end if;
		end if;
	end process;

	buzzer <= state;
end music;