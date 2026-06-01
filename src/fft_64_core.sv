module fft_64_core (
    input logic clk, n_rst, valid,
    input logic [15:0] in_i, in_q,
    output logic valid_out,
    output logic [15:0] out_i, out_q
);

//variable defs
logic start1, start2, start3, start4, start5, start6;
logic stage1_en, stage2_en, stage3_en, stage4_en, stage5_en, stage6_en, out_en;
logic [4:0] stage6_count;
logic [5:0] count, next_count, out_count;

logic [5:0] stage1_top_index, stage1_bottom_index, stage2_top_index, stage2_bottom_index, stage3_top_index, stage3_bottom_index, stage4_top_index, stage4_bottom_index, stage5_top_index, stage5_bottom_index, stage6_top_index, stage6_bottom_index;
logic [15:0] i1_samp1, i1_samp2, q1_samp1, q1_samp2;
logic [15:0] i2_samp1, i2_samp2, q2_samp1, q2_samp2;
logic [15:0] i3_samp1, i3_samp2, q3_samp1, q3_samp2;
logic [15:0] i4_samp1, i4_samp2, q4_samp1, q4_samp2;
logic [15:0] i5_samp1, i5_samp2, q5_samp1, q5_samp2;
logic [15:0] i6_samp1, i6_samp2, q6_samp1, q6_samp2;

//stage memory
logic [63:0][15:0] samples_i, samples_q, stage1_i, stage1_q, stage2_i, stage2_q, stage3_i, stage3_q, stage4_i, stage4_q, stage5_i, stage5_q, stage6_i, stage6_q;

//W ROM declaration
logic [31:0][15:0] W_ROM_real, W_ROM_imag;

//module defs
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage1_counter (.clk(clk), .n_rst(n_rst), .pulse(start1), .counting(stage1_en), .count_out());
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage2_counter (.clk(clk), .n_rst(n_rst), .pulse(start2), .counting(stage2_en), .count_out());
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage3_counter (.clk(clk), .n_rst(n_rst), .pulse(start3), .counting(stage3_en), .count_out());
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage4_counter (.clk(clk), .n_rst(n_rst), .pulse(start4), .counting(stage4_en), .count_out());
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage5_counter (.clk(clk), .n_rst(n_rst), .pulse(start5), .counting(stage5_en), .count_out());
pulse_counter #(.SIZE(3'd5), .COUNTVAL(6'd32)) stage6_counter (.clk(clk), .n_rst(n_rst), .pulse(start6), .counting(stage6_en), .count_out(stage6_count));
pulse_counter #(.SIZE(3'd6), .COUNTVAL(7'd64)) out_counter (.clk(clk), .n_rst(n_rst), .pulse(out_en), .counting(valid_out), .count_out(out_count));

//all W in Q2.14 format
//index through W 0-31 which is what top index is anyway so reused signal aligns A and W
computation_block stage1_comp (
    .A_real(samples_i[stage1_top_index]), .A_imag(samples_q[stage1_top_index]),
    .B_real(samples_i[stage1_bottom_index]), .B_imag(samples_q[stage1_bottom_index]),
    .W_real(W_ROM_real[stage1_top_index]), .W_imag(W_ROM_imag[stage1_top_index]),
    .i_samp1(i1_samp1), .i_samp2(i1_samp2), .q_samp1(q1_samp1), .q_samp2(q1_samp2)
);

computation_block stage2_comp (
    .A_real(stage1_i[stage2_top_index]), .A_imag(stage1_q[stage2_top_index]),
    .B_real(stage1_i[stage2_bottom_index]), .B_imag(stage1_q[stage2_bottom_index]),
    .W_real(W_ROM_real[{stage2_top_index[3:0], 1'b0}]), .W_imag(W_ROM_imag[{stage2_top_index[3:0], 1'b0}]),
    .i_samp1(i2_samp1), .i_samp2(i2_samp2), .q_samp1(q2_samp1), .q_samp2(q2_samp2)
);

