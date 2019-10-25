/*********************************************************************************
Environment: 	Windows8.1 (X64) + Quartus13.1
Name	     : 	Cordic
Function	  :	This Cordic Module is used to Generate Sin/Cos wave
Create date： 	2019/10/25
Author	  : 	isaactesla@pku.edu.cn
version	  : 	V1.0.0
update records: updated by 		 date				content		version
				isaactesla     2019/10/25        	create  	 V1.0.0

Copyright(c)：
	Institute of MicroElectronics(IME), EECS, Peking University
	All Right reserved.
**********************************************************************************
Input:	
		clk_50M:	clock of the system (50MHz)
		FreCtrl：the frequency Control number of the Sin/Cos wave 21990~2^40/50E6
							=21990 * freq_number (21990 means 1Hz wave)
Output：
		SinOut:	18bit Sin signal output
		CosOut:	18bit Cos signal output
Temp:
		Amp:	Output signal amplitude of the wave
		PhaseInit: initial phase 32768~45Degree	
********************************************************************************/
module Cordic(
	clk_50M,FreCtrl,PhaseInit,
	SinOut,CosOut);

input clk_50M;
input signed [17:0] PhaseInit;

input signed [31:0] FreCtrl;
output reg signed [17:0] SinOut=0;
output reg signed [17:0] CosOut=0;

reg signed [17:0] eps;
reg rst_n=1;
reg ena=1;
reg signed [17:0] amp=39795; // Out Amplitude Maxax=131072   Correspond amp=2^16*0.607253=39795  
reg signed [17:0] PhaseInit=0;

reg signed [17:0] x0,y0,z0,x8,y8,z8;
reg signed [17:0] x1,y1,z1,x9,y9,z9;
reg signed [17:0] x2,y2,z2,x10,y10,z10;
reg signed [17:0] x3,y3,z3,x11,y11,z11;
reg signed [17:0] x4,y4,z4,x12,y12,z12;
reg signed [17:0] x5,y5,z5,x13,y13,z13;
reg signed [17:0] x6,y6,z6,x14,y14,z14;
reg signed [17:0] x7,y7,z7,x15,y15,z15;
reg signed [17:0] x16,y16,z16,x17,y17,z17;
reg signed [39:0] addb=0; 

// determine the frequency of the wave
always @(posedge clk_50M or negedge rst_n)
begin
	if(!rst_n)
      begin
      addb<=0;
      end
   else
      if(ena)
         begin
           addb <= addb + FreCtrl;			// 1Hz SinWave	number	=	2^40/50M ~21990
         end
end

// determine the amplitude and initial phase of the wave
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x0<=0;
         y0<=0;
         z0<=0;
      end
   else
      if(ena)
         begin
            x0 <= amp;		//define transfer factor constant X0=0.607253*2^16=39796.9
            y0 <= 0; 
            z0 <= addb[39:22]+PhaseInit; 		// initial phase
         end
end

