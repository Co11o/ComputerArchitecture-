--Author Jackson Collalti
-- 32 Bit XOR gate
library IEEE;
use IEEE.std_logic_1164.all;

entity XOR_32BITS is
  port(i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));

end XOR_32BITS;

architecture dataflow of XOR_32BITS is
    begin

    AND32: for i in 0 to 31 generate
        o_F(i) <= i_A(i) XOR i_B(i);
    end generate;
    
end dataflow;