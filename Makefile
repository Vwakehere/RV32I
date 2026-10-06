%_sim: source/%.v test_benches/%_tb.v
	iverilog -o build/$@ source/*.v test_benches/$*_tb.v
	vvp build/$@