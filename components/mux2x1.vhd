library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is
  -- Total de bits das entradas e saidas
  generic ( data_width : natural := 4);
  port (
    a, b : in std_logic_vector((data_width-1) downto 0);
    selector : in std_logic;
    output : out std_logic_vector((data_width-1) downto 0)
  );

end entity;

architecture comportamento of mux2x1 is
  begin

    output <= a when selector = '0' else
                  b;

  end architecture;
