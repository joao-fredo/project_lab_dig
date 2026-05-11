library ieee;
use ieee.std_logic_1164.all;

entity uc_pista is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        iniciar    : in  std_logic;
        sensor1    : in  std_logic;
        sensor2    : in  std_logic;
        zera       : out std_logic;
        pronto     : out std_logic;
        medir      : out std_logic -- Sinal que vai para a entrada 'sinal' do medidor
    );
end entity;

architecture fsm of uc_pista is
    type estado_t is (ST_IDLE, ST_PREPARADO, ST_MEDINDO, ST_RESULTADO);
    signal estado, prox_estado : estado_t;
begin
    -- Registro de Estado
    process(clock, reset)
    begin
        if reset = '1' then
            estado <= ST_IDLE;
        elsif rising_edge(clock) then
            estado <= prox_estado;
        end if;
    end process;

    -- Lógica de Próximo Estado
    process(estado, iniciar, sensor1, sensor2)
    begin
        case estado is
            when ST_IDLE =>
                if iniciar = '1' then prox_estado <= ST_PREPARADO;
                else                  prox_estado <= ST_IDLE;
                end if;

            when ST_PREPARADO =>
                if sensor1 = '1' then prox_estado <= ST_MEDINDO;
                else                  prox_estado <= ST_PREPARADO;
                end if;

            when ST_MEDINDO =>
                if sensor2 = '1' then prox_estado <= ST_RESULTADO;
                else                  prox_estado <= ST_MEDINDO;
                end if;

            when ST_RESULTADO =>
                if iniciar = '1' then prox_estado <= ST_PREPARADO;
                else                  prox_estado <= ST_RESULTADO;
                end if;
        end case;
    end process;

    -- Lógica de Saída
    zera   <= '1' when estado = ST_IDLE else '0';
    medir  <= '1' when estado = ST_MEDINDO else '0';
    pronto <= '1' when estado = ST_RESULTADO else '0';
end architecture;