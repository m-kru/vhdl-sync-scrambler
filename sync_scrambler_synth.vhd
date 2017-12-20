library ieee;
use ieee.std_logic_1164.all;

use work.sync_scrambler_pkg.all;

entity sync_scrambler_synth is
    generic (
        LENGTH: positive := 64;
        POLYNOMIAL: std_ulogic_vector := scrambler_poly((58, 39, 0));
        INIT_STATE: std_ulogic_vector := b"1010_1100_0011_0101"
    );
    port (
        clk: in std_ulogic;
        reset: in std_ulogic;
        control: in std_ulogic_vector(1 downto 0);
        in_word: in std_ulogic_vector(LENGTH - 1 downto 0);
        out_word: out std_ulogic_vector(LENGTH - 1 downto 0)
    );
end;

architecture synchronous of sync_scrambler_synth is

    signal reset_sync: std_ulogic;
    signal control_sync: std_ulogic_vector(1 downto 0);
    signal in_word_sync: std_ulogic_vector(LENGTH - 1 downto 0);

begin

    sync_scrambler_inst: entity work.sync_scrambler
        generic map (
            LENGTH => LENGTH,
            POLYNOMIAL => POLYNOMIAL,
            INIT_STATE => INIT_STATE
        )
        port map (
            clk => clk,
            srst => reset_sync,
            control => control_sync,
            in_word => in_word_sync,
            out_word => out_word
        );

    sync_inputs : process(clk)
    begin
        if rising_edge(clk) then
            reset_sync <= reset;
            control_sync <= control;
            in_word_sync <= in_word;
        end if;
    end process;

end;
