//all W inputs in 2.14 format
//A and B inputs are scaled up one integer bit and down one fractional bit for every multiplication, so 1.15 -> 2,14 etc

module computation_block #(
    parameter INVERSE = 1'b0
) (
    input logic signed [15:0] A_real, A_imag, B_real, B_imag, W_real, W_imag,
    output logic signed [15:0] i_samp1, q_samp1, i_samp2, q_samp2
);

logic signed [16:0] real_term, imag_term, unslice_i1, unslice_q1;
logic signed [32:0] i1, i2, q1, q2;
logic signed [32:0] samp2_iadd, samp2_qadd, samp2_isub, samp2_qsub;

always_comb begin 
    unslice_i1 = A_real + B_real;
    unslice_q1 = A_imag + B_imag;
    i_samp1 = unslice_i1[16:1];
    q_samp1 = unslice_q1[16:1];

    real_term = A_real - B_real;
    imag_term = A_imag - B_imag;
    i1 = real_term * W_real;
    i2 = imag_term * W_imag;
    q1 = imag_term * W_real;
    q2 = real_term * W_imag;

    samp2_iadd = i1 + i2;
    samp2_isub = i1 - i2;
    samp2_qadd = q1 + q2;
    samp2_qsub = q1 - q2;
    i_samp2 = INVERSE ? samp2_iadd[29:14] : samp2_isub[29:14];
    q_samp2 = INVERSE ? samp2_qsub[29:14] : samp2_qadd[29:14];
end

endmodule