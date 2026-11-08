// =====================================================================
// Rask test av FSM-en alene (uten timer): H og T styres direkte
// Sjekker alle overgangene i tilstandsdiagrammet på noen få klokker.
// =====================================================================
`timescale 1ns/1ps

module tb_fsm;
    reg  clk = 0, rst_n = 0, h = 0, t = 0;
    wire tn = ~t;                 // testbench kan bruke operatorer
    wire p, rn, s1, s0;
    integer errors = 0;

    fsm dut (.p(p), .rn(rn), .s1(s1), .s0(s0),
             .h(h), .tn(tn), .clk(clk), .rst_n(rst_n));

    always #976562.5 clk = ~clk;  // 512 Hz

    task check(input [1:0] st, input pe, input re, input [8*24-1:0] txt);
        begin
            if ({s1,s0} !== st || p !== pe || rn !== ~re) begin
                $display("FEIL  %0s: tilstand=%b%b P=%b Rn=%b", txt, s1, s0, p, rn);
                errors = errors + 1;
            end else
                $display("OK    %0s: tilstand=%b%b P=%b R=%b", txt, s1, s0, p, ~rn);
        end
    endtask

    // Sett innganger midt i lav-perioden, sjekk rett etter stigende flanke
    task step(input hv, input tv);
        begin
            @(negedge clk); h = hv; t = tv;
            @(posedge clk); #10;
        end
    endtask

    initial begin
        #10; check(2'b00, 0, 0, "reset -> WAIT");
        #5_000_000 rst_n = 1;
        step(0,0); check(2'b00, 0, 0, "WAIT, H=0 T=0 -> WAIT");
        step(1,0); check(2'b01, 0, 1, "WAIT, H=1 -> RESET");
        step(1,0); check(2'b01, 0, 1, "RESET, H=1 -> RESET");
        step(0,0); check(2'b00, 0, 0, "RESET, H=0 -> WAIT");
        step(0,1); check(2'b10, 1, 1, "WAIT, T=1 -> PACE");
        step(1,1); check(2'b00, 0, 0, "PACE -> WAIT (alltid)");
        step(1,1); check(2'b01, 0, 1, "WAIT, H=1 T=1 -> RESET");
        step(0,0); check(2'b00, 0, 0, "RESET, H=0 -> WAIT");
        if (errors == 0) $display("Alle tester OK");
        else             $display("%0d feil", errors);
        $finish;
    end
endmodule