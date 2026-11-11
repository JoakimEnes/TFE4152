`timescale 1ns/1ps

//Project: Pacemaker for TFE4152 by Joakim Enes and Martin

module timer (
    input wire clk,
    input wire R_n,
    output wire T_n
);			  
    wire [9:0] q;
    wire [9:0] qn;
    wire [9:0] stage_clk;

    nand2 t_nand (T_n, q[8], q[9]);
    assign stage_clk[0] = clk;
    assign stage_clk[9:1] = qn[8:0];

    genvar i;
    generate
        for (i=0; i<10; i=i+1) begin : bits

        dff_r bit_ff (
            .q (q[i]),
            .qn (qn[i]),
            .d (qn[i]),
            .clk (stage_clk[i]),
            .clrn (R_n)
        );
        end
    endgenerate
endmodule