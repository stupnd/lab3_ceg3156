LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux8to1_8bit IS
    PORT(
        i0, i1, i2, i3, i4, i5, i6, i7 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        s                              : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        o_data                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END mux8to1_8bit;

ARCHITECTURE struct OF mux8to1_8bit IS
BEGIN
    WITH s SELECT
        o_data <= i0 WHEN "000",
                  i1 WHEN "001",
                  i2 WHEN "010",
                  i3 WHEN "011",
                  i4 WHEN "100",
                  i5 WHEN "101",
                  i6 WHEN "110",
                  i7 WHEN "111",
                  (others => '0') WHEN OTHERS; -- Optional default case for safety
END struct;
