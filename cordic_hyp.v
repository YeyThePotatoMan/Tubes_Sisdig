module cordic_hyp (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire signed [31:0] theta,
    output reg                done,
    output wire signed [31:0] cosh_o,
    output wire signed [31:0] sinh_o
);
    localparam N = 30;
    localparam signed [31:0] X0 = 32'sh1351E872;

    reg               busy;
    reg        [4:0]  k;
    reg signed [31:0] x, y, z;
    reg        [4:0]  sh;
    reg signed [31:0] ang;

    always @(*) begin
        if (k <= 5'd2)       sh = k + 5'd1;
        else if (k <= 5'd4)  sh = 5'd4;
        else if (k <= 5'd13) sh = k;
        else                 sh = k - 5'd1;
    end

    always @(*) begin
        case (k)
            5'd0:  ang = 32'sd147453245;
            5'd1:  ang = 32'sd68561855;
            5'd2:  ang = 32'sd33730852;
            5'd3:  ang = 32'sd16799113;
            5'd4:  ang = 32'sd16799113;
            5'd5:  ang = 32'sd8391340;
            5'd6:  ang = 32'sd4194645;
            5'd7:  ang = 32'sd2097195;
            5'd8:  ang = 32'sd1048581;
            5'd9:  ang = 32'sd524289;
            5'd10: ang = 32'sd262144;
            5'd11: ang = 32'sd131072;
            5'd12: ang = 32'sd65536;
            5'd13: ang = 32'sd32768;
            5'd14: ang = 32'sd32768;
            5'd15: ang = 32'sd16384;
            5'd16: ang = 32'sd8192;
            5'd17: ang = 32'sd4096;
            5'd18: ang = 32'sd2048;
            5'd19: ang = 32'sd1024;
            5'd20: ang = 32'sd512;
            5'd21: ang = 32'sd256;
            5'd22: ang = 32'sd128;
            5'd23: ang = 32'sd64;
            5'd24: ang = 32'sd32;
            5'd25: ang = 32'sd16;
            5'd26: ang = 32'sd8;
            5'd27: ang = 32'sd4;
            5'd28: ang = 32'sd2;
            5'd29: ang = 32'sd1;
            default: ang = 32'sd0;
        endcase
    end

    wire signed [31:0] dx = y >>> sh;
    wire signed [31:0] dy = x >>> sh;

    assign cosh_o = x;
    assign sinh_o = y;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
            done <= 1'b0;
            k    <= 5'd0;
            x    <= 32'sd0;
            y    <= 32'sd0;
            z    <= 32'sd0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    x    <= X0;
                    y    <= 32'sd0;
                    z    <= theta;
                    k    <= 5'd0;
                    busy <= 1'b1;
                end
            end else begin
                if (z[31]) begin
                    x <= x - dx;
                    y <= y - dy;
                    z <= z + ang;
                end else begin
                    x <= x + dx;
                    y <= y + dy;
                    z <= z - ang;
                end
                if (k == N - 1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    k <= k + 5'd1;
                end
            end
        end
    end
endmodule
