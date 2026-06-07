`timescale 1ns/1ps

module tb_qpsk_demapper;

localparam CLK_PERIOD = 10ns;
string testname = "";

logic clk;
logic [15:0] in_i, in_q;
logic [3:0] llr_i, llr_q;

qpsk_demapper DUT (
    .in_i(in_i), .in_q(in_q),
    .llr_i(llr_i), .llr_q(llr_q)
);

initial begin
    clk = 0;
end
always #(CLK_PERIOD / 2.0) clk = ~clk;

initial begin
    testname = "Noiseless Mapping";
    in_i = 16'h5A82; //0.707
    in_q = 16'hA57E; //-0.707
    repeat (4) @(negedge clk);
    in_i = 16'hA57E; 
    in_q = 16'h5A82;
    repeat (4) @(negedge clk);

    testname = "Above +/- 0.707 Mapping";        
    in_i = 16'h7FFF; //0.99999
    in_q = 16'h8000; //-1.0
    repeat (4) @(negedge clk);
    in_i = 16'h8000;
    in_q = 16'h7FFF;
    repeat (4) @(negedge clk);

    testname = "Moderate Noise Mapping";
    in_i = 16'h4D91; //0.606
    in_q = 16'hBF5C; //-0.505
    repeat (4) @(negedge clk);
    in_i = 16'hCC4A; //-0.404
    in_q = 16'h26C9; //0.303
    repeat (4) @(negedge clk);

    testname = "Heavy Noise Mapping";
    in_i = 16'hECCC; //-0.101
    in_q = 16'h0CEE; //0.101
    repeat (4) @(negedge clk);
    in_i = 16'h000C; //close to 0+
    in_q = 16'hFFFD; //close to 0-
    repeat (4) @(negedge clk);
    in_i = 16'h0000; //0
    in_q = 16'h0000; //0
    repeat (4) @(negedge clk);
    
            
end

endmodule