//level 1
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x1<=0;
         y1<=0;
         z1<=0;
      end
   else
      if(ena)
         if(z0[17]==1'b0)
            begin
               x1 <= x0 - y0;
               y1 <= y0 + x0;
               z1 <= z0 - 32768;  //45deg
            end
         else
            begin
               x1 <= x0 + y0;
               y1 <= y0 - x0;
               z1 <= z0 + 32768;  //45deg
            end
end

//level 2
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x2<=0;
         y2<=0;
         z2<=0;
      end
   else
      if(ena)
         if(z1[17]==1'b0)
            begin
               x2 <= x1 - y1;
               y2 <= y1 + x1;
               z2 <= z1 - 32768;  //45deg
            end
         else
            begin
               x2 <= x1 + y1;
               y2 <= y1 - x1;
               z2 <= z1 + 32768;  //45deg
            end
end

//level 3
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x3<=0;
         y3<=0;
         z3<=0;
      end
   else
      if(ena)
         if(z2[17]==1'b0)
            begin
               x3 <= x2 - y2;
               y3 <= y2 + x2;
               z3 <= z2 - 32768;  //45deg
            end
         else
            begin
               x3 <= x2 + y2;
               y3 <= y2 - x2;
               z3 <= z2 + 32768;  //45deg
            end
end

//level 4
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x4<=0;
         y4<=0;
         z4<=0;
      end
   else
      if(ena)
         if(z3[17]==1'b0)
            begin
               x4 <= x3 - {y3[17],y3[17:1]};
               y4 <= y3 + {x3[17],x3[17:1]};
               z4 <= z3 - 19344;  //26.5651deg
            end
         else
            begin
               x4 <= x3 + {y3[17],y3[17:1]};
               y4 <= y3 - {x3[17],x3[17:1]};
               z4 <= z3 + 19344;  //26.5651deg
            end
end

//level 5
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x5<=0;
         y5<=0;
         z5<=0;
      end
   else
      if(ena)
         if(z4[17]==1'b0)
            begin
               x5 <= x4 - {{2{y4[17]}},y4[17:2]};
               y5 <= y4 + {{2{x4[17]}},x4[17:2]};
               z5 <= z4 - 10221;  //14.0362deg
            end
         else
            begin
               x5 <= x4 + {{2{y4[17]}},y4[17:2]};
               y5 <= y4 - {{2{x4[17]}},x4[17:2]};
               z5 <= z4 + 10221;  //14.0362deg
            end
end            
  
//level 6
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x6<=0;
         y6<=0;
         z6<=0;
      end
   else
      if(ena)
         if(z5[17]==1'b0)
            begin
               x6 <= x5 - {{3{y5[17]}},y5[17:3]};
               y6 <= y5 + {{3{x5[17]}},x5[17:3]};
               z6 <= z5 - 5188;  //7.12502deg
            end
         else
            begin
               x6 <= x5 + {{3{y5[17]}},y5[17:3]};
               y6 <= y5 - {{3{x5[17]}},x5[17:3]};
               z6 <= z5 + 5188;  //7.12502deg
            end
end 

//level 7
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x7<=0;
         y7<=0;
         z7<=0;
      end
   else
      if(ena)
         if(z6[17]==1'b0)
            begin
               x7 <= x6 - {{4{y6[17]}},y6[17:4]};
               y7 <= y6 + {{4{x6[17]}},x6[17:4]};
               z7 <= z6 - 2604;  //3.57633deg
            end
         else
            begin
               x7 <= x6 + {{4{y6[17]}},y6[17:4]};
               y7 <= y6 - {{4{x6[17]}},x6[17:4]};
               z7 <= z6 + 2604;  //3.57633deg
            end
end 

//level 8
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x8<=0;
         y8<=0;
         z8<=0;
      end
   else
      if(ena)
         if(z7[17]==1'b0)
            begin
               x8 <= x7 - {{5{y7[17]}},y7[17:5]};
               y8 <= y7 + {{5{x7[17]}},x7[17:5]};
               z8 <= z7 - 1303;  //1.78991deg
            end
         else
            begin
               x8 <= x7 + {{5{y7[17]}},y7[17:5]};
               y8 <= y7 - {{5{x7[17]}},x7[17:5]};
               z8 <= z7 + 1303;  //1.78991deg
            end
end 

//level 9
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x9<=0;
         y9<=0;
         z9<=0;
      end
   else
      if(ena)
         if(z8[17]==1'b0)
            begin
               x9 <= x8 - {{6{y8[17]}},y8[17:6]};
               y9 <= y8 + {{6{x8[17]}},x8[17:6]};
               z9 <= z8 - 652;  //0.895174deg
            end
         else
            begin
               x9 <= x8 + {{6{y8[17]}},y8[17:6]};
               y9 <= y8 - {{6{x8[17]}},x8[17:6]};
               z9 <= z8 + 652;  //0.895174deg
            end
end 

//level 10
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x10<=0;
         y10<=0;
         z10<=0;
      end
   else
      if(ena)
         if(z9[17]==1'b0)
            begin
               x10 <= x9 - {{7{y9[17]}},y9[17:7]};
               y10 <= y9 + {{7{x9[17]}},x9[17:7]};
               z10 <= z9 - 326;  //0.447614deg
            end
         else
            begin
               x10 <= x9 + {{7{y9[17]}},y9[17:7]};
               y10 <= y9 - {{7{x9[17]}},x9[17:7]};
               z10 <= z9 + 326;  //0.447614deg
            end
end 

//level 11
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x11<=0;
         y11<=0;
         z11<=0;
      end
   else
      if(ena)
         if(z10[17]==1'b0)
            begin
               x11 <= x10 - {{8{y10[17]}},y10[17:8]};
               y11 <= y10 + {{8{x10[17]}},x10[17:8]};
               z11 <= z10 - 163;  //0.223811deg
            end
         else
            begin
               x11 <= x10 + {{8{y10[17]}},y10[17:8]};
               y11 <= y10 - {{8{x10[17]}},x10[17:8]};
               z11 <= z10 + 163;  //0.223811deg
            end
end 

//level 12
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x12<=0;
         y12<=0;
         z12<=0;
      end
   else
      if(ena)
         if(z11[17]==1'b0)
            begin
               x12 <= x11 - {{9{y11[17]}},y11[17:9]};
               y12 <= y11 + {{9{x11[17]}},x11[17:9]};
               z12 <= z11 - 81;  //0.111906deg
            end
         else
            begin
               x12 <= x11 + {{9{y11[17]}},y11[17:9]};
               y12 <= y11 - {{9{x11[17]}},x11[17:9]};
               z12 <= z11 + 81;  //0.111906deg
            end
end 

//level 13
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x13<=0;
         y13<=0;
         z13<=0;
      end
   else
      if(ena)
         if(z12[17]==1'b0)
            begin
               x13 <= x12 - {{10{y12[17]}},y12[17:10]};
               y13 <= y12 + {{10{x12[17]}},x12[17:10]};
               z13 <= z12 - 41;  //0.0559529deg
            end
         else
            begin
               x13 <= x12 + {{10{y12[17]}},y12[17:10]};
               y13 <= y12 - {{10{x12[17]}},x12[17:10]};
               z13 <= z12 + 41;  //0.0559529deg
            end
end 

//level 14
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x14<=0;
         y14<=0;
         z14<=0;
      end
   else
      if(ena)
         if(z13[17]==1'b0)
            begin
               x14 <= x13 - {{11{y13[17]}},y13[17:11]};
               y14 <= y13 + {{11{x13[17]}},x13[17:11]};
               z14 <= z13 - 20;  //0.0279765deg
            end
         else
            begin
               x14 <= x13 + {{11{y13[17]}},y13[17:11]};
               y14 <= y13 - {{11{x13[17]}},x13[17:11]};
               z14 <= z13 + 20;  //0.0279765deg
            end
end 

//level 15
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x15<=0;
         y15<=0;
         z15<=0;
      end
   else
      if(ena)
         if(z14[17]==1'b0)
            begin
               x15 <= x14 - {{12{y14[17]}},y14[17:12]};
               y15 <= y14 + {{12{x14[17]}},x14[17:12]};
               z15 <= z14 - 10;  //0.0139882deg
            end
         else
            begin
               x15 <= x14 + {{12{y14[17]}},y14[17:12]};
               y15 <= y14 - {{12{x14[17]}},x14[17:12]};
               z15 <= z14 + 10;  //0.0139882deg
            end
end 

//level 16
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x16<=0;
         y16<=0;
         z16<=0;
      end
   else
      if(ena)
         if(z15[17]==1'b0)
            begin
               x16 <= x15 - {{13{y15[17]}},y15[17:13]};
               y16 <= y15 + {{13{x15[17]}},x15[17:13]};
               z16 <= z15 - 5;  //0.00699411deg
            end
         else
            begin
               x16 <= x15 + {{13{y15[17]}},y15[17:13]};
               y16 <= y15 - {{13{x15[17]}},x15[17:13]};
               z16 <= z15 + 5;  //0.00699411deg
            end
end 

//level 17
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         x17<=0;
         y17<=0;
         z17<=0;
      end
   else
      if(ena)
         if(z16[17]==1'b0)
            begin
               x17 <= x16 - {{14{y16[17]}},y16[17:14]};
               y17 <= y16 + {{14{x16[17]}},x16[17:14]};
               z17 <= z16 - 3;  //0.00349706deg
            end
         else
            begin
               x17 <= x16 + {{14{y16[17]}},y16[17:14]};
               y17 <= y16 - {{14{x16[17]}},x16[17:14]};
               z17 <= z16 + 3;  //0.00349706deg
            end
end 

//level 18
always @(posedge clk_50M or negedge rst_n)
begin
   if(!rst_n)
      begin
         CosOut<=0;
         SinOut<=0;
         eps<=0;
      end
   else
      if(ena)
         if(z17[17]==1'b0)
            begin
               CosOut <= x17 - {{15{y17[17]}},y17[17:15]};
               SinOut <= y17 + {{15{x17[17]}},x17[17:15]};
               eps <= z17 - 1;  //0.00174853deg
            end
         else
            begin
               CosOut <= x17 + {{15{y17[17]}},y17[17:15]};
               SinOut <= y17 - {{15{x17[17]}},x17[17:15]};
               eps <= z17 + 1;  //0.00174853deg
            end
end 

endmodule
