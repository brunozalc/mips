library ieee;
use ieee.std_logic_1164.all;

entity data_flow_control_unit is
    port (
        opcode : in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        output : out std_logic_vector(13 downto 0)
    );
end entity;

architecture behavioral of data_flow_control_unit is

    -- opcodes e functs do grupo A
    constant lw : std_logic_vector(5 downto 0) := "100011";   -- opcode
    constant sw : std_logic_vector(5 downto 0) := "101011";   -- opcode
    constant add : std_logic_vector(5 downto 0) := "100000";  -- funct
    constant sub : std_logic_vector(5 downto 0) := "100010";  -- funct
    constant andr : std_logic_vector(5 downto 0) := "100100"; -- funct
    constant orr : std_logic_vector(5 downto 0) := "100101";  -- funct
    constant slt : std_logic_vector(5 downto 0) := "101010";  -- funct
    constant beq : std_logic_vector(5 downto 0) := "000100";  -- opcode
    constant j : std_logic_vector(5 downto 0) := "000010";    -- opcode

    -- opcodes e functs do grupo B
    constant lui : std_logic_vector(5 downto 0) := "001111";  -- opcode
    constant addi : std_logic_vector(5 downto 0) := "001000"; -- opcode
    constant andi : std_logic_vector(5 downto 0) := "001100"; -- opcode
    constant ori : std_logic_vector(5 downto 0) := "001101";  -- opcode
    constant slti : std_logic_vector(5 downto 0) := "001010"; -- opcode
    constant bne : std_logic_vector(5 downto 0) := "000101";  -- opcode
    constant jal : std_logic_vector(5 downto 0) := "000011";  -- opcode
    constant jr : std_logic_vector(5 downto 0) := "001000";   -- funct

    -- palavra de controle (13 downto 0)
    -- bit 13: JR (1=JR, 0=NOT JR)
    -- bit 12: MUX_PC+4_BEQ_JMP (1=BEQ/JMP, 0=PC+4)
    -- bit 11..10: MUX_RT_RD (00=RT, 01=RD, 10=#31, 11=N/A)
    -- bit 9: ORI_ANDI (1=ORI/ANDI, 0=NOT ORI/ANDI)
    -- bit 8: ENABLE_REG (1=ENABLE, 0=DISABLE)
    -- bit 7: MUX_RT_IMM (1=IMM, 0=RT)
    -- bit 6: R_TYPE (1=R_TYPE, 0=I_TYPE)
    -- bit 5..4: MUX_ULA_MEM (00=ULA, 01=MEM, 10=PC+4, 11=LUI)
    -- bit 3: BEQ (1=BEQ, 0=NOT BEQ)
    -- bit 2: BNE (1=BNE, 0=NOT BNE)
    -- bit 1: ENABLE_MEM_RD (1=ENABLE, 0=DISABLE)
    -- bit 0: ENABLE_MEM_WR (1=ENABLE, 0=DISABLE)

    signal control_word : std_logic_vector(13 downto 0);

    -- aliases
    alias control_jr : std_logic is control_word(13);
    alias mux_pc4_beq_jmp : std_logic is control_word(12);
    alias mux_rt_rd : std_logic_vector(1 downto 0) is control_word(11 downto 10);
    alias ori_andi : std_logic is control_word(9);
    alias enable_reg : std_logic is control_word(8);
    alias mux_rt_imm : std_logic is control_word(7);
    alias r_type : std_logic is control_word(6);
    alias mux_ula_mem : std_logic_vector(1 downto 0) is control_word(5 downto 4);
    alias enable_beq : std_logic is control_word(3);
    alias enable_bne : std_logic is control_word(2);
    alias enable_mem_rd : std_logic is control_word(1);
    alias enable_mem_wr : std_logic is control_word(0);

begin

    -- controle de jump
    control_jr <= '1' when (opcode = "000000" and funct = jr) else '0';
    
    mux_pc4_beq_jmp <= '1' when (opcode = j or opcode = jal) else '0';

    -- controle de branch
    enable_beq <= '1' when (opcode = beq) else '0';
    enable_bne <= '1' when (opcode = bne) else '0';

    -- controle da memória
    enable_mem_rd <= '1' when (opcode = lw) else '0';
    enable_mem_wr <= '1' when (opcode = sw) else '0';

    -- controle de registradores
    mux_rt_rd <= "01" when (opcode = "000000" and funct /= jr) else   -- instruções tipo R usam rd
                 "10" when (opcode = jal) else                        -- JAL usa #31
                 "00";                                                -- outros usam rt
    
    enable_reg <= '1' when (opcode = lw or                            -- loads na memória
                           (opcode = "000000" and funct /= jr) or     -- instruções tipo R
                           opcode = addi or opcode = slti or          -- aritmética com imediato
                           opcode = ori or opcode = andi or           -- lógica com imediato
                           opcode = lui or opcode = jal)              -- casos especiais
                 else '0';

    -- controle da ULA
    ori_andi <= '1' when (opcode = ori or opcode = andi) else '0';
    
    mux_rt_imm <= '1' when (opcode = lw or opcode = sw or             -- operações na memória (imediato é o offset)
                           opcode = addi or opcode = slti or          -- aritmética com imediato
                           opcode = ori or opcode = andi)             -- lógica com imediato
                  else '0';
    
    r_type <= '1' when (opcode = "000000") else '0';

    -- controle do mux ULA/MEM
    mux_ula_mem <= "01" when (opcode = lw) else                       -- dados da memória
                   "10" when (opcode = jal) else                      -- PC+4
                   "11" when (opcode = lui) else                      -- imediato superior
                   "00";                                              -- dados da ULA

    -- saída 
    output <= control_word;

end architecture;
