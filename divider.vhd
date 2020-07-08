library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity divider is
	port (
		clk_in  : in std_logic; --高频输入
		clk_out : out std_logic --低频输出
	);
end divider;

architecture divider of divider is

	signal cnt   : std_logic_vector(2 downto 0); --分频计数器
	signal state : std_logic;                    --脉冲状态寄存

begin
	process (clk_in)
	begin
		if (clk_in'event and clk_in = '1') then
			case cnt is
				when "100" => --(4+1)*2=10分频
					state              <= not state;
					cnt                <= "000";
				when others => cnt <= cnt + 1;
			end case;
		end if;
	end process;

	clk_out <= state;
end divider;