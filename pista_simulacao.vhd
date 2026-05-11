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
        
        -- Saídas para os displays de tempo
        tempo0     : out std_logic_vector(6 downto 0);
        tempo1     : out std_logic_vector(6 downto 0);
        tempo2     : out std_logic_vector(6 downto 0);
        tempo3     : out std_logic_vector(6 downto 0)
    );
end entity;

architecture estrutural of pista_simulacao is

    -- Fio interno para conectar a UC ao Medidor
    signal s_medir : std_logic;

begin

    -- Instância da Unidade de Controle da Pista
    UC_PISTA: entity work.uc_pista
        port map (
            clock      => clock,
            reset      => reset,
            iniciar    => iniciar,
            sensor1    => sensor1,
            sensor2    => sensor2,
            zera       => open,       
            pronto     => pronto,
            medir      => s_medir     -- Fio que carrega o pulso gerado
        );

    -- Instância do Medidor de Largura de Pulso (Exp 04)
    MEDIDOR: entity work.medidor_largura
        port map (
            clock        => clock,
            reset        => reset,    -- Voltou ao normal (sem o 'not')
            liga         => '1',      -- Voltou a '1' fixo
            sinal        => s_medir,  -- Recebe o pulso gerado pela UC
            display0     => tempo0,
            display1     => tempo1,
            display2     => tempo2,
            display3     => tempo3,
            db_estado    => open, 
            pronto       => open,
            fim          => open,
            db_clock     => open,
            db_sinal     => open,
            db_zeraCont  => open,
            db_contaCont => open
        );

end architecture;
