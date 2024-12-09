library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    generic (
        data_width : natural := 32;
        address_width : natural := 32;
        test_type : character := 'A'
    );
    port (
        clk : in std_logic;

        -- sinais de controle
        enable_jr : in std_logic;
        sel_mux_pc4 : in std_logic;
        enable_beq : in std_logic;
        enable_bne : in std_logic;

        -- inputs
        rs_data : in std_logic_vector(address_width - 1 downto 0);
        mux_beq_out : in std_logic;
        branch_target : in std_logic_vector(address_width - 1 downto 0);
        jump_address : in std_logic_vector(25 downto 0);

        -- saída para análise
        pc_out : out std_logic_vector(address_width - 1 downto 0);

        -- outputs para o registrador IF/ID
        instruction_out : out std_logic_vector(data_width - 1 downto 0);
        pc_plus_4_out : out std_logic_vector(address_width - 1 downto 0)
    );

end entity;

architecture structural of fetch is
    signal current_pc : std_logic_vector(address_width - 1 downto 0);
    signal pc_plus_4 : std_logic_vector(address_width - 1 downto 0);
    signal mux_pc_out : std_logic_vector(address_width - 1 downto 0);
    signal mux_pc4_out : std_logic_vector(address_width - 1 downto 0);
    signal mux_branch_out : std_logic_vector(address_width - 1 downto 0);
    signal jump_target : std_logic_vector(address_width - 1 downto 0);
    signal branch_taken : std_logic;

begin

    jump_target <= pc_plus_4(31 downto 28) & jump_address & "00";
    branch_taken <= mux_beq_out and (enable_beq or enable_bne);

    -- COMPONENTES PRINCIPAIS ----------------------------------------------

    -- PC (program counter)
    PC : entity work.generic_register
        generic map(
            data_width => address_width -- instruções têm 32 bits
        )
        port map(
            DIN => mux_pc_out,
            DOUT => current_pc,
            ENABLE => '1',
            CLK => clk,
            RST => '0'
        );

    -- ROM
    ROM : entity work.rom
        generic map(
            test_type => test_type
        )
        port map(
            address => current_pc,
            data => instruction_out
        );

    -- MULTIPLEXADORES ----------------------------------------------------

    -- mux do branch
    MUX_BRANCH : entity work.mux2x1
        generic map(
            data_width => address_width
        )
        port map(
            a => pc_plus_4,
            b => branch_target,
            selector => branch_taken,
            output => mux_branch_out
        );

    -- mux do JUMP
    MUX_PC4 : entity work.mux2x1
        generic map(
            data_width => address_width
        )
        port map(
            a => mux_branch_out,
            b => jump_target,
            selector => sel_mux_pc4,
            output => mux_pc4_out
        );

    -- mux do PC
    MUX_PC : entity work.mux2x1
        generic map(
            data_width => address_width
        )
        port map(
            a => mux_pc4_out,
            b => rs_data,
            selector => enable_jr,
            output => mux_pc_out
        );

    -- SOMADORES ----------------------------------------------------------

    -- somador do PC
    PC_INCREMENTER : entity work.const_incrementer
        generic map(
            data_width => address_width,
            const => 4
        )
        port map(
            input => current_pc,
            output => pc_plus_4
        );

    pc_out <= current_pc;
    pc_plus_4_out <= pc_plus_4;
end architecture;
