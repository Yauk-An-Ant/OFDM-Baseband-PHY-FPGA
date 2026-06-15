module fft_64_core #(
    parameter INVERSE = 1'b0
)(
    input logic clk, n_rst, valid_in,
    input logic [15:0] in_i, in_q,
    output logic valid_out,
    output logic [15:0] out_i, out_q
);

//variable defs
logic next_valid_out;
logic out_writesel, out_readsel, next_out_writesel, next_out_readsel;
logic start1, start2, start3, start4, start5, start6;
logic stage1_en, stage2_en, stage3_en, stage4_en, stage5_en, stage6_en, out_en;
logic count2_en, count3_en, count4_en, count5_en, count6_en;
logic [4:0] stage1_count, stage2_count, stage3_count, stage4_count, stage5_count, stage6_count;
logic [5:0] count, next_count, out_count, reversed_out_count;

logic [5:0] stage1_top_index, stage1_bottom_index, stage2_top_index, stage2_bottom_index, stage3_top_index, stage3_bottom_index, stage4_top_index, stage4_bottom_index, stage5_top_index, stage5_bottom_index, stage6_top_index, stage6_bottom_index;
logic [15:0] i1_samp1, i1_samp2, q1_samp1, q1_samp2;
logic [15:0] i2_samp1, i2_samp2, q2_samp1, q2_samp2;
logic [15:0] i3_samp1, i3_samp2, q3_samp1, q3_samp2;
logic [15:0] i4_samp1, i4_samp2, q4_samp1, q4_samp2;
logic [15:0] i5_samp1, i5_samp2, q5_samp1, q5_samp2;
logic [15:0] i6_samp1, i6_samp2, q6_samp1, q6_samp2;

//stage memory
logic [63:0][15:0] samples_i, samples_q, stage1_i, stage1_q, stage2_i, stage2_q, stage3_i, stage3_q, stage4_i, stage4_q, stage5_i, stage5_q, stage6_i_A, stage6_q_A, stage6_i_B, stage6_q_B;

//W ROM
(* ram_style = "distributed" *) logic signed [15:0] W_ROM_real[31:0], W_ROM_imag[31:0];

initial begin
    $readmemh("/home/achary/achary/Projects/OFDM/src/W_ROM_real.mem", W_ROM_real);
    $readmemh("/home/achary/achary/Projects/OFDM/src/W_ROM_imag.mem", W_ROM_imag);
end

//module defs
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage1_counter (.clk(clk), .n_rst(n_rst), .pulse(start1), .count_en(valid_in), .counting(stage1_en), .count_out(stage1_count));
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage2_counter (.clk(clk), .n_rst(n_rst), .pulse(start2), .count_en(count2_en), .counting(stage2_en), .count_out(stage2_count));
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage3_counter (.clk(clk), .n_rst(n_rst), .pulse(start3), .count_en(count3_en), .counting(stage3_en), .count_out(stage3_count));
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage4_counter (.clk(clk), .n_rst(n_rst), .pulse(start4), .count_en(count4_en), .counting(stage4_en), .count_out(stage4_count));
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage5_counter (.clk(clk), .n_rst(n_rst), .pulse(start5), .count_en(count5_en), .counting(stage5_en), .count_out(stage5_count));
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage6_counter (.clk(clk), .n_rst(n_rst), .pulse(start6), .count_en(count6_en), .counting(stage6_en), .count_out(stage6_count));
pulse_counter #(.SIZE(3'd6), .COUNTVAL(7'd64)) out_counter (.clk(clk), .n_rst(n_rst), .pulse(out_en), .count_en(1'b1), .counting(next_valid_out), .count_out(out_count));

//all W in Q2.14 format
//index through W 0-31 which is what top index is anyway so reused signal aligns A and W
computation_block #(.INVERSE(INVERSE)) stage1_comp (
    .A_real(samples_i[stage1_top_index]), .A_imag(samples_q[stage1_top_index]),
    .B_real(samples_i[stage1_bottom_index]), .B_imag(samples_q[stage1_bottom_index]),
    .W_real(W_ROM_real[stage1_count]), .W_imag(W_ROM_imag[stage1_count]),
    .i_samp1(i1_samp1), .i_samp2(i1_samp2), .q_samp1(q1_samp1), .q_samp2(q1_samp2)
);

