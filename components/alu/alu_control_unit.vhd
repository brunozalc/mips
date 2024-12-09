library ieee;
use ieee.std_logic_1164.all;

entity alu_control_unit is
    port (
        opcode : in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        r_type : in std_logic;
        alu_control : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of alu_control_unit is
    
    signal decoder_opcode_output : std_logic_vector(2 downto 0);
    signal decoder_funct_output : std_logic_vector(2 downto 0);

  begin 

    OPCODE_DECODER : entity work.opcode_decoder
        port map (
            opcode => opcode,
            output => decoder_opcode_output
        );

    FUNCT_DECODER : entity work.funct_decoder
        port map (
            funct => funct,
            output => decoder_funct_output
        );

    MUX_R_TYPE : entity work.mux2x1
		    generic map (
	            data_width => 3
        )
        port map (
            a => decoder_opcode_output,
            b => decoder_funct_output,
            selector => r_type,
            output => alu_control
        );

end architecture;
