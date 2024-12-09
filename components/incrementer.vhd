library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;          -- Biblioteca IEEE para funções aritméticas

entity incrementer is
    generic
    (
        data_width : natural := 32
    );
    port
    (
        input_a, input_b: in STD_LOGIC_VECTOR((data_width-1) downto 0);
        output:  out STD_LOGIC_VECTOR((data_width-1) downto 0)
    );
end entity;

architecture comportamento of incrementer is
    begin
        output <= STD_LOGIC_VECTOR(unsigned(input_a) + unsigned(input_b));
end architecture;
