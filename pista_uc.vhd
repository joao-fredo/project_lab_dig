library ieee;
use ieee.std_logic_1164.all;

entity uc_pista is
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        iniciar       : in  std_logic;
        sensor1       : in  std_logic;
        sensor2       : in  std_logic;
        fim           : in  std_logic;
        zera          : out std_logic;
        pronto        : out std_logic;
        medir         : out std_logic;
        multa_sentido : out std_logic
    );
end entity;

architecture fsm of uc_pista is
    type estado_t is (ST_IDLE, ST_PREPARADO, ST_MEDINDO, ST_MEDINDO_INV, ST_RESULTADO, ST_RESULTADO_INV);
    signal estado, prox_estado : estado_t;

    signal s1_reg, s2_reg     : std_logic;
    signal s1_pulso, s2_pulso : std_logic;
begin
    -- 1. Lógica Combinacional do Detector de Borda
    s1_pulso <= sensor1 and not s1_reg;
    s2_pulso <= sensor2 and not s2_reg;

    -- 2. Registradores Síncronos (A mágica contra Glitches acontece aqui)
    process(clock, reset)
    begin
        if reset = '1' then
            estado <= ST_IDLE;
            s1_reg <= '0';
            s2_reg <= '0';
            zera   <= '1'; 
        elsif rising_edge(clock) then
            estado <= prox_estado;
            s1_reg <= sensor1;
            s2_reg <= sensor2;

            -- O pino 'zera' agora é um Flip-Flop! 
            if prox_estado = ST_IDLE or prox_estado = ST_PREPARADO then
                zera <= '1';
            elsif (estado = ST_RESULTADO or estado = ST_RESULTADO_INV) and (s1_pulso = '1' or s2_pulso = '1') then
                zera <= '1'; -- Garante o auto-rearme limpo
            else
                zera <= '0';
            end if;
        end if;
    end process;

    -- 3. Lógica de Próximo Estado
    process(estado, iniciar, s1_pulso, s2_pulso, fim)
    begin
        case estado is
            when ST_IDLE =>
                if iniciar = '1' then prox_estado <= ST_PREPARADO;
                else                  prox_estado <= ST_IDLE;
                end if;

            when ST_PREPARADO =>
                if s1_pulso = '1' then    prox_estado <= ST_MEDINDO;
                elsif s2_pulso = '1' then prox_estado <= ST_MEDINDO_INV;
                else                      prox_estado <= ST_PREPARADO;
                end if;

            when ST_MEDINDO =>
                if fim = '1' then         prox_estado <= ST_PREPARADO;
                elsif s2_pulso = '1' then prox_estado <= ST_RESULTADO;
                else                      prox_estado <= ST_MEDINDO;
                end if;

            when ST_MEDINDO_INV =>
                if fim = '1' then         prox_estado <= ST_PREPARADO;
                elsif s1_pulso = '1' then prox_estado <= ST_RESULTADO_INV;
                else                      prox_estado <= ST_MEDINDO_INV;
                end if;

            when ST_RESULTADO =>
                if iniciar = '1' then     prox_estado <= ST_PREPARADO;
                elsif s1_pulso = '1' then prox_estado <= ST_MEDINDO;
                elsif s2_pulso = '1' then prox_estado <= ST_MEDINDO_INV;
                else                      prox_estado <= ST_RESULTADO;
                end if;

            when ST_RESULTADO_INV =>
                if iniciar = '1' then     prox_estado <= ST_PREPARADO;
                elsif s1_pulso = '1' then prox_estado <= ST_MEDINDO;
                elsif s2_pulso = '1' then prox_estado <= ST_MEDINDO_INV;
                else                      prox_estado <= ST_RESULTADO_INV;
                end if;
        end case;
    end process;

    -- 4. Lógica de Saída (Exclusiva de controle)
    medir         <= '1' when (estado = ST_MEDINDO or estado = ST_MEDINDO_INV) else '0';
    pronto        <= '1' when (estado = ST_RESULTADO or estado = ST_RESULTADO_INV) else '0';
    multa_sentido <= '1' when estado = ST_RESULTADO_INV else '0';

end architecture;