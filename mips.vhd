library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline.all;

entity mips is
    generic (
        data_width : natural := 32;
        address_width : natural := 32;
        simulate : boolean := FALSE;
        test_type : character := 'B' -- A ou B, para escolher o tipo de teste
    );
    port (
        CLOCK_50 : in std_logic;
        FPGA_RESET_N : in std_logic;
        KEY : in std_logic_vector(3 downto 0);
        SW : in std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );

end entity;

architecture structural of mips is
    signal clk, reset : std_logic;

    -- sinais para os registradores do pipeline
    signal if_id_in, if_id_out : if_id_io;
    signal id_ex_in, id_ex_out : id_ex_io;
    signal ex_mem_in, ex_mem_out : ex_mem_io;
    signal mem_wb_in, mem_wb_out : mem_wb_io;

    signal if_id_out_vector : std_logic_vector(IF_ID_WIDTH - 1 downto 0);
    signal id_ex_out_vector : std_logic_vector(ID_EX_WIDTH - 1 downto 0);
    signal ex_mem_out_vector : std_logic_vector(EX_MEM_WIDTH - 1 downto 0);
    signal mem_wb_out_vector : std_logic_vector(MEM_WB_WIDTH - 1 downto 0);

    -- sinais internos
    signal pc_out : std_logic_vector(address_width - 1 downto 0);
    signal write_data : std_logic_vector(data_width - 1 downto 0);

    -- output para os LEDs e HEXs
    signal led_hex_output : std_logic_vector(31 downto 0);

