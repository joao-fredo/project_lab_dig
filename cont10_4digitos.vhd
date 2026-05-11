library ieee;
use ieee.std_logic_1164.all;

entity cont10_4digitos is
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
end entity cont10_4digitos;

architecture estrutural of cont10_4digitos is

    -- Declaracao do componente de 1 digito projetado na Atividade 1
    component cont10 is
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            Q      : out std_logic_vector(3 downto 0);
            RCO    : out std_logic
        );
    end component;

    -- Sinais internos para receber os RCOs individuais de cada estagio
    signal rco_0, rco_1, rco_2, rco_3 : std_logic;
   
    -- Sinais internos para propagar o enable em cascata
    signal en_1, en_2, en_3 : std_logic;

begin

    -- Logica combinacional de geracao dos enables (cascateamento)
    en_1 <= enable and rco_0;
    en_2 <= en_1 and rco_1;
    en_3 <= en_2 and rco_2;

    -- Logica de geracao do RCO final do circuito de 4 digitos
    RCO  <= en_3 and rco_3;

    -- Instanciacao e Port Map dos 4 estagios
    c0: cont10 port map (
        clock  => clock,
        clear  => clear,
        enable => enable,
        Q      => Q0,
        RCO    => rco_0
    );
   
    c1: cont10 port map (
        clock  => clock,
        clear  => clear,
        enable => en_1,  
        Q      => Q1,
        RCO    => rco_1
    );
   
    c2: cont10 port map (
        clock  => clock,
        clear  => clear,
        enable => en_2,  
        Q      => Q2,
        RCO    => rco_2
    );
   
    c3: cont10 port map (
        clock  => clock,
        clear  => clear,
        enable => en_3,  
        Q      => Q3,
        RCO    => rco_3
    );

end architecture estrutural;
