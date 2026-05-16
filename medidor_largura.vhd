library ieee;
use ieee.std_logic_1164.all;

entity medidor_largura is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        liga         : in  std_logic;
        sinal        : in  std_logic;
        display0     : out std_logic_vector(6 downto 0);
        display1     : out std_logic_vector(6 downto 0);
        display2     : out std_logic_vector(6 downto 0);
        display3     : out std_logic_vector(6 downto 0);
        db_estado    : out std_logic_vector(6 downto 0); 
        pronto       : out std_logic;
        fim          : out std_logic;
        multa_vel    : out std_logic; -- NOVO PINO: Exportando a multa para o Top-Level
        db_clock     : out std_logic;
        db_sinal     : out std_logic;
        db_zeraCont  : out std_logic;
        db_contaCont : out std_logic
    );
end entity medidor_largura;

architecture estrutural of medidor_largura is

    -- Atualizando o componente interno para reconhecer o pino de multa que vem do calculador
    component cont10_4digitos_7seg is
        port (
            clock    : in  std_logic;
            clear    : in  std_logic;
            enable   : in  std_logic;
            display0 : out std_logic_vector(6 downto 0);
            display1 : out std_logic_vector(6 downto 0);
            display2 : out std_logic_vector(6 downto 0);
            display3 : out std_logic_vector(6 downto 0);
            RCO      : out std_logic;
            multa_vel: out std_logic  -- NOVO PINO AQUI TAMBÉM
        );
    end component;

begin

    fd: cont10_4digitos_7seg
        port map (
            clock    => clock,
            clear    => reset,        
            enable   => sinal,        
            display0 => display0,
            display1 => display1,
            display2 => display2,
            display3 => display3,
            RCO      => fim,
            multa_vel=> multa_vel     -- Conectando a saída do bloco à saída do medidor
        );

    -- Ligando os LEDs de depuração
    pronto       <= not sinal;
    db_clock     <= clock;        
    db_sinal     <= sinal;        
    db_zeraCont  <= reset;
    db_contaCont <= sinal;        
    db_estado    <= "1111111";

end architecture estrutural;
