----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2025 12:40:09
-- Design Name: 
-- Module Name: ROM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------




-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Sig_ROM is
    generic (
        inWidth   : integer := 32;  -- Larghezza dell'indirizzo di input
        dataWidth : integer := 16   -- Larghezza dei dati in uscita
    );
    port (
        clk       : in  std_logic;                               -- Segnale di clock
        x         : in  std_logic_vector(31 downto 0);   -- Input
        out_value : out std_logic_vector(dataWidth-1 downto 0)  -- Output
    );
end Sig_ROM;

architecture Behavioral of Sig_ROM is
    -- Memoria ROM
    type mem_type is array ( 0 to 2**inWidth-1) of std_logic_vector(dataWidth-1 downto 0);
    
    -- Funzione per caricare il contenuto della ROM da un file
    impure function init_mem (filename : string) return mem_type is
        file file_handle : text open read_mode is filename;
        variable line_content : line;
        variable mem_content : mem_type;
    begin
        for i in mem_content'range loop
            readline(file_handle, line_content);
            read(line_content, mem_content(i));
        end loop;
        return mem_content;
    end function;

    -- Inizializzazione della memoria come costante
    constant mem : mem_type := init_mem("sig_data.txt");

    -- Segnale per l'indirizzo calcolato
    signal y : std_logic_vector(inWidth-1 downto 0);

begin
    -- Processo di lettura dalla ROM
    process(clk)
    begin
        if rising_edge(clk) then
            -- Calcolo indirizzo simmetrico per valori positivi e negativi
            if signed(x) >= 0 then
                y <= std_logic_vector(signed(x)+ 2**(inWidth-1));
            else
                y <= std_logic_vector(unsigned(x)-2**(inWidth-1));
            end if;
            -- Lettura del valore dalla ROM
            out_value <= mem(to_integer(unsigned(y)));
        end if;
    end process;

end Behavioral;
