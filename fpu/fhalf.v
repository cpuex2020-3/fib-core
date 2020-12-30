`default_nettype none
`timescale 10ps / 1ps

module fhalf (
    input wire [31:0] x, 
    output wire [31:0] y
    );
    wire [7:0] e1;
    wire [7:0] e2;
    assign e1 = x[30:23];
    assign e2 = e1 - 1;
    assign y = {x[31], e2, x[22:0]};
endmodule
