library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

package sync_scrambler_pkg is
    constant SYNC_SCRAMBLER_CTRL_PASS: std_ulogic_vector(1 downto 0) := "00";
    constant SYNC_SCRAMBLER_CTRL_SCRAMBLE: std_ulogic_vector(1 downto 0) := "01";
    constant SYNC_SCRAMBLER_CTRL_GET_STATE: std_ulogic_vector(1 downto 0) := "10";
    constant SYNC_SCRAMBLER_CTRL_SET_STATE: std_ulogic_vector(1 downto 0) := "11";
    
    type scrambler_coef_array is array (natural range <>) of natural;

    function scrambler_poly(coef_array: scrambler_coef_array) return std_ulogic_vector;
end;

package body sync_scrambler_pkg is

    function find_min_coef(coef_array: scrambler_coef_array) return natural is
        variable min: natural;
    begin
        min := coef_array(0);

        for i in coef_array'range loop
            if coef_array(i) < min then
                min := coef_array(i);
            end if;
        end loop;

        return min;
    end;

    function find_max_coef(coef_array: scrambler_coef_array) return natural is
        variable max: natural;
    begin
        max := coef_array(0);

        for i in coef_array'range loop
            if coef_array(i) > max then
                max := coef_array(i);
            end if;
        end loop;

        return max;
    end;

    function scrambler_poly(coef_array: scrambler_coef_array)
    return std_ulogic_vector is 
        variable min: natural := find_min_coef(coef_array);
        variable max: natural := find_max_coef(coef_array);
--        variable poly: std_ulogic_vector(max downto 0) := (others => '0');
        variable poly: std_ulogic_vector(0 to max) := (others => '0');
    begin
        assert min = 0 report "Synchronous scrambler polynomial is probably" &
                              "missing coefficient for x^0." severity error;

        for i in coef_array'range loop
            poly(max - coef_array(i)) := '1';
        end loop;

        return poly;
    end;

end package body;
