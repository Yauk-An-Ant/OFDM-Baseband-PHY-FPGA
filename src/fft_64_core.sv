module fft_64_core (
    input logic clk, n_rst, valid,
    input logic [15:0] in_i, in_q,
    output logic valid_out,
    output logic [15:0] out_i, out_q
);



always_ff @(posedge clk, posedge n_rst) begin
    if(~n_rst) begin

    end else begin

    end
end

always_comb begin

end

endmodule