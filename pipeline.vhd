library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pipeline is

    -- sinais do registrador IF/ID
    type if_id_io is record
        instruction : std_logic_vector(31 downto 0);
        pc_plus_4 : std_logic_vector(31 downto 0);
    end record;

    constant IF_ID_WIDTH : integer := 32 + 32;

    -- sinais do registrador ID/EX
    type id_ex_io is record
        pc_plus_4 : std_logic_vector(31 downto 0);
        control_word : std_logic_vector(13 downto 0);
        opcode : std_logic_vector(5 downto 0);
        funct : std_logic_vector(5 downto 0);
        rs_data : std_logic_vector(31 downto 0);
        rt_data : std_logic_vector(31 downto 0);
        rd_address : std_logic_vector(4 downto 0);
        rt_address : std_logic_vector(4 downto 0);
        extended_imm : std_logic_vector(31 downto 0);
        lui_imm : std_logic_vector(31 downto 0);
    end record;

    constant ID_EX_WIDTH : integer := 32 + 14 + 6 + 6 + 32 + 32 + 5 + 5 + 32 + 32;

    -- sinais do registrador EX/MEM
    type ex_mem_io is record
        alu_out : std_logic_vector(31 downto 0);
        alu_zero : std_logic;
        branch_target : std_logic_vector(31 downto 0);
        mux_beq_out : std_logic;
        mux_rt_rd_out : std_logic_vector(4 downto 0);
        mux_rt_imm_out : std_logic_vector(31 downto 0);
        pc_plus_4 : std_logic_vector(31 downto 0);
        rt_data : std_logic_vector(31 downto 0);
        lui_imm : std_logic_vector(31 downto 0);
        sel_mux_ula_mem : std_logic_vector(1 downto 0);
        enable_reg : std_logic;
        enable_beq : std_logic;
        enable_bne : std_logic;
        enable_mem_read : std_logic;
        enable_mem_write : std_logic;
    end record;

    constant EX_MEM_WIDTH : integer := 32 + 1 + 32 + 1 + 5 + 32 + 32 + 32 + 32 + 2 + 1 + 1 + 1 + 1 + 1;

    -- sinais do registrador MEM/WB
    type mem_wb_io is record
        ram_out : std_logic_vector(31 downto 0);
        pc_plus_4 : std_logic_vector(31 downto 0);
        alu_out : std_logic_vector(31 downto 0);
        lui_imm : std_logic_vector(31 downto 0);
        write_register : std_logic_vector(4 downto 0);
        sel_mux_ula_mem : std_logic_vector(1 downto 0);
        enable_reg : std_logic;
    end record;

    constant MEM_WB_WIDTH : integer := 32 + 32 + 32 + 32 + 5 + 2 + 1;

    -- declarações das funções de conversão
    function if_id_to_vector(rec : if_id_io) return std_logic_vector;
    function vector_to_if_id(vec : std_logic_vector) return if_id_io;

    function id_ex_to_vector(rec : id_ex_io) return std_logic_vector;
    function vector_to_id_ex(vec : std_logic_vector) return id_ex_io;

    function ex_mem_to_vector(rec : ex_mem_io) return std_logic_vector;
    function vector_to_ex_mem(vec : std_logic_vector) return ex_mem_io;

    function mem_wb_to_vector(rec : mem_wb_io) return std_logic_vector;
    function vector_to_mem_wb(vec : std_logic_vector) return mem_wb_io;

end package;

