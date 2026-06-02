library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_camera_capture is
end tb_camera_capture;

architecture Behavioral of tb_camera_capture is
    component camera_capture
        Port ( pclk, vsync, href : in STD_LOGIC;
               d_in : in STD_LOGIC_VECTOR(7 downto 0);
               addr : out STD_LOGIC_VECTOR(16 downto 0);
               dout : out STD_LOGIC_VECTOR(11 downto 0);
               we : out STD_LOGIC);
    end component;

    signal pclk : std_logic := '0';
    signal vsync, href : std_logic := '0';
    signal d_in : std_logic_vector(7 downto 0) := (others => '0');
    signal addr : std_logic_vector(16 downto 0);
    signal dout : std_logic_vector(11 downto 0);
    signal we : std_logic;

    constant pclk_period : time := 20 ns; -- Simulatie van 50MHz pixelklok

begin
    uut: camera_capture port map (
        pclk => pclk, vsync => vsync, href => href,
        d_in => d_in, addr => addr, dout => dout, we => we
    );

    pclk_process: process
    begin
        pclk <= '0'; wait for pclk_period/2;
        pclk <= '1'; wait for pclk_period/2;
    end process;

    stim_proc: process
    begin
        -- 1. Start Frame (VSYNC puls)
        vsync <= '1'; wait for 100 ns;
        vsync <= '0'; wait for 100 ns;

        -- 2. Start Lijn (HREF hoog)
        href <= '1';
        
        -- Pixel 1: Byte 1 (Rood/Groen)
        d_in <= "11110000"; -- Rood max
        wait for pclk_period;
        
        -- Pixel 1: Byte 2 (Groen/Blauw)
        d_in <= "00001111"; -- Blauw max
        wait for pclk_period; 
        
        -- Check: Nu zou 'we' hoog moeten zijn en 'dout' data moeten bevatten.
        
        -- Pixel 2: Byte 1
        d_in <= "10101010"; 
        wait for pclk_period;
        
        -- Pixel 2: Byte 2
        d_in <= "01010101"; 
        wait for pclk_period;

        -- Einde lijn
        href <= '0';
        wait for 100 ns;
        
        assert false report "Simulatie klaar" severity failure;
    end process;
end Behavioral;