
library ieee;
use ieee.std_logic_1164.all;

entity funct_decoder is
    port (
        funct : in std_logic_vector(5 downto 0);
        output : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of funct_decoder is

    constant add : std_logic_vector(5 downto 0) := "100000";  -- funct
    constant sub : std_logic_vector(5 downto 0) := "100010";  -- funct
    constant andr : std_logic_vector(5 downto 0) := "100100"; -- funct
    constant orr : std_logic_vector(5 downto 0) := "100101";  -- funct
    constant slt : std_logic_vector(5 downto 0) := "101010";  -- funct
    constant jr : std_logic_vector(5 downto 0) := "001000";   -- funct

    -- sinais de controle da ULA
    -- bit 2: inverte B (ativa o carry-in do bit 0)
    -- bit 1..0: operação

    signal ula_control : std_logic_vector(2 downto 0);

    alias invert_b : std_logic is ula_control(2);
    alias operation : std_logic_vector(1 downto 0) is ula_control(1 downto 0);
    
begin

    invert_b <= '1' when (funct = sub or funct = slt) else '0';
    operation <= "00" when (funct = andr or funct = jr) else
                 "01" when (funct = orr) else
                 "10" when (funct = add or funct = sub) else
                 "11" when (funct = slt) else
                 "10";

    output <= ula_control;
    

end architecture;
