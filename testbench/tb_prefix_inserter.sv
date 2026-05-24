/*
VERIFICATION NOTE:
    these things should work regardless of the input format so the inputs
    will be counting in correspondance with their position in the symbol
    so its easier to see whats happening in the simulation
*/

module tb_prefix_inserter;

    localparam CLK_PERIOD = 10ns;
    string testname = "";

    logic clk, n_rst, valid_data, valid_symbol;
    logic [15:0] in_i, in_q, out_i, out_q;

    logic [5:0] counter;

    //clkgen
    initial begin
        clk = 0;
    end
    always #(CLK_PERIOD / 2.0) clk = ~clk;

    prefix_inserter DUT (
        .clk(clk), .n_rst(n_rst), .valid_data(valid_data),
        .in_i(in_i), .in_q(in_q),
        .valid_symbol(valid_symbol),
        .out_i(out_i), .out_q(out_q)
    );

    task reset_dut;
    begin
        n_rst = 0;
        repeat (4) @(posedge clk);
        n_rst = 1;
        @(negedge clk);
    end
    endtask

    integer i, j;

    initial begin
        n_rst = 0;
        in_i = '0;
        in_q = '0;
        valid_data = 0;

        testname = "Asynchronous Reset";
        reset_dut();

         testname = "One Symbol Insert";
        counter = 0;
        @(negedge clk);
        valid_data = 1;
        for(i = 0; i < 64; i++) begin
            in_i = counter;
            in_q = counter;

            @(negedge clk);
            counter = counter + 1;
        end
        valid_data = 0;
        repeat (24) @(negedge clk);

        testname = "Three Symbol Insert";
        valid_data = 1;
        for(j = 0; j < 3; j++) begin
            counter = 0;
            for(i = 0; i < 64; i++) begin
                in_i = counter;
                in_q = counter;

                @(negedge clk);
                counter = counter + 1;
            end
        end
        valid_data = 0;
        repeat (10) @(negedge clk);
    end

endmodule   