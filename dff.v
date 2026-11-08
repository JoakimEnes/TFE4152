`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin 

//D-latch med aktiv lav

module dlatch_r(output q, qn, input d, dn, en, clrn);
	wire en_x, en_c, s_n, r_n, r_x, r_c;
	
	nand2 g1 (en_x, en, clrn);
	inv g2 (en_c, en_x);
	
	nand2 g3 (s_n, d, en_c);
	nand2 g4 (r_n, dn, en_c);
	
	nand2 g5 (r_x, r_n, clrn);
	inv g6 (r_c, r_x);
	
	nand2 g7 (q, s_n, qn);
	nand2 g8 (qn, r_c, q);
	
endmodule
	
//D flip flop: positive edge triggered med master-slave og asynkron clear

module dff_r(output q, qn, input d, clk, clrn);
	wire dn, clkn, mq, mqn;
	
	inv i_d (dn, d);
	inv i_clk (clkn, clk);
	
	dlatch_r master (mq, mqn, d, dn, clkn, clrn); //åpem når clk = 0
	dlatch_r slave (q, qn, mq, mqn, clk, clrn);	  //åpen når clk = 1
	
endmodule