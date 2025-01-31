`timescale 1ns / 100ps
`default_nettype none

module test_fcvt_s_w();
   logic        clk, rstn;
   logic [31:0]  x1,  c,  y;
   int          x1i;
   real         cr;
   shortreal    cf, yf;

   fcvt_s_w u1(clk, rstn, x1, y);

   initial begin
      $display("start of checking module fcvt_s_w");
      // Initializing ...
      #1;
      rstn = 0;
      clk = 1;
      #1;
      clk = 0;
      #1;
      clk = 1;
      rstn = 1;
      #1;
      clk = 0;
      #1;
      clk = 1;
      #1;
      // Main routine
      repeat(1024*1024*8) begin
         x1 = $urandom();
         x1i = x1;
         if(x1[30:23]==255 || x1[30:23]==0) begin
            if(x1[30:0]==0)begin
               $display("x1 is zero.");
            end else begin
               //$display("x1 is nan or inf.");
               continue;
            end
         end

         repeat(5) begin
            clk = 0;
            #1; 
            clk = 1;
            #1; 
         end
         
         cr = $itor(x1i);
         cf = shortreal'(cr);
         c  = $shortrealtobits(cf);

         yf = $bitstoshortreal(y);

         if (c != y) begin
            $display("x1 = %b %b %b %d",
               x1[31], x1[30:23], x1[22:0], x1i);
            $display("c  = %b %b %b %e",
               c[31], c[30:23], c[22:0], cf);
            $display("y  = %b %b %b %e",
               y[31], y[30:23], y[22:0], yf);
         end
      end
      $display("end of checking module fcvt_s_w");
      $finish;
   end
endmodule

`default_nettype wire
