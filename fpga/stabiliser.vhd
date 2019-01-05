library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity stabiliser is port
	(
		clock, reset	: in std_logic := '0';
		in_signal 		: in std_logic := '0';
		is_stable		: out std_logic := '0'
	);
end entity;

architecture arch of stabiliser is
	signal r0, r1 : std_logic := '0';
	signal counter : unsigned(8 downto 0) := (others => '0');
begin
	process(clock, reset, in_signal)
	begin
		if rising_edge(clock) then
			if reset='1' then
				r0 <= '0';
				r1 <= '0';
				counter <= (others => '0');
			else
				counter <= counter +1;
				if counter="111111111" then
					r0 <= in_signal;
					r1 <= r0;
				end if;
			end if;
		end if;
	end process;

	is_stable <= '1' when r0=r1 else '0';
end;