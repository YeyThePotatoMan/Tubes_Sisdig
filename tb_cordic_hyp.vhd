library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_cordic_hyp is
end entity;

architecture sim of tb_cordic_hyp is
    constant SCALE : real := 268435456.0;

    signal clk       : std_logic := '0';
    signal rst_n     : std_logic := '0';
    signal start     : std_logic := '0';
    signal done      : std_logic;
    signal theta     : signed(31 downto 0) := (others => '0');
    signal co, si    : signed(31 downto 0);
    signal finished  : boolean := false;
begin
    dut : entity work.cordic_hyp
        port map (clk => clk, rst_n => rst_n, start => start, theta => theta,
                  done => done, cosh_o => co, sinh_o => si);

    clk_gen : process
    begin
        while not finished loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    stim : process
        variable t, ec, es, maxe : real := 0.0;
    begin
        wait for 20 ns;
        rst_n <= '1';
        for i in -22 to 22 loop
            t := real(i) * 0.05;
            theta <= to_signed(integer(t * SCALE), 32);
            wait until rising_edge(clk);
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            wait until done = '1';
            wait for 1 ns;
            ec := abs(real(to_integer(co)) - cosh(t) * SCALE);
            es := abs(real(to_integer(si)) - sinh(t) * SCALE);
            if ec > maxe then maxe := ec; end if;
            if es > maxe then maxe := es; end if;
            report "theta=" & real'image(t) &
                   " err_lsb cosh=" & integer'image(integer(ec)) &
                   " sinh=" & integer'image(integer(es));
        end loop;
        report "max error = " & integer'image(integer(maxe)) & " LSB (Q4.28)";
        if maxe < 64.0 then
            report "PASS";
        else
            report "FAIL" severity failure;
        end if;
        finished <= true;
        wait;
    end process;
end architecture;
