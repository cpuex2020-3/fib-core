`timescale 1ns / 100ps
`default_nettype none


function void check_fle_s(
    input logic [31:0] x1,
    input logic [31:0] x2,
    input logic [31:0] y);
   logic c;
   shortreal    x1f, x2f;

   x1f = $bitstoshortreal(x1);
   x2f = $bitstoshortreal(x2);
   // fle
   c = (x1f<=x2f) ? 1 : 0;

   if (c != y[0]) begin
      $display("x1 = %b %b %b %e",
         x1[31], x1[30:23], x1[22:0], x1f);
      $display("x2 = %b %b %b %e",
         x2[31], x2[30:23], x2[22:0], x2f);
      $display("c  = %b", c);
      $display("y  = %b", y[0]);
   end
   return;
endfunction

module test_fle_s();
   logic [31:0]  x1,  x2;
   logic [31:0]  y;

   fle_s u1(x1, x2, y);

   initial begin
      $display("start of checking module fle_s");
      // Main routine
      

      x1 = 32'h00000000;
      x2 = 32'h00000000;
      #1;
      check_fle_s(x1, x2, y);

      x1 = 32'h80000000;
      x2 = 32'h00000000;
      #1;
      check_fle_s(x1, x2, y);

      x1 = 32'h00000000;
      x2 = 32'h80000000;
      #1;
      check_fle_s(x1, x2, y);


      repeat(1024*1024*8) begin
         x1 = $urandom();
         x2 = $urandom();
         if(x1[30:23]==255 || x1[30:23]==0) begin
            if(x1[30:0]==0)begin
               $display("x1 is zero.");
            end else begin
               //$display("x1 is nan or inf.");
               continue;
            end
         end
         if(x2[30:23]==255 || x2[30:23]==0) begin
            if(x2[30:0]==0)begin
               $display("x2 is zero.");
            end else begin
               //$display("x2 is nan or inf.");
               continue;
            end
         end
         #1;
         check_fle_s(x1, x2, y);
      end
      repeat(1024*1024*8) begin
         x1 = $urandom();
         x2 = x1;
         if(x1[30:23]==255 || x1[30:23]==0) begin
            if(x1[30:0]==0)begin
               $display("x1 is zero.");
            end else begin
               //$display("x1 is nan or inf.");
               continue;
            end
         end
         if(x2[30:23]==255 || x2[30:23]==0) begin
            if(x2[30:0]==0)begin
               $display("x2 is zero.");
            end else begin
               //$display("x2 is nan or inf.");
               continue;
            end
         end
         #1;
         check_fle_s(x1, x2, y);
      end
      $display("end of checking module fle_s");
      $finish;
   end
endmodule

`default_nettype wire
