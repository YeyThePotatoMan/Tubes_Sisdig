library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_hyp is
    port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        start  : in  std_logic;
        theta  : in  signed(31 downto 0);
        done   : out std_logic;
        cosh_o : out signed(31 downto 0);
        sinh_o : out signed(31 downto 0)
    );
end entity;

architecture rtl of cordic_hyp is
    constant N  : integer := 30;
    constant X0 : signed(31 downto 0) := to_signed(324135026, 32);

    type rom_t is array (0 to N - 1) of integer;
    constant ANG : rom_t := (
        147453245, 68561855, 33730852, 16799113, 16799113,
        8391340, 4194645, 2097195, 1048581, 524289,
        262144, 131072, 65536, 32768, 32768,
        16384, 8192, 4096, 2048, 1024,
        512, 256, 128, 64, 32,
        16, 8, 4, 2, 1
    );

    function shift_of(k : integer) return integer is
    begin
        if k <= 2 then
            return k + 1;
        elsif k <= 4 then
            return 4;
        elsif k <= 13 then
            return k;
        else
            return k - 1;
        end if;
    end function;

    signal x, y, z : signed(31 downto 0);
    signal k       : integer range 0 to N - 1;
    signal busy    : std_logic;
begin
    cosh_o <= x;
    sinh_o <= y;

    process (clk, rst_n)
        variable sh : integer range 0 to 31;
        variable dx, dy : signed(31 downto 0);
    begin
        if rst_n = '0' then
            busy <= '0';
            done <= '0';
            k    <= 0;
            x    <= (others => '0');
            y    <= (others => '0');
            z    <= (others => '0');
        elsif rising_edge(clk) then
            done <= '0';
            if busy = '0' then
                if start = '1' then
                    x    <= X0;
                    y    <= (others => '0');
                    z    <= theta;
                    k    <= 0;
                    busy <= '1';
                end if;
            else
                sh := shift_of(k);
                dx := shift_right(y, sh);
                dy := shift_right(x, sh);
                if z(31) = '1' then
                    x <= x - dx;
                    y <= y - dy;
                    z <= z + to_signed(ANG(k), 32);
                else
                    x <= x + dx;
                    y <= y + dy;
                    z <= z - to_signed(ANG(k), 32);
                end if;
                if k = N - 1 then
                    busy <= '0';
                    done <= '1';
                else
                    k <= k + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
