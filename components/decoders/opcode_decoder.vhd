library ieee;
use ieee.std_logic_1164.all;

entity opcode_decoder is
    port (
        opcode : in std_logic_vector(5 downto 0);
        output : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of opcode_decoder is

    constant lw : std_logic_vector(5 downto 0) := "100011";   -- opcode
    constant sw : std_logic_vector(5 downto 0) := "101011";   -- opcode
    constant beq : std_logic_vector(5 downto 0) := "000100";  -- opcode
    constant j : std_logic_vector(5 downto 0) := "000010";    -- opcode
    constant lui : std_logic_vector(5 downto 0) := "001111";  -- opcode
    constant addi : std_logic_vector(5 downto 0) := "001000"; -- opcode
    constant andi : std_logic_vector(5 downto 0) := "001100"; -- opcode
    constant ori : std_logic_vector(5 downto 0) := "001101";  -- opcode
    constant slti : std_logic_vector(5 downto 0) := "001010"; -- opcode
    constant bne : std_logic_vector(5 downto 0) := "000101";  -- opcode
    constant jal : std_logic_vector(5 downto 0) := "000011";  -- opcode

    -- sinais de controle da ULA
    -- bit 2: inverte B (ativa o carry-in do bit 0)
    -- bit 1..0: operação

    signal ula_control : std_logic_vector(2 downto 0);

    alias invert_b : std_logic is ula_control(2);
    alias operation : std_logic_vector(1 downto 0) is ula_control(1 downto 0);

begin

    invert_b <= '1' when (opcode = beq or opcode = bne or opcode = slti) else '0';
    operation <= "00" when (opcode = andi or opcode = j or opcode = jal) else
                 "01" when (opcode = ori) else
                 "11" when (opcode = slti) else
                 "10";

    output <= ula_control;

end architecture;
