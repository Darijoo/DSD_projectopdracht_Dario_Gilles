library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ov7670_controller is
end tb_ov7670_controller;

architecture Behavioral of tb_ov7670_controller is
    component ov7670_controller
        Port ( clk, resend : in STD_LOGIC;
               config_finished : out STD_LOGIC;
               sioc : out STD_LOGIC;
               siod : inout STD_LOGIC);
    end component;

    signal clk : std_logic := '0';
    signal resend : std_logic := '0';
    signal finished, sioc : std_logic;
    signal siod : std_logic;

begin
    uut: ov7670_controller port map (
        clk => clk, resend => resend,
        config_finished => finished, sioc => sioc, siod => siod
    );

    -- Simuleer de pull-up weerstand op de I2C lijn
    -- (In het echt trekt een weerstand de lijn naar 1 als niemand stuurt)
    siod <= 'H'; 

    clk_process: process
    begin
        clk <= '0'; wait for 10 ns; -- Snellere klok voor simulatie
        clk <= '1'; wait for 10 ns;
    end process;

    stim_proc: process
    begin
        -- Start conditie
        wait for 100 ns;
        resend <= '1'; -- Reset de controller
        wait for 100 ns;
        resend <= '0'; -- Start configuratie
        
        -- Wacht lang genoeg om een paar bits te zien verschuiven
        wait for 50 ms; 
        
        assert false report "Simulatie klaar" severity failure;
    end process;
end Behavioral;