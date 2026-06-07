module ofdm_rx(
    input logic clk, n_rst, valid_in,
    input logic [15:0] in_i, in_q,
    output logic [3:0] llr_i, llr_q
);

logic valid_symbol;
logic [15:0] symbol_i, symbol_q, fft_i, fft_q;

cyclic_prefix_handler #(.TRIM(1'b1)) prefix_trimmer (
    .clk(clk), .n_rst(n_rst), .valid_data(valid_in),
    .in_i(in_i), .in_q(in_q), .valid_symbol(valid_symbol),
    .out_i(symbol_i), .out_q(symbol_q)
);

fft_64_core #(.INVERSE(1'b0)) fft (
    .clk(clk), .n_rst(n_rst), .valid_in(valid_symbol),
    .in_i(symbol_i), .in_q(symbol_q), .valid_out(),
    .out_i(fft_i), .out_q(fft_q)
);

qpsk_demapper demapper (
    .in_i(fft_i), .in_q(fft_q),
    .llr_i(llr_i), .llr_q(llr_q)
);

endmodule