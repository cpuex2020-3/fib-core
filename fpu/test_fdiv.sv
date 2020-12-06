`timescale 1ns / 100ps
`default_nettype none

function shortreal abs(input shortreal x);
   if (x >= 0) return (x);
   else        return (-x);
endfunction

function shortreal max(input shortreal x, input shortreal y);
   if (x >= y) return (x);
   else        return (y);
endfunction

module test_fdiv();
   wire [31:0] x1,x2,y;
   wire        ovf;
   logic       clk, rstn;
   logic [31:0] x1i,x2i;
   shortreal    fx1,fx2,fy,myfy;
   int          i,j,k,it,jt;
   bit [22:0]   m1,m2;
   bit [9:0]    dum1,dum2;
   logic [31:0] fybit;
   int          s1,s2;
   logic [23:0] dy;
   bit [22:0] tm;
   bit 	      fovf;
   bit 	      checkovf;
   shortreal h20, eps, p127;

   assign h20 = 1.0/2097152*2;
   assign eps = 1.0/2097152/2097152/2097152/2097152/2097152/2097152;
   assign p127 = 2.0*2097152*2097152*2097152*2097152*2097152*2097152;

   assign x1 = x1i;
   assign x2 = x2i;
   
   fdiv u1(x1, x2, clk, rstn, y);
   assign ovf = 1'b0;

   initial begin
      // $dumpfile("test_fdiv.vcd");
      // $dumpvars(0);

      $display("start of checking module fdiv");
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

      for (i=1; i<255; i++) begin
         for (j=1; j<255; j++) begin
            for (s1=0; s1<2; s1++) begin
               for (s2=0; s2<2; s2++) begin
                  repeat(1/*10*/) begin 
                  #1;

                  {m1,dum1} = $urandom();
                  x1i = {s1[0],i[7:0],m1};
                  {m2,dum2} = $urandom();
                  x2i = {s2[0],j[7:0],m2};

                  fx1 = $bitstoshortreal(x1i);
                  fx2 = $bitstoshortreal(x2i);
                  fy = fx1 / fx2;
                  fybit = $shortrealtobits(fy);

		          checkovf = i < 255;
                    
                  clk = 0;
                  #1;
                  clk = 1;
                  #1;


		          if (checkovf && fybit[30:23] == 255) begin
			         fovf = 1;
		          end else begin
			         fovf = 0;
   		          end
 
                  #1;
                  myfy = $bitstoshortreal(y);
                  if (y !== fybit || ovf !== fovf) begin
                     if (x1[30:23] == '1 && x1[22:0] != '0) begin
                        $display("y is incorrect, but x1 is nan so it is ok.");
                     end else if (x2[30:23] == '1 && x2[22:0] != '0) begin
                        $display("y is incorrect, but x2 is nan so it is ok.");
                     end else if (fybit[30:23] == '1 && fybit[22:0] != '0) begin
                        $display("y is incorrect, but fybit is nan so it is ok.");
                     end else if (abs(fy-myfy) < max(abs(fy)*h20, eps))  begin
                        //$display("y is quite near to fy.");
                     end else if (abs(fy) >= p127)  begin
                        //$display("abs(fy) is too large.");
                     end else begin
                        $display("x1 = %b %b %b %e",
				                  x1[31], x1[30:23], x1[22:0], $bitstoshortreal(x1));
                        $display("x2 = %b %b %b %e",
				                  x2[31], x2[30:23], x2[22:0], $bitstoshortreal(x2));
                        $display("correct : %b %b %b %e, %b",
				                  fybit[31], fybit[30:23], fybit[22:0], fy, fovf);
                        $display("myanswer: %b %b %b %e, %b\n",
				                  y[31], y[30:23], y[22:0], myfy, ovf);
                     end
                  end
                  end
               end
            end
         end
      end
      $display("end of checking module fdiv");
      $finish;
   end
endmodule

`default_nettype wire
