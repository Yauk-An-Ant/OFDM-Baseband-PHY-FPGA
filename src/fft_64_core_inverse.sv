//FFT wrapper module for verification purpose

module fft_64_core_inverse (
    input logic clk, n_rst, valid_in,
    input logic [15:0] in_i, in_q,
    output logic valid_out,
    output logic [15:0] out_i, out_q
);

fft_64_core #(.INVERSE(1'b1)) DUT(
    .clk(clk), .n_rst(n_rst),
    .valid_in(valid_in), .in_i(in_i), .in_q(in_q),
    .valid_out(valid_out), .out_i(out_i), .out_q(out_q)
);

endmodule