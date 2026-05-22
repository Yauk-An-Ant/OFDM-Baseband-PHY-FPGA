module tb_qpsk_mapper;
    localparam CLK_PERIOD = 10ns;

    logic clk, n_rst, serial_in;
    logic [15:0] out_i, out_q;

    localparam [7:0] bitstream  = 8'b00011011;

    qpsk_mapper DUT (
        .clk(clk), .n_rst(n_rst),
        .serial_in(serial_in),
        .out_i(out_i), .out_q(out_q)
    );

    //clkgen
    initial begin
        clk = 0;
    end
    always #(CLK_PERIOD / 2.0) clk = ~clk; //100 MHz sim clock

    task reset_dut;
    begin
        n_rst = 0;
        repeat (4) @(posedge clk);
        n_rst = 1;
        @(negedge clk);
    end
    endtask

    integer i;
    string testname = "";

    initial begin
        //init
        serial_in = 0;

        //reset
        testname = "Asynchronous Reset";
        reset_dut();

        //bitstream test
        testname = "Bit Mapping";
        @(negedge clk);
        for(i = 7; i >= 0; i--) begin
            serial_in = bitstream[i];
            @(negedge clk);
        end

        serial_in = 0;
        repeat (4) @(negedge clk);
    end
endmodule