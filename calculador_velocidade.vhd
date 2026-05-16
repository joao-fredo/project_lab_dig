library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculador_velocidade is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        atualiza       : in  std_logic;
        q3, q2, q1, q0 : in  std_logic_vector(3 downto 0);
        v3, v2, v1, v0 : out std_logic_vector(3 downto 0);
        multa_vel      : out std_logic -- NOVO: Pino de excesso de velocidade
    );
end entity;

architecture calc of calculador_velocidade is
    signal tempo_int : integer range 0 to 9999;
    signal vel_int   : integer range 0 to 9999;
begin
    tempo_int <= to_integer(unsigned(q3)) * 1000 +
                 to_integer(unsigned(q2)) * 100 +
                 to_integer(unsigned(q1)) * 10 +
                 to_integer(unsigned(q0));

    process(clock, reset)
    begin
        if reset = '1' then
            vel_int <= 0;
        elsif rising_edge(clock) then
            if atualiza = '1' then
                if tempo_int > 0 then
                    vel_int <= 1000 / tempo_int;
                else
                    vel_int <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Lógica de Multa (> 10.0 m/s)
    multa_vel <= '1' when vel_int > 100 else '0';

    v0 <= std_logic_vector(to_unsigned(vel_int mod 10, 4));
    v1 <= std_logic_vector(to_unsigned((vel_int / 10) mod 10, 4));
    v2 <= std_logic_vector(to_unsigned((vel_int / 100) mod 10, 4));
    v3 <= std_logic_vector(to_unsigned((vel_int / 1000) mod 10, 4));

end architecture;
