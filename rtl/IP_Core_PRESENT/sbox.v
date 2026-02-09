//////////////////////////////////////////////////////////////////////////////////
// Pós Graduação em Microeletronica - Universidade Estadual do Maranhão (UEMA)
// Equipe A - IP Core Criptografia PRESENT-80
// 
// Descrição: 
//    Implementação da S-Box de 4 bits do algoritmo PRESENT.
//    Tabela de substituição: 
//    x: 0 1 2 3 4 5 6 7 8 9 A B C D E F
//    S: C 5 6 B 9 0 A D 3 E F 8 4 7 1 2
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module sbox(
    input  wire [3:0] in_nibble,  // Entrada de 4 bits
    output reg  [3:0] out_nibble  // Saída de 4 bits substituída
    );

    // Lógica Combinacional (Look-Up Table)
    always @(*) begin
        case (in_nibble)
            4'h0: out_nibble = 4'hC;
            4'h1: out_nibble = 4'h5;
            4'h2: out_nibble = 4'h6;
            4'h3: out_nibble = 4'hB;
            4'h4: out_nibble = 4'h9;
            4'h5: out_nibble = 4'h0;
            4'h6: out_nibble = 4'hA;
            4'h7: out_nibble = 4'hD;
            4'h8: out_nibble = 4'h3;
            4'h9: out_nibble = 4'hE;
            4'hA: out_nibble = 4'hF;
            4'hB: out_nibble = 4'h8;
            4'hC: out_nibble = 4'h4;
            4'hD: out_nibble = 4'h7;
            4'hE: out_nibble = 4'h1;
            4'hF: out_nibble = 4'h2;
            default: out_nibble = 4'h0; // Boa prática para evitar latches indesejados
        endcase
    end

endmodule