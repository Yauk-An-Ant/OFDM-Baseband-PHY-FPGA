`timescale 1ns/1ps

module tb_fft_64_core_forward;

localparam CLK_PERIOD = 10ns;

logic clk, n_rst, valid_in, valid_out;
logic [15:0] in_i, in_q, out_i, out_q;
string testname = "";

initial begin
    clk = 0;
end
always #(CLK_PERIOD / 2.0) clk = ~clk;

fft_64_core_forward DUT(
    .clk(clk), .n_rst(n_rst),
    .valid_in(valid_in), .in_i(in_i), .in_q(in_q),
    .valid_out(valid_out), .out_i(out_i), .out_q(out_q)
);

task reset_dut;
begin
    n_rst = 0;
    repeat (2) @(negedge clk);
    n_rst = 1;
    @(negedge clk);
end
endtask

task automatic stream_frame_from_file(
    input logic twocycle, 
    input string real_file,
    input string imag_file
);
begin
    integer file_real, file_imag;
    integer status_real, status_imag;
    integer i;

    file_real = $fopen(real_file, "r");
    file_imag = $fopen(imag_file, "r");

    if(!file_real || !file_imag) begin
        $display("ERROR: Could not open files.");
        $finish;
    end
    @(negedge clk);

    valid_in = 1'b1;

    for(i = 0; i < 64; i++) begin
        status_real = $fscanf(file_real, "%x\n", in_i);
        status_imag = $fscanf(file_imag, "%x\n", in_q);

        @(negedge clk);
        if(twocycle) begin
            valid_in = 1'b0;
            @(negedge clk);
            valid_in = 1'b1;
        end
    end

    valid_in = 1'b0;
    in_i = 16'h0000;
    in_q = 16'h0000;

    $fclose(file_real);
    $fclose(file_imag);
    @(negedge clk);
end
endtask

initial begin
    in_i = 16'h0000;
    in_q = 16'h0000;
    valid_in = 1'b0;

    testname = "Asynchronous Reset";
    reset_dut();

    testname = "All Zeroes";
    stream_frame_from_file(1'b0, "testdata/fft_test_zeroes_real.txt", "testdata/fft_test_zeroes_imag.txt");
        
    testname = "Constant Value/Interrupted Streaming";
    stream_frame_from_file(1'b1, "testdata/fft_test_dc_real.txt", "testdata/fft_test_dc_imag.txt");
    
    testname = "Single Frequency";
    stream_frame_from_file(1'b0, "testdata/fft_test_sine_real.txt", "testdata/fft_test_sine_imag.txt");
    
    testname = "Single Phasor";
    stream_frame_from_file(1'b0, "testdata/fft_test_phasor_real.txt", "testdata/fft_test_phasor_imag.txt");
    
    testname = "Overflow Prevention";
    stream_frame_from_file(1'b0, "testdata/fft_test_overflow_real.txt", "testdata/fft_test_overflow_imag.txt");
    
    testname = "Linear Superposition";
    stream_frame_from_file(1'b0, "testdata/fft_test_superposition_real.txt", "testdata/fft_test_superposition_imag.txt");
    
    testname = "Single Spike";
    stream_frame_from_file(1'b0, "testdata/fft_test_spike_real.txt", "testdata/fft_test_spike_imag.txt");
    $finish;
end
endmodule