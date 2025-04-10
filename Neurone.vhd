library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neuron_controlled is
    generic (
        dataWidth : integer := 16;
        addrWidth : integer := 10;
        layerNo   : integer := 0;
        neuronNo  : integer := 0
    );
    port (
        clk               : in  std_logic;
        rst               : in  std_logic;

        -- Configurazione pesi
        config_layer_num  : in  std_logic_vector(31 downto 0);
        config_neuron_num : in  std_logic_vector(31 downto 0);
        weightValue       : in  std_logic_vector(dataWidth-1 downto 0);--peso da scrivere in memoria
        weightValid       : in  std_logic;-- sempre per la scrittura

        -- Input runtime
        myinput           : in  std_logic_vector(dataWidth-1 downto 0):=(others=>'0');
        myinputValid      : in  std_logic:='0';

        -- Bias
        bias              : in  signed(dataWidth-1 downto 0);

        -- Output
        outvalid          : out std_logic;
        output_result     : out std_logic_vector(dataWidth-1 downto 0)
        
    );
end entity;

architecture Behavioral of neuron_controlled is

    -- Internal signals
    signal w_addr        : unsigned(addrWidth-1 downto 0) := (others => '0');
    signal r_addr        : unsigned(addrWidth-1 downto 0) := (others => '0');
    signal wen, ren      : std_logic := '0';

    signal w_in, w_out   : std_logic_vector(dataWidth-1 downto 0):=(others=>'0');
    signal myinputd      : std_logic_vector(dataWidth-1 downto 0):=(others=>'0');
    signal mul           : signed(2*dataWidth-1 downto 0):= (others => '0');
    signal sum           : signed(2*dataWidth-1 downto 0) := (others => '0');

    signal weight_valid, mult_valid : std_logic := '0';
    signal muxValid_d, muxValid_f   : std_logic := '0';
    signal sigValid                 : std_logic := '0';
    signal outvalid2                : std_logic;
    constant numWeight : unsigned(addrWidth-1 downto 0) := to_unsigned(4, addrWidth); -- Sono stati caricati pesi sufficenti?

    -- Attivazione
    signal act_input  : std_logic_vector(2*dataWidth-1 downto 0);
    signal act_output : std_logic_vector(dataWidth-1 downto 0);

begin

    -----------------------------------
    -- Istanziazione ROM pesi
    -----------------------------------
    weight_rom: entity work.rom
        generic map (
            data_width => dataWidth,
            addr_width => addrWidth
        )
        port map (
            address => std_logic_vector(r_addr),
            clk     => clk,
            data    => w_out
        );

    -----------------------------------
    -- Istanziazione ROM attivazione
    -----------------------------------
    activation_rom: entity work.Sig_ROM
        generic map (
            inWidth   => dataWidth,
            dataWidth => dataWidth
        )
        port map (
            clk       => clk,
            x         => act_input,
            out_value => act_output
        );

    -----------------------------------
    -- Scrittura pesi (configurazione)
    -----------------------------------
    process(clk)
    begin
    
        if rising_edge(clk) then
            if rst = '1' then
                w_addr <= (others => '0');
                wen <= '0';
            elsif weightValid = '1' and--2 ciclo di clock
                  config_layer_num = std_logic_vector(to_unsigned(layerNo, 32)) and
                  config_neuron_num = std_logic_vector(to_unsigned(neuronNo, 32)) then
                w_in <= weightValue;
                w_addr <= w_addr + 1;--indirizzo scrittura
                wen <= '1';
            else
                wen <= '0';
            end if;
        end if;
    end process;

    -----------------------------------
    -- Lettura pesi (runtime)
    -----------------------------------
    ren <= myinputValid;--permette la lettura della memoria pesi

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or outvalid2 = '1' then
                r_addr <= (others => '0');
            elsif myinputValid = '1' then--dal seconod ciclo
                r_addr <= r_addr + 1;--aumento dell'indirizzo lettura quando il segnale valid è alto 
            end if;
        end if;
    end process;

    -----------------------------------
    -- Moltiplicazione input * peso
    -----------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            mul <= signed(myinputd) * signed(w_out);--nelsecondo ciclo di clock del imput che abbiamo inserito lo somma
        
        end if;
    end process;

    -----------------------------------
    -- Accumulatore + bias
    -----------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or outvalid2 = '1' then
                sum <= (others => '0');
            elsif r_addr = numWeight and muxValid_f = '1' then--sommo dopo che ho finito i dati da inserire
                sum <= sum + bias;
            elsif mult_valid = '1' then
                sum <= sum + mul;--dal terzo ciclo
            end if;
        end if;
    
    end process;

    -----------------------------------
    -- Pipeline control
    -----------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
        --ciclo zero inserisco il primo dato
            myinputd     <= myinput;--1 ciclo di clock
            weight_valid <= myinputValid;--1cicli di clock
            mult_valid   <= weight_valid;--2 cicli di clock

            if r_addr = numWeight and muxValid_f = '1' then-- ho inserito tutti i dati
                sigValid <= '1';--6 ciclo di clock 
            else
                sigValid <= '0';
            end if;

            outvalid     <= sigValid;--un blocco successivo può leggere l'uscita
            outvalid2    <= sigValid;--7 ciclo di clock
            muxValid_d   <= mult_valid;--ritardo del segnale di 3 ciclo di clock
            muxValid_f   <= not mult_valid and muxValid_d;--abilita la somma con bias 4 cicli di clock
        end if;
    end process;

    -----------------------------------
    -- Output attivazione
    -----------------------------------
    act_input <= std_logic_vector(sum);
    output_result <= act_output;--uscita del neurone 
    

end Behavioral;