package body pipeline is

    -- funções de apoio para o registrador IF/ID
    function if_id_to_vector(rec : if_id_io) return std_logic_vector is
    begin
        return rec.instruction & rec.pc_plus_4;
    end function;

    function vector_to_if_id(vec : std_logic_vector) return if_id_io is
        variable rec : if_id_io;
        variable idx : integer := IF_ID_WIDTH - 1;
    begin
        rec.instruction := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.pc_plus_4 := vec(idx downto idx - 31);
        idx := idx - 32;
        return rec;
    end function;

    -- funções de apoio para o registrador ID/EX
    function id_ex_to_vector(rec : id_ex_io) return std_logic_vector is
    begin
        return rec.pc_plus_4 & rec.control_word & rec.opcode & rec.funct & rec.rs_data & rec.rt_data & rec.rd_address & rec.rt_address & rec.extended_imm & rec.lui_imm;
    end function;

    function vector_to_id_ex(vec : std_logic_vector) return id_ex_io is
        variable rec : id_ex_io;
        variable idx : integer := ID_EX_WIDTH - 1;
    begin
        rec.pc_plus_4 := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.control_word := vec(idx downto idx - 13);
        idx := idx - 14;
        rec.opcode := vec(idx downto idx - 5);
        idx := idx - 6;
        rec.funct := vec(idx downto idx - 5);
        idx := idx - 6;
        rec.rs_data := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.rt_data := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.rd_address := vec(idx downto idx - 4);
        idx := idx - 5;
        rec.rt_address := vec(idx downto idx - 4);
        idx := idx - 5;
        rec.extended_imm := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.lui_imm := vec(idx downto idx - 31);
        idx := idx - 32;
        return rec;
    end function;

    -- funções de apoio para o registrador EX/MEM
    function ex_mem_to_vector(rec : ex_mem_io) return std_logic_vector is
    begin
        return rec.alu_out & rec.alu_zero & rec.branch_target & rec.mux_beq_out & rec.mux_rt_rd_out & rec.mux_rt_imm_out & rec.pc_plus_4 & rec.rt_data & rec.lui_imm & rec.sel_mux_ula_mem & rec.enable_reg & rec.enable_beq & rec.enable_bne & rec.enable_mem_read & rec.enable_mem_write;
    end function;

    function vector_to_ex_mem(vec : std_logic_vector) return ex_mem_io is
        variable rec : ex_mem_io;
        variable idx : integer := EX_MEM_WIDTH - 1;
    begin
        rec.alu_out := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.alu_zero := vec(idx);
        idx := idx - 1;
        rec.branch_target := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.mux_beq_out := vec(idx);
        idx := idx - 1;
        rec.mux_rt_rd_out := vec(idx downto idx - 4);
        idx := idx - 5;
        rec.mux_rt_imm_out := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.pc_plus_4 := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.rt_data := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.lui_imm := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.sel_mux_ula_mem := vec(idx downto idx - 1);
        idx := idx - 2;
        rec.enable_reg := vec(idx);
        idx := idx - 1;
        rec.enable_beq := vec(idx);
        idx := idx - 1;
        rec.enable_bne := vec(idx);
        idx := idx - 1;
        rec.enable_mem_read := vec(idx);
        idx := idx - 1;
        rec.enable_mem_write := vec(idx);
        idx := idx - 1;
        return rec;
    end function;

    -- funções de apoio para o registrador MEM/WB
    function mem_wb_to_vector(rec : mem_wb_io) return std_logic_vector is
    begin
        return rec.ram_out & rec.pc_plus_4 & rec.alu_out & rec.lui_imm & rec.write_register & rec.sel_mux_ula_mem & rec.enable_reg;
    end function;

    function vector_to_mem_wb(vec : std_logic_vector) return mem_wb_io is
        variable rec : mem_wb_io;
        variable idx : integer := MEM_WB_WIDTH - 1;
    begin
        rec.ram_out := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.pc_plus_4 := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.alu_out := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.lui_imm := vec(idx downto idx - 31);
        idx := idx - 32;
        rec.write_register := vec(idx downto idx - 4);
        idx := idx - 5;
        rec.sel_mux_ula_mem := vec(idx downto idx - 1);
        idx := idx - 2;
        rec.enable_reg := vec(idx);
        idx := idx - 1;
        return rec;
    end function;

end package body;
