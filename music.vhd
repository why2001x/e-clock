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

	signal state    : std_logic;                    --蜂鸣器状态寄存
	signal cnt_freq : std_logic_vector(1 downto 0); --频率计数器控制铃声频率
	signal cnt_len  : std_logic_vector(5 downto 0); --时长计数器控制每个音符的持续时间，保证不同频率的音符有相同的时长
	signal music    : std_logic;                    --整点报时音乐开关

begin
	--本次实验采用了两种频率的铃音，由于仿真软件的限制，采用真实的人耳听力范围内的频率会导致仿真时间极短，因此仅用低频铃音作为示范
	process (clk, mode)
		variable tmp : std_logic_vector(1 downto 0);
	begin
		if (clk'event and clk = '1') then
			if (mode(0) = '1' or mode(1) = '1') then --时间/闹钟设置状态蜂鸣器休眠
				cnt_freq <= "00";
				state    <= '0';
				music    <= '0';
			elsif (mode(2) = '1' and mint = a_mint and hour = a_hour) then --闹钟匹配，将高频输入6分频得到铃音，持续一分钟或者手动关闭闹钟
				case cnt_freq is
					when "00" =>
						cnt_freq                <= "10";
						state                   <= not state;
					when others => cnt_freq <= cnt_freq - 1;
				end case;
				music <= '0';
			elsif (mint = "01011001" and secd = "01011001") then
				music    <= '1';
				cnt_len  <= "110010";
				cnt_freq <= "01";
			elsif (music = '1') then --50，26，14，6，0为时长控制参数，与音符频率有关
				if (cnt_len > 0) then
					if (cnt_len > 26) then
						tmp := "00"; --2分频
					elsif (cnt_len > 14) then
						tmp := "01"; --4分频
					elsif (cnt_len > 6) then
						tmp := "10"; --6分频
					else
						tmp := "11"; --8分频
					end if;
					case cnt_freq is
						when "00" =>
							cnt_freq                <= tmp;
							state                   <= not state;
							cnt_len                 <= cnt_len - 1;
						when others => cnt_freq <= cnt_freq - 1;
					end case;
				else --音乐结束重置
					music    <= '0';
					cnt_freq <= "00";
					state    <= '0';
				end if;
			else
				cnt_freq <= "00";
				state    <= '0';
			end if;
		end if;
	end process;

	buzzer <= state;
end music;
