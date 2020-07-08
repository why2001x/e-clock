library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.all;

entity count_05 is
	port (
		aclr   : in STD_LOGIC;
		clk_en : in STD_LOGIC;
		clock  : in STD_LOGIC;
		cout   : out STD_LOGIC;
		q      : out STD_LOGIC_VECTOR (2 downto 0)
	);
end count_05;
architecture SYN of count_05 is

	signal sub_wire0 : STD_LOGIC;
	signal sub_wire1 : STD_LOGIC_VECTOR (2 downto 0);

	component lpm_counter
		generic (
			lpm_direction   : STRING;
			lpm_modulus     : NATURAL;
			lpm_port_updown : STRING;
			lpm_type        : STRING;
			lpm_width       : NATURAL
		);
		port (
			aclr   : in STD_LOGIC;
			clk_en : in STD_LOGIC;
			clock  : in STD_LOGIC;
			cout   : out STD_LOGIC;
			q      : out STD_LOGIC_VECTOR (2 downto 0)
		);
	end component;

begin
	cout <= sub_wire0;
	q    <= sub_wire1(2 downto 0);

	LPM_COUNTER_component : LPM_COUNTER
	generic map(
		lpm_direction   => "UP",
		lpm_modulus     => 6,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type        => "LPM_COUNTER",
		lpm_width       => 3
	)
	port map(
		aclr   => aclr,
		clk_en => clk_en,
		clock  => clock,
		cout   => sub_wire0,
		q      => sub_wire1
	);

end SYN;