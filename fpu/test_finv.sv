`timescale 1ns / 100ps
`default_nettype none

module test_finv();
   logic        clk, rstn;
   wire [31:0]  y;
   logic [31:0] x, c;
   shortreal    fx, fc, fy;
   int          i, s, e, m, d;
   int          d06, d07, d08, d09, d10, d11, d12, d13, d14;

   finv u1(x,clk,rstn,y);

   initial begin
      $display("start of checking module finv");
      // Initializing ...
      d06 = 0;
      d07 = 0;
      d08 = 0;
      d09 = 0;
      d10 = 0;
      d11 = 0;
      d12 = 0;
      d13 = 0;
      d14 = 0;
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
      for (s=0; s<2; s++) begin
         for (e=1; e<256; e++) begin
            $display("e = %d/255", e);
            for (m=0; m<(1<<23); m++) begin
               x = {s[0], e[7:0], m[22:0]};
               fx = $bitstoshortreal(x);
               fc = 1 / fx;
               c  = $shortrealtobits(fc);
               clk = 0;
               #1;
               clk = 1;
               #1;
               fy = $bitstoshortreal(y);
              
               d = 10+y-c;
               if (c[30:23] == 8'b0 || (c[30:23] == '1 && c[22:0] != '0)) begin
                  // c is nan.
               end else begin
                  if (6 <= d & d <= 14) begin
                     if (d == 6) begin
                        d06 += 1;
                     end else if (d == 7) begin
                        d07 += 1;
                     end else if (d == 8) begin
                        d08 += 1;
                     end else if (d == 9) begin
                        d09 += 1;
                     end else if (d == 10) begin
                        d10 += 1;
                     end else if (d == 11) begin
                        d11 += 1;
                     end else if (d == 12) begin
                        d12 += 1;
                     end else if (d == 13) begin
                        d13 += 1;
                     end else if (d == 14) begin
                        d14 += 1;
                   end
                  end else begin
                      $display("x       : %b %b %b %e", x[31], x[30:23], x[22:0], fx);
                      $display("correct : %b %b %b %e", c[31], c[30:23], c[22:0], fc);
                      $display("myanswer: %b %b %b %e", y[31], y[30:23], y[22:0], fy);
                      $display("diff: %d", 10+y-c);
                  end
               end
               #1;
            end
         end
      end

      $display("d06 = %d", d06);
      $display("d07 = %d", d07);
      $display("d08 = %d", d08);
      $display("d09 = %d", d09);
      $display("d10 = %d", d10);
      $display("d11 = %d", d11);
      $display("d12 = %d", d12);
      $display("d13 = %d", d13);
      $display("d14 = %d", d14);

      $display("end of checking module finv");
      $finish;
   end
endmodule

`default_nettype wire
