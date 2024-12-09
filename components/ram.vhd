library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram IS
   generic (
          data_width: natural := 32;
          addr_width: natural := 32;
          memory_addr_width:  natural := 6 );   -- 64 posicoes de 32 bits cada
   port ( clk      : IN  STD_LOGIC;
          address : IN  STD_LOGIC_VECTOR (addr_width-1 DOWNTO 0);
          data_in  : in std_logic_vector(data_width-1 downto 0);
          data_out : out std_logic_vector(data_width-1 downto 0);
          we, re, enable : in std_logic
        );
end entity;

architecture assincrona OF ram IS
  type blocoMemoria IS ARRAY(0 TO 2**memory_addr_width - 1) OF std_logic_vector(data_width-1 DOWNTO 0);

  signal memRAM: blocoMemoria;
--  Caso queira inicializar a RAM (para testes):
--  attribute ram_init_file : string;
--  attribute ram_init_file of memRAM:
--  signal is "RAMcontent.mif";

-- Utiliza uma quantidade menor de endereços locais:
   signal local_address : std_logic_vector(memory_addr_width-1 downto 0);

begin

  -- Ajusta o enderecamento para o acesso de 32 bits.
  local_address <= address(memory_addr_width+1 downto 2);

  process(clk)
  begin
      if(rising_edge(clk)) then
          if(we = '1' and enable='1') then
              memRAM(to_integer(unsigned(local_address))) <= data_in;
          end if;
      end if;
  end process;

  -- A leitura deve ser sempre assincrona:
  data_out <= memRAM(to_integer(unsigned(local_address))) when (re = '1' and enable='1') else (others => 'Z');

end architecture;
