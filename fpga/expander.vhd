library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity expander is port
	(
		clock, reset : in std_logic := '0';
		in_signal : in std_logic := '0';
		out_signal : out std_logic := '0'
	);
end;

architecture arch of expander is
	signal counter : unsigned(15 downto 0) := (others => '0');
	signal state 	: std_logic := '0';
begin
	process(clock, reset, in_signal, counter)
	begin
		if rising_edge(clock) then
			if reset='1' then
				counter <= (others => '0');
				state <= '0';
			else
				if state='1' then
					counter <= counter +1;
				end if;
				
				if in_signal='1' and state='0' then
					state <= '1';
				elsif counter="1111111111111111" then
					counter <= (others => '0');
					state <= '0';
				end if;
			end if;
		end if;
	end process;
	
	out_signal <= state;
end;