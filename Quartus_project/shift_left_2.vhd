library ieee;
use ieee.std_logic_1164.all;

entity shift_left_2 is
    port(
        din  : in  std_logic_vector(31 downto 0);
        dout : out std_logic_vector(31 downto 0)
    );
end shift_left_2;

architecture dataflow of shift_left_2 is
begin
    -- Shift left by 2:
    -- The top 30 bits come from the lower 30 bits of 'din'
    -- The lower 2 bits become '0'
    dout <= din(29 downto 0) & "00";
end dataflow;
