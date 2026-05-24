//This module uses Q1.15 fixed-point format

//incredibly simple scaling solution, divide sample by 2^12 (>> 12)

module qpsk_demapper (
    input logic [15:0] in_i, in_q,
    output logic [3:0] llr_i, llr_q
);

logic [16:0] scaled_i, scaled_q;

always_comb begin
    //goal here is to achieve a 1.4x approximation using shift and add (1x + 0.25x + 0.125x = 1.375x), this is enough to scale 0.707 to the max
    //second term is >> 2 and third is >> 3, both are extending sign bit
    scaled_i = {in_i[15], in_i} + ({in_i[15], in_i[15], in_i[15], in_i[14:2]}) + ({in_i[15], in_i[15], in_i[15], in_i[15], in_i[14:3]});
    scaled_q = {in_q[15], in_q} + ({in_q[15], in_q[15], in_q[15], in_q[14:2]}) + ({in_q[15], in_q[15], in_q[15], in_q[15], in_q[14:3]});

    //overflor check ! (and then underflow check)
    if(~scaled_i[16] & scaled_i[15]) begin
        llr_i = 4'b0111; //max value 7
    end else if (scaled_i[16] & ~scaled_i[15]) begin
        llr_i = 4'b1000;
    end else begin
        if(scaled_i[15:12] == 0 && |scaled_i[11:0]) begin
           if(scaled_i[16]) begin
                llr_i = 4'b1111;
           end else begin
                llr_i = 4'b0001;
           end 
        end else begin
            llr_i = scaled_i[15:12];
        end
    end

    // repeat for q
    if(~scaled_q[16] & scaled_q[15]) begin
        llr_q = 4'b0111; //max value 7
    end else if (scaled_q[16] & ~scaled_q[15]) begin
        llr_q = 4'b1000;
    end else begin
        if(scaled_q[15:12] == 0 && |scaled_q[11:0]) begin
           if(scaled_q[16]) begin
                llr_q = 4'b1111;
           end else begin
                llr_q = 4'b0001;
           end 
        end else begin
            llr_q = scaled_q[15:12];
        end
    end

end

endmodule