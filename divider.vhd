LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE work.Counters.ALL;

ENTITY divider IS
    PORT (
        clk_in : IN std_logic;
        clk_out : OUT std_logic
    );
END divider;

ARCHITECTURE divider OF divider IS
    SIGNAL state : std_logic;
    SIGNAL cnt : std_logic_vector(2 DOWNTO 0);
BEGIN
    PROCESS (clk_in)
    BEGIN
        IF (clk_in'event AND clk_in = '1') THEN
            CASE cnt IS
                WHEN "100" =>
                    state <= NOT state;
                    cnt <= "000";
                WHEN OTHERS => cnt <= cnt + 1;
            END CASE;
        END IF;
    END PROCESS;
    clk_out <= state;
END divider;