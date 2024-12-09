library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Baseado no apendice C (Register Files) do COD (Patterson & Hennessy).

entity regular_reg_file is
    generic (
        data_width : natural := 32;
        file_address_width : natural := 5 --Resulta em 2^5=32 posicoes
    );
    -- Leitura de 2 registradores e escrita em 1 registrador simultaneamente.
    port (
        clk : in std_logic;
        --
        address_1 : in std_logic_vector((file_address_width - 1) downto 0);
        address_2 : in std_logic_vector((file_address_width - 1) downto 0);
        address_3 : in std_logic_vector((file_address_width - 1) downto 0);
        --
        write_data_3 : in std_logic_vector((data_width - 1) downto 0);
        --
        enable_write_3 : in std_logic := '0';
        output_1 : out std_logic_vector((data_width - 1) downto 0);
        output_2 : out std_logic_vector((data_width - 1) downto 0)
    );
end entity;

architecture comportamento of regular_reg_file is

    subtype palavra_t is std_logic_vector((data_width - 1) downto 0);
    type memoria_t is array(2 ** file_address_width - 1 downto 0) of palavra_t;

    function initMemory
        return memoria_t is variable tmp : memoria_t := (others => (others => '0'));
    begin
        -- Inicializa os endereços:
        tmp(0) := x"AAAAAAAA"; -- Nao deve ter efeito.
        tmp(8) := 32x"00"; -- $t0 = 0x00
        tmp(9) := 32x"0A"; -- $t1 = 0x0A
        tmp(10) := 32x"0B"; -- $t2 = 0x0B
        tmp(11) := 32x"0C"; -- $t3 = 0x0C
        tmp(12) := 32x"0D"; -- $t4 = 0x0D
        tmp(13) := 32x"16"; -- $t5 = 0x16
        return tmp;
    end initMemory;

    -- Declaracao dos registradores:
    shared variable registrador : memoria_t := initMemory;
    constant zero : std_logic_vector(data_width - 1 downto 0) := (others => '0');

begin

    process (clk) is
    begin
        if (rising_edge(clk)) then
            if (enable_write_3 = '1') then
                registrador(to_integer(unsigned(address_3))) := write_data_3;
            end if;
        end if;
    end process;

    -- IF endereco = 0 : retorna ZERO
    output_2 <= zero when to_integer(unsigned(address_2)) = to_integer(unsigned(zero)) else
        registrador(to_integer(unsigned(address_2)));
    output_1 <= zero when to_integer(unsigned(address_1)) = to_integer(unsigned(zero)) else
        registrador(to_integer(unsigned(address_1)));

end architecture;
