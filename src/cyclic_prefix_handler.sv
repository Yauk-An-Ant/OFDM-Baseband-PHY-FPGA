module cyclic_prefix_handler #(
    parameter TRIM
) (
    input logic clk, n_rst, valid_data,
    input logic [15:0] in_i, in_q,
    output logic valid_symbol,
    output logic [15:0] out_i, out_q
);

logic next_valid_symbol;

//triple ring buffer stuff AAAAAAAAAA
logic [1:0] symbols_ready, next_symbols_ready;
logic [1:0] write_sel, next_write_sel;
logic [1:0] read_sel, next_read_sel;

logic [5:0] sample_count, next_sample_count;
logic [6:0] out_count, next_out_count;
logic [15:0] next_out_i, next_out_q;

//registers
logic [63:0][15:0] i_regA, i_regB, i_regC, q_regA, q_regB, q_regC;

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        valid_symbol <= 0;
        out_i <= 16'h0000;
        out_q <= 16'h0000;

        out_count <= 7'b0;

        symbols_ready <= 2'b0;
        write_sel <= 2'b0;
        read_sel <= 2'b0;
        sample_count <= 6'b0;
    end else begin 
        valid_symbol <= next_valid_symbol;
        out_i <= next_out_i;
        out_q <= next_out_q;

        out_count <= next_out_count;
        
        symbols_ready <= next_symbols_ready;
        write_sel <= next_write_sel;
        read_sel <= next_read_sel;
        sample_count <= next_sample_count;

        //write logic
        if(write_sel == 0) begin
            i_regA[sample_count] <= in_i;
            q_regA[sample_count] <= in_q;
        end else if(write_sel == 1) begin
            i_regB[sample_count] <= in_i;
            q_regB[sample_count] <= in_q;
        end else begin
            i_regC[sample_count] <= in_i;
            q_regC[sample_count] <= in_q;
        end
    end 
end

always_comb begin
    next_valid_symbol = 0;
    next_out_i = 16'h0000;
    next_out_q = 16'h0000;

    next_out_count = out_count;

    next_symbols_ready = symbols_ready;
    next_write_sel = write_sel;
    next_read_sel = read_sel;
    next_sample_count = sample_count;

    if(TRIM) begin
        if(out_count < 6'd16) begin
            next_valid_symbol = 0;
            next_out_i = 16'h0000;
            next_out_q = 16'h0000;
        end else begin
            next_valid_symbol = 1;
            next_out_i = in_i;
            next_out_q = in_q;
        end

        if(valid_data) begin
            if(out_count < 79) begin
                next_out_count = out_count + 1;
            end else begin
                next_out_count = 0;
            end
        end
    end else begin //INSERT mode
        //write select logic
        if(sample_count < 63 && valid_data) begin
            next_sample_count = sample_count + 1;
        end else if(valid_data) begin
            next_sample_count = 0;

            if(write_sel < 2) begin
                next_write_sel = write_sel + 1;
            end else begin
                next_write_sel = 0;
            end

            if(symbols_ready < 3) begin
                next_symbols_ready = symbols_ready + 1;
            end
        end

        //read select logic
        if(|symbols_ready | |out_count) begin
            next_valid_symbol = 1;

            if(out_count < 79) begin
                next_out_count = out_count + 1;
            end else begin
                next_out_count = 0;

                if(|symbols_ready) begin
                    next_symbols_ready = symbols_ready - 1;
                end
                
                if(read_sel < 2) begin
                    next_read_sel = read_sel + 1;
                end else begin
                    next_read_sel = 0;
                end
            end
        end else begin
            next_valid_symbol = 0;
        end

        //read logic
        if(read_sel == 0) begin
            if(out_count < 7'd16) begin
                next_out_i = i_regA[out_count + 48];
                next_out_q = q_regA[out_count + 48];
            end else begin
                next_out_i = i_regA[out_count - 16];
                next_out_q = q_regA[out_count - 16];
            end
        end else if(read_sel == 1) begin
            if(out_count < 7'd16) begin
                next_out_i = i_regB[out_count + 48];
                next_out_q = q_regB[out_count + 48];
            end else begin
                next_out_i = i_regB[out_count - 16];
                next_out_q = q_regB[out_count - 16];
            end
        end else begin
            if(out_count < 7'd16) begin
                next_out_i = i_regC[out_count + 48];
                next_out_q = q_regC[out_count + 48];
            end else begin
                next_out_i = i_regC[out_count - 16];
                next_out_q = q_regC[out_count - 16];
            end
        end
    end
end

endmodule