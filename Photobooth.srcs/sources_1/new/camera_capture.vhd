library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity camera_capture is
    Port ( pclk, vsync, href : in STD_LOGIC; d_in : in STD_LOGIC_VECTOR(7 downto 0);
           addr : out STD_LOGIC_VECTOR(16 downto 0); dout : out STD_LOGIC_VECTOR(11 downto 0); we : out STD_LOGIC);
end camera_capture;

architecture Behavioral of camera_capture is
    signal r_addr  : unsigned(16 downto 0) := (others => '0');
    signal latch   : std_logic_vector(7 downto 0) := (others => '0');
    signal second  : std_logic := '0';
begin
    addr <= std_logic_vector(r_addr);
    process(pclk) begin
        if rising_edge(pclk) then
            if vsync = '1' then
                r_addr <= (others => '0'); second <= '0'; we <= '0';
            elsif href = '1' then
                if second = '0' then
                    latch <= d_in; second <= '1'; we <= '0';
                else
                    -- Correcte RGB565 naar RGB444 mapping:
                    -- latch bevat: R4 R3 R2 R1 R0 G5 G4 G3
                    -- d_in bevat:  G2 G1 G0 B4 B3 B2 B1 B0
                    -- Red (4 bits)   = latch(7 downto 4)
                    -- Green (4 bits) = latch(2 downto 0) & d_in(7)
                    -- Blue (4 bits)  = d_in(4 downto 1)
                    dout <= latch(7 downto 4) & latch(2 downto 0) & d_in(7) & d_in(4 downto 1);
                    we <= '1'; r_addr <= r_addr + 1; second <= '0';
                end if;
            else we <= '0'; second <= '0';
            end if;
        end if;
    end process;
end Behavioral;