library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_driver is
    Port ( 
        clk_25mhz : in  STD_LOGIC;   -- De pixel klok
        reset     : in  STD_LOGIC;   -- Reset signaal
        hsync     : out STD_LOGIC;   -- Horizontale sync
        vsync     : out STD_LOGIC;   -- Verticale sync
        video_on  : out STD_LOGIC;   -- Hoog als we binnen het zichtbare gebied zijn
        pixel_x   : out STD_LOGIC_VECTOR(9 downto 0); -- Huidige X positie (0-639)
        pixel_y   : out STD_LOGIC_VECTOR(9 downto 0)  -- Huidige Y positie (0-479)
    );
end vga_driver;

architecture Behavioral of vga_driver is
    -- VGA Timing parameters voor 640x480 @ 60Hz
    constant HD : integer := 640; -- Horizontaal Display
    constant HF : integer := 16;  -- H. Front Porch
    constant HS : integer := 96;  -- H. Sync Pulse
    constant HB : integer := 48;  -- H. Back Porch
    constant HT : integer := 800; -- H. Totaal (640+16+96+48)

    constant VD : integer := 480; -- Verticaal Display
    constant VF : integer := 10;  -- V. Front Porch
    constant VS : integer := 2;   -- V. Sync Pulse
    constant VB : integer := 33;  -- V. Back Porch
    constant VT : integer := 525; -- V. Totaal (480+10+2+33)

    signal h_cnt_reg, h_cnt_next : unsigned(9 downto 0) := (others => '0');
    signal v_cnt_reg, v_cnt_next : unsigned(9 downto 0) := (others => '0');
    
    signal h_sync_reg, v_sync_reg : std_logic := '0';
    signal h_sync_next, v_sync_next : std_logic := '0';

begin

    -- Registers
    process(clk_25mhz, reset)
    begin
        if reset = '1' then
            h_cnt_reg <= (others => '0');
            v_cnt_reg <= (others => '0');
            h_sync_reg <= '0';
            v_sync_reg <= '0';
        elsif rising_edge(clk_25mhz) then
            h_cnt_reg <= h_cnt_next;
            v_cnt_reg <= v_cnt_next;
            h_sync_reg <= h_sync_next;
            v_sync_reg <= v_sync_next;
        end if;
    end process;

    -- Horizontale teller (0 tot 799)
    h_cnt_next <= (others => '0') when h_cnt_reg = (HT - 1) else h_cnt_reg + 1;

    -- Verticale teller (0 tot 524)
    process(v_cnt_reg, h_cnt_reg)
    begin
        v_cnt_next <= v_cnt_reg;
        if h_cnt_reg = (HT - 1) then
            if v_cnt_reg = (VT - 1) then
                v_cnt_next <= (others => '0');
            else
                v_cnt_next <= v_cnt_reg + 1;
            end if;
        end if;
    end process;

    -- Sync signalen (Active Low)
    h_sync_next <= '0' when (h_cnt_reg >= (HD + HF)) and (h_cnt_reg <= (HD + HF + HS - 1)) else '1';
    v_sync_next <= '0' when (v_cnt_reg >= (VD + VF)) and (v_cnt_reg <= (VD + VF + VS - 1)) else '1';

    -- Video_on logica: Alleen hoog in het zichtbare gebied (640x480)
    video_on <= '1' when (h_cnt_reg < HD) and (v_cnt_reg < VD) else '0';

    -- Outputs
    hsync <= h_sync_reg;
    vsync <= v_sync_reg;
    pixel_x <= std_logic_vector(h_cnt_reg);
    pixel_y <= std_logic_vector(v_cnt_reg);

end Behavioral;