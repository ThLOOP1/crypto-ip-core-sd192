//////////////////////////////////////////////////////////////////////////////////
// Pós Graduação em Microeletronica - Universidade Estadual do Maranhão (UEMA)
// Equipe A - Testbench de Sistema Completo
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_top_module();

    // Sinais de estímulo
    reg        clk;
    reg        rst_n;
    reg        start;
    reg [63:0] plaintext;
    reg [79:0] key_input;

    // Sinais de observação
    wire [63:0] ciphertext;
    wire        ready;

    // Vetor de teste oficial
    localparam [63:0] EXPECTED = 64'h3333DCD3213210D2;

    // Instanciação do Módulo Principal
    top_module dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .key_input  (key_input),
        .ciphertext (ciphertext),
        .ready      (ready)
    );

    // Geração do Clock
    always #5 clk = ~clk;

    // Bloco de Monitorização para GTKWave
    initial begin
        $dumpfile("simulacao.vcd");
        $dumpvars(0, tb_top_module);
    end

    // Procedimento de Teste
    initial begin
        // Reset inicial
        clk = 0;
        rst_n = 0;
        start = 0;
        plaintext = 64'h0;
        key_input = 80'h0;

        #20 rst_n = 1;
        #10;

        // Aplicação do Vetor de Teste Oficial
        plaintext = 64'hFFFF_FFFF_FFFF_FFFF;
        key_input = 80'hFFFF_FFFF_FFFF_FFFF_FFFF;
        
        $display("==================================================");
        $display("INICIANDO TESTE PRESENT-80");
        $display("Plaintext: %h", plaintext);
        $display("Chave: %h", key_input);
        $display("Esperado: %h", EXPECTED);
        $display("==================================================");
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Aguarda sinal de conclusão
        wait(ready);
        
        #20;
        $display("--------------------------------------------------");
        $display("Resultado Obtido: %h", ciphertext);
        $display("Resultado Esperado: %h", EXPECTED);

        if (ciphertext === EXPECTED)
            $display(">>> TESTE COM SUCESSO! <<<");
        else
            $display(">>> ERRO NO RESULTADO! <<<");
        $display("--------------------------------------------------");

        #100;
        $finish;
    end

    // Monitoramento detalhado
    always @(posedge clk) begin
        case (dut.current_state)
            dut.ST_INIT: begin
                $display("INIT: Carregando plaintext = %h", dut.plaintext);
            end
            dut.ST_ADD_KEY: begin
                $display("Rodada %0d: XOR com chave %h = %h", 
                         dut.round_counter, 
                         dut.round_key_wire,
                         dut.state ^ dut.round_key_wire);
            end
            dut.ST_SBOX_PLAYER: begin
                $display("Rodada %0d: Após S-Box/Player = %h", 
                         dut.round_counter, 
                         dut.data_after_player);
            end
            dut.ST_FINAL_XOR: begin
                $display("FINAL: XOR com K32 = %h, Resultado = %h", 
                         dut.round_key_wire,
                         dut.state ^ dut.round_key_wire);
            end
        endcase
    end

endmodule