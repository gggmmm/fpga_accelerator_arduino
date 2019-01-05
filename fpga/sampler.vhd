library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler is
	port(
		clock, reset 	: in std_logic := '0';
		in_signal 		: in std_logic := '0';
		expected_state : in std_logic := '0';
		is_stable		: out std_logic := '0';
		out_signal 		: out std_logic := '0'
	);
end;

architecture arch of sampler is
	signal counter 	: unsigned(8 downto 0) := (others => '0'); -- ~10us
	signal ps, cs, ns : std_logic_vector(2 downto 0) := (others => '0');
	
	constant S_IDLE	: std_logic_vector(2 downto 0) := "000";
	constant S_WAIT	: std_logic_vector(2 downto 0) := "001";
	constant S_CHECK_STABIL	: std_logic_vector(2 downto 0) := "010";
	constant S_OK	: std_logic_vector(2 downto 0) := "011";
	constant S_BAD	: std_logic_vector(2 downto 0) := "100";
begin
	process(clock, reset, cs, ns)
	begin
		if rising_edge(clock) then
			if reset='1' then
				cs <= (others => '0');
				ps <= (others => '0');
				counter <= (others => '0');
			else
				cs <= ns;
				ps <= cs;
				if cs=S_WAIT then
					counter <= counter +1;
				end if;
				
				if cs=S_CHECK_STABIL then
					counter <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	process(cs, in_signal, expected_state, counter)
	begin
		ns <= cs;
		case(cs) is
			when S_IDLE =>	if in_signal=expected_state then
									ns <= S_WAIT;
								end if;
			when S_WAIT => if counter="111111111" then
									ns <= S_CHECK_STABIL;
								end if;
			when S_CHECK_STABIL => 	if in_signal=expected_state then
												ns <= S_OK;
											else
												ns <= S_BAD;
											end if;
			when S_OK => ns <= S_IDLE;
			when S_BAD => ns <= S_IDLE;
			when others => ns <= cs;
		end case;
	end process;
	
	is_stable <= '1' when cs=S_OK or cs=S_BAD else '0';
	out_signal <= in_signal;
end;