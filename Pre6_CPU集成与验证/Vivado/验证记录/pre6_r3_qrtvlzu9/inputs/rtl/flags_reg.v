`timescale 1ns/1ps
// Architectural flags change at WB under independent masks. Address ADD,
// MOV, AND/OR and branches preserve flags through zero write masks.
module flags_reg(
    input clk, rst, z_we, cv_we, z_in, c_in, v_in,
    output reg Z, C, V
);
    always @(posedge clk) begin
        if (rst) begin
            Z <= 1'b0;
            C <= 1'b0;
            V <= 1'b0;
        end else begin
            if (z_we) Z <= z_in;
            if (cv_we) begin
                C <= c_in;
                V <= v_in;
            end
        end
    end
endmodule
