`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin 
	

//Modules - Gates:inv, nor2, nand2  


//Comb gates
//INV:

module inv(output y, input a);
	supply1 vdd;
	supply0 gnd; 
	
	pmos #1 (y, vdd, a);
	nmos #1 (y, gnd, a);

endmodule

//NOR2:

module nor2(output y, input a, b);
	supply1 vdd;
	supply0 gnd;
	wire m;
	
	pmos #0 (m, vdd, a);
	pmos #1 (y, m, b);
	
	nmos #1 (y, gnd, a);
	nmos #1 (y, gnd, b);

endmodule

//The rest of the system

//NAND2:

module nand2(output y, input a, b);
	supply1 vdd;
	supply0 gnd;
	wire m;
	
	pmos #1 (y, vdd, a);
	pmos #1 (y, vdd, b);
	
	nmos #1 (y, m, a);
	nmos #0 (m, gnd, b);

endmodule



