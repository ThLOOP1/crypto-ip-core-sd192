/*
 * TEA (Tiny Encryption Algorithm) - Módulo Top-Level
 * Integra criptografia e descriptografia com seleção por modo
 * 
 * mode = 0: Criptografia
 * mode = 1: Descriptografia
 */

module tea_top (
    input wire clk,              // Clock
    input wire rst,              // Reset assíncrono
    input wire start,            // Inicia operação
    input wire mode,             // 0 = encrypt, 1 = decrypt
    input wire [31:0] v0_in,     // Entrada v[0]
    input wire [31:0] v1_in,     // Entrada v[1]
    input wire [31:0] k0,        // Chave k[0]
    input wire [31:0] k1,        // Chave k[1]
    input wire [31:0] k2,        // Chave k[2]
    input wire [31:0] k3,        // Chave k[3]
    output wire [31:0] v0_out,   // Saída v[0]
    output wire [31:0] v1_out,   // Saída v[1]
    output wire done             // Sinal de conclusão
);

    // Sinais do módulo de criptografia
    wire [31:0] enc_v0_out, enc_v1_out;
    wire enc_done;
    
    // Sinais do módulo de descriptografia
    wire [31:0] dec_v0_out, dec_v1_out;
    wire dec_done;
    
    // Sinais de controle
    wire start_encrypt, start_decrypt;
    
    // Seleciona qual módulo ativar baseado no modo
    assign start_encrypt = start & ~mode;
    assign start_decrypt = start & mode;
    
    // Multiplexação das saídas baseada no modo
    assign v0_out = mode ? dec_v0_out : enc_v0_out;
    assign v1_out = mode ? dec_v1_out : enc_v1_out;
    assign done = mode ? dec_done : enc_done;
    
    // Instanciação do módulo de criptografia
    tea_encrypt encrypt_inst (
        .clk(clk),
        .rst(rst),
        .start(start_encrypt),
        .v0_in(v0_in),
        .v1_in(v1_in),
        .k0(k0),
        .k1(k1),
        .k2(k2),
        .k3(k3),
        .v0_out(enc_v0_out),
        .v1_out(enc_v1_out),
        .done(enc_done)
    );
    
    // Instanciação do módulo de descriptografia
    tea_decrypt decrypt_inst (
        .clk(clk),
        .rst(rst),
        .start(start_decrypt),
        .v0_in(v0_in),
        .v1_in(v1_in),
        .k0(k0),
        .k1(k1),
        .k2(k2),
        .k3(k3),
        .v0_out(dec_v0_out),
        .v1_out(dec_v1_out),
        .done(dec_done)
    );

endmodule