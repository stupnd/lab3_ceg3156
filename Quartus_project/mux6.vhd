LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux6 IS
    PORT(
        sel : IN  std_logic;       -- Select signal
        a   : IN  std_logic_vector(5 DOWNTO 0);  -- Data input 0 (5-bit)
        b   : IN  std_logic_vector(5 DOWNTO 0);  -- Data input 1 (5-bit)
        y   : OUT std_logic_vector(5 DOWNTO 0)   -- Multiplexer output (5-bit)
    );
END mux6;

ARCHITECTURE structural OF mux6 IS
    COMPONENT mux2
        PORT(
            sel : IN  std_logic;
            a   : IN  std_logic;
            b   : IN  std_logic;
            y   : OUT std_logic
        );
    END COMPONENT;
BEGIN
    -- Instantiate 5 single-bit 2:1 multiplexers
    gen_mux: FOR i IN 0 TO 5 GENERATE
        mux_inst : mux2 PORT MAP(
            sel => sel,
            a   => a(i),
            b   => b(i),
            y   => y(i)
        );
    END GENERATE gen_mux;
END structural;
