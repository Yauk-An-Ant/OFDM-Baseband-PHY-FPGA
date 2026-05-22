//This module uses Q1.15 fixed-point format

module qpsk_mapper (
    input logic clk, n_rst, serial_in,
    output logic [15:0] out_i, out_q
);

logic toggle, i_bit;
logic [1:0] signs;

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        //reset values
        toggle <= 0;
        i_bit <= 0;
        signs <= 2'b00;
    end else begin
        //goes high every 2 cycles to keep invalid qpsk data out of output
        toggle <= ~toggle;

        if(toggle) begin
            signs <= {i_bit, serial_in};
        end else begin
            i_bit <= serial_in;
        end
    end
end

always_comb begin
    //0.707 and -0.707 respectively
    out_i = signs[1] ? 16'h5A82 : 16'hA57E;
    out_q = signs[0] ? 16'h5A82 : 16'hA57E;
end

endmodule