`timescale 1ns / 1ps
// EES-331: external 100 MHz PL clock; eight active-high LEDs.
// Power-up: LED0 on. Advance by one LED every 0.5 seconds.
module ees331_led (
    input  wire       clk_100m,
    output reg  [7:0] led = 8'b00000001
);
    reg [25:0] count = 26'd0;
    always @(posedge clk_100m) begin
        if (count == 26'd49999999) begin
            count <= 26'd0;
            led <= {led[6:0], led[7]};
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
