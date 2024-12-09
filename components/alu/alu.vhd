library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        op       : in  std_logic_vector(1 downto 0);
        invert   : in  std_logic;
        result   : out std_logic_vector(31 downto 0);
        zero     : out std_logic;
        overflow : out std_logic
    );
end entity;

architecture structural of alu is

    -- valores de carry entre as partes
    signal carry_chain : std_logic_vector(31 downto 0);

    -- sinal de propagação do SLT
    signal set_signal  : std_logic;

begin

    -- valor inicial do carry
    -- configuramos para o valor da flag de inversão: A - B = A + (-B) = A + not B + 1
    carry_chain(0) <= invert;

    LSB: entity work.alu_bit
        port map (
            a      => a(0),
            b      => b(0),
            invert => invert,
            op     => op,
            slt    => set_signal,
            cin    => carry_chain(0),
            cout   => carry_chain(1),
            result => result(0)
        );


    OTHER_BITS: for i in 1 to 30 generate
        ALU_BIT: entity work.alu_bit
            port map (
                a      => a(i),
                b      => b(i),
                invert => invert,
                op     => op,
                slt    => '0', 
                cin    => carry_chain(i),
                cout   => carry_chain(i+1),
                result => result(i)
            );
    end generate;

    MSB: entity work.alu_msb
        port map (
            a        => a(31),
            b        => b(31),
            invert   => invert,
            op       => op,
            cin      => carry_chain(30),
            cout     => open,  
            result   => result(31),
            overflow => overflow,
            set      => set_signal       
        );

    -- saída da flag zero, quando todos os 32 bits são zero
    zero <= '1' when result = x"00000000" else '0';

end architecture;
