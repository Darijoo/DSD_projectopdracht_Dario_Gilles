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
                    dout <= latch(7 downto 4) & d_in(7 downto 4) & d_in(3 downto 0);
                    we <= '1'; r_addr <= r_addr + 1; second <= '0';
                end if;
            else we <= '0'; second <= '0';
            end if;
        end if;
    end process;
end Behavioral;