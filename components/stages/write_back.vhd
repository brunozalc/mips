library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- o estágio de escrita (WB) é responsável por:

-- 1. escrever o resultado da ALU ou o dado lido na memória no banco de registradores
-- 2. passar informações para a etapa ID do pipeline

entity write_back is
    generic (
        data_width : natural := 32;
        address_width : natural := 32
    );
    port (
        clk : in std_logic;

        -- sinais de controle
        sel_mux_ula_mem : in std_logic_vector(1 downto 0);

        -- entradas
        alu_result : in std_logic_vector(data_width - 1 downto 0);
        ram_data : in std_logic_vector(data_width - 1 downto 0);
        pc_plus_4 : in std_logic_vector(data_width - 1 downto 0);
        lui_imm : in std_logic_vector(data_width - 1 downto 0);

        -- saídas
        write_data : out std_logic_vector(data_width - 1 downto 0)
    );

end entity;

architecture structural of write_back is

begin
    -- MUX DE ESCRITA ---------------------------------------------------------

    MUX_ULA_MEM : entity work.mux4x1
        generic map(
            data_width => data_width
        )
        port map(
            a => alu_result,
            b => ram_data,
            c => pc_plus_4,
            d => lui_imm,
            selector => sel_mux_ula_mem,
            output => write_data
        );

end architecture;
