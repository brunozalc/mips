library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
    generic (data_width : natural := 8);
    port (
        a, b, c, d : in std_logic_vector((data_width-1) downto 0);
        selector : in std_logic_vector(1 downto 0);
        output : out std_logic_vector((data_width-1) downto 0)
    );
end entity;

architecture comportamento of mux4x1 is
begin

  output <= a when (selector = "00") else
                b when (selector = "01") else
                c when (selector = "10") else
                d;

end architecture;
