LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sign_extender_16to32 IS
    PORT(
        input_16  : IN  std_logic_vector(15 DOWNTO 0);  -- 16-bit input
        output_32 : OUT std_logic_vector(31 DOWNTO 0)  -- 32-bit output
    );
END sign_extender_16to32;

ARCHITECTURE structural OF sign_extender_16to32 IS
BEGIN
    -- Copy input bits directly
    output_32(15 DOWNTO 0) <= input_16;
    
    -- Extend sign bit (MSB of input_16) to the upper 16 bits
    output_32(31 DOWNTO 16) <= (OTHERS => input_16(15));
END structural;
