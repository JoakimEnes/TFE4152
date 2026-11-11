`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin Rikardsen

module pacemaker (
    input wire H,
    input wire clk,
    input wire rst_n,
    output wire P
);
    // Synkronisering av H til klokken
    wire H_clk;

    dff_r H_dff (
        .q(H_clk),
        .d(H),
        .clk(clk),
        .clrn(rst_n)
    );

    wire R_n;
    wire T_n;

    // Timeren nullstilles av FSM-en (R_n) og ved oppstart (rst_n):
    // timer_rst_n = R_n * rst_n
    wire timer_rst_n;
    wire timer_rst_n_nand;

    nand2 reset_nand (timer_rst_n_nand, rst_n, R_n);
    inv   reset_inv  (timer_rst_n, timer_rst_n_nand);

    timer timer_inst (
        .clk(clk),
        .R_n(timer_rst_n),
        .T_n(T_n)
    );

    fsm fsm_inst (
        .p(P),
        .rn(R_n),
        .h(H_clk),
        .tn(T_n),
        .clk(clk),
        .rst_n(rst_n)
    );
endmodule