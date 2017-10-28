check_syntax:
	@ghdl -s sync_scrambler*

analyze_pkg: work_dir
	@ghdl -a --workdir=work sync_scrambler_pkg.vhd

analyze_scrambler: analyze_pkg
	@ghdl -a --workdir=work sync_scrambler.vhd

analyze_tb: analyze_scrambler
	@ghdl -a --workdir=work sync_scrambler_tb.vhd

elaborate_tb: analyze_tb analyze_scrambler
	@ghdl -e --workdir=work sync_scrambler_tb

simulate: elaborate_tb
	@ghdl -r --workdir=work sync_scrambler_tb --vcd=waveform.vcd

work_dir:
	@mkdir -p work

clean:
	-rm -rf work
	-rm waveform.vcd
	-rm sync_scrambler_tb
	-rm work-obj93.cf
	-rm sync_scrambler_pkg.o
	-rm e~sync_scrambler_tb.o
