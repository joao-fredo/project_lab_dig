library ieee;
use ieee.std_logic_1164.all;

entity pista_simulacao is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        iniciar    : in  std_logic;
        sensor1    : in  std_logic;
        sensor2    : in  std_logic;
        pronto     : out std_logic;
        multa      : out std_logic; -- NOVO: Pino que vai para o LED/Buzzer da FPGA
        tempo0     : out std_logic_vector(6 downto 0);
        tempo1     : out std_logic_vector(6 downto 0);
        tempo2     : out std_logic_vector(6 downto 0);
        tempo3     : out std_logic_vector(6 downto 0)
    );
end entity;

architecture estrutural of pista_simulacao is

    signal s_medir         : std_logic;
    signal s_zera          : std_logic; 
    signal s_fim           : std_logic; -- Fio do estouro de tempo
    signal s_multa_vel     : std_logic; -- Fio da velocidade limite
    signal s_multa_sentido : std_logic; -- Fio da contramão
    signal s_pronto        : std_logic; 
    
    signal s_reset_medidor : std_logic;

begin

    s_reset_medidor <= reset or s_zera;
    pronto          <= s_pronto;

    -- A multa global só apita se a medição acabou E (houve excesso de vel. OU contramão)
    multa <= s_pronto and (s_multa_vel or s_multa_sentido);

    UC_PISTA: entity work.uc_pista
        port map (
            clock         => clock,
            reset         => reset,
            iniciar       => iniciar,
            sensor1       => sensor1,
            sensor2       => sensor2,
            fim           => s_fim,            -- Liga o RCO à Máquina de Estados
            zera          => s_zera,     
            pronto        => s_pronto,
            medir         => s_medir,
            multa_sentido => s_multa_sentido   -- Extrai a contramão
        );

    MEDIDOR: entity work.medidor_largura
        port map (
            clock        => clock,
            reset        => s_reset_medidor, 
            liga         => '1',      
            sinal        => s_medir,  
            display0     => tempo0,
            display1     => tempo1,
            display2     => tempo2,
            display3     => tempo3,
            db_estado    => open, 
            pronto       => open,
            fim          => s_fim,             -- Extrai o RCO do contador
            multa_vel    => s_multa_vel,       -- Extrai a verificação > 10m/s
            db_clock     => open,
            db_sinal     => open,
            db_zeraCont  => open,
            db_contaCont => open
        );

end architecture;