computation_block stage3_comp (
    .A_real(stage2_i[stage3_top_index]), .A_imag(stage2_q[stage3_top_index]),
    .B_real(stage2_i[stage3_bottom_index]), .B_imag(stage2_q[stage3_bottom_index]),
    .W_real(W_ROM_real[{stage3_top_index[2:0], 2'b00}]), .W_imag(W_ROM_imag[{stage3_top_index[2:0], 2'b00]}),
    .i_samp1(i3_samp1), .i_samp2(i3_samp2), .q_samp1(q3_samp1), .q_samp2(q3_samp2)
);

computation_block stage4_comp (
    .A_real(stage3_i[stage4_top_index]), .A_imag(stage3_q[stage4_top_index]),
    .B_real(stage3_i[stage4_bottom_index]), .B_imag(stage3_q[stage4_bottom_index]),
    .W_real(W_ROM_real[{stage4_top_index[1:0], 3'b000}]), .W_imag(W_ROM_imag[{stage4_top_index[1:0], 3'b000}]),
    .i_samp1(i4_samp1), .i_samp2(i4_samp2), .q_samp1(q4_samp1), .q_samp2(q4_samp2)
);

computation_block stage5_comp (
    .A_real(stage4_i[stage5_top_index]), .A_imag(stage4_q[stage5_top_index]),
    .B_real(stage4_i[stage5_bottom_index]), .B_imag(stage4_q[stage5_bottom_index]),
    .W_real(W_ROM_real[{stage5_top_index[0], 4'b0000}]), .W_imag(W_ROM_imag[{stage5_top_index[0], 4'b0000}]),
    .i_samp1(i5_samp1), .i_samp2(i5_samp2), .q_samp1(q5_samp1), .q_samp2(q5_samp2)
);

//16'h4000 is 1.0 in Q2.14 format and 0 is 0 for the imaginary component
computation_block stage6_comp (
    .A_real(stage5_i[stage6_top_index]), .A_imag(stage5_q[stage6_top_index]),
    .B_real(stage5_i[stage6_bottom_index]), .B_imag(stage5_q[stage6_bottom_index]),
    .W_real(16'h4000), .W_imag(16'h0000),
    .i_samp1(i6_samp1), .i_samp2(i6_samp2), .q_samp1(q6_samp1), .q_samp2(q6_samp2)
);

always_ff @(posedge clk, posedge n_rst) begin
    if(~n_rst) begin
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
        stage6_i <= '0;
        stage6_q <= '0;
        count <= 0;
    end else begin
        count <= next_count;

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
            stage6_i[stage6_top_index] <= i6_samp1;
            stage6_i[stage6_bottom_index] <= i6_samp2;
            stage6_q[stage6_top_index] <= q6_samp1;
            stage6_q[stage6_bottom_index] <= q6_samp2;
        end
    end
end

always_comb begin
    start1 = (count == 32);
    start2 = (count == 48);
    start3 = (count == 56);
    start4 = (count == 60);
    start5 = (count == 62);
    start6 = (count == 63);

    out_en = (stage6_count == 31);

    if(count < 63) begin
        next_count = count + 1;
    end else begin
        next_count = 0;
    end

    //index calcs
    stage1_top_index = {1'b0, count[4:0]};
    stage1_bottom_index = count;
    stage2_top_index = count & 6'b101111;
    stage2_bottom_index = count | 6'b010000;
    stage3_top_index = count & 6'b110111;
    stage3_bottom_index = count | 6'b001000;
    stage4_top_index = count & 6'b111011;
    stage4_bottom_index = count | 6'b000100;
    stage5_top_index = count & 6'b111101;
    stage5_bottom_index = count | 6'b000010;
    stage6_top_index = count & 6'b111110;
    stage6_bottom_index = count | 6'b000001;
end

//W_rom

endmodule