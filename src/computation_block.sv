//all W inputs in 2.14 format
//A and B inputs are scaled up one integer bit and down one fractional bit for every multiplication, so 1.15 -> 2,14 etc

module computation_block #(
    parameter INVERSE
) (
    input logic signed [15:0] A_real, A_imag, B_real, B_imag, W_real, W_imag,
    output logic signed [15:0] i_samp1, q_samp1, i_samp2, q_samp2
);

logic signed [16:0] real_term, imag_term;
logic signed [31:0] i1, i2, q1, q2;

always_comb begin 
   i_samp1 = (A_real + B_real)[16:1];
   q_samp1 = (A_imag + B_imag)[16:1];

    real_term = A_real - B_real;
    imag_term = A_imag - B_imag;
    i1 = real_term * W_real;
    i2 = imag_term * W_imag;
    q1 = imag_term * W_real;
    q2 = real_term * W_imag;

    i_samp2 = INVERSE ? (i1 + i2)[29:14] : (i1 - i2)[29:14];
    q_samp2 = INVERSE ? (q1 - q2)[29:14] : (q1 + q2)[29:14];
end

endmodule