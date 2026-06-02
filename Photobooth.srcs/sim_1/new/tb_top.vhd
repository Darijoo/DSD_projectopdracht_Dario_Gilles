library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_photobooth is
end tb_photobooth;

architecture Behavioral of tb_photobooth is
    component photobooth
        Port ( clk : in STD_LOGIC;
               sw : in STD_LOGIC_VECTOR(15 downto 0);
               led : out STD_LOGIC_VECTOR(15 downto 0);
               Hsync, Vsync : out STD_LOGIC;
               vgaRed, vgaBlue, vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
               OV7670_PCLK, OV7670_HREF, OV7670_VSYNC : in STD_LOGIC;
               OV7670_D : in STD_LOGIC_VECTOR(7 downto 0);
               OV7670_XCLK, OV7670_SIOC : out STD_LOGIC;
               OV7670_SIOD : inout STD_LOGIC;
               OV7670_RESET, OV7670_PWDN : out STD_LOGIC);
    end component;

    signal clk : std_logic := '0';
    signal sw : std_logic_vector(15 downto 0) := (others => '0');
    signal led : std_logic_vector(15 downto 0);
    signal Hsync, Vsync : std_logic;
    signal vgaRed, vgaBlue, vgaGreen : std_logic_vector(3 downto 0);
    
    -- Camera signalen simuleren
    signal cam_pclk : std_logic := '0';
    signal cam_href : std_logic := '0';
    signal cam_vsync : std_logic := '0';
    signal cam_data : std_logic_vector(7 downto 0) := (others => '0');
    signal cam_xclk, cam_sioc, cam_siod, cam_reset, cam_pwdn : std_logic;

    constant clk_period : time := 10 ns; -- 100 MHz systeemklok

begin
    uut: photobooth port map (
        clk => clk, sw => sw, led => led,
        Hsync => Hsync, Vsync => Vsync,
        vgaRed => vgaRed, vgaBlue => vgaBlue, vgaGreen => vgaGreen,
        OV7670_PCLK => cam_pclk, OV7670_HREF => cam_href, OV7670_VSYNC => cam_vsync,
        OV7670_D => cam_data,
        OV7670_XCLK => cam_xclk, OV7670_SIOC => cam_sioc, OV7670_SIOD => cam_siod,
        OV7670_RESET => cam_reset, OV7670_PWDN => cam_pwdn
    );

    -- 100 MHz Systeemklok
    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Camera PCLK simulatie (bijv 25MHz)
    pclk_process: process
    begin
        cam_pclk <= '0'; wait for 20 ns;
        cam_pclk <= '1'; wait for 20 ns;
    end process;

    stim_proc: process
    begin
        -- Initialisatie
        sw <= (others => '0'); -- Normaal beeld
        wait for 100 ns;

        -- Test 1: Activeer Grayscale Filter (SW0)
        sw(0) <= '1';
        wait for 500 ns;
        
        -- Test 2: Activeer Freeze (SW4)
        sw(4) <= '1';
        wait for 500 ns;
        
        -- Test 3: Zet terug naar normaal
        sw <= (others => '0');
        
        wait;
    end process;
end Behavioral;