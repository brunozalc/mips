library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    generic (
        data_width : natural := 32;
        addr_width : natural := 32;
        memoryAddrWidth : natural := 6; -- 64 posicoes de 32 bits cada
        test_type : character := 'A'
    );
    port (
        address : in std_logic_vector (addr_width - 1 downto 0);
        data : out std_logic_vector (data_width - 1 downto 0)
    );
end entity;

architecture assincrona of rom is
    -- função para escolher o arquivo mif de acordo com o tipo de teste
    function get_mif_file(test_type : character) return string is
    begin
        case test_type is
            when 'A' => return "teste_pipeline_a.mif";
            when 'B' => return "teste_pipeline_b.mif";
            when others => return "teste_pipeline_a.mif";
        end case;
    end function;

    type blocoMemoria is array(0 to 2 ** memoryAddrWidth - 1) of std_logic_vector(data_width - 1 downto 0);

    signal memROM : blocoMemoria;
    attribute ram_init_file : string;
    attribute ram_init_file of memROM : signal is get_mif_file(test_type);

    -- Utiliza uma quantidade menor de endereços locais:
    signal EnderecoLocal : std_logic_vector(memoryAddrWidth - 1 downto 0);

begin
    EnderecoLocal <= address(memoryAddrWidth + 1 downto 2);
    data <= memROM (to_integer(unsigned(EnderecoLocal)));
end architecture;
