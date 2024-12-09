library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  --Soma (esta biblioteca =ieee)

entity const_incrementer is
    generic
    (
        data_width : natural := 32;
        const : natural := 4
    );
    port
    (
        input: in  STD_LOGIC_VECTOR((data_width-1) downto 0);
        output:   out STD_LOGIC_VECTOR((data_width-1) downto 0)
    );
end entity;

architecture comportamento of const_incrementer is
    begin
        output <= std_logic_vector(unsigned(input) + const);
end architecture;
