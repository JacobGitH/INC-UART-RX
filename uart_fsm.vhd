-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xkopec58
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   BITCounter : in std_logic_vector(3 downto 0);
   CLKCounter : in std_logic_vector(4 downto 0);
   CountEnable : out std_logic;
   BitEnable : out std_logic;
   DoutVldSignal : out std_logic
   );
end entity UART_FSM;
-------------------------------------------------
architecture behavioral of UART_FSM is
   type CStatus is (WaitingForStartBit, STARTBit, Data, STOPBit, DOUT_VLD );
   signal status : CStatus := WaitingForStartBit;
begin

   CountEnable <= '1' when status = STARTBit or status = Data or status = STOPBit else '0';
   BitEnable <= '1' when status = Data else '0';
   DoutVldSignal <= '1' when status = DOUT_VLD else '0';

   process (CLK, RST)  begin
      if CLK'event AND CLK = '1' then
         if RST = '1' then
            status <= WaitingForStartBit;
         else
            case status is
               when WaitingForStartBit => 
                  if DIN = '0' then status <= STARTBit; end if;
               when STARTBit =>
                  if CLKCounter = "10110" then status <= Data; end if;
               when Data => 
                  if BITCounter = "1000" then status <= STOPBit; end if;
               when STOPBit =>
                  if CLKCounter = "10110" then status <= DOUT_VLD; end if;
               when DOUT_VLD => 
                  status <= WaitingForStartBit;
               when others => null;
            end case;
         end if;
      end if;
   end process;   
   
end behavioral;
