//this is a wrapper module for the cyclic prefix handler TRIM = 1
//ONLY FOR TESTBENCHING
//not used in final design

module prefix_trimmer (
    input logic clk, n_rst, valid_data,
    input logic [15:0] in_i, in_q,
    output logic valid_symbol,
    output logic [15:0] out_i, out_q
);

cyclic_prefix_handler #(.TRIM(1'b1)) trimmer (
    .clk(clk), .n_rst(n_rst), .valid_data(valid_data),
    .in_i(in_i), .in_q(in_q),
    .valid_symbol(valid_symbol),
    .out_i(out_i), .out_q(out_q)
);

endmodule