library ieee;
use ieee.std_logic_1164.all;

entity signal_extender is
    generic
    (
        data_in_width : natural  :=    16;
        data_out_width   : natural  :=    32
    );
    port
    (
        -- Input ports
        signal_in : in  std_logic_vector(data_in_width-1 downto 0);
        -- Output ports
        signal_out: out std_logic_vector(data_out_width-1 downto 0)
    );
end entity;

architecture comportamento of signal_extender is
begin

    signal_out <= (data_out_width-1 downto data_in_width => signal_in(data_in_width-1)) & signal_in;

end architecture;
