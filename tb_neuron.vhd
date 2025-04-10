library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_neuron_controlled is
end tb_neuron_controlled;

architecture Behavioral of tb_neuron_controlled is

    constant clk_period : time := 10 ns;

    -- DUT parameters
    constant dataWidth : integer := 16;
    constant addrWidth : integer := 10;

    signal clk               : std_logic := '0';
    signal rst               : std_logic := '1';

    signal config_layer_num  : std_logic_vector(31 downto 0);
    signal config_neuron_num : std_logic_vector(31 downto 0);
    signal weightValue       : std_logic_vector(dataWidth-1 downto 0);
    signal weightValid       : std_logic := '0';

    signal myinput           : std_logic_vector(dataWidth-1 downto 0);
    signal myinputValid      : std_logic := '0';

    signal bias              : signed(dataWidth-1 downto 0) := to_signed(5, dataWidth);

    signal outvalid          : std_logic;
    signal output_val        : std_logic_vector(dataWidth-1 downto 0);
    signal mul1           : signed(2*dataWidth-1 downto 0):= (others => '0');
    signal sum1          : signed(2*dataWidth-1 downto 0) := (others => '0');

begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- DUT instantiation
    DUT: entity work.neuron_controlled
        generic map (
            dataWidth => dataWidth,
            addrWidth => addrWidth,
            layerNo   => 0,
            neuronNo  => 0
        )
        port map (
            clk               => clk,
            rst               => rst,
            config_layer_num  => config_layer_num,
            config_neuron_num => config_neuron_num,
            weightValue       => weightValue,
            weightValid       => weightValid,
            myinput           => myinput,
            myinputValid      => myinputValid,
            bias              => bias,
            outvalid          => outvalid,
            output_result     => output_val
            
        );

    -- Stimulus process
    stim_proc : process
    begin
        
        rst <= '0';
        -- Config layer/neuron
        config_layer_num  <= x"00000000";
        config_neuron_num <= x"00000000";
     
        
        -- Carica pesi
--        for i in 0 to 3 loop
--            weightValue <= std_logic_vector(to_signed(2 * (i + 1), dataWidth));  -- pesi: 2, 4, 6, 8
--            weightValid <= '1';
--        end loop;
--        weightValid <= '0';
       --dopo un ciclo di clock da weightValid sarà valido 
        --wait for 20 ns;

        -- Invia input
        for i in 0 to 3 loop
            myinput <= std_logic_vector(to_signed(i + 1, dataWidth));  
            myinputValid <= '1';
            wait for clk_period;
        end loop;
        myinputValid <= '0';

        wait for 50 ns;
        
         for i in 0 to 3 loop
            myinput <= std_logic_vector(to_signed(i + 50, dataWidth));  
            myinputValid <= '1';
            wait for clk_period;
        end loop;
        myinputValid <= '0';
        wait;
     
    end process;

 
end Behavioral;
