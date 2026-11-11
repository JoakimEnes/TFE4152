`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin Rikardsen

// Testbench for hele den digitale delen (FSM + timer).
//   Del 1: normal puls, slag ved 0.5, 1.5 og 2.5 s -> ingen pacing
//   Del 2: ingen slag i 3.5 s -> pacing ca. 1.5 s etter siste slag,
//          og deretter hvert ca. 1.5 s
// Testbenchen sjekker selv antall pacingpulser, tidspunkt og pulsbredde.

module tb_pacemaker;
	// Signaler testbenchen styrer
	reg clk = 0, H = 0, rst_n = 0;

	// Signaler testbenchen leser
	wire P;
	wire s1 = dut.fsm_inst.s1;	// tilstanden, hentet inne i FSM-en
	wire s0 = dut.fsm_inst.s0;
	wire T  = ~dut.T_n;		// timeout: T' fra timeren, gjort om til T

	// Variabler for målingene
	integer   paces  = 0;		// antall pacingpulser
	integer   errors = 0;		// antall feil
	realtime  last_beat;		// tidspunkt for slutten av siste hjerteslag
	realtime  first_pace;		// tidspunkt for første pacingpuls
	realtime  t_rise = -1;		// når P sist gikk høy

	// Kretsen som testes
	pacemaker dut (.H(H), .clk(clk), .rst_n(rst_n), .P(P));

	// Klokke: 512 Hz
	always #976562.5 clk = ~clk;

	// Logg tilstandsskifter
	always @(s1 or s0)
		$display("%0.4f s  tilstand = %b%b", $realtime/1e9, s1, s0);

	// Logg når timeren gir timeout
	always @(posedge T)
		$display("%0.4f s  T = 1 (timeout)", $realtime/1e9);

	// Når P går høy: tell pulsen og lagre tidspunktet
	always @(posedge P) begin
		t_rise = $realtime;
		paces  = paces + 1;
		if (paces == 1) first_pace = $realtime;
		$display("%0.4f s  PACE start", $realtime/1e9);
	end

	// Når P går lav: sjekk pulsbredden (krav: 2 ms +- 50 %, altså 1-3 ms)
	always @(negedge P) begin
		if (t_rise >= 0) begin
			if (($realtime - t_rise) >= 1e6 && ($realtime - t_rise) <= 3e6)
				$display("OK    pulsbredde = %0.3f ms", ($realtime - t_rise)/1e6);
			else begin
				$display("FEIL  pulsbredde = %0.3f ms (krav 1-3 ms)", ($realtime - t_rise)/1e6);
				errors = errors + 1;
			end
		end
	end

	// Ett hjerteslag: H høy i 40 ms
	task beat;
		begin
			H = 1;
			#40_000_000;
			H = 0;
			last_beat = $realtime;
		end
	endtask

	// Testforløpet
	initial begin
		#5_000_000 rst_n = 1;		// slipp reset etter 5 ms

		// Del 1: normal puls, ett slag i sekundet
		#495_000_000 beat;		// slag ved 0.5 s
		#960_000_000 beat;		// slag ved 1.5 s
		#960_000_000 beat;		// slag ved 2.5 s

		if (paces == 0)
			$display("OK    ingen pacing ved normal puls");
		else begin
			$display("FEIL  %0d pacingpulser ved normal puls (forventet 0)", paces);
			errors = errors + 1;
		end

		// Del 2: ingen slag i 3.5 s
		#1_750_000_000;
		#1_750_000_000;

		// Sjekk at det kom to pacingpulser
		if (paces == 2)
			$display("OK    2 pacingpulser uten hjerteslag");
		else begin
			$display("FEIL  %0d pacingpulser uten hjerteslag (forventet 2)", paces);
			errors = errors + 1;
		end

		// Sjekk at første pacing kom ca. 1.5 s etter siste slag
		if ((first_pace - last_beat) >= 1.49e9 && (first_pace - last_beat) <= 1.52e9)
			$display("OK    første pacing %0.4f s etter siste slag", (first_pace - last_beat)/1e9);
		else begin
			$display("FEIL  første pacing %0.4f s etter siste slag (forventet ca. 1.5 s)",
			         (first_pace - last_beat)/1e9);
			errors = errors + 1;
		end

		// Oppsummering
		if (errors == 0) $display("Alle tester OK");
		else             $display("%0d feil", errors);

		$finish;
	end
endmodule