computation_block #(.INVERSE(INVERSE)) stage2_comp (
    .A_real(stage1_i[stage2_top_index]), .A_imag(stage1_q[stage2_top_index]),
    .B_real(stage1_i[stage2_bottom_index]), .B_imag(stage1_q[stage2_bottom_index]),
    .W_real(W_ROM_real[{stage2_count[3:0], 1'b0}]), .W_imag(W_ROM_imag[{stage2_count[3:0], 1'b0}]),
    .i_samp1(i2_samp1), .i_samp2(i2_samp2), .q_samp1(q2_samp1), .q_samp2(q2_samp2)
);

computation_block #(.INVERSE(INVERSE)) stage3_comp (
    .A_real(stage2_i[stage3_top_index]), .A_imag(stage2_q[stage3_top_index]),
    .B_real(stage2_i[stage3_bottom_index]), .B_imag(stage2_q[stage3_bottom_index]),
    .W_real(W_ROM_real[{stage3_count[2:0], 2'b00}]), .W_imag(W_ROM_imag[{stage3_count[2:0], 2'b00}]),
    .i_samp1(i3_samp1), .i_samp2(i3_samp2), .q_samp1(q3_samp1), .q_samp2(q3_samp2)
);

computation_block #(.INVERSE(INVERSE)) stage4_comp (
    .A_real(stage3_i[stage4_top_index]), .A_imag(stage3_q[stage4_top_index]),
    .B_real(stage3_i[stage4_bottom_index]), .B_imag(stage3_q[stage4_bottom_index]),
    .W_real(W_ROM_real[{stage4_count[1:0], 3'b000}]), .W_imag(W_ROM_imag[{stage4_count[1:0], 3'b000}]),
    .i_samp1(i4_samp1), .i_samp2(i4_samp2), .q_samp1(q4_samp1), .q_samp2(q4_samp2)
);

computation_block #(.INVERSE(INVERSE)) stage5_comp (
    .A_real(stage4_i[stage5_top_index]), .A_imag(stage4_q[stage5_top_index]),
    .B_real(stage4_i[stage5_bottom_index]), .B_imag(stage4_q[stage5_bottom_index]),
    .W_real(W_ROM_real[{stage5_count[0], 4'b0000}]), .W_imag(W_ROM_imag[{stage5_count[0], 4'b0000}]),
    .i_samp1(i5_samp1), .i_samp2(i5_samp2), .q_samp1(q5_samp1), .q_samp2(q5_samp2)
);

