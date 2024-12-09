
library ieee;
use ieee.std_logic_1164.all;

entity mux2x1_bit is
  -- Total de bits das entradas e saidas
  port (
    a, b : in std_logic;
    selector : in std_logic;
    output : out std_logic
  );

end entity;

architecture comportamento of mux2x1_bit is
  begin

    output <= a when selector = '0' else
                  b;

  end architecture;
