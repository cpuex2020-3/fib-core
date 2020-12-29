`timescale 1ns / 100ps
`default_nettype none

module test_fsgnj_s();
   logic [31:0]  x1,  x2,  c,  y;
   shortreal    x1f, x2f, cf, yf;

   fsgnj_s u1(x1, x2[31], y);

   initial begin
      $display("start of checking module fsgnj_s");
      // Main routine
      repeat(1024*1024*8) begin
         x1 = $urandom();
         x2 = $urandom();
         x1f = $bitstoshortreal(x1);
         x2f = $bitstoshortreal(x2);
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
         
         // fsgnj
         if(x2[31] == 0) begin 
            cf = + abs(x1f);
         end else begin
            cf = - abs(x1f);
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
      $display("end of checking module fsgnj_s");
      $finish;
   end
endmodule

`default_nettype wire