//16'h4000 is 1.0 in Q2.14 format and 0 is 0 for the imaginary component
computation_block #(.INVERSE(INVERSE)) stage6_comp (
    .A_real(stage5_i[stage6_top_index]), .A_imag(stage5_q[stage6_top_index]),
    .B_real(stage5_i[stage6_bottom_index]), .B_imag(stage5_q[stage6_bottom_index]),
    .W_real(16'h4000), .W_imag(16'h0000),
    .i_samp1(i6_samp1), .i_samp2(i6_samp2), .q_samp1(q6_samp1), .q_samp2(q6_samp2)
);

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        out_i <= '0;
        out_q <= '0;
        valid_out <= 0;

        samples_i <= '0;
        samples_q <= '0;
        stage1_i <= '0;
        stage1_q <= '0;
        stage2_i <= '0;
        stage2_q <= '0;
        stage3_i <= '0;
        stage3_q <= '0;
        stage4_i <= '0;
        stage4_q <= '0;
        stage5_i <= '0;
        stage5_q <= '0;
        stage6_i_A <= '0;
        stage6_q_A <= '0;
        stage6_i_B <= '0;
        stage6_q_B <= '0;
        count <= 0;

        out_writesel <= 0;
        out_readsel <= 0;
    end else begin
        count <= next_count;
        valid_out <= next_valid_out;

        out_writesel <= next_out_writesel;
        out_readsel <= next_out_readsel;

        samples_i[count] <= in_i;
        samples_q[count] <= in_q;

        if(stage1_en) begin
            stage1_i[stage1_top_index] <= i1_samp1;
            stage1_i[stage1_bottom_index] <= i1_samp2;
            stage1_q[stage1_top_index] <= q1_samp1;
            stage1_q[stage1_bottom_index] <= q1_samp2;
        end

        if(stage2_en) begin
            stage2_i[stage2_top_index] <= i2_samp1;
            stage2_i[stage2_bottom_index] <= i2_samp2;
            stage2_q[stage2_top_index] <= q2_samp1;
            stage2_q[stage2_bottom_index] <= q2_samp2;
        end
        
        if(stage3_en) begin
            stage3_i[stage3_top_index] <= i3_samp1;
            stage3_i[stage3_bottom_index] <= i3_samp2;
            stage3_q[stage3_top_index] <= q3_samp1;
            stage3_q[stage3_bottom_index] <= q3_samp2;
        end

        if(stage4_en) begin
            stage4_i[stage4_top_index] <= i4_samp1;
            stage4_i[stage4_bottom_index] <= i4_samp2;
            stage4_q[stage4_top_index] <= q4_samp1;
            stage4_q[stage4_bottom_index] <= q4_samp2;
        end

        if(stage5_en) begin
            stage5_i[stage5_top_index] <= i5_samp1;
            stage5_i[stage5_bottom_index] <= i5_samp2;
            stage5_q[stage5_top_index] <= q5_samp1;
            stage5_q[stage5_bottom_index] <= q5_samp2;
        end

        if(stage6_en) begin
            if(out_writesel) begin
                stage6_i_B[stage6_top_index] <= i6_samp1;
                stage6_i_B[stage6_bottom_index] <= i6_samp2;
                stage6_q_B[stage6_top_index] <= q6_samp1;
                stage6_q_B[stage6_bottom_index] <= q6_samp2;
            end else begin
                stage6_i_A[stage6_top_index] <= i6_samp1;
                stage6_i_A[stage6_bottom_index] <= i6_samp2;
                stage6_q_A[stage6_top_index] <= q6_samp1;
                stage6_q_A[stage6_bottom_index] <= q6_samp2;
            end 
        end

        //if inverse, divide by N (64) so arithmetic right shift by 6
        if(next_valid_out) begin
            if(INVERSE) begin
                if(out_readsel) begin
                    out_i <= {stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15], stage6_i_B[reversed_out_count][15:6]};
                    out_q <= {stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15], stage6_q_B[reversed_out_count][15:6]};
                end else begin
                    out_i <= {stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15], stage6_i_A[reversed_out_count][15:6]};
                    out_q <= {stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15], stage6_q_A[reversed_out_count][15:6]}; 
                end
            end else begin
                if(out_readsel) begin
                    out_i <= stage6_i_B[reversed_out_count];
                    out_q <= stage6_q_B[reversed_out_count];
                end else begin
                    out_i <= stage6_i_A[reversed_out_count];
                    out_q <= stage6_q_A[reversed_out_count];    
                end
            end
        end else begin
            out_i <= 16'h0000;
            out_q <= 16'h0000;
        end
    end
end

always_comb begin
    next_out_writesel = out_writesel;
    next_out_readsel = out_readsel;
    out_en = 0;

    next_count = count;
    start1 = (count == 33);
    start2 = (stage1_count == 17);
    start3 = (stage2_count == 9);
    start4 = (stage3_count == 5);
    start5 = (stage4_count == 3);
    start6 = (stage5_count == 2);

    if(stage6_count == 31) begin
        out_en = 1;
        next_out_writesel = ~out_writesel;
    end

    if(out_count == 63) begin
        next_out_readsel = ~out_readsel;
    end

    reversed_out_count = {out_count[0], out_count[1], out_count[2], out_count[3], out_count[4], out_count[5]};

    if(valid_in) begin
        if(count < 63) begin
            next_count = count + 1;
        end else begin
            next_count = 0;
        end
    end

    //index calcs
    stage1_top_index = stage1_count;
    stage1_bottom_index = {1'b1, stage1_count};
    stage2_top_index = (stage2_count & 5'b01111);
    stage2_bottom_index = stage2_count | 5'b10000;
    stage3_top_index    = (stage3_count & 5'b10111);
    stage3_bottom_index = stage3_count | 5'b01000;
    stage4_top_index    = (stage4_count & 5'b11011);
    stage4_bottom_index = stage4_count | 5'b00100;
    stage5_top_index    = (stage5_count & 5'b11101);
    stage5_bottom_index = stage5_count | 5'b00010;
    stage6_top_index    = (stage6_count & 5'b11110);
    stage6_bottom_index = stage6_count | 5'b00001;

    count2_en = stage2_count < 16 ? valid_in : 1'b1;
    count3_en = stage3_count < 8 ? valid_in : 1'b1;
    count4_en = stage4_count < 4 ? valid_in : 1'b1;
    count5_en = stage5_count < 2 ? valid_in : 1'b1;
    count6_en = stage6_count < 1 ? valid_in : 1'b1;
end

endmodule