`timescale 1ns/1ps

module tb_top;

logic clk;
logic n_rst;
logic [1:0] toggle;

// Instantiate DUT
top dut (
    .clk(clk),
    .n_rst(n_rst),
    .toggle(toggle)
);

//clkgen
always #5ns clk = ~clk;   // 100 MHz sim clock

initial begin
    // init
    clk = 0;
    n_rst = 0;

    // reset pulse
    @(negedge clk);
    n_rst = 1;

    // run simulation
    repeat (8) @(negedge clk);
    $finish;
end

endmodule