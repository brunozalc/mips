library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  port (  
		a      : in std_logic;
		b      : in std_logic;
		cin    : in std_logic;
		cout	 : out std_logic;
		result : out std_logic
  );
  
end entity;

architecture arquitetura of adder is

begin

  result <= (a xor b) xor cin; -- a + b + cin	
  cout <= (a and b) or (cin and (a xor b)); -- cout

end architecture;
