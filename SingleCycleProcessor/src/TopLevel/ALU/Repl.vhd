--Jackson Collalti
--Repl 
--REPL.QB RD, CONST8 RD = CONST8 || CONST8 || CONST8 || CONST8
library IEEE;
use IEEE.std_logic_1164.all;

entity Repl is
  port(i_A          : in STD_LOGIC_VECTOR(7 DOWNTO 0); --Const8
       o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
end Repl;

architecture dataflow of Repl is
    begin
        
    -- o_F = CONST8 || CONST8 || CONST8 || CONST8
    o_F <= (i_A) & (i_A) & (i_A) & (i_A);
    
end dataflow;