----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.03.2025 14:01:36
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity rom is
    generic (
        data_width : integer := 32;  -- Width of each word in the ROM
        addr_width : integer := 10; -- Width of the address bus
        filename   : string  := "rom_data.txt"  -- File to initialize the ROM
    );
    port (
        address : in  std_logic_vector(addr_width-1 downto 0);
        clk: in std_logic;
        data    : out std_logic_vector(data_width-1 downto 0):=(others=>'0')
    );
end entity rom;

architecture impl of rom is
    subtype word_t is std_logic_vector(data_width-1 downto 0);
    type rom_array is array (0 to 2**addr_width-1) of word_t;
    -- Function to initialize ROM from a file
    impure function init_rom (filename : string) return rom_array is
        file init_file : text open read_mode is filename;
        variable init_line : line;
        variable result_mem : rom_array;
    begin
        for i in result_mem'range loop
            readline(init_file, init_line);
            ieee.std_logic_textio.read(init_line, result_mem(i));
        end loop;
        return result_mem;
    end init_rom;

    -- ROM signal initialized from the file
    signal rom : rom_array := init_rom(filename);
begin
    process(Clk)
    begin
     if rising_edge(clk) then
    -- Output data based on the address
    data <= rom(to_integer(unsigned(address)));
    end if;
    end process;
    
end architecture impl;