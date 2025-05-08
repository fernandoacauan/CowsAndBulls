library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Game is port (
   input: in std_logic_vector(15 downto 0);
   clk:   in std_logic;
   ok:    in std_logic;
   vc:    out std_logic_vector(2 downto 0);
   tr:   out std_logic_vector(2 downto 0);
   vit1:  out std_logic_vector(7 downto 0);
   vit2:  out std_logic_vector(7 downto 0)
);
end entity;

--*******************************
--*     ESTADOS                 *
--* "000" ----> ler   segr1     *
--* "001" ----> ler   segr2     *
--* "010" ----> adv   segr2     *
--* "011" ----> adv   segr1     *
--*  100 -----> analisa digito? *
--* "101" ----> fim             *
--*******************************

architecture game of Game is 
   signal estados : std_logic_vector(2 downto 0) := "000";
   signal segr1   : std_logic_vector(15 downto 0) := "0000000000000000";
   signal segr2   : std_logic_vector(15 downto 0) := "0000000000000000";
   signal clear   : std_logic := '0';
   signal w1 	  : unsigned(7 downto 0) := "00000000";
   signal w2 	  : unsigned(7 downto 0) := "00000000";
   signal dsp_msg : std_logic_vector(2 downto 0) := "000";

--****ESTADOS DO dsp_msg*******
--  "000" limpa o clear       |
--  "001" imprime "J1 SETUP"  |
--  "010" imprime "J2 SETUP"  |
--  "011" imprime "J1 GUESS"  |
--  "100" imprime "J2 GUESS"  |
--  "101" imprime " x TO y VA"|
--  "110" imprime "BULLSEYE"  |
--***************************** 
   
begin
   main: process is
	variable num0 : std_logic_vector(3 downto 0);
	variable num1 : std_logic_vector(3 downto 0);
	variable num2 : std_logic_vector(3 downto 0);
	variable num3 : std_logic_vector(3 downto 0);
   	variable adv  : std_logic_vector(15 downto 0) := "0000000000000000";
	variable touro: integer;
	variable vaca : integer;
	variable current_p: integer := 1;
   begin
      if (rising_edge(clk)) then
       if (ok = '0') then --para que o input só seja aceito 1 vez
	case dsp_msg is
	   when "001" =>
	    --algoritmo pra imprimir "J1 SETUP"
	    dsp_msg <= "000";
	   when "010" =>
	    --algoritmo pra imprimir "J2 SETUP"
	    dsp_msg <= "000";
	   when "011" =>
	    --algoritmo pra imprimir "J1 GUESS"
	    dsp_msg <= "000";
	   when "100" =>
	    --algoritmo pra imprimir "J2 GUESS"
	    dsp_msg <= "000";
	   when "101" =>
	    --algoritmo pra imprimir " x TO y VA"
	    dsp_msg <= "000";
	   when "110" =>
	    --algoritmo pra imprimir "BULLSEYE"
	    dsp_msg <= "000";

	   when "000" =>
	    clear <= '0'; -- clear seria a flag que só reseta quando param de precionar o botao
	   when others => clear <= '0';
	  end case;
	elsif (ok = '1' and clear = '0') then
	case estados is
	  when "000" => -- ler segr1
		segr1 <= input;
		num0 := input (3 downto 0);
		num1 := input (4 downto 7);
		num2 := input (8 downto 11);
		num3 := input (12 downto 15);
		if( num0 = num1 or num0 = num2 or num0 = num3 or num1 = num2 or num1 = num3 or num2 = num3) then
				-- faz alguma coisa pra mostrar erro: parte = rodrigo;
		else
			estados <= "001"; 
		end if;
		clear <= '1';
		dsp_msg <= "010";
	 when  "001" => -- ler segr2
		segr2 <= input;
		num0 := input (3 downto 0);
		num1 := input (4 downto 7);
		num2 := input (8 downto 11);
		num3 := input (12 downto 15);
		if( num0 = num1 or num0 = num2 or num0 = num3 or num1 = num2 or num1 = num3 or num2 = num3) then
				-- faz alguma coisa pra mostrar erro: parte = rodrigo;
		else
			estados <= "010";  
		end if;
		clear <= '1';
		dsp_msg <= "011";
	  when "010" => -- user1 tenta adivinhar o segredo do user2
		touro := 0;
		vaca := 0;
		adv := input;
		if	(adv(0 downto 3) = segr2(0 downto 3)) then touro := touro + 1; end if;
		if	(adv(4 downto 7) = segr2(4 downto 7)) then touro := touro + 1; end if;
		if	(adv(8 downto 11) = segr2(8 downto 11)) then touro := touro + 1; end if;
		if	(adv(12 downto 15) = segr2(12 downto 15)) then touro := touro + 1; end if;
		if	(adv(0 downto 3) = segr2(4 downto 7) or adv(0 downto 3) = segr2(8 downto 11) or adv(0 downto 3) = segr2(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(4 downto 7) = segr2(0 downto 3) or adv(4 downto 7) = segr2(8 downto 11) or adv(4 downto 7) = segr2(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(8 downto 11) = segr2(4 downto 7) or adv(8 downto 11) = segr2(0 downto 3) or adv(8 downto 11) = segr2(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(12 downto 15) = segr2(4 downto 7) or adv(12 downto 15) = segr2(8 downto 11) or adv(12 downto 15) = segr2(0 downto 3)) then vaca := vaca + 1; end if;
		if (touro = 4) then 
			w1 <= w1 + b"1"; 
			estados <= "000";
			dsp_msg <= "110";
		else
			estados <= "100";
			dsp_msg <= "101";
		end if;
		clear <= '1';
	  when "011" => -- user2 tenta adivinhar o segredo do user1
		touro := 0;
		vaca := 0;
		adv := input;
		if	(adv(0 downto 3) = segr1(0 downto 3)) then touro := touro + 1; end if;
		if	(adv(4 downto 7) = segr1(4 downto 7)) then touro := touro + 1; end if;
		if	(adv(8 downto 11) = segr1(8 downto 11)) then touro := touro + 1; end if;
		if	(adv(12 downto 15) = segr2(12 downto 15)) then touro := touro + 1; end if;
		if	(adv(0 downto 3) = segr1(4 downto 7) or adv(0 downto 3) = segr1(8 downto 11) or adv(0 downto 3) = segr1(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(4 downto 7) = segr1(0 downto 3) or adv(4 downto 7) = segr1(8 downto 11) or adv(4 downto 7) = segr1(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(8 downto 11) = segr1(4 downto 7) or adv(8 downto 11) = segr1(0 downto 3) or adv(8 downto 11) = segr1(12 downto 15)) then vaca := vaca + 1; end if;
		if	(adv(12 downto 15) = segr1(4 downto 7) or adv(12 downto 15) = segr1(8 downto 11) or adv(12 downto 15) = segr1(0 downto 3)) then vaca := vaca + 1; end if;
		if(touro = 4) then 
			w2 <= w2 + b"1"; 
			estados <= "000";
			dsp_msg <= "110";
		else
			estados <= "100";
			dsp_msg <= "101";
		end if;
		clear <= '1';
	   when "100" =>
		if ( current_p = 1) then
			estados <= "011";
			dsp_msg <= "100";
			current_p := current_p + 1;
		elsif ( current_p = 2) then
			estados <= "010";
			dsp_msg <= "011";
			current_p := current_p - 1;
		end if;
		
	 when others =>
	end case;
      end if;
      end if;
      wait;
   end process;
end architecture;