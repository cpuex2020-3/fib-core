`timescale 1ns / 100ps
`default_nettype none

module test_fsgnj();
   wire [31:0]  x1,  x2,  c,  y;
   shortreal    x1f, x2f, cf, yf;

   fsgnj u1(x1, x2, y);

   initial begin
      $display("start of checking module fsgnj");
      // Main routine
      repeat(10) begin
         x1 = $urandom();
         x2 = $urandom();
         x1f = $bitstoshortreal(x1);
         x2f = $bitstoshortreal(x2);
         #1;
         
         // fsgnj
         if(x1f >= 0) begin 
            cf = + abs(x2f);
         end else begin
            cf = - abs(x2f);
         end

         c  = $shortrealtobits(cf);
         if (c != y) begin
            $display("x1 = %b %b %b %e",
               x1[31], x1[30:23], x1[22:0], x1f);
            $display("x2 = %b %b %b %e",
               x2[31], x2[30:23], x2[22:0], x2f);
            $display("c  = %b %b %b %e",
               c[31], c[30:23], c[22:0], cf);
            $display("y  = %b %b %b %e",
               y[31], y[30:23], y[22:0], yf);
         end
      end
      $display("end of checking module fsgnj");
      $finish;
   end
endmodule

`default_nettype wire
