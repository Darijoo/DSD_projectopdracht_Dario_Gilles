library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_controller is
    Port ( 
        clk, resend : in STD_LOGIC;
        config_finished : out STD_LOGIC;
        sioc : out STD_LOGIC;
        siod : inout STD_LOGIC
    );
end ov7670_controller;

architecture Behavioral of ov7670_controller is
    signal addr : integer range 0 to 15 := 0;
    signal command : std_logic_vector(15 downto 0);
    signal finished : std_logic := '0';
    type state_type is (ST_IDLE, ST_START, ST_BIT_LOW, ST_BIT_HIGH, ST_STOP, ST_PAUSE);
    signal state : state_type := ST_IDLE;
    signal bit_idx : integer range 0 to 27 := 0;
    signal tx_buffer : std_logic_vector(27 downto 0);
    signal s_siod, s_sioc : std_logic := '1';
    signal timer : integer := 0;

    type reg_array is array (0 to 5) of std_logic_vector(15 downto 0);
    constant registers : reg_array := (
        x"1280", -- Reset camera
        x"1204", -- COM7: RGB Mode
        x"1100", -- CLKRC: Geen vertraging
        x"4010", -- COM15: RGB565
        x"3A04", -- TSLB: UV order
        x"FFFF"
    );
begin
    config_finished <= finished;
    sioc <= s_sioc;
    siod <= '0' when s_siod = '0' else 'Z';
    tx_buffer <= "01000010" & "1" & command(15 downto 8) & "1" & command(7 downto 0) & "1" & "0";

    process(clk) begin
        if rising_edge(clk) then
            if resend = '1' then state <= ST_IDLE; addr <= 0; finished <= '0';
            else
                case state is
                    when ST_IDLE =>
                        s_sioc <= '1'; s_siod <= '1';
                        if finished = '0' then
                            command <= registers(addr);
                            if command = x"FFFF" then finished <= '1';
                            else bit_idx <= 27; state <= ST_START; end if;
                        end if;
                    when ST_START => s_siod <= '0'; state <= ST_BIT_LOW;
                    when ST_BIT_LOW => s_sioc <= '0'; s_siod <= tx_buffer(bit_idx); state <= ST_BIT_HIGH;
                    when ST_BIT_HIGH => s_sioc <= '1';
                        if bit_idx > 0 then bit_idx <= bit_idx - 1; state <= ST_BIT_LOW;
                        else state <= ST_STOP; end if;
                    when ST_STOP => s_sioc <= '1'; s_siod <= '0'; timer <= 0; state <= ST_PAUSE;
                    when ST_PAUSE => s_siod <= '1';
                        if timer < 500 then timer <= timer + 1;
                        else addr <= addr + 1; state <= ST_IDLE; end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;