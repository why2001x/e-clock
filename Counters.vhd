LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE Counters IS

COMPONENT count_02 IS
	PORT (
		aclr, clk_en, clock: IN STD_LOGIC;
		cout: OUT STD_LOGIC;
		q: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT count_05 IS
	PORT (
		aclr, clk_en, clock: IN STD_LOGIC;
		cout: OUT STD_LOGIC;
		q: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT count_09 IS
	PORT (
		aclr, clk_en, clock: IN STD_LOGIC;
		cout: OUT STD_LOGIC;
		q: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;

END Counters;