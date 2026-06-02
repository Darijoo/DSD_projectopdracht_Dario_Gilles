library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ov7670_constants is
    type register_pair is record
        reg_addr : std_logic_vector(7 downto 0);
        val      : std_logic_vector(7 downto 0);
    end record;

    type register_array is array (natural range <>) of register_pair;

    constant initialization_regs : register_array := (
        -- 1. RESET
        (x"12", x"80"), -- COM7: Reset alles eerst
        (x"12", x"04"), -- COM7: Output format: RGB
        (x"11", x"00"), -- CLKRC: Internal clock, gebruik externe XCLK direct

        -- 2. AUTO SYSTEMS (HIER ZAT HET PROBLEEM!)
        (x"13", x"E7"), -- COM8: Zet Auto Gain, Auto White Balance en Auto Exposure AAN!
        (x"6F", x"9E"), -- AWBCTR0: Simple AWB instellingen (belangrijk voor kleur)

        -- 3. BEELDFORMAAT
        (x"40", x"D0"), -- COM15: RGB565, Full Range (F0 tot 00 mapping)
        (x"8C", x"00"), -- RGB444: Uit
        (x"0C", x"00"), -- COM3: Geen scaling
        (x"3E", x"00"), -- COM14: Geen scaling pixel clock divider

        -- 4. SCALING (640x480 -> QVGA instellingen voor stabiel beeld)
        (x"70", x"3A"), -- SCALING_XSC
        (x"71", x"35"), -- SCALING_YSC
        (x"72", x"11"), -- SCALING_DCWCTR
        (x"73", x"F0"), -- SCALING_PCLK_DIV
        (x"A2", x"02"), -- SCALING_PCLK_DELAY

        -- 5. HARDWARE WINDOW
        (x"17", x"11"), -- HSTART
        (x"18", x"61"), -- HSTOP
        (x"32", x"A4"), -- HREF
        (x"19", x"03"), -- VSTART
        (x"1A", x"7B"), -- VSTOP
        (x"03", x"0A"), -- VREF

        -- 6. KLEUR MATRIX (Jouw instellingen waren goed, maar werken pas met AWB aan)
        (x"4f", x"80"), (x"50", x"80"), (x"51", x"00"),
        (x"52", x"22"), (x"53", x"5e"), (x"54", x"80"),
        (x"58", x"9e"), 
        
        -- 7. DIVERSE OPTIES
        (x"15", x"00"), -- COM10: PCLK niet inversen
        (x"1E", x"37")  -- MVFP: Mirror/V-Flip
    );
end package ov7670_constants;