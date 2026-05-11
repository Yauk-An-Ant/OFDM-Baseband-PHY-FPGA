`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2026 09:17:27 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input logic clk,
    input logic n_rst,
    output logic [1:0] toggle
    );
    
    
    always_ff @(posedge clk) begin
        if(~n_rst) begin
            toggle <= '0;
        end else begin
            toggle <= toggle + 1;
        end
    end
endmodule
