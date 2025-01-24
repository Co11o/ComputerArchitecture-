-- tb_controller.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the controller component.
--              
-- 10/10/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
ENTITY tb_controller IS
	GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_controller;

ARCHITECTURE behavior OF tb_controller IS

	-- Define the total clock period time
	CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

	-- TODO: change component declaration as needed.
	COMPONENT controller IS
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
			o_JUMP_EN : OUT STD_LOGIC; --0=no/1=yes
			o_JR : OUT STD_LOGIC;
			o_JAL : OUT STD_LOGIC;
			o_HALT : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL s_CLK, reset : STD_LOGIC := '0';
	SIGNAL s_OPCODE : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL s_FUNCTION : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL s_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_DST_REG : STD_LOGIC;
	SIGNAL s_ALUSrc : STD_LOGIC;
	SIGNAL s_EXTENSION : STD_LOGIC;
	SIGNAL s_MEM_TO_REG : STD_LOGIC;
	SIGNAL s_REG_WRITE : STD_LOGIC;
	SIGNAL s_MEM_WRITE : STD_LOGIC;
	SIGNAL s_BRANCH : STD_LOGIC;
	SIGNAL s_JUMP_EN : STD_LOGIC;
	SIGNAL s_JR : STD_LOGIC;
	SIGNAL s_JAL : STD_LOGIC;
	SIGNAL s_HALT : STD_LOGIC;

BEGIN
	control : controller
	PORT MAP(
		i_OPCODE => s_OPCODE,
		i_FUNCTION => s_FUNCTION,
		o_ALUOP => s_ALUOP,
		o_DST_REG => s_DST_REG,
		o_ALUSrc => s_ALUSrc,
		o_EXTENSION => s_EXTENSION,
		o_MEM_TO_REG => s_MEM_TO_REG,
		o_REG_WRITE => s_REG_WRITE,
		o_MEM_WRITE => s_MEM_WRITE,
		o_BRANCH => s_BRANCH,
		o_JUMP_EN => s_JUMP_EN,
		o_JR => s_JR,
		o_JAL => s_JAL,
		o_HALT => s_HALT);

	P_CLK : PROCESS
	BEGIN
		s_CLK <= '0';
		WAIT FOR gCLK_HPER;
		s_CLK <= '1';
		WAIT FOR gCLK_HPER;
	END PROCESS;

	-- Testbench process  
	P_TB : PROCESS
	BEGIN

		-- Pass each instruction into the controller and check the outputs.

		--add
		s_OPCODE <= "000000";
		s_FUNCTION <= "100000";
			WAIT FOR cCLK_PER;

		--addu
		s_FUNCTION <= "100001";
			WAIT FOR cCLK_PER;

		--and
		s_FUNCTION <= "100100";
			WAIT FOR cCLK_PER;

		--nor
		s_FUNCTION <= "100111";
			WAIT FOR cCLK_PER;

		--xor
		s_FUNCTION <= "100110";
			WAIT FOR cCLK_PER;

		--or
		s_FUNCTION <= "100101";
			WAIT FOR cCLK_PER;

		--slt
		s_FUNCTION <= "101010";
			WAIT FOR cCLK_PER;

		--sll
		s_FUNCTION <= "000000";
			WAIT FOR cCLK_PER;

		--srl
		s_FUNCTION <= "000010";
			WAIT FOR cCLK_PER;

		--sra
		s_FUNCTION <= "000011";
			WAIT FOR cCLK_PER;

		--sub
		s_FUNCTION <= "100010";
			WAIT FOR cCLK_PER;

		--subu
		s_FUNCTION <= "100011";
			WAIT FOR cCLK_PER;

		--jr
		s_FUNCTION <= "001000";
			WAIT FOR cCLK_PER;

		--addi
		s_OPCODE <= "001000";
		s_FUNCTION <= "------";
			WAIT FOR cCLK_PER;

		--addiu
		s_OPCODE <= "001001";
		WAIT FOR cCLK_PER;

		--andi
		s_OPCODE <= "001100";
		WAIT FOR cCLK_PER;

		--lui
		s_OPCODE <= "001111";
		WAIT FOR cCLK_PER;

		--lw
		s_OPCODE <= "100011";
		WAIT FOR cCLK_PER;

		--xori
		s_OPCODE <= "001110";
		WAIT FOR cCLK_PER;

		--ori
		s_OPCODE <= "001101";
		WAIT FOR cCLK_PER;

		--slti
		s_OPCODE <= "001010";
		WAIT FOR cCLK_PER;

		--sw
		s_OPCODE <= "101011";
		WAIT FOR cCLK_PER;

		--beq
		s_OPCODE <= "000100";
		WAIT FOR cCLK_PER;

		--bne
		s_OPCODE <= "000101";
		WAIT FOR cCLK_PER;

		--j
		s_OPCODE <= "000010";
		WAIT FOR cCLK_PER;

		--jal
		s_OPCODE <= "000011";
		WAIT FOR cCLK_PER;

		--halt
		s_OPCODE <= "010100";
		WAIT FOR cCLK_PER;

		WAIT;
	END PROCESS;

END behavior;
