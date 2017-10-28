library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.sync_scrambler_pkg.all;

entity sync_scrambler_tb is
end;

architecture testbench of sync_scrambler_tb is

    constant CLK_PERIOD: time := 10 ns;
    signal clk: std_ulogic := '0';

    signal reset: std_ulogic := '0';
    signal control: std_ulogic_vector(1 downto 0) := "00";
    signal in_word: std_ulogic_vector(63 downto 0) := (others => '0');
    signal out_word: std_ulogic_vector(63 downto 0) := (others => '0');

begin

    sync_scrambler_inst: entity work.sync_scrambler
        port map (
            clk => clk,
            reset => reset,
            control => control,
            in_word => in_word,
            out_word => out_word
        );

    clock: process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;

    main: process
        procedure reset_scrambler is
        begin
            reset <= '1';
            wait for CLK_PERIOD;
            reset <= '0';
        end;

        procedure test_0_state is
        begin
            control <= SYNC_SCRAMBLER_CTRL_SET_STATE;
            in_word <= (others => '0');
            wait for CLK_PERIOD;
            control <= sync_scrambler_ctrl_scramble;
            in_word <= (others => '1');
            wait for CLK_PERIOD;
            assert out_word = in_word report "Out_word differs from in_word" &
                                        " for NULL internal scrambler state."
            severity failure;
        end;

        procedure test_default_generics is
        begin
            control <= sync_scrambler_ctrl_scramble;
            in_word <= (others => '0');
            wait for CLK_PERIOD;
            assert out_word = x"000000AC351586A0"
            report "Out_word differs from in_word for default internal scrambler state.";
        end;

    begin
        test_0_state;
        reset_scrambler;
        test_default_generics;

        wait for CLK_PERIOD;
        report "End of simulation! (ignore this failure)" severity failure;
        wait;
    end process;
end;
