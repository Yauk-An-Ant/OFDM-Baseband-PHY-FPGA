module ofdm_tx(
    input logic clk, n_rst, serial_in, valid_in,
    output logic [15:0] out_i, out_q
);

logic toggle, valid, valid_data;
logic [15:0] qpsk_i, qpsk_q, ifft_i, ifft_q;

assign valid_data = valid_in & toggle;

qpsk_mapper mapper(
    .clk(clk), .n_rst(n_rst), .serial_in(serial_in),
    .out_i(qpsk_i), .out_q(qpsk_q)
);

fft_64_core #(.INVERSE(1'b1)) ifft (
    .clk(clk), .n_rst(n_rst), .valid_in(valid_data),
    .in_i(qpsk_i), .in_q(qpsk_q), .valid_out(valid),
    .out_i(ifft_i), .out_q(ifft_q)
);

cyclic_prefix_handler #(.TRIM(1'b0)) prefix_inserter (
    .clk(clk), .n_rst(n_rst), .valid_data(valid),
    .in_i(ifft_i), .in_q(ifft_q), .valid_symbol(), 
    .out_i(out_i), .out_q(out_q)
);

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        toggle <= 1'b0;
    end else begin
        toggle <= ~toggle;
    end
end

endmodule