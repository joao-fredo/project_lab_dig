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
        db_clock     : out std_logic;
        db_sinal     : out std_logic;
        db_zeraCont  : out std_logic;
        db_contaCont : out std_logic
    );
end entity medidor_largura;

architecture estrutural of medidor_largura is

    -- Mantemos apenas os contadores (O Fluxo de Dados)
    component cont10_4digitos_7seg is
        port (
            clock    : in  std_logic;
            clear    : in  std_logic;
            enable   : in  std_logic;
            display0 : out std_logic_vector(6 downto 0);
            display1 : out std_logic_vector(6 downto 0);
            display2 : out std_logic_vector(6 downto 0);
            display3 : out std_logic_vector(6 downto 0);
            RCO      : out std_logic
        );
    end component;

begin

    -- Ligação Direta (Bypass da UC antiga):
    -- O 'sinal' que chega da uc_pista vai ligar o contador diretamente!
    
    fd: cont10_4digitos_7seg
        port map (
            clock    => clock,
            clear    => reset,        -- O reset global zera o contador
            enable   => sinal,        -- O sinal 'medir' habilita a contagem!
            display0 => display0,
            display1 => display1,
            display2 => display2,
            display3 => display3,
            RCO      => fim           
        );

    -- Ligando os LEDs de depuração diretamente aos fios
    pronto       <= not sinal;    
    db_clock     <= clock;        
    db_sinal     <= sinal;        
    db_zeraCont  <= reset;        
    db_contaCont <= sinal;        

    -- Como removemos a UC antiga, o display de estado dela fica apagado
    db_estado    <= "1111111"; 

end architecture estrutural;
