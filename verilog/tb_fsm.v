`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin Rikardsen

// Testbench for FSM-en alene (uten timer).
// H og T' styres direkte, slik at alle overgangene kan testes raskt.
// Hver test sjekker selv tilstanden og begge utgangene P og R.
// Tilstander: WAIT = 00 (P=0, R=0), SENSE = 01 (P=0, R=1), PACE = 10 (P=1, R=1)

module tb_fsm;
	// Signaler testbenchen styrer
	reg clk = 0, rst_n = 0, h = 0, tn = 1;

	// Signaler testbenchen leser
	wire p, rn, s1, s0;

	// Teller antall feil
	integer errors = 0;

	// Kretsen som testes
	fsm dut (.p(p), .rn(rn), .s1(s1), .s0(s0),
	         .h(h), .tn(tn), .clk(clk), .rst_n(rst_n));

	// Klokke: 512 Hz
	always #976562.5 clk = ~clk;

	// Testforløpet
	initial begin
		#5_000_000 rst_n = 1;

		// Test 1: WAIT, ingen slag, ingen timeout -> WAIT (00)
		@(negedge clk); h = 0; tn = 1;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 0 && p === 0 && rn === 1)
			$display("OK    1. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  1. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b (forventet 00, P=0, R=0)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 2: WAIT, hjerteslag -> SENSE (01)
		@(negedge clk); h = 1; tn = 1;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 1 && p === 0 && rn === 0)
			$display("OK    2. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  2. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b (forventet 01, P=0, R=1)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 3: SENSE, slaget pågår -> SENSE (01)
		@(negedge clk); h = 1; tn = 1;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 1 && p === 0 && rn === 0)
			$display("OK    3. SENSE, H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  3. SENSE, H=%b T=%b -> %b%b  P=%b R=%b (forventet 01, P=0, R=1)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 4: SENSE, slaget er over -> WAIT (00)
		@(negedge clk); h = 0; tn = 1;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 0 && p === 0 && rn === 1)
			$display("OK    4. SENSE, H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  4. SENSE, H=%b T=%b -> %b%b  P=%b R=%b (forventet 00, P=0, R=0)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 5: WAIT, timeout -> PACE (10)
		@(negedge clk); h = 0; tn = 0;
		@(posedge clk); #10;
		if (s1 === 1 && s0 === 0 && p === 1 && rn === 0)
			$display("OK    5. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  5. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b (forventet 10, P=1, R=1)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 6: PACE, alltid -> WAIT (00), H og T spiller ingen rolle
		@(negedge clk); h = 1; tn = 0;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 0 && p === 0 && rn === 1)
			$display("OK    6. PACE,  H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  6. PACE,  H=%b T=%b -> %b%b  P=%b R=%b (forventet 00, P=0, R=0)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Test 7: WAIT, slag og timeout samtidig -> SENSE (01), H har prioritet
		@(negedge clk); h = 1; tn = 0;
		@(posedge clk); #10;
		if (s1 === 0 && s0 === 1 && p === 0 && rn === 0)
			$display("OK    7. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b", h, ~tn, s1, s0, p, ~rn);
		else begin
			$display("FEIL  7. WAIT,  H=%b T=%b -> %b%b  P=%b R=%b (forventet 01, P=0, R=1)", h, ~tn, s1, s0, p, ~rn);
			errors = errors + 1;
		end

		// Oppsummering
		if (errors == 0) $display("Alle tester OK");
		else             $display("%0d feil", errors);

		$finish;
	end
endmodule

