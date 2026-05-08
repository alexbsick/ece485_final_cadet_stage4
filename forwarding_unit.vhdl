library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity forwarding_unit is
    Port (
        ex_mem_reg_write : in STD_LOGIC;
        mem_wb_reg_write : in STD_LOGIC;
        mem_wb_mem_read  : in STD_LOGIC;
        mem_wb_load_addr : in STD_LOGIC;
        ex_mem_rd        : in STD_LOGIC_VECTOR(4 downto 0);
        mem_wb_rd        : in STD_LOGIC_VECTOR(4 downto 0);
        id_ex_rs1        : in STD_LOGIC_VECTOR(4 downto 0);
        -- To do the opcodes
        id_ex_instr      : in STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_instr     : in STD_LOGIC_VECTOR(31 downto 0);
        -- need any other input or output registers?
        mux_select_A     : out STD_LOGIC_VECTOR(1 downto 0)
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is

   signal previous_opcode, current_opcode       : STD_LOGIC_VECTOR(6 downto 0);
   signal current_rs1, ex_rs1, mem_rs1          : STD_LOGIC_VECTOR(4 downto 0);
   signal current_rs2, ex_rs2, mem_rs2          : STD_LOGIC_VECTOR(4 downto 0);


begin

    previous_opcode <= ex_mem_instr(6 downto 0);
    current_opcode <= id_ex_instr(6 downto 0);

    current_rs1 <= id_ex_instr(19 downto 15);
    ex_rs1 <= ex_mem_instr(19 downto 15);
    
    current_rs2 <= id_ex_instr(24 downto 20);
    ex_rs2 <= ex_mem_instr(24 downto 20);
    

    process(ex_mem_reg_write, mem_wb_mem_read, mem_wb_load_addr, ex_mem_rd, mem_wb_rd, id_ex_rs1, previous_opcode, current_opcode, current_rs1, ex_rs1, mem_rs1, current_rs2, ex_rs2, mem_rs2) -- any others?)
begin
    -- mux to select alu input A (with forwarding)
    --    mux_select_A
    --       00 normal
    --       01 forward from alu output
    --       10 forward from memory output
    --       11 forward from custom LoadAddr

  -- Default: no forwarding
  mux_select_A <= "00";

  -- EX hazard
  if (current_rs1 = ex_mem_rd and ex_mem_reg_write = '1') then  -- alu to register case (Addi -> LW) 
    mux_select_A <= "01";
  elsif (current_rs1 = mem_wb_rd and mem_wb_reg_write = '1') then  -- memory to register case (LW -> ADD) and (SUBI -> BNE)
    mux_select_A <= "10";
  elsif (current_opcode = "0010111") then  -- load address to register case
    mux_select_A <= "11";
  end if;
    end process;
end Behavioral;