library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga is port
(
	CLOCK_50, reset 	: in std_logic := '0';
	f_af 	        		: in std_logic := '0';
	is_stable			: in std_logic := '0';
	data            	: inout std_logic_vector(7 downto 0) := (others => 'Z');
	state					: out std_logic_vector(3 downto 0) := "0000";
	f_fa 	        		: out std_logic := '0'
);
end fpga;

architecture arch of fpga is
    signal op1, op2, code, result 	: std_logic_vector(7 downto 0) := (others => '0');
    signal cs, ns, ps   	: std_logic_vector(3 downto 0) := (others => '0');
	 
    constant S_IDLE 			: std_logic_vector(3 downto 0) := "0000";
	 constant S_FETCH_C 		: std_logic_vector(3 downto 0) := "0001";
	 constant S_WAIT_C 		: std_logic_vector(3 downto 0) := "0010";
	 constant S_FETCH_OP1	: std_logic_vector(3 downto 0) := "0011";
	 constant S_WAIT_OP1		: std_logic_vector(3 downto 0) := "0100";
	 constant S_FETCH_OP2	: std_logic_vector(3 downto 0) := "0101";
	 constant S_WAIT_OP2		: std_logic_vector(3 downto 0) := "0110";
	 constant S_NOTIFY		: std_logic_vector(3 downto 0) := "0111";
	 constant S_ACK_REC		: std_logic_vector(3 downto 0) := "1000";
begin
	f_fa <= '1' when cs=S_FETCH_C or cs=S_FETCH_OP1 or cs=S_FETCH_OP2 or cs=S_NOTIFY else '0';
	state <= code(3 downto 0);
	
	process(code, op1, op2)
	begin
		case(code) is
			when "00000000" => result <= std_logic_vector(unsigned(op1) + unsigned(op2));
			when "00000001" => result <= std_logic_vector(unsigned(op1) - unsigned(op2));
			when "00000010" => result <= std_logic_vector(resize(unsigned(op1) * unsigned(op2), result'length));
			when "00000011" => result <= std_logic_vector(unsigned(op1) / unsigned(op2));
			when others => result <= "ZZZZZZZZ";
		end case;
	end process;
	data <= result when cs=S_NOTIFY else "ZZZZZZZZ";
	
	FSM: process(CLOCK_50, reset, ns, cs)
	begin
		if rising_edge(CLOCK_50) then
			if reset='1' then
				cs <= S_IDLE;
				ps <= S_IDLE;
				code <= (others => '0');
				op1 <= (others => '0');
				op2 <= (others => '0');
			else
				cs <= ns;
				ps <= cs;
				
				if ns=S_FETCH_C then
					code <= data;
				end if;
				if ns=S_FETCH_OP1 then
					op1 <= data;
				end if;
				if ns=S_FETCH_OP2 then
					op2 <= data;
				end if;
			end if;
		end if;
	end process;
	
	next_state: process(cs, f_af, is_stable)
	begin
		ns <= cs;
		case(cs) is
			when S_IDLE 	=> if f_af='1' and is_stable='1' then
										ns <= S_FETCH_C; 
									end if;
			when S_FETCH_C =>	if f_af='0' and is_stable='1' then
										ns <= S_WAIT_C;
									end if;
			when S_WAIT_C 	=>	if f_af='1' and is_stable='1' then
										ns <= S_FETCH_OP1;
									end if;
			when S_FETCH_OP1 	=>	if f_af='0' and is_stable='1' then
										ns <= S_WAIT_OP1;
									end if;
			when S_WAIT_OP1 	=>	if f_af='1' and is_stable='1' then
											ns <= S_FETCH_OP2;
										end if;
			when S_FETCH_OP2 	=>	if f_af='0' and is_stable='1' then
											ns <= S_WAIT_OP2;
										end if;
			when S_WAIT_OP2 	=>	ns <= S_NOTIFY;
			when S_NOTIFY 		=>	if f_af='1' and is_stable='1' then
											ns <= S_ACK_REC;
										end if;
			when S_ACK_REC		=>	if f_af='0' and is_stable='1' then
											ns <= S_IDLE;
										end if;
			when others =>  ns <= cs;
		end case;
	end process;
end arch;
