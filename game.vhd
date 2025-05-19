LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY clock_divider IS
    GENERIC (
        HALF_MS_COUNT : INTEGER := 50000 -- Para 100 MHz
    );
    PORT (
        clock    : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        ck_1KHz  : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF clock_divider IS
    SIGNAL count_50K  : INTEGER RANGE 0 TO HALF_MS_COUNT-1 := 0;
    SIGNAL ck_1KHz_int: STD_LOGIC := '0';
BEGIN
    ck_1KHz <= ck_1KHz_int;

    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            ck_1KHz_int <= '0';
            count_50K   <= 0;
        ELSIF rising_edge(clock) THEN
            IF count_50K = HALF_MS_COUNT - 1 THEN
                ck_1KHz_int <= NOT ck_1KHz_int;
                count_50K   <= 0;
            ELSE
                count_50K <= count_50K + 1;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY Game IS PORT (
    input           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    clk             : IN  STD_LOGIC;
    ok              : IN  STD_LOGIC;
    display_segment : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    AN              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 0 ativa, 1 desliga
    vit1            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vit2            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE game OF Game IS

    SIGNAL estados   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL segr1     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL segr2     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL clear     : STD_LOGIC := '0';
    SIGNAL w1        : unsigned(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w2        : unsigned(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dsp_msg   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
    SIGNAL counter   : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ck_1KHz   : STD_LOGIC;
BEGIN

    -- Instância do divisor de clock
    div_clock: ENTITY work.clock_divider
    GENERIC MAP (
        HALF_MS_COUNT => 50000
    )
    PORT MAP (
        clock    => clk,
        reset    => '0', -- Reset desabilitado
        ck_1KHz  => ck_1KHz
    );

    main : PROCESS (ck_1KHz)
        VARIABLE num0, num1, num2, num3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE adv : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE touro, vaca : INTEGER := 0;
        VARIABLE current_p : INTEGER := 1;
    BEGIN
        IF rising_edge(ck_1KHz) THEN
            CASE dsp_msg IS
                WHEN "001" =>
                    --algoritmo pra imprimir "J1 SETUP"

                    CASE counter IS

                        WHEN "0000" =>
                            AN <= "01111111";
                            display_segment <= "10000111"; -- (BCD) 11100001 (original)
                            counter <= "0001";
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "10011111";
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11111111";
                            display_segment <= "11111111";
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "01001001";
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "01100001";
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            display_segment <= "11100001";
                            counter <= "0110";
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "10000011";
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "00110001";
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;
              WHEN "010" =>
                    --algoritmo pra imprimir "J2 SETUP"
                    CASE counter IS

                        WHEN "0000" =>
                            AN <= "01111111";
                            display_segment <= "10000111"; -- J
                            counter <= "0001";
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "00100101"; -- 2 ( A B G  D E )
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11011111";
                            display_segment <= "11111111"; -- espaco
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "01001001"; -- s
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "01100001"; -- e
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            display_segment <= "11100001"; -- t (FEDG)
                            counter <= "0110";
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "10000011"; -- u
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "00110001"; -- p
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;

                WHEN "011" =>
                    --algoritmo pra imprimir "J1 GUESS"

                    CASE counter IS

                        WHEN "0000" =>
                            AN <= "01111111";
                            display_segment <= "10000111"; -- J (bcde)
                            counter <= "0001";
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "10011111"; -- 1
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11011111";
                            display_segment <= "11111111"; -- espaco
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "01000000"; -- g ( acdefg )
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "10000011"; -- u
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            display_segment <= "01100001"; -- e (FEDG)
                            counter <= "0110";
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "01001001"; -- s
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "01001001"; -- s
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;

                WHEN "100" =>
                    --algoritmo pra imprimir "J2 GUESS"
                    CASE counter IS

                        WHEN "0000" =>
                            AN <= "01111111";
                            display_segment <= "10000111"; -- J
                            counter <= "0001";
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "00100101"; -- 2
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11011111";
                            display_segment <= "11111111"; -- espaco
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "01000001"; -- g ( acdefg )
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "10000011"; -- u
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            display_segment <= "01100001"; -- e (FEDG)
                            counter <= "0110";
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "01001001"; -- s
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "01001001"; -- s
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;

                WHEN "101" =>
                    --algoritmo pra imprimir " x TO y VA"
                    CASE counter IS

                        WHEN "0000" => -- touro
                            AN <= "01111111";
                            CASE touro IS
                                WHEN 0 =>
                                    display_segment <= "00000001"; -- 0
                                    counter <= "0001";
                                WHEN 1 =>
                                    display_segment <= "10011111"; -- 1
                                    counter <= "0001";
                                WHEN 2 =>
                                    display_segment <= "00100101"; -- 2
                                    counter <= "0001";
                                WHEN 3 =>
                                    display_segment <= "00001101"; -- 3
                                    counter <= "0001";
                                WHEN OTHERS =>  display_segment <= "10000001";
                            END CASE;
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "11111111"; -- espaco
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11011111";
                            display_segment <= "11100001"; -- t 
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "00000011"; -- o
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "11111111"; -- espaco
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            CASE vaca IS
                                WHEN 0 =>
                                    display_segment <= "00000011"; -- 0
                                    counter <= "0110";
                                WHEN 1 =>
                                    display_segment <= "10011111"; -- 1
                                    counter <= "0110";
                                WHEN 2 =>
                                    display_segment <= "00100101"; -- 2
                                    counter <= "0110";
                                WHEN 3 =>
                                    display_segment <= "00001101"; -- 3
                                    counter <= "0110";
                                WHEN 4 =>
                                    display_segment <= "10011001"; -- 4 (bcfg)
                                    counter <= "0110";
                                WHEN OTHERS =>
                            END CASE;
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "10000010"; -- v
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "00010001"; -- a (abcefg)
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;
                WHEN "110" =>
                    --algoritmo pra imprimir "BULLSEYE"
                    CASE counter IS

                        WHEN "0000" =>
                            AN <= "01111111";
                            display_segment <= "11000001"; -- B
                            counter <= "0001";
                        WHEN "0001" =>
                            AN <= "10111111";
                            display_segment <= "10000011"; -- u
                            counter <= "0010";
                        WHEN "0010" =>
                            AN <= "11011111";
                            display_segment <= "11100011"; -- l
                            counter <= "0011";
                        WHEN "0011" =>
                            AN <= "11101111";
                            display_segment <= "11100011"; -- l
                            counter <= "0100";
                        WHEN "0100" =>
                            AN <= "11110111";
                            display_segment <= "01001001"; -- s
                            counter <= "0101";
                        WHEN "0101" =>
                            AN <= "11111011";
                            display_segment <= "01100001"; -- e
                            counter <= "0110";
                        WHEN "0110" =>
                            AN <= "11111101";
                            display_segment <= "10001001"; -- y
                            counter <= "0111";
                        WHEN "0111" =>
                            AN <= "11111110";
                            display_segment <= "01100001"; -- e
                            counter <= "0000";
                        WHEN OTHERS =>
                    END CASE;
                WHEN OTHERS =>
            END CASE;

            -- Lógica do jogo
             IF (ok = '0') THEN --para que o input só seja aceito 1 vez
                clear <= '0'; -- clear seria a flag que só reseta quando param de precionar o botao
            ELSIF (ok = '1' AND clear = '0') THEN
                CASE estados IS
                    WHEN "000" => -- ler segr1
                        segr1 <= input;
                        num0 := input (3 DOWNTO 0);
                        num1 := input (7 DOWNTO 4);
                        num2 := input (11 DOWNTO 8);
                        num3 := input (15 DOWNTO 12);
                        IF (num0 = num1 OR num0 = num2 OR num0 = num3 OR num1 = num2 OR num1 = num3 OR num2 = num3) THEN
                            -- faz alguma coisa pra mostrar erro: parte = rodrigo;
                        ELSE
                            estados <= "001";
                        END IF;
                        clear <= '1';
                        dsp_msg <= "010";
                    WHEN "001" => -- ler segr2
                        segr2 <= input;
                        num0 := input (3 DOWNTO 0);
                        num1 := input (7 DOWNTO 4);
                        num2 := input (11 DOWNTO 8);
                        num3 := input (15 DOWNTO 12);
                        IF (num0 = num1 OR num0 = num2 OR num0 = num3 OR num1 = num2 OR num1 = num3 OR num2 = num3) THEN
                            -- faz alguma coisa pra mostrar erro: parte = rodrigo;
                        ELSE
                            estados <= "010";
                        END IF;
                        clear <= '1';
                        dsp_msg <= "011";
                    WHEN "010" => -- user1 tenta adivinhar o segredo do user2
                        touro := 0;
                        vaca := 0;
                        adv := input;
                        IF (adv(3 DOWNTO 0) = segr2(3 DOWNTO 0)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(7 DOWNTO 4) = segr2(7 DOWNTO 4)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(11 DOWNTO 8) = segr2(11 DOWNTO 8)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(15 DOWNTO 12) = segr2(15 DOWNTO 12)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(3 DOWNTO 0) = segr2(7 DOWNTO 4) OR adv(3 DOWNTO 0) = segr2(11 DOWNTO 8) OR adv(3 DOWNTO 0) = segr2(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(7 DOWNTO 4) = segr2(3 DOWNTO 0) OR adv(7 DOWNTO 4) = segr2(11 DOWNTO 8) OR adv(7 DOWNTO 4) = segr2(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(11 DOWNTO 8) = segr2(7 DOWNTO 4) OR adv(11 DOWNTO 8) = segr2(3 DOWNTO 0) OR adv(11 DOWNTO 8) = segr2(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(15 DOWNTO 12) = segr2(7 DOWNTO 4) OR adv(15 DOWNTO 12) = segr2(11 DOWNTO 8) OR adv(15 DOWNTO 12) = segr2(3 DOWNTO 0)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (touro = 4) THEN
                            w1 <= w1 + b"1";
                            estados <= "101";
                            dsp_msg <= "110";
                        ELSE
                            estados <= "100";
                            dsp_msg <= "101";
                        END IF;
                        clear <= '1';
                    WHEN "011" => -- user2 tenta adivinhar o segredo do user1
                        touro := 0;
                        vaca := 0;
                        adv := input;
                        IF (adv(3 DOWNTO 0) = segr1(3 DOWNTO 0)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(7 DOWNTO 4) = segr1(7 DOWNTO 4)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(11 DOWNTO 8) = segr1(11 DOWNTO 8)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(15 DOWNTO 12) = segr2(15 DOWNTO 12)) THEN
                            touro := touro + 1;
                        END IF;
                        IF (adv(3 DOWNTO 0) = segr1(7 DOWNTO 4) OR adv(3 DOWNTO 0) = segr1(11 DOWNTO 8) OR adv(3 DOWNTO 0) = segr1(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(7 DOWNTO 4) = segr1(3 DOWNTO 0) OR adv(7 DOWNTO 4) = segr1(11 DOWNTO 8) OR adv(7 DOWNTO 4) = segr1(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(11 DOWNTO 8) = segr1(7 DOWNTO 4) OR adv(11 DOWNTO 8) = segr1(3 DOWNTO 0) OR adv(11 DOWNTO 8) = segr1(15 DOWNTO 12)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (adv(15 DOWNTO 12) = segr1(7 DOWNTO 4) OR adv(15 DOWNTO 12) = segr1(11 DOWNTO 8) OR adv(15 DOWNTO 12) = segr1(3 DOWNTO 0)) THEN
                            vaca := vaca + 1;
                        END IF;
                        IF (touro = 4) THEN
                            w2 <= w2 + b"1";
                            estados <= "101";
                            dsp_msg <= "110";
                        ELSE
                            estados <= "100";
                            dsp_msg <= "101";
                        END IF;
                        clear <= '1';
                    WHEN "100" =>
                        IF (current_p = 1) THEN
                            estados <= "011";
                            dsp_msg <= "100";
                            current_p := current_p + 1;
                        ELSIF (current_p = 2) THEN
                            estados <= "010";
                            dsp_msg <= "011";
                            current_p := current_p - 1;
                        END IF;
                        clear <= '1';
                    WHEN "101" =>
                            estados <= "000";
                            current_p := 1;
                            dsp_msg <= "001";
                        clear <= '1';
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Atribuição das saídas de vitórias
    vit1 <= STD_LOGIC_VECTOR(w1);
    vit2 <= STD_LOGIC_VECTOR(w2);

END ARCHITECTURE;