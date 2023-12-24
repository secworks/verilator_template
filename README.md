# verilator_template
(Hopefully) simple template for a Verilator SystemVerilog project with
a usable testbench.

We want to have a template that generates a clock and a reset that
drives a testbench that instantiates a simple DUT. The testbench
should be able to feed the DUT with test vectors and probe the
internal state of the DUT.

This can then be used as basis for other design.
