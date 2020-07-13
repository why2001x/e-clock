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
	signal cnt_freq : std_logic_vector(3 downto 0); --频率计数器控制铃声频率
	signal cnt_len  : std_logic_vector(4 downto 0); --时长计数器控制每个音符的持续时间，保证不同频率的音符有相同的时长
	signal music    : std_logic;                    --整点报时音乐开关

begin
	--本次实验验收由于仿真时长限制，仅展示了低频音乐作为示范，报告中采用正常音符版本
	process (clk, mode)
		variable tmp : std_logic_vector(3 downto 0);
	begin
		if (clk'event and clk = '1') then
			if (mode(0) = '1' or mode(1) = '1') then --时间/闹钟设置状态蜂鸣器休眠，并保证响铃时设置音乐能及时停止
				cnt_freq <= "0000";
				state    <= '0';
				music    <= '0';
			elsif (mode(2) = '1' and mint = a_mint and hour = a_hour) then --闹钟匹配，将高频输入6分频得到铃音，持续一分钟或者手动关闭闹钟
				case cnt_freq is
					when "0000" =>
						cnt_freq                <= "0010";
						state                   <= not state;
					when others => cnt_freq <= cnt_freq - 1;
				end case;
				music <= '0';
			elsif (mint = "01011001" and secd = "01011001") then --整点报时音乐激活
				music    <= '1';
				cnt_len  <= "10111";
				cnt_freq <= "0000";
			elsif (music = '1') then --50，26，14，6，0为时长控制参数，与音符频率有关，此处为一段5hz,2.5hz,1.67hz,1.25hz的音乐--25.5,17,15,19
				if (cnt_len > 0) then
					if (cnt_len > 19) then
						tmp := "1100"; --26分频,4
					elsif (cnt_len > 13) then
						tmp := "0111"; --16分频,6
					elsif (cnt_len > 6) then
						tmp := "0110"; --14分频,7
					else
						tmp := "1000"; --18分频,6
					end if;
					case cnt_freq is
						when "0000" =>
							cnt_freq                <= tmp;
							state                   <= not state;
							cnt_len                 <= cnt_len - 1;
						when others => cnt_freq <= cnt_freq - 1;
					end case;
				else --音乐结束重置
					music    <= '0';
					cnt_freq <= "0000";
					state    <= '0';
				end if;
			else --保证铃声结束后回归初始状态
				cnt_freq <= "0000";
				state    <= '0';
			end if;
		end if;
	end process;

	buzzer <= state;
end music;