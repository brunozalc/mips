library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_model is
  generic   (
    data_width_in 	: natural :=  4;
    data_width_out  : natural :=  7
  );

  port   (
    data_in  : in  std_logic_vector(data_width_in-1 downto 0);
    clk     : in  std_logic;
    display_out : out  std_logic_vector(data_width_out-1 downto 0)
    
  );
end entity;

architecture arch_name of hex_model is

begin
							
HEX :  entity work.hex_converter
			port map(	dadoHex 			=> data_in,
							apaga 			=> '0',
							negativo 		=> '0',
							overFlow 		=> '0',
							saida7seg 		=> display_out
						);

end architecture;
