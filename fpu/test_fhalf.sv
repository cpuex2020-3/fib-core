`timescale 1ns / 100ps
`default_nettype none

module test_fhalf();
   wire [31:0]  y;
   logic [31:0] x, c;
   shortreal    fx, fc, fy;
   int          s, e, m;

   fhalf u1(x,y);

   initial begin
      $display("start of checking module fhalf");

      // Main routine
      for (s=0; s<2; s++) begin
         for (e=1; e<256; e++) begin
            #1;
            $display("e = %d/255", e);
            for (m=0; m<(1<<23); m++) begin
               x = {s[0], e[7:0], m[22:0]};
               fx = $bitstoshortreal(x);
               fc = fx / 2;
               c  = $shortrealtobits(fc);
               fy = $bitstoshortreal(y);
               #1;

               if (c[30:23] == 8'b0 || (c[30:23] == '1 && c[22:0] != '0)) begin
                  // c is nan.
               end else begin
                  if (c == y) begin
                  end else begin
                      $display("x       : %b %b %b %e", x[31], x[30:23], x[22:0], fx);
                      $display("correct : %b %b %b %e", c[31], c[30:23], c[22:0], fc);
                      $display("myanswer: %b %b %b %e", y[31], y[30:23], y[22:0], fy);
                      $display("diff: %d", 10+y-c);
                  end
               end
            end
         end
      end

      $display("end of checking module fhalf");
      $finish;
   end
endmodule

`default_nettype wire
