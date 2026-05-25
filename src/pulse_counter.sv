//simple counter that starts on a pulse, it also resets if pulse goes high during the count cycle

module pulse_counter #(
    parameter SIZE,
    parameter COUNTVAL
) (
    input logic clk, n_rst, pulse,
    output logic counting,
    output logic [SIZE-1:0] count_out
);

logic next_counting;
logic [SIZE-1:0] next_count;

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        counting <= 0;
        count_out <= '0;
    end else begin
        counting <= next_counting;
        count_out <= next_count;
    end
end

always_comb begin
    next_counting = counting;
    next_count = count_out;

    if(pulse) begin
        next_counting = 1;
        next_count = 0;
    end else if(counting && count_out < (COUNTVAL - 1)) begin
        next_count = count_out + 1;
    end else if(counting) begin
        next_count = 0;
        next_counting = 0;
    end
end

endmodule