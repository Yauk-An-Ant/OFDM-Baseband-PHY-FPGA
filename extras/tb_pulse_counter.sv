//literally just for my peace of mind i might just delete this.
//yay it works!
//ill leave it in here incase but like no need for wrapper module

module tb_pulse_counter;

    localparam CLK_PERIOD = 10ns;

    logic clk, n_rst, pulse, counting;
    logic [4:0] count_out;

    initial begin
        clk = 0;
    end
    always #(CLK_PERIOD / 2.0) clk = ~clk;

    pulse_32_counter DUT (.*);

    task reset_dut;
    begin
        n_rst = 0;
        repeat (4) @(posedge clk);
        n_rst = 1;
        @(negedge clk);
    end
    endtask

    initial begin
        pulse = 0;
        
        reset_dut();

        pulse = 1;
        @(negedge clk);
        pulse = 0;
        repeat (31) @(negedge clk);

        pulse = 1;
        @(negedge clk);
        pulse = 0;
        repeat (10) @(negedge clk);
        pulse = 1;
        @(negedge clk);
        pulse = 0;
        repeat (34) @(negedge clk);
    end

endmodule