library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- o estágio de execução (EX) é responsável por:

-- 1. selecionar a origem dos dados para a ULA
-- 2. executar a operação aritmética ou lógica da instrução (inclusive para instruções de branch)
-- 3. selecionar o registrador de destino
-- 4. passar informações para a próxima etapa do pipeline (MEM)

entity execute is
    generic (
        data_width : natural := 32;
        address_width : natural := 32
    );
    port (
        clk : in std_logic;

        -- sinais de controle
        enable_beq : in std_logic;
        r_type : in std_logic;
        sel_mux_rt_rd : in std_logic_vector(1 downto 0);
        sel_mux_rt_imm : in std_logic;

        -- inputs do estágio ID
        pc_plus_4 : in std_logic_vector(address_width - 1 downto 0);
        opcode : in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        rt_address : in std_logic_vector(4 downto 0);
        rd_address : in std_logic_vector(4 downto 0);
        rs_data : in std_logic_vector(data_width - 1 downto 0);
        rt_data : in std_logic_vector(data_width - 1 downto 0);
        extended_imm : in std_logic_vector(data_width - 1 downto 0);

        -- outputs
        alu_out : out std_logic_vector(data_width - 1 downto 0);
        alu_zero_out : out std_logic;
        branch_target : out std_logic_vector(address_width - 1 downto 0);
        mux_beq_out : out std_logic;
        mux_rt_rd_out : out std_logic_vector(4 downto 0);
        mux_rt_imm_out : out std_logic_vector(data_width - 1 downto 0)
    );

end entity;

architecture structural of execute is

    signal mux_rt_imm_out_internal : std_logic_vector(data_width - 1 downto 0);
    signal alu_ctrl : std_logic_vector(2 downto 0);
    alias alu_ctrl_op : std_logic_vector(1 downto 0) is alu_ctrl(1 downto 0);
    alias alu_ctrl_invert : std_logic is alu_ctrl(2);
    signal alu_zero_internal : std_logic;

begin

    -- ULA ----------------------------------------------

    ALU : entity work.alu
        port map(
            a => rs_data,
            b => mux_rt_imm_out_internal,
            op => alu_ctrl_op,
            invert => alu_ctrl_invert,
            result => alu_out,
            zero => alu_zero_internal,
            overflow => open
        );

    -- UC da ULA
    ALU_CONTROL_UNIT : entity work.alu_control_unit
        port map(
            opcode => opcode,
            funct => funct,
            r_type => r_type,
            alu_control => alu_ctrl
        );
    -- MULTIPLEXADORES ----------------------------------

    -- mux do registrador de destino
    MUX_RT_RD : entity work.mux4x1
        generic map(
            data_width => 5
        )
        port map(
            a => rt_address,
            b => rd_address,
            c => "11111", -- para a instrução JAL
            d => "00000", -- não usado
            selector => sel_mux_rt_rd,
            output => mux_rt_rd_out
        );

    -- mux do RT/IMM
    MUX_RT_IMM : entity work.mux2x1
        generic map(
            data_width => data_width
        )
        port map(
            a => rt_data,
            b => extended_imm,
            selector => sel_mux_rt_imm,
            output => mux_rt_imm_out_internal
        );

    -- mux do BEQ
    MUX_BEQ : entity work.mux2x1
        generic map(
            data_width => 1
        )
        port map(
            a(0) => not(alu_zero_internal),
            b(0) => alu_zero_internal,
            selector => enable_beq,
            output(0) => mux_beq_out
        );

    -- INCREMENTADOR DE BRANCH --------------------------

    -- somador do BEQ/BNE (com shift left de 2)
    BRANCH_INCREMENTER : entity work.incrementer
        generic map(
            data_width => address_width
        )
        port map(
            input_a => pc_plus_4,
            input_b => std_logic_vector(shift_left(signed(extended_imm), 2)),
            output => branch_target
        );

    mux_rt_imm_out <= mux_rt_imm_out_internal;
    alu_zero_out <= alu_zero_internal;


end architecture;
