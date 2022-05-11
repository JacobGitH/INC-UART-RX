-- uart.vhd: UART controller - receiving part
-- Author(s): xkopec58
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  
-------------------------------------------------
architecture behavioral of UART_RX is
signal bitcounter : std_logic_vector(3 downto 0);
signal clkcounter : std_logic_vector(4 downto 0);
signal bitenable : std_logic;
signal countenable : std_logic;
begin
	FSM: entity work.UART_FSM
	 port map (
		CLK => CLK,
		RST => RST,
		DIN => DIN,
		BITCounter => bitcounter,
		CLKCounter => clkcounter,
		CountEnable => countenable,
		BitEnable => bitenable,
		DoutVldSignal => DOUT_VLD
	);

	process(CLK, RST) begin --clk counter
		if CLK'event AND CLK = '1' then
			if RST = '0' then
				if countenable = '1' then
					clkcounter <= clkcounter + 1;
				else 
					clkcounter <= "00000";
				end if;
			else
				clkcounter <= "00000";
			end if;
			if bitenable = '1' and clkcounter(4) = '1' then
				clkcounter <= "00000";
			end if;
		end if;
	end process;


	process (CLK, RST) begin --bit counter
	if CLK'event AND CLK = '1' then
		if RST = '1' then
			bitcounter <= "0000";
		elsif bitenable = '0' then
			bitcounter <= "0000";
		end if;
		if bitenable = '1' and clkcounter(4) = '1' then
			bitcounter <= bitcounter + 1;
		end if;
	end if;
	end process;

	
	process (CLK) begin  -- output
	if CLK'event AND CLK = '1' then
			if bitenable = '1' and clkcounter(4) = '1' then 
				case bitcounter is
					when "0000" => DOUT(0) <= DIN;
					when "0001" => DOUT(1) <= DIN;
					when "0010" => DOUT(2) <= DIN;
					when "0011" => DOUT(3) <= DIN;
					when "0100" => DOUT(4) <= DIN;
					when "0101" => DOUT(5) <= DIN;
					when "0110" => DOUT(6) <= DIN;
					when "0111" => DOUT(7) <= DIN;
					when others => null;
				end case;
			end if;	
		end if;
	end process;

end behavioral;