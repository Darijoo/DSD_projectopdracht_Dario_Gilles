library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vga is
-- Een testbench heeft geen poorten
end tb_vga;

architecture Behavioral of tb_vga is
    -- Component declaratie (Unit Under Test)
    component vga_driver
        Port ( clk_25mhz : in STD_LOGIC;
               reset : in STD_LOGIC;
               hsync, vsync, video_on : out STD_LOGIC;
               pixel_x, pixel_y : out STD_LOGIC_VECTOR(9 downto 0));
    end component;

    -- Signalen om de poorten aan te sturen
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal hsync, vsync, video_on : std_logic;
    signal px, py : std_logic_vector(9 downto 0);
    
    -- Klok periode (25 MHz = 40 ns)
    constant clk_period : time := 40 ns;

begin
    -- Instantiatie van de module
    uut: vga_driver port map (
        clk_25mhz => clk, reset => rst,
        hsync => hsync, vsync => vsync, video_on => video_on,
        pixel_x => px, pixel_y => py
    );

    -- Klok proces
    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Stimulus proces
    stim_proc: process
    begin
        -- Reset systeem
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        
        -- Laat de simulatie lang genoeg lopen om een paar lijnen te zien
        -- 1 lijn = 800 clocks * 40ns = 32000 ns (32 us)
        wait for 100 us; 
        
        -- Stop simulatie (optioneel, anders loopt hij oneindig)
        assert false report "Simulatie klaar (geen fout)" severity failure;
    end process;
end Behavioral;