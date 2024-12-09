library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- o estágio de leitura à memória (MEM) é responsável por:

-- 1. acessar a memória de dados (RAM) para leitura ou escrita
-- 2. passar informações para a próxima etapa do pipeline (WB)
-- 3. abrigar sequência final da lógica de branch

entity memory is
    generic (
        data_width : natural := 32;
        address_width : natural := 32
    );
    port (
        clk : in std_logic;

        -- sinais de controle
        enable_mem_rd : in std_logic;
        enable_mem_wr : in std_logic;

        -- entradas
        alu_result : in std_logic_vector(data_width - 1 downto 0);
        rt_data : in std_logic_vector(data_width - 1 downto 0);

        -- saídas
        ram_out : out std_logic_vector(data_width - 1 downto 0)
    );

end entity;

architecture structural of memory is


begin

    -- RAM ---------------------------------------------------------

    RAM : entity work.ram
        generic map(
            data_width => data_width,
            addr_width => address_width
        )
        port map(
            clk => clk,
            enable => '1',
            address => alu_result,
            data_in => rt_data,
            we => enable_mem_wr,
            re => enable_mem_rd,
            data_out => ram_out
        );

end architecture;
