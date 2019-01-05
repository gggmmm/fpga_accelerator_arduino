-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 2.1.2019 20:45:58 GMT

library ieee;
use ieee.std_logic_1164.all;

entity tb_fpga is
end tb_fpga;

architecture tb of tb_fpga is

    component fpga
        port (CLOCK_50 : in std_logic;
              reset    : in std_logic;
              f_af     : in std_logic;
              data     : inout std_logic_vector (7 downto 0);
              f_fa     : out std_logic
              );
    end component;

    signal CLOCK_50 : std_logic := '0';
    signal reset    : std_logic := '0';
    signal f_af     : std_logic := '0';
    signal data     : std_logic_vector (7 downto 0) := (others => '0');
    signal f_fa     : std_logic := '0';

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : fpga
    port map (CLOCK_50 => CLOCK_50,
              reset    => reset,
              f_af     => f_af,
              data     => data,
              f_fa     => f_fa);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that CLOCK_50 is really your main clock signal
    CLOCK_50 <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        f_af <= '0';
        data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- ================================== TEST 1 ADD ===============================
        -- CODE, add
        data <= "00000000", "ZZZZZZZZ" after 1*TbPeriod;
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00001010", "ZZZZZZZZ" after 1*TbPeriod; -- op1, 10
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 7*TbPeriod;
        
        data <= "00000011", "ZZZZZZZZ" after 1*TbPeriod; -- op2, 3
        f_af <= '1', '0' after 1*TbPeriod;
        wait until f_fa='1';
        wait for 5*TbPeriod;
        f_af <= '1', '0' after 3*TbPeriod;
        
        wait until falling_edge(CLOCK_50);
        wait for 3*TbPeriod;
        
        -- ================================== TEST 1 SUB ===============================
        -- CODE, sub
        data <= "00000001", "ZZZZZZZZ" after 1*TbPeriod;
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00001010", "ZZZZZZZZ" after 1*TbPeriod; -- op1, 10
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00000011", "ZZZZZZZZ" after 1*TbPeriod; -- op2, 3
        f_af <= '1', '0' after 1*TbPeriod;
        wait until f_fa='1';
        wait for 5*TbPeriod;
        f_af <= '1', '0' after 3*TbPeriod;
        
        wait until falling_edge(CLOCK_50);
        wait for 3*TbPeriod;
        
        -- ================================== TEST 1 MUL ===============================
        -- CODE, mul
        data <= "00000010", "ZZZZZZZZ" after 1*TbPeriod;
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00001010", "ZZZZZZZZ" after 1*TbPeriod; -- op1, 10
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00000011", "ZZZZZZZZ" after 1*TbPeriod; -- op2, 3
        f_af <= '1', '0' after 1*TbPeriod;
        wait until f_fa='1';
        wait for 5*TbPeriod;
        f_af <= '1', '0' after 3*TbPeriod;
        
        wait until falling_edge(CLOCK_50);
        wait for 3*TbPeriod;
        
        -- ================================== TEST DIV ===============================
        -- CODE, div
        data <= "00000011", "ZZZZZZZZ" after 1*TbPeriod;
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00010000", "ZZZZZZZZ" after 1*TbPeriod; -- op1, 16
        f_af <= '1', '0' after 1*TbPeriod;
        wait for 5*TbPeriod;
        
        data <= "00000100", "ZZZZZZZZ" after 1*TbPeriod; -- op2, 4
        f_af <= '1', '0' after 1*TbPeriod;
        wait until f_fa='1';
        wait for 5*TbPeriod;
        f_af <= '1', '0' after 3*TbPeriod;
        
        wait until falling_edge(CLOCK_50);
        wait for 3*TbPeriod;
        
        
        wait for 10 * TbPeriod;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_fpga of tb_fpga is
    for tb
    end for;
end cfg_tb_fpga;
