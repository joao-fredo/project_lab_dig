library ieee;
use ieee.std_logic_1164.all;

entity tb_pista_simulacao is
end entity;

architecture sim of tb_pista_simulacao is

    signal clock   : std_logic := '0';
    signal reset   : std_logic := '0';
    signal iniciar : std_logic := '0';
    signal sensor1 : std_logic := '0';
    signal sensor2 : std_logic := '0';
    
    signal pronto  : std_logic;
    signal multa   : std_logic;
    signal tempo0  : std_logic_vector(6 downto 0);
    signal tempo1  : std_logic_vector(6 downto 0);
    signal tempo2  : std_logic_vector(6 downto 0);
    signal tempo3  : std_logic_vector(6 downto 0);

    -- Clock de 1 ms
    constant clk_period : time := 1 ms;

begin

    DUT: entity work.pista_simulacao
        port map (
            clock   => clock,
            reset   => reset,
            iniciar => iniciar,
            sensor1 => sensor1,
            sensor2 => sensor2,
            pronto  => pronto,
            multa   => multa,
            tempo0  => tempo0,
            tempo1  => tempo1,
            tempo2  => tempo2,
            tempo3  => tempo3
        );

    clk_process: process
    begin
        while true loop
            clock <= '0';
            wait for clk_period / 2;
            clock <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_process: process
    begin
        -- ========================================================
        -- INICIALIZAÇÃO E TESTE 1: Reset e Prontidão
        -- ========================================================
        reset <= '1';
        wait for 2 * clk_period;
        reset <= '0';
        wait for 2 * clk_period;
        
        iniciar <= '1';
        wait for 2 * clk_period;
        iniciar <= '0';
        wait for 10 * clk_period;

        -- ========================================================
        -- TESTE 2: Medição Válida (Sem Multa) 
        -- Tempo = 150 ms | Vel Real = 0.66 m/s | Display: 0006 (0.6)
        -- ========================================================
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 148 * clk_period;
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 3: Excesso de Velocidade (> 10 m/s)
        -- Tempo = 8 ms | Vel Real = 12.5 m/s | Display: 0125 (12.5) | MULTA = 1
        -- ========================================================
        iniciar <= '1'; wait for 2 * clk_period; iniciar <= '0'; wait for 5 * clk_period;
        
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 6 * clk_period; -- Tempo corrigido para disparar a multa!
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 4: Contramão
        -- Tempo = 150 ms invertidos | Vel = 0.6 m/s | MULTA = 1 (Sentido)
        -- ========================================================
        iniciar <= '1'; wait for 2 * clk_period; iniciar <= '0'; wait for 5 * clk_period;
        
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0'; -- Aciona Sensor 2 primeiro
        wait for 148 * clk_period;
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 7 e 8: Auto-rearme do sentido correto e incorreto
        -- Tempo em ambos = 100 ms | Vel = 1.0 m/s | Display: 0010 (1.0)
        -- ========================================================
        -- Placa exibindo multa da contramão. Aciona sensor 1 direto:
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 98 * clk_period;
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0';
        wait for 20 * clk_period;

        -- Placa exibindo sentido correto. Aciona sensor 2 direto (contramão):
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0';
        wait for 98 * clk_period;
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 9: Proteção contra Divisão por Zero
        -- Sensores ativados juntos (Tempo = 0) | Vel = 0000 | Evita crash
        -- ========================================================
        iniciar <= '1'; wait for 2 * clk_period; iniciar <= '0'; wait for 5 * clk_period;
        
        sensor1 <= '1'; sensor2 <= '1'; -- Ambos ao mesmo tempo
        wait for 5 * clk_period;
        sensor1 <= '0'; sensor2 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 10: Imunidade a ruído nos botões
        -- Tempo total = 100 ms | Vel = 1.0 m/s | Display: 0010
        -- ========================================================
        iniciar <= '1'; wait for 2 * clk_period; iniciar <= '0'; wait for 5 * clk_period;
        
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 50 * clk_period;
        
        iniciar <= '1'; wait for 5 * clk_period; iniciar <= '0'; -- Ruído intencional!
        
        wait for 50 * clk_period;
        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0';
        wait for 20 * clk_period;

        -- ========================================================
        -- TESTE 5 e 6: Timeout (10 segundos para estourar o contador)
        -- ========================================================
        iniciar <= '1'; wait for 2 * clk_period; iniciar <= '0'; wait for 5 * clk_period;
        
        sensor1 <= '1'; wait for 2 * clk_period; sensor1 <= '0';
        wait for 10005 * clk_period; -- Aguarda estourar os 9999 ms do BCD

        sensor2 <= '1'; wait for 2 * clk_period; sensor2 <= '0'; -- Inicia contramão
        wait for 10005 * clk_period; -- Aguarda estourar também

        wait; -- Fim da simulação
    end process;

end architecture;
