`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin 

// FSM:

module next_state (output n1, n0, input s1, h, tn);
	//n1 = NOR2( INV( NOR2(S1, H)), Tn)
	
	wire a, a_n;
	
	nor2 g_a (a, s1, h);
	inv g_an (a_n, a);
	nor2 g_n1 (n1, a_n, tn);
	
	//n0 = NOR2(S1, H')	   
	wire h_n;
	
	inv g_hn(h_n, h);
	nor2 g_n0(n0, s1, h_n);
	
endmodule 

// output logic for Rn and P
// P kan forenkles til S1 direkte, og vi må kun assigne den.
	
module output_logic (output rn, input s1, s1n, s0);	
	
	// Rn = NOR2 (s1, s0) 
	nor2 g_rn (rn, s1, s0);

endmodule

// state register, with 2 dff's:
// rst_n is an independent and external reset signal. rst_n != rn
module state_reg (output s1, s1n, s0, s0n, input n1, n0, clk, rst_n);
	
	dff_r dffs1 (s1, s1n, n1, clk, rst_n); //S1 på stigende flanke
	dff_r dffs0 (s0, s0n, n0, clk, rst_n); //S0 på stigende flanke 					  	
	
endmodule

//SÅ sammensetting av alt - FSM module:

module fsm (output p, rn, s1, s0, input h, tn, clk, rst_n);
	wire n1, n0, s1n, s0n;
	
	// neste state
	next_state u_next (n1, n0, s1, h, tn);
	
	//outputs:								 
	assign p = s1; // Direkte setter P = s1 som forenkling pga dont care felt
	output_logic u_out (rn, s1, s1n, s0); 
	
	// lagre verdier
	state_reg u_reg (s1, s1n, s0, s0n, n1, n0, clk, rst_n);
	
endmodule
	
	

