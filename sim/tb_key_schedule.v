`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Testbench para o Key Schedule do PRESENT-80
// Objetivo: Validar a geração de subchaves e a integração com a S-Box
////////////////////////////////////////////////////////////////////////////////

module tb_key_schedule;

    // 1. Declaração de Sinais (Inputs como reg, Outputs como wire)
    reg clk;
    reg rst_n;
    reg load_key;
    reg update_key;
    reg [4:0] round_counter;
    reg [79:0] key_input;

    wire [63:0] round_key;

    // 2. Instanciação do Módulo Principal (DUT - Device Under Test)
    key_schedule uut (
        .clk(clk),
        .rst_n(rst_n),
        .load_key(load_key),
        .update_key(update_key),
        .round_counter(round_counter),
        .key_input(key_input),
        .round_key(round_key)
    );

    // 3. Geração de Clock (100 MHz -> Período de 10ns)
    always #5 clk = ~clk;

    // 4. Procedimento de Teste
    initial begin
        // --- Inicialização ---
        $display("=== INICIO DA SIMULACAO KEY SCHEDULE ===");
        clk = 0;
        rst_n = 0;          // Reset ativo
        load_key = 0;
        update_key = 0;
        round_counter = 0;
        key_input = 0;

        // Solta o Reset após 20ns
        #20 rst_n = 1; 

        // -----------------------------------------------------------------
        // CASO DE TESTE 1: Chave de Teste Padrão (Tudo Zero)
        // -----------------------------------------------------------------
        $display("\n[TESTE 1] Carregando chave 0x00...00");
        
        // Configura a entrada
        key_input = 80'h00000000000000000000; 
        
        // Pulso de carga (sincronizado com clock)
        @(posedge clk);
        load_key = 1;
        @(posedge clk); 
        load_key = 0; // Desliga o load

        $display("Chave Inicial (Round 1): %h (Esperado: 0000000000000000)", round_key);

        // --- Simulando a FSM pedindo novas chaves ---
        
        // Rodada 1 -> Para gerar chave da Rodada 2
        @(posedge clk);
        round_counter = 1; // FSM diz: "Estamos indo para round 2"
        update_key = 1;    // FSM diz: "Calcule a próxima"
        
        @(posedge clk);
        update_key = 0;    // FSM desliga o update
        #1; // Pequeno delay para leitura
        $display("Chave Round 2: %h (S-Box e Rotacao aplicadas)", round_key);

        // Rodada 2 -> Para gerar chave da Rodada 3
        @(posedge clk);
        round_counter = 2; 
        update_key = 1;
        
        @(posedge clk);
        update_key = 0;
        #1;
        $display("Chave Round 3: %h", round_key);

        // -----------------------------------------------------------------
        // CASO DE TESTE 2: Chave Tudo '1' (FFFF...)
        // Verifica se a S-Box está substituindo corretamente F -> 2
        // -----------------------------------------------------------------
        $display("\n[TESTE 2] Carregando chave 0xFF...FF");
        key_input = 80'hFFFFFFFFFFFFFFFFFFFF;
        
        @(posedge clk);
        load_key = 1;
        @(posedge clk);
        load_key = 0;

        $display("Chave Inicial (Round 1): %h (Esperado: FFFFFFFFFFFFFFFF)", round_key);

        // Avança uma rodada
        @(posedge clk);
        round_counter = 1;
        update_key = 1;
        
        @(posedge clk);
        update_key = 0;
        #1;
        
        // Análise rápida:
        // Entrada era F...F. Rotação mantém F...F.
        // S-Box(F) deve gerar 2 (conforme sbox.v: 4'hF -> 4'h2) 
        // Então os 4 bits superiores da próxima chave devem ser 2.
        $display("Chave Round 2: %h (Verifique se comeca com '2' ou proximo)", round_key);

        // Fim da simulação
        #50;
        $display("\n=== FIM DA SIMULACAO ===");
        $stop;
    end

endmodule