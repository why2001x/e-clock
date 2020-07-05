LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY lpm;
USE lpm.ALL;

ENTITY count_09 IS
	PORT (
		aclr : IN STD_LOGIC;
		clk_en : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		cout : OUT STD_LOGIC;
		q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END count_09;
ARCHITECTURE SYN OF count_09 IS

	SIGNAL sub_wire0 : STD_LOGIC;
	SIGNAL sub_wire1 : STD_LOGIC_VECTOR (3 DOWNTO 0);

	COMPONENT lpm_counter
		GENERIC (
			lpm_direction : STRING;
			lpm_modulus : NATURAL;
			lpm_port_updown : STRING;
			lpm_type : STRING;
			lpm_width : NATURAL
		);
		PORT (
			aclr : IN STD_LOGIC;
			clk_en : IN STD_LOGIC;
			clock : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	cout <= sub_wire0;
	q <= sub_wire1(3 DOWNTO 0);

	LPM_COUNTER_component : LPM_COUNTER
	GENERIC MAP(
		lpm_direction => "UP",
		lpm_modulus => 10,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 4
	)
	PORT MAP(
		aclr => aclr,
		clk_en => clk_en,
		clock => clock,
		cout => sub_wire0,
		q => sub_wire1
	);

END SYN;
