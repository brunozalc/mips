library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- o estágio de decodificação (ID) é responsável por:

-- 1. decodificar a instrução recebida do estágio IF
-- 2. ler dados do registrador, se necessário
-- 3. gerar os sinais de controle para os próximos estágios
-- 4. estender o sinal de imediato, se necessário
-- 5. passar informações para a próxima etapa do pipeline (EX)

entity decode is
    generic (
        data_width : natural := 32;
        address_width : natural := 32;
        test_type : character := 'A'
    );
    port (

        clk : in std_logic;

        -- inputs do estágio IF
        instruction : in std_logic_vector(data_width - 1 downto 0);

        -- inputs do estágio WB
        write_address : in std_logic_vector(4 downto 0);
        write_data : in std_logic_vector(data_width - 1 downto 0);
        enable_reg : in std_logic;

        -- outputs
        control_word : out std_logic_vector(13 downto 0);
        opcode : out std_logic_vector(5 downto 0);
        funct : out std_logic_vector(5 downto 0);
        rs_data : out std_logic_vector(data_width - 1 downto 0);
        rt_data : out std_logic_vector(data_width - 1 downto 0);
        rd_address : out std_logic_vector(4 downto 0);
        rt_address : out std_logic_vector(4 downto 0);
        extended_imm : out std_logic_vector(data_width - 1 downto 0);
        lui_imm : out std_logic_vector(data_width - 1 downto 0)
    );

end entity;

architecture structural of decode is

    signal control_word_internal : std_logic_vector(13 downto 0);

    alias opcode_inst : std_logic_vector(5 downto 0) is instruction(31 downto 26);
    alias rs_inst : std_logic_vector(4 downto 0) is instruction(25 downto 21);
    alias rt_inst : std_logic_vector(4 downto 0) is instruction(20 downto 16);
    alias rd_inst : std_logic_vector(4 downto 0) is instruction(15 downto 11);
    alias funct_inst : std_logic_vector(5 downto 0) is instruction(5 downto 0);
    alias imm_inst : std_logic_vector(15 downto 0) is instruction(15 downto 0);

begin

    -- BANCO DE REGISTRADORES ----------------------------------------------

    REGFILE_CHOICE : if test_type = 'A' generate
            -- banco de registradores regular (rising edge)
            REG_FILE : entity work.regular_reg_file
                port map(
                    clk => clk,
                    address_1 => rs_inst,
                    address_2 => rt_inst,
                    address_3 => write_address, -- do estágio WB
                    write_data_3 => write_data, -- do estágio WB
                    enable_write_3 => enable_reg, -- do estágio WB
                    output_1 => rs_data,
                    output_2 => rt_data
                );
    elsif test_type = 'B' generate
            -- banco de registradores explícito -> usar para teste do grupo B
            REG_FILE : entity work.explicit_reg_file
                port map(
                    clk => clk,
                    enderecoA => rs_inst,
                    enderecoB => rt_inst,
                    enderecoC => write_address, -- do estágio WB
                    dadoEscritaC => write_data, -- do estágio WB
                    escreveC => enable_reg, -- do estágio WB
                    saidaA => rs_data,
                    saidaB => rt_data
                );
        end generate;

        -- UNIDADE DE CONTROLE ----------------------------------------------

        DATA_FLOW_CONTROL_UNIT : entity work.data_flow_control_unit
            port map(
                opcode => opcode_inst,
                funct => funct_inst,
                output => control_word_internal
            );

        -- EXTENSOR DE SINAL -----------------------------------------------------------

        SIGNAL_EXTENDER : entity work.mux2x1
            generic map(
                data_width => data_width
            )
            port map(
                a => (data_width - 1 downto 16 => imm_inst(15)) & imm_inst, -- extensão de sinal
                b => x"0000" & imm_inst, -- extensão de zero
                selector => control_word_internal(9), -- ori/andi, da palavra de controle
                output => extended_imm
            );

        lui_imm <= imm_inst & x"0000"; -- lui: move imediato para os 16 bits mais significativos

        -- outputs
        control_word <= control_word_internal;
        opcode <= opcode_inst;
        funct <= funct_inst;
        rd_address <= rd_inst;
        rt_address <= rt_inst;

    end architecture;
