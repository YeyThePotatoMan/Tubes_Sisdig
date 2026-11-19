`timescale 1ns/1ps

module tb_cordic_hyp;
    localparam real SCALE = 268435456.0;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg start = 1'b0;
    reg signed [31:0] theta = 32'sd0;
    wire done;
    wire signed [31:0] co, si;

    cordic_hyp dut (
        .clk(clk), .rst_n(rst_n), .start(start), .theta(theta),
        .done(done), .cosh_o(co), .sinh_o(si)
    );

    always #5 clk = ~clk;

    real t, ec, es, maxe;
    integer i;

    initial begin
        maxe = 0.0;
        #20 rst_n = 1'b1;
        for (i = -22; i <= 22; i = i + 1) begin
            t = i * 0.05;
            theta = $rtoi(t * SCALE);
            @(posedge clk); start <= 1'b1;
            @(posedge clk); start <= 1'b0;
            @(posedge done);
            #1;
            ec = co - ($exp(t) + $exp(-t)) / 2.0 * SCALE;
            es = si - ($exp(t) - $exp(-t)) / 2.0 * SCALE;
            if (ec < 0.0) ec = -ec;
            if (es < 0.0) es = -es;
            if (ec > maxe) maxe = ec;
            if (es > maxe) maxe = es;
            $display("theta=%6.2f  cosh=%12.9f  sinh=%12.9f  err_lsb=%5.1f %5.1f",
                     t, co / SCALE, si / SCALE, ec, es);
        end
        $display("max error = %0.1f LSB (Q4.28)", maxe);
        if (maxe < 64.0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
