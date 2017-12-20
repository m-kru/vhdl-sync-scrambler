# Parallel synchronous scrambler
Parallel synchronous scrambler/descrambler implementation in VHDL.
Nowadays scramblers are mainly used to provide randomness to the EMI generated
by the electrical transitions, allow for clock recovery and maintain DC balance.

The advantage of synchronous scrambler compared to self-synchronous one is the
the fact that synchronous scrambler doesn't feed the input data back upon itself,
so it doesn't multiply transmission errors. The drawback is that it requires
explicit synchronization but once the synchronous scrambler has synchronized
it should never become unsynchronized.

Customizable parameters:

* data width
* polynomial
* initial state

## Testbench
`sync_scrambler_tb.vhd` tests only default generics. If you use `ghdl` then call
`make simulate` to run testbench. `waveform.vcd` file is generated to analyze
signals transitions.

Call `make clean` to remove all unnecessary files from repository.

**Note:**
Ignore `warning: reference to alias "poly_downto" violate pure rule
for function "poly_out"`, it is/was ghdl bug: [issue](https://github.com/ghdl/ghdl/issues/447).

## Synthesis
`sync_scrambler_synth.vhd` file can be used for standalone synthesis, it just
synchronizes signals from pinouts so that timing analyzis can be carried out
properly.

I have successfully synthesized it for Artix-7 FPGA Family with Vivado 2017.3
for 100 MHz clock frequency. It can probably work with faster clock, I haven't
checked it, 100 MHz was enough for me.
