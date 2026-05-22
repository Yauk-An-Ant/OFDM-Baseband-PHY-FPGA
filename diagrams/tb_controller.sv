`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_controller ();

    localparam CLK_PERIOD = 10ns;

    logic clk, n_rst, dr, lc, overflow, cnt_up, clear, modwait, err;
    logic [2:0] op;
    logic [3:0] src1, src2, dest;

    controller DUT (.*);

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(negedge clk);
        @(negedge clk);
    end
    endtask

    initial begin
        n_rst = 1;
        dr = 0;
        lc = 0;
        overflow = 0;

        reset_dut();
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("IDLE not working on reset");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("IDLE not working on self transition");
        end
        lc = 1;

        @(negedge clk);
        if (err | cnt_up | ~clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | ~modwait) begin
            $display("CLEAR not working from IDLE");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 3'b011 | src1 != 0 | src2 != 0 | dest != 4'h5 | ~modwait) begin
            $display("LOADCOEF1 not working from CLEAR");
        end
        lc = 0;

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF2 not working from LOADCOEF1");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF2 not working from self transition");
        end
        lc = 1;

        @(negedge clk);
        if (err | cnt_up | clear | op != 3'b011 | src1 != 0 | src2 != 0 | dest != 4'h6 | ~modwait) begin
            $display("LOADCOEF2 not working from WAITCOEF2");
        end
        lc = 0;

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF3 not working from LOADCOEF2");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF3 not working from self transition");
        end
        lc = 1;
        
        @(negedge clk);
        if (err | cnt_up | clear | op != 3'b011 | src1 != 0 | src2 != 0 | dest != 4'h7 | ~modwait) begin
            $display("LOADCOEF3 not working from WAITCOEF3");
        end
        lc = 0;

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF4 not working from LOADCOEF3");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("WAITCOEF4 not working from self transition");
        end
        lc = 1;

        @(negedge clk);
        if (err | cnt_up | clear | op != 3'b011 | src1 != 0 | src2 != 0 | dest != 4'h8 | ~modwait) begin
            $display("LOADCOEF4 not working from WAITCOEF4");
        end
        lc = 0;

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("IDLE not working from LOADCOEF4");
        end

        dr = 1;
        @(negedge clk)
        if(err | cnt_up | clear | ~modwait | op != 3'b101 | src1 != 4'hf | src2 != 4'hf | dest != 4'hf) begin
            $display("WAITSAMP not working from IDLE");
        end
        dr = 0;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from WAITSAMP");
        end
        dr = 1;

        @(negedge clk)
        if(err | cnt_up | clear | ~modwait | op != 3'b101 | src1 != 4'hf | src2 != 4'hf | dest != 4'hf) begin
            $display("WAITSAMP not working from ERROR");
        end

        @(negedge clk);
        if(err | ~cnt_up | clear | ~modwait | op != 3'b010 | src1 != 4'h0 | src2 != 4'h0 | dest != 4'he) begin
            $display("LOADSAMP not working from WAITSAMP");
        end

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b001 | src1 != 4'h3 | src2 != 4'h0 | dest != 4'h4) begin
            $display("SHIFTSAMP1 not working from LOADSAMP");
        end
        dr = 0;

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b001 | src1 != 4'h2 | src2 != 4'h0 | dest != 4'h3) begin
            $display("SHIFTSAMP2 not working from SHIFTSAMP1");
        end

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b001 | src1 != 4'h1 | src2 != 4'h0 | dest != 4'h2) begin
            $display("SHIFTSAMP3 not working from SHIFTSAMP2");
        end

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b001 | src1 != 4'he | src2 != 4'h0 | dest != 4'h1) begin
            $display("SHIFTSAMP4 not working from SHIFTSAMP3");
        end

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b110 | src1 != 4'h1 | src2 != 4'h5 | dest != 4'h9) begin
            $display("MULT1 not working from SHIFTSAMP4");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULT1");
        end
        dr = 1;
        overflow = 0;
        repeat (7) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b100 | src1 != 4'hf | src2 != 4'h9 | dest != 4'hf) begin
            $display("MULCHK1 not working from MULT1");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULCHK1");
        end
        dr = 1;
        overflow = 0;
        repeat (8) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b110 | src1 != 4'h2 | src2 != 4'h6 | dest != 4'h9) begin
            $display("MULT2 not working from MULCHK1");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULT2");
        end
        dr = 1;
        overflow = 0;
        repeat (9) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b101 | src1 != 4'hf | src2 != 4'h9 | dest != 4'hf) begin
            $display("MULCHK2 not working from MULT2");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULCHK2");
        end
        dr = 1;
        overflow = 0;
        repeat (10) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b110 | src1 != 4'h3 | src2 != 4'h7 | dest != 4'h9) begin
            $display("MULT3 not working from MULCHK2");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULT3");
        end
        dr = 1;
        overflow = 0;
        repeat (11) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b100 | src1 != 4'hf | src2 != 4'h9 | dest != 4'hf) begin
            $display("MULCHK3 not working from MULT3");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULCHK3");
        end
        dr = 1;
        overflow = 0;
        repeat (12) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b110 | src1 != 4'h4 | src2 != 4'h8 | dest != 4'h9) begin
            $display("MULT4 not working from MULCHK3");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULT4");
        end
        dr = 1;
        overflow = 0;
        repeat (13) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b101 | src1 != 4'hf | src2 != 4'h9 | dest != 4'hf) begin
            $display("MULCHK4 not working from MULT4");
        end
        overflow = 1;

        @(negedge clk);
        if(~err | cnt_up | clear | modwait | op != 0 | src1 != 0 | src2 != 0 | dest != 0) begin
            $display("ERROR not working from MULCHK4");
        end
        dr = 1;
        overflow = 0;
        repeat (14) @(negedge clk);

        @(negedge clk);
        if(err | cnt_up | clear | ~modwait | op != 3'b001 | src1 != 4'hf | src2 != 4'h0 | dest != 4'h0) begin
            $display("OUT not working from MULCHK4");
        end

        @(negedge clk);
        if (err | cnt_up | clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | modwait) begin
            $display("IDLE not working from OUT");
        end
        dr = 1;

        @(negedge clk);
        dr = 0;
        @(negedge clk);
        lc = 1;
        @(negedge clk);
        if (err | cnt_up | ~clear | op != 0 | src1 != 0 | src2 != 0 | dest != 0 | ~modwait) begin
            $display("CLEAR not working from ERROR");
        end

        $finish;
    end
endmodule

/* verilator coverage_on */

