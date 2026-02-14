//////////////////////////////////////////////////////////////////////////////////
// Pós Graduação em Microeletronica - Universidade Estadual do Maranhão (UEMA)
// Equipe A - IP Core Criptografia PRESENT-80
// 
// Descrição: 
//    Implementação do Gerador de Chaves (Key Schedule) para o PRESENT-80.
//    Responsável por gerar e atualizar o registrador de chave de 80 bits e
//    fornecer a subchave de 64 bits para cada uma das 31 rodadas.
//
//    Algoritmo de Atualização (Update Logic):
//    1. Rotação: Rotacionar o registrador 61 bits à esquerda.
//    2. S-Box:   Substituir os 4 bits mais significativos (S-Box).
//    3. XOR:     XOR dos bits [19:15] com o contador de rodada (round_counter).
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module key_schedule(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load_key,      // Carrega a chave inicial
    input  wire        update_key,    // Calcula a próxima chave
    input  wire [4:0]  round_counter, // Vem do Top Level (FSM)
    input  wire [79:0] key_input,     // Chave de entrada (80 bits)
    output wire [63:0] round_key      // Chave parcial para o Datapath
    );

    // Registrador de estado da chave
    reg [79:0] k_reg;

    // Fios intermediários para a lógica combinacional
    wire [79:0] rotated_key;
    wire [3:0]  sbox_in;
    wire [3:0]  sbox_out;
    wire [79:0] next_key;

    // 1. Saída da Chave da Rodada
    assign round_key = k_reg[79:16];


    // 2. Lógica de Rotação (Shift)
    assign rotated_key = {k_reg[18:0], k_reg[79:19]};

    // 3. Instanciação da S-Box (Reuso do módulo sbox.v)
    assign sbox_in = rotated_key[79:76];

	 
    // Conexão com o módulo sbox.v 
    sbox u_sbox (
        .in_nibble (sbox_in), 
        .out_nibble(sbox_out)
    );

	 
	 
    // 4. Montagem da Próxima Chave (Next State Logic)
    
    assign next_key[79:76] = sbox_out;                      // Bits da S-Box
    assign next_key[75:20] = rotated_key[75:20];            // Bits inalterados
    assign next_key[19:15] = rotated_key[19:15] ^ round_counter; // XOR com contador
    assign next_key[14:0]  = rotated_key[14:0];             // Bits inalterados

   
    // 5. Lógica Sequencial (Flip-Flops)
	 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            k_reg <= 80'b0;
        end else begin
            if (load_key) begin
                k_reg <= key_input;  // Carrega chave externa
            end else if (update_key) begin
                k_reg <= next_key;   // Atualiza para próxima rodada
            end
        end
    end


endmodule
