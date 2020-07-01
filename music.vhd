LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY music IS
    PORT (
        clk : IN std_logic;
        mode : IN std_logic_vector(2 DOWNTO 0);
        hour, mint, secd, a_hour, a_mint : IN std_logic_vector(7 DOWNTO 0);
        buzzer : OUT std_logic
    );
END music;

ARCHITECTURE music OF music IS
    SIGNAL cnt : std_logic_vector(1 DOWNTO 0);
    SIGNAL state : std_logic;
BEGIN
    PROCESS (clk, mode)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (mode(0) = '1' OR mode(1) = '1') THEN
                cnt <= "00";
                state <= '0';
            ELSIF (mint = a_mint AND hour = a_hour AND mode(2) = '1') THEN
                cnt <= "00";
                state <= '1';
            ELSIF (mint = "01011001" AND secd = "01011001") THEN
                state <= '1';
                cnt <= "11";
            ELSIF (cnt > 0) THEN
                cnt <= cnt - 1;
                state <= NOT state;
            ELSE
                state <= '0';
            END IF;
        END IF;
    END PROCESS;
    buzzer <= state;
END music;