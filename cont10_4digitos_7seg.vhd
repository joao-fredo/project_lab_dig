library ieee;
use ieee.std_logic_1164.all;

entity cont10_4digitos_7seg is
    port (
        clock    : in  std_logic;
        clear    : in  std_logic;
        enable   : in  std_logic;
        display0 : out std_logic_vector(6 downto 0);
        display1 : out std_logic_vector(6 downto 0);
        display2 : out std_logic_vector(6 downto 0);
        display3 : out std_logic_vector(6 downto 0);
        RCO      : out std_logic;
        multa_vel: out std_logic -- O PINO FALTANDO DEVE ESTAR AQUI!
    );
end entity cont10_4digitos_7seg;

architecture estrutural of cont10_4digitos_7seg is

    component cont10_4digitos is
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            Q0     : out std_logic_vector(3 downto 0);
            Q1     : out std_logic_vector(3 downto 0);
            Q2     : out std_logic_vector(3 downto 0);
            Q3     : out std_logic_vector(3 downto 0);
            RCO    : out std_logic
        );
    end component;

    component hex7seg is
        port (
            hex     : in  std_logic_vector(3 downto 0);
            display : out std_logic_vector(6 downto 0)
        );
    end component;

    component calculador_velocidade is
        port (
            clock          : in  std_logic;
            reset          : in  std_logic;
            atualiza       : in  std_logic;
            q3, q2, q1, q0 : in  std_logic_vector(3 downto 0);
            v3, v2, v1, v0 : out std_logic_vector(3 downto 0);
            multa_vel      : out std_logic -- E AQUI!
        );
    end component;

    signal sQ0, sQ1, sQ2, sQ3 : std_logic_vector(3 downto 0);
    signal sV0, sV1, sV2, sV3 : std_logic_vector(3 downto 0);
    signal s_atualiza         : std_logic;

begin

    s_atualiza <= not enable;

    contador: cont10_4digitos port map (
        clock => clock, clear => clear, enable => enable,
        Q0 => sQ0, Q1 => sQ1, Q2 => sQ2, Q3 => sQ3, RCO => RCO
    );

    calculador: calculador_velocidade port map (
        clock => clock, reset => clear, atualiza => s_atualiza,
        q3 => sQ3, q2 => sQ2, q1 => sQ1, q0 => sQ0,
        v3 => sV3, v2 => sV2, v1 => sV1, v0 => sV0,
        multa_vel => multa_vel -- E CONECTADO AQUI!
    );

    hex0: hex7seg port map ( hex => sV0, display => display0 );
    hex1: hex7seg port map ( hex => sV1, display => display1 );
    hex2: hex7seg port map ( hex => sV2, display => display2 );
    hex3: hex7seg port map ( hex => sV3, display => display3 );

end architecture estrutural;