begin

    -- geração do clock (no botão KEY0)
    clock_generation : if simulate generate
        clk <= CLOCK_50; --  na simulação, clock é o sinal CLOCK_50
        reset <= '0';
    else
        generate
            detector_key0 : work.edgeDetector(bordaSubida)
            port map(
                clk => CLOCK_50,
                entrada => (not KEY(0)),
                saida => clk
            );

            detector_reset : work.edgeDetector(bordaSubida)
            port map(
                clk => reset,
                entrada => (not FPGA_RESET_N),
                saida => reset
            );

        end generate;

        -- INSTRUCTION FETCH (IF) ----------------------------------------------

        IF_STAGE : entity work.fetch
            generic map(
                test_type => test_type
            )
            port map(
                clk => clk,

                -- sinais de controle
                enable_jr => id_ex_in.control_word(13),
                sel_mux_pc4 => id_ex_in.control_word(12),
                enable_beq => ex_mem_out.enable_beq,
                enable_bne => ex_mem_out.enable_bne,

                -- inputs
                rs_data => id_ex_in.rs_data,
                mux_beq_out => ex_mem_out.mux_beq_out,
                branch_target => ex_mem_out.branch_target,
                jump_address => if_id_out.instruction(25 downto 0),

                -- saída para análise
                pc_out => pc_out,

                -- saídas para o registrador IF/ID
                instruction_out => if_id_in.instruction,
                pc_plus_4_out => if_id_in.pc_plus_4
            );

        -- REGISTRADOR IF/ID ----------------------------------------------

        IF_ID : entity work.generic_register
            generic map(
                data_width => IF_ID_WIDTH
            )
            port map(
                DIN => if_id_to_vector(if_id_in),
                DOUT => if_id_out_vector,
                ENABLE => '1',
                CLK => clk,
                RST => reset
            );

        if_id_out <= vector_to_if_id(if_id_out_vector);

        -- INSTRUCTION DECODE (ID) ----------------------------------------------

        ID_STAGE : entity work.decode
            generic map(
                test_type => test_type
            )
            port map(
                clk => clk,

                -- entradas do registrador IF/ID
                instruction => if_id_out.instruction,

                -- entradas do estágio WB
                write_address => mem_wb_out.write_register,
                write_data => write_data,
                enable_reg => mem_wb_out.enable_reg,

                -- saídas para o registrador ID/EX
                control_word => id_ex_in.control_word,
                opcode => id_ex_in.opcode,
                funct => id_ex_in.funct,
                rs_data => id_ex_in.rs_data,
                rt_data => id_ex_in.rt_data,
                rd_address => id_ex_in.rd_address,
                rt_address => id_ex_in.rt_address,
                extended_imm => id_ex_in.extended_imm,
                lui_imm => id_ex_in.lui_imm
            );

        -- REGISTRADOR ID/EX ----------------------------------------------

        id_ex_in.pc_plus_4 <= if_id_out.pc_plus_4;

        ID_EX : entity work.generic_register
            generic map(
                data_width => ID_EX_WIDTH
            )
            port map(
                DIN => id_ex_to_vector(id_ex_in),
                DOUT => id_ex_out_vector,
                ENABLE => '1',
                CLK => clk,
                RST => reset
            );

        id_ex_out <= vector_to_id_ex(id_ex_out_vector);

        -- EXECUTE (EX)     ----------------------------------------------

        EX_STAGE : entity work.execute
            port map(
                clk => clk,

                -- sinais de controle
                enable_beq => id_ex_out.control_word(3),
                r_type => id_ex_out.control_word(6),
                sel_mux_rt_rd => id_ex_out.control_word(11 downto 10),
                sel_mux_rt_imm => id_ex_out.control_word(7),

                -- inputs do estágio ID
                pc_plus_4 => id_ex_out.pc_plus_4,
                opcode => id_ex_out.opcode,
                funct => id_ex_out.funct,
                rt_address => id_ex_out.rt_address,
                rd_address => id_ex_out.rd_address,
                rs_data => id_ex_out.rs_data,
                rt_data => id_ex_out.rt_data,
                extended_imm => id_ex_out.extended_imm,

                -- outputs
                alu_out => ex_mem_in.alu_out,
                alu_zero_out => ex_mem_in.alu_zero,
                branch_target => ex_mem_in.branch_target,
                mux_beq_out => ex_mem_in.mux_beq_out,
                mux_rt_rd_out => ex_mem_in.mux_rt_rd_out,
                mux_rt_imm_out => ex_mem_in.mux_rt_imm_out
            );

        -- REGISTRADOR EX/MEM ----------------------------------------------

        ex_mem_in.pc_plus_4 <= id_ex_out.pc_plus_4;
        ex_mem_in.rt_data <= id_ex_out.rt_data;
        ex_mem_in.lui_imm <= id_ex_out.lui_imm;
        ex_mem_in.enable_reg <= id_ex_out.control_word(8);
        ex_mem_in.sel_mux_ula_mem <= id_ex_out.control_word(5 downto 4);
        ex_mem_in.enable_beq <= id_ex_out.control_word(3);
        ex_mem_in.enable_bne <= id_ex_out.control_word(2);
        ex_mem_in.enable_mem_read <= id_ex_out.control_word(1);
        ex_mem_in.enable_mem_write <= id_ex_out.control_word(0);

        EX_MEM : entity work.generic_register
            generic map(
                data_width => EX_MEM_WIDTH
            )
            port map(
                DIN => ex_mem_to_vector(ex_mem_in),
                DOUT => ex_mem_out_vector,
                ENABLE => '1',
                CLK => clk,
                RST => reset
            );

        ex_mem_out <= vector_to_ex_mem(ex_mem_out_vector);

        -- MEMORY ACCESS (MEM) ----------------------------------------------

        MEM_STAGE : entity work.memory
            port map(
                clk => clk,

                -- sinais de controle
                enable_mem_rd => ex_mem_out.enable_mem_read,
                enable_mem_wr => ex_mem_out.enable_mem_write,

                -- entradas
                alu_result => ex_mem_out.alu_out,
                rt_data => ex_mem_out.rt_data,

                -- saídas
                ram_out => mem_wb_in.ram_out
            );

        -- REGISTRADOR MEM/WB ----------------------------------------------

        mem_wb_in.pc_plus_4 <= ex_mem_out.pc_plus_4;
        mem_wb_in.lui_imm <= ex_mem_out.lui_imm;
        mem_wb_in.alu_out <= ex_mem_out.alu_out;
        mem_wb_in.write_register <= ex_mem_out.mux_rt_rd_out;
        mem_wb_in.sel_mux_ula_mem <= ex_mem_out.sel_mux_ula_mem;
        mem_wb_in.enable_reg <= ex_mem_out.enable_reg;

        MEM_WB : entity work.generic_register
            generic map(
                data_width => MEM_WB_WIDTH
            )
            port map(
                DIN => mem_wb_to_vector(mem_wb_in),
                DOUT => mem_wb_out_vector,
                ENABLE => '1',
                CLK => clk,
                RST => reset
            );

        mem_wb_out <= vector_to_mem_wb(mem_wb_out_vector);

        -- WRITE BACK (WB) ----------------------------------------------

        WB_STAGE : entity work.write_back
            port map(
                clk => clk,

                -- sinais de controle
                sel_mux_ula_mem => mem_wb_out.sel_mux_ula_mem,

                -- entradas
                alu_result => mem_wb_out.alu_out,
                ram_data => mem_wb_out.ram_out,
                pc_plus_4 => mem_wb_out.pc_plus_4,
                lui_imm => mem_wb_out.lui_imm,

                -- saídas
                write_data => write_data
            );

        -- OUTPUTS (LEDs e HEXs) ----------------------------------------------

        -- mux de output para os LEDs e HEXs
        MUX_OUTPUT : entity work.mux4x1
            generic map(
                data_width => data_width
            )
            port map(
                a => pc_out,
                b => id_ex_out.pc_plus_4,
                c => ex_mem_in.alu_out,
                d => write_data,
                selector => SW(1 downto 0),
                output => led_hex_output
            );

        -- LEDs
        LEDR(9) <= ex_mem_in.alu_zero;
        LEDR(8) <= mem_wb_out.enable_reg;
        LEDR(7 downto 0) <= led_hex_output(31 downto 24);

        -- HEXs
        DISPLAY_0 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(3 downto 0),
                clk => clk,
                display_out => HEX0
            );

        DISPLAY_1 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(7 downto 4),
                clk => clk,
                display_out => HEX1
            );

        DISPLAY_2 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(11 downto 8),
                clk => clk,
                display_out => HEX2
            );

        DISPLAY_3 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(15 downto 12),
                clk => clk,
                display_out => HEX3
            );

        DISPLAY_4 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(19 downto 16),
                clk => clk,
                display_out => HEX4
            );

        DISPLAY_5 : entity work.hex_model
            generic map(
                data_width_in => 4,
                data_width_out => 7
            )
            port map(
                data_in => led_hex_output(23 downto 20),
                clk => clk,
                display_out => HEX5
            );

    end architecture;
