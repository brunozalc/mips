library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_msb is
    port (
        a        : in  std_logic;
        b        : in  std_logic;
        invert   : in  std_logic;
        op       : in  std_logic_vector(1 downto 0);
        cin      : in  std_logic;
        cout     : out std_logic;
        result   : out std_logic;
        overflow : out std_logic;
        set      : out std_logic    
    );
end entity;

architecture behavioral of alu_msb is
    signal b_final   : std_logic;
    signal adder_out : std_logic;
    signal ovf      : std_logic;

begin

    INVERTER : entity work.mux2x1 
        generic map (data_width => 1)
        port map(
            a(0) => b,
            b(0) => not b,
            selector => invert,
            output(0) => b_final
        );

    ADDER : entity work.adder 
        port map(
            a => a, 
            b => b_final,
            cin => cin,
            cout => cout,
            result => adder_out
        );

    ovf <= cin xor cout;
    overflow <= ovf when op = "10" else '0';
    
    set <= adder_out xor ovf;

    MUX_OP: entity work.mux4x1 
        generic map (data_width => 1)
        port map(
            a(0) => a and b_final,  -- AND 
            b(0) => a or b_final,   -- OR 
            c(0) => adder_out,      -- ADD ou SUB
            d(0) => '0',            -- SLT
            selector => op,
            output(0) => result
        );

end architecture;
