/*
 * TEA (Tiny Encryption Algorithm) - Módulo de Criptografia
 * Baseado na especificação de Wheeler & Needham (1994)
 * 
 * Parâmetros:
 * - Bloco de dados: 64 bits (2 x 32 bits)
 * - Chave: 128 bits (4 x 32 bits)
 * - Rodadas: 32 ciclos
 */

module tea_encrypt (
    input wire clk,              // Clock
    input wire rst,              // Reset assíncrono
    input wire start,            // Inicia criptografia
    input wire [31:0] v0_in,     // Entrada v[0]
    input wire [31:0] v1_in,     // Entrada v[1]
    input wire [31:0] k0,        // Chave k[0]
    input wire [31:0] k1,        // Chave k[1]
    input wire [31:0] k2,        // Chave k[2]
    input wire [31:0] k3,        // Chave k[3]
    output reg [31:0] v0_out,    // Saída v[0] criptografado
    output reg [31:0] v1_out,    // Saída v[1] criptografado
    output reg done              // Sinal de conclusão
);

    // Constante delta (derivada da razão áurea)
    localparam [31:0] DELTA = 32'h9E3779B9;
    
    // Número de rodadas
    localparam NUM_ROUNDS = 32;
    
    // Registradores internos
    reg [31:0] v0, v1;
    reg [31:0] sum;
    reg [5:0] round_counter;  // 6 bits para contar até 32
    
    // Registradores temporários para nova iteração
    reg [31:0] v0_next, v1_next;
    reg [31:0] sum_next;
    
    // Estados da máquina de estados
    localparam IDLE = 2'b00;
    localparam PROCESS = 2'b01;
    localparam DONE = 2'b10;
    
    reg [1:0] state;
    
    // Máquina de estados
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            v0 <= 32'h0;
            v1 <= 32'h0;
            sum <= 32'h0;
            round_counter <= 6'h0;
            v0_out <= 32'h0;
            v1_out <= 32'h0;
            done <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // Inicialização
                        v0 <= v0_in;
                        v1 <= v1_in;
                        sum <= 32'h0;
                        round_counter <= 6'h0;
                        state <= PROCESS;
                    end
                end
                
                PROCESS: begin
                    if (round_counter < NUM_ROUNDS) begin
                        // Calcula sum para esta rodada
                        sum_next = sum + DELTA;
                        
                        // Calcula v0_next: v0 += ((v1<<4) + k0) ^ (v1 + sum_next) ^ ((v1>>5) + k1)
                        v0_next = v0 + (((v1 << 4) + k0) ^ (v1 + sum_next) ^ ((v1 >> 5) + k1));
                        
                        // Calcula v1_next: v1 += ((v0_next<<4) + k2) ^ (v0_next + sum_next) ^ ((v0_next>>5) + k3)
                        // Deve ser utilizado v0_next (valor ATUALIZADO de v0)
                        v1_next = v1 + (((v0_next << 4) + k2) ^ (v0_next + sum_next) ^ ((v0_next >> 5) + k3));
                        
                        // Atualiza registradores
                        sum <= sum_next;
                        v0 <= v0_next;
                        v1 <= v1_next;
                        
                        round_counter <= round_counter + 1;
                    end
                    else begin
                        // Processo completo
                        v0_out <= v0;
                        v1_out <= v1;
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1'b1;
                    if (!start) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule