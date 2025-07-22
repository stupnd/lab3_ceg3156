library ieee;
use ieee.std_logic_1164.all;

entity shift_left_2_26_to_28 is
    port(
        din  : in  std_logic_vector(25 downto 0);
        dout : out std_logic_vector(27 downto 0)
    );
end shift_left_2_26_to_28;

architecture dataflow of shift_left_2_26_to_28 is
begin
    dout <= din(25 downto 0) & "00";
end dataflow;
