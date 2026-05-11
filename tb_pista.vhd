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
    signal tempo0  : std_logic_vector(6 downto 0);
    signal tempo1  : std_logic_vector(6 downto 0);
    signal tempo2  : std_logic_vector(6 downto 0);
    signal tempo3  : std_logic_vector(6 downto 0);

    -- Clock de 1 ms (já adaptado para o bypass do divisor)
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
        -- INICIALIZAÇÃO
        reset <= '1';
        wait for 2 * clk_period;
        reset <= '0';
        wait for 2 * clk_period;

        -- TESTE 1: Passagem de 350 ms
        iniciar <= '1';
        wait for 2 * clk_period;
        iniciar <= '0';
        wait for 10 * clk_period;

        sensor1 <= '1';
        wait for 2 * clk_period; 
        sensor1 <= '0';

        wait for 350 * clk_period;

        sensor2 <= '1';
        wait for 2 * clk_period;
        sensor2 <= '0';

        wait for 20 * clk_period;

        -- TESTE 2: Passagem de 125 ms
        iniciar <= '1';
        wait for 2 * clk_period;
        iniciar <= '0';
        wait for 10 * clk_period;

        sensor1 <= '1';
        wait for 2 * clk_period;
        sensor1 <= '0';

        wait for 125 * clk_period;

        sensor2 <= '1';
        wait for 2 * clk_period;
        sensor2 <= '0';

        wait for 20 * clk_period;

        wait;
    end process;

end architecture;
