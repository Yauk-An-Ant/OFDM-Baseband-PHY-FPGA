//literally just for my peace of mind i might just delete this.

module pulse_32_counter (
    input logic clk, n_rst, pulse,
    output logic counting,
    output logic [4:0] count_out
);

pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) counter (
    .clk(clk), .n_rst(n_rst), .pulse(pulse),
    .counting(counting), .count_out(count_out)
);

endmodule