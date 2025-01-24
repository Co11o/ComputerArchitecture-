-- controller.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains is the implementation of the control unit for our processor.

-- 10/9/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY controller IS

	PORT (
		i_OPCODE : IN STD_LOGIC_VECTOR(5 DOWNTO 0); --bits [31:26] of instruction
		i_FUNCTION : IN STD_LOGIC_VECTOR(5 DOWNTO 0); --bits [5:0] of instruction
		o_ALUOP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --4-bit function to be fed into ALU to determine alu function
		o_DST_REG : OUT STD_LOGIC; --0=rt/1=rd
		o_ALUSrc : OUT STD_LOGIC; --0=register/1=immediate
		o_EXTENSION : OUT STD_LOGIC; --0=unsigned/1=signed
		o_MEM_TO_REG : OUT STD_LOGIC; --0=ALU/1=memory
		o_REG_WRITE : OUT STD_LOGIC; --0=disabled/1=enabled
		o_MEM_WRITE : OUT STD_LOGIC; --0=disabled/1=enabled
		o_BRANCH : OUT STD_LOGIC; --0=no/1=yes
		o_BRANCH_TYPE : OUT STD_LOGIC; --BNE = 0, BEQ = 1
		o_JUMP_EN : OUT STD_LOGIC; --0=no/1=yes
		o_JR : OUT STD_LOGIC; --0=no/1=yes
		o_JAL : OUT STD_LOGIC; --0=no/1=yes
		o_HALT : OUT STD_LOGIC
	);
END controller;

ARCHITECTURE dataflow OF controller IS
BEGIN

	o_ALUOP <= "0110" WHEN ((i_OPCODE = "000000") AND (i_FUNCTION = "100000")) ELSE --add
		"1011" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100001") ELSE --addu
		"0100" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100100") ELSE --and
		"0001" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100111") ELSE --nor
		"0010" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100110") ELSE --xor
		"0011" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100101") ELSE --or
		"0000" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "101010") ELSE --slt
		"1000" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "000000") ELSE --sll
		"0111" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "000010") ELSE --srl
		"1001" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "000011") ELSE --sra
		"0101" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100010") ELSE --sub
		"1100" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "100011") ELSE --subu
		"0000" WHEN (i_OPCODE = "000000" AND i_FUNCTION = "001000") ELSE --jr
		"0110" WHEN (i_OPCODE = "001000") ELSE --addi
		"1011" WHEN (i_OPCODE = "001001") ELSE --addiu
		"0100" WHEN (i_OPCODE = "001100") ELSE --andi
		"1010" WHEN (i_OPCODE = "001111") ELSE --lui
		"0110" WHEN (i_OPCODE = "100011") ELSE --lw
		"0010" WHEN (i_OPCODE = "001110") ELSE --xori
		"0011" WHEN (i_OPCODE = "001101") ELSE --ori
		"0000" WHEN (i_OPCODE = "001010") ELSE --slti
		"0110" WHEN (i_OPCODE = "101011") ELSE --sw
		"1100" WHEN (i_OPCODE = "000100") ELSE --beq
		"1100" WHEN (i_OPCODE = "000101") ELSE --bne
		"0000" WHEN (i_OPCODE = "000010") ELSE --j
		"0000" WHEN (i_OPCODE = "000010"); --jal

	o_DST_REG <= '1' WHEN (i_OPCODE = "000000") ELSE
		'0';

	o_ALUSrc <= '0' WHEN (i_OPCODE = "000000" OR i_OPCODE = "000010" OR i_OPCODE = "000011" OR i_OPCODE = "000100" OR i_OPCODE = "000101") ELSE --R-type/j/jal
		'1';

	o_EXTENSION <= '1' WHEN (i_OPCODE = "001000") ELSE --addi
		'1' WHEN (i_OPCODE = "001001") ELSE --addiu
		'1' WHEN (i_OPCODE = "100011") ELSE --lw
		'1' WHEN (i_OPCODE = "001010") ELSE --slti
		'1' WHEN (i_OPCODE = "101011") ELSE --sw
		'1' WHEN (i_OPCODE = "000100") ELSE --beq
		'1' WHEN (i_OPCODE = "000101") ELSE --bne
		'0';

	o_MEM_TO_REG <= '1' WHEN (i_OPCODE = "100011") ELSE --lw
		'0';

	o_REG_WRITE <= '0' WHEN (i_OPCODE = "000000" AND i_FUNCTION = "001000") ELSE --jr
		'0' WHEN (i_OPCODE = "101011") ELSE --sw
		'0' WHEN (i_OPCODE = "000100") ELSE --beq
		'0' WHEN (i_OPCODE = "000101") ELSE --bne
		'0' WHEN (i_OPCODE = "000010") ELSE --j
		'1';

	o_MEM_WRITE <= '1' WHEN (i_OPCODE = "101011") ELSE --sw
		'0';

	o_BRANCH <= '1' WHEN (i_OPCODE = "000100") ELSE --beq
		'1' WHEN (i_OPCODE = "000101") ELSE --bne
		'0';

	o_BRANCH_TYPE <= '1' WHEN (i_OPCODE = "000100") ELSE
		'0';

	o_JUMP_EN <= '1' WHEN (i_OPCODE = "000000" AND i_FUNCTION = "001000") ELSE --jr
		'1' WHEN (i_OPCODE = "000010") ELSE --j
		'1' WHEN (i_OPCODE = "000011") ELSE --jal
		'0';

	o_JR <= '1' WHEN (i_OPCODE = "000000" AND i_FUNCTION = "001000") ELSE --jr
		'0';

	o_JAL <= '1' WHEN (i_OPCODE = "000011") ELSE --jal
		'0';

	o_HALT <= '1' WHEN (i_OPCODE = "010100") ELSE
		'0';

END dataflow;