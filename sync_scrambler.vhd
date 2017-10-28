library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_scrambler_pkg.all;

entity sync_scrambler is
    generic (
        -- Length of scrambled words.
        LENGTH: positive := 64;
        -- Polynomial value in MSB first form the default is x^58 + x^39 + 1.
        -- Polynomial value -- must not exceed word length in order to use
        -- in_word and out_word ports for getting and setting the
        -- scrambler internal state.
        POLYNOMIAL: std_ulogic_vector := scrambler_poly((58, 39, 0));
        -- Initial scrambler state, must differ from 0 and not exceed polynomial
        -- length.
        INIT_STATE: std_ulogic_vector := b"1010_1100_0011_0101"
    );
    port (
        clk: in std_ulogic;
        reset: in std_ulogic;
        -- Control vector:
        -- "00" - out word equals in word
        -- "01" - out word is scrambled
        -- "10" - out word is scrambler state
        -- "11" - set scrambler state
        control: in std_ulogic_vector(1 downto 0);
        in_word: in std_ulogic_vector(LENGTH - 1 downto 0);
        out_word: out std_ulogic_vector(LENGTH - 1 downto 0)
    );
end;

architecture behavioral of sync_scrambler is

    function state_to_out(st: std_ulogic_vector(INIT_STATE'reverse_range))
    return std_ulogic_vector is
        variable ret: std_ulogic_vector(LENGTH - 1 downto 0) := (others => '0');
    begin
        for i in st'range loop
            ret(i) := st(i);
        end loop;
        return ret;
    end;

    alias POLY_DOWNTO: std_ulogic_vector(POLYNOMIAL'reverse_range) is POLYNOMIAL;
    alias INIT_DOWNTO: std_ulogic_vector(INIT_STATE'reverse_range) is INIT_STATE;
    signal state: std_ulogic_vector(POLY_DOWNTO'range) := std_ulogic_vector(to_unsigned(to_integer(unsigned(INIT_DOWNTO)), POLY_DOWNTO'length));

   function poly_out(st: std_ulogic_vector(POLY_DOWNTO'range))
    return std_ulogic is
        variable ret: std_ulogic := '0';
    begin
        for i in natural(POLY_DOWNTO'length - 1) downto 1 loop
            ret := ret xor (POLY_DOWNTO(i) and st(i));
        end loop;
        return ret;
    end;

begin

    process (clk)
        procedure scramble is
            variable aux_state: std_ulogic_vector(POLY_DOWNTO'range);
            variable state_out: std_ulogic;
        begin
            aux_state := state;

            for i in in_word'range loop
                state_out := poly_out(aux_state);
                out_word(i) <= in_word(i) xor state_out;
                aux_state := aux_state(state'length - 2 downto 0) & state_out;
            end loop;

            state <= aux_state;
        end;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= std_ulogic_vector(to_unsigned(to_integer(unsigned(INIT_DOWNTO)), POLY_DOWNTO'length));
            else
                case control is
                    when "00" =>
                        out_word <= in_word;
                    when "01" =>
                        scramble;
                    when "10" =>
                        out_word <= state_to_out(state);
                    when "11" =>
                        state <= in_word(state'range);
                    when others =>
                        out_word <= (others => 'X');
                end case;
            end if;
        end if;
    end process;
end;
