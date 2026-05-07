library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    Port (
        reset :          in STD_LOGIC;
        -- Here are the signals I need
        instr          : in STD_LOGIC_VECTOR(31 downto 0);
        if_id_instr    : in STD_LOGIC_VECTOR(31 downto 0);
        branch         : in STD_LOGIC;
        jump           : in STD_LOGIC;
        stall_counter  : in integer range 0 to 3 := 0;
        start_stall    : out STD_LOGIC;
        double_stall   : out STD_LOGIC
    );
end hazard_detection_unit;

-- NOTE: only looks one instruction before dependency (not two or three before)
architecture Behavioral of hazard_detection_unit is
   signal working_opcode, incoming_opcode       : STD_LOGIC_VECTOR(6 downto 0);
   signal working_rs1, incoming_rs1             : STD_LOGIC_VECTOR(4 downto 0);
   signal working_rs2, incoming_rs2             : STD_LOGIC_VECTOR(4 downto 0);
   signal working_rd, incoming_rd               : STD_LOGIC_VECTOR(4 downto 0);
begin
    -- would opcodes of instructions be useful?
    working_opcode <= if_id_instr(6 downto 0);
    incoming_opcode <= instr(6 downto 0);
    
    working_rs1 <= if_id_instr(19 downto 15);
    incoming_rs1 <= instr(19 downto 15);
    
    working_rs2 <= if_id_instr(24 downto 20);
    incoming_rs2 <= instr(24 downto 20);
    
    working_rd <= if_id_instr(11 downto 7);
    incoming_rd <= instr(11 downto 7);
    process(instr, branch, jump, stall_counter, working_opcode, incoming_opcode, working_rs1, incoming_rs1, working_rs2, incoming_rs2, working_rd, incoming_rd) -- any others?))
    begin      
        if (reset = '1') then
            start_stall <= '0';
            double_stall <= '0';
        -- stall cases, dependency on a (1)load from memory, (2) load_addr
        -- There are only 2 cases that need a single stall and 1 that needs a double stall
        -- the Lw after La needs a single stall, as well as the add after Lw
        -- The BNE needs the double stall
        -- My solution
        elsif (incoming_opcode = "0000011" and working_opcode = "0010111" and stall_counter = 0) then
            start_stall <= '1';
            double_stall <= '0';
        
        elsif (incoming_opcode = "0110011" and working_opcode = "0000011" and stall_counter = 0) then
            start_stall <= '1';
            double_stall <= '0';
        elsif (incoming_opcode = "1100011" and working_opcode = "0010011" and stall_counter = 0) then
            start_stall <= '1';
            double_stall <= '1';
        else
            start_stall <= '0';
            double_stall <= '0';
        end if;  
        -- Original Code from york
--        elsif (stall_counter = 0 
--              and working_rd = incoming_rs1) then -- single stall data dependency case
--                start_stall <= '1';
--        elsif (<what control signals and/or opcodes?>) --(3) add, (4) addi/subi
--              and (<what control signals and/or opcodes?>)  -- stall data dependency case
--              and (<what control signals and/or opcodes?>) then --BNE double stall
--                    start_stall <= '1';
--                    double_stall <= '1';
--        elsif -- stall cases for branch or jump, needing time to calulate branch address, etc
--              (<what control signals and/or opcodes?>) then 
--                start_stall <= '1';  
--                double_stall <= '0';    
--        else        
--                start_stall <= '0';
--        end if;    
        
    end process;
end Behavioral;
