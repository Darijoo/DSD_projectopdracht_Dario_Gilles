library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity photobooth is
    Port ( 
        clk : in STD_LOGIC; 
        sw : in STD_LOGIC_VECTOR(15 downto 0); 
        led : out STD_LOGIC_VECTOR(15 downto 0);
        
        -- VGA Interface
        Hsync, Vsync : out STD_LOGIC;
        vgaRed, vgaBlue, vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
        
        -- OV7670 Interface
        OV7670_PCLK, OV7670_HREF, OV7670_VSYNC : in STD_LOGIC;
        OV7670_D : in STD_LOGIC_VECTOR(7 downto 0);
        OV7670_XCLK, OV7670_SIOC : out STD_LOGIC;
        OV7670_SIOD : inout STD_LOGIC;
        OV7670_RESET, OV7670_PWDN : out STD_LOGIC
    );
end photobooth;

architecture Behavioral of photobooth is
    signal clk_div : unsigned(16 downto 0) := (others => '0');
    signal capture_addr, read_addr_vec : std_logic_vector(16 downto 0);
    signal capture_data, ram_out : std_logic_vector(11 downto 0);
    signal capture_we, config_done, video_on : std_logic;
    signal p_x, p_y : std_logic_vector(9 downto 0);
    
    -- NIEUW: Signaal om het schrijven naar RAM te blokkeren
    signal ram_write_enable : std_logic_vector(0 downto 0);

begin
    process(clk) begin
        if rising_edge(clk) then clk_div <= clk_div + 1; end if;
    end process;

    OV7670_XCLK  <= clk_div(1); 
    OV7670_RESET <= '1';
    OV7670_PWDN  <= '0';

    inst_i2c: entity work.ov7670_controller 
        port map(clk => clk_div(15), resend => sw(15), config_finished => config_done, 
                 sioc => OV7670_SIOC, siod => OV7670_SIOD);
    
    inst_cap: entity work.camera_capture 
        port map(pclk => OV7670_PCLK, vsync => OV7670_VSYNC, href => OV7670_HREF, 
                 d_in => OV7670_D, addr => capture_addr, dout => capture_data, we => capture_we);
    
    -- FREEZE LOGICA (SW4):
    -- Als SW4 LAAG is ('0'), mag de camera schrijven (Live beeld).
    -- Als SW4 HOOG is ('1'), forceren we de Write Enable op '0' (Freeze).
    ram_write_enable(0) <= capture_we when sw(4) = '0' else '0';

    inst_ram: entity work.picture_memory 
        port map(
            clka  => OV7670_PCLK, 
            wea   => ram_write_enable, -- Gebruik hier het nieuwe signaal
            addra => capture_addr, 
            dina  => capture_data, 
            clkb  => clk_div(1), 
            addrb => read_addr_vec, 
            doutb => ram_out
        );
    
    inst_vga: entity work.vga_driver 
        port map(clk_25mhz => clk_div(1), reset => '0', hsync => Hsync, vsync => Vsync, 
                 video_on => video_on, pixel_x => p_x, pixel_y => p_y);

    process(p_x, p_y) variable res : integer; begin
        res := (to_integer(unsigned(p_y(9 downto 1))) * 320) + to_integer(unsigned(p_x(9 downto 1)));
        if res < 76800 then read_addr_vec <= std_logic_vector(to_unsigned(res, 17)); 
        else read_addr_vec <= (others => '0'); end if;
    end process;

    -- DSP & Filters
    process(video_on, ram_out, sw)
        variable r, g, b : unsigned(3 downto 0);
        variable gray    : unsigned(3 downto 0);
    begin
        if video_on = '1' then
            r := unsigned(ram_out(11 downto 8));
            g := unsigned(ram_out(7 downto 4));
            b := unsigned(ram_out(3 downto 0));

            -- SW0: Grayscale
            gray := (r/4) + (g/2) + (b/4);
            if sw(0) = '1' then r := gray; g := gray; b := gray; end if;

            -- SW1: Invert
            if sw(1) = '1' then r := not r; g := not g; b := not b; end if;

            -- SW2: Threshold
            if sw(2) = '1' then
                if gray > 7 then r := "1111"; g := "1111"; b := "1111";
                else r := "0000"; g := "0000"; b := "0000"; end if;
            end if;

            -- SW3: Compressie
            if sw(3) = '1' then
                r := r and "1100"; g := g and "1100"; b := b and "1100";
            end if;

            vgaRed <= std_logic_vector(r); vgaGreen <= std_logic_vector(g); vgaBlue <= std_logic_vector(b);
        else
            vgaRed <= "0000"; vgaGreen <= "0000"; vgaBlue <= "0000";
        end if;
    end process;

    led(0) <= config_done; 
    led(1) <= OV7670_VSYNC; 
    led(4) <= sw(4); -- Status LED voor Freeze
    led(15) <= sw(15);
end Behavioral;