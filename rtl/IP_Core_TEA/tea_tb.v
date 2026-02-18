/*
 * Testbench para TEA (Tiny Encryption Algorithm)
 * Testa criptografia e descriptografia com vetores de teste
 */

`timescale 1ns/1ps

module tea_tb;

    // Sinais do DUT (Device Under Test)
    reg clk;
    reg rst;
    reg start;
    reg mode;
    reg [31:0] v0_in, v1_in;
    reg [31:0] k0, k1, k2, k3;
    wire [31:0] v0_out, v1_out;
    wire done;
    
    // Variáveis para teste
    reg [31:0] encrypted_v0, encrypted_v1;
    reg [31:0] cipher1_v0, cipher1_v1;
    integer test_number;
    
    // Instanciação do módulo top-level
    tea_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .v0_in(v0_in),
        .v1_in(v1_in),
        .k0(k0),
        .k1(k1),
        .k2(k2),
        .k3(k3),
        .v0_out(v0_out),
        .v1_out(v1_out),
        .done(done)
    );
    
    // Geração do clock (100 MHz -> 10ns período)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Tarefa para reset
    task apply_reset;
        begin
            rst = 1;
            start = 0;
            #20;
            rst = 0;
            #10;
        end
    endtask
    
    // Tarefa para criptografar
    task encrypt;
        input [31:0] v0, v1;
        input [31:0] key0, key1, key2, key3;
        begin
            @(posedge clk);
            mode = 0;  // Modo encrypt
            v0_in = v0;
            v1_in = v1;
            k0 = key0;
            k1 = key1;
            k2 = key2;
            k3 = key3;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Aguarda conclusão
            wait(done);
            encrypted_v0 = v0_out;
            encrypted_v1 = v1_out;
            @(posedge clk);
        end
    endtask
    
    // Tarefa para descriptografar
    task decrypt;
        input [31:0] v0, v1;
        input [31:0] key0, key1, key2, key3;
        begin
            @(posedge clk);
            mode = 1;  // Modo decrypt
            v0_in = v0;
            v1_in = v1;
            k0 = key0;
            k1 = key1;
            k2 = key2;
            k3 = key3;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Aguarda conclusão
            wait(done);
            @(posedge clk);
        end
    endtask
    
    // Processo de teste
    initial begin
        $display("==============================================");
        $display("  TEA (Tiny Encryption Algorithm) Testbench");
        $display("  Baseado em Wheeler & Needham (1994)");
        $display("==============================================\n");
        
        // Inicialização
        test_number = 0;
        
        // Reset inicial
        apply_reset();
        
        // ==========================================
        // TESTE 1: Vetor de teste básico
        // ==========================================
        test_number = 1;
        $display("Teste %0d: Vetor básico", test_number);
        $display("------------------------------------------");
        $display("Plaintext:  v0=0x00000000, v1=0x00000000");
        $display("Key:        k0=0x00000000, k1=0x00000000, k2=0x00000000, k3=0x00000000");
        
        encrypt(32'h00000000, 32'h00000000, 
                32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000);
        
        $display("Ciphertext: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        // Descriptografa
        decrypt(encrypted_v0, encrypted_v1,
                32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000);
        
        $display("Decrypted:  v0=0x%h, v1=0x%h", v0_out, v1_out);
        
        if (v0_out == 32'h00000000 && v1_out == 32'h00000000) begin
            $display("✓ TESTE 1 PASSOU\n");
        end else begin
            $display("✗ TESTE 1 FALHOU\n");
        end
        
        // ==========================================
        // TESTE 2: Vetor de teste com dados não-zero
        // ==========================================
        test_number = 2;
        $display("Teste %0d: Dados não-zero", test_number);
        $display("------------------------------------------");
        $display("Plaintext:  v0=0x12345678, v1=0x9ABCDEF0");
        $display("Key:        k0=0x0A0B0C0D, k1=0x0E0F1011, k2=0x12131415, k3=0x16171819");
        
        encrypt(32'h12345678, 32'h9ABCDEF0,
                32'h0A0B0C0D, 32'h0E0F1011, 32'h12131415, 32'h16171819);
        
        $display("Ciphertext: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        // Descriptografa
        decrypt(encrypted_v0, encrypted_v1,
                32'h0A0B0C0D, 32'h0E0F1011, 32'h12131415, 32'h16171819);
        
        $display("Decrypted:  v0=0x%h, v1=0x%h", v0_out, v1_out);
        
        if (v0_out == 32'h12345678 && v1_out == 32'h9ABCDEF0) begin
            $display("✓ TESTE 2 PASSOU\n");
        end else begin
            $display("✗ TESTE 2 FALHOU\n");
        end
        
        // ==========================================
        // TESTE 3: Vetor de teste com todos bits 1
        // ==========================================
        test_number = 3;
        $display("Teste %0d: Todos bits 1", test_number);
        $display("------------------------------------------");
        $display("Plaintext:  v0=0xFFFFFFFF, v1=0xFFFFFFFF");
        $display("Key:        k0=0xFFFFFFFF, k1=0xFFFFFFFF, k2=0xFFFFFFFF, k3=0xFFFFFFFF");
        
        encrypt(32'hFFFFFFFF, 32'hFFFFFFFF,
                32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF);
        
        $display("Ciphertext: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        // Descriptografa
        decrypt(encrypted_v0, encrypted_v1,
                32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF);
        
        $display("Decrypted:  v0=0x%h, v1=0x%h", v0_out, v1_out);
        
        if (v0_out == 32'hFFFFFFFF && v1_out == 32'hFFFFFFFF) begin
            $display("✓ TESTE 3 PASSOU\n");
        end else begin
            $display("✗ TESTE 3 FALHOU\n");
        end
        
        // ==========================================
        // TESTE 4: Teste padrão ASCII "HELLO!!!"
        // ==========================================
        test_number = 4;
        $display("Teste %0d: String ASCII 'HELLO!!!' (HELL = v0, O!!! = v1)", test_number);
        $display("------------------------------------------");
        // 'HELL' = 0x48454C4C, 'O!!!' = 0x4F212121 (big-endian)
        $display("Plaintext:  v0=0x48454C4C, v1=0x4F212121");
        $display("Key:        k0=0xA56BABCD, k1=0xEF012345, k2=0x6789ABCD, k3=0xEF012345");
        
        encrypt(32'h48454C4C, 32'h4F212121,
                32'hA56BABCD, 32'hEF012345, 32'h6789ABCD, 32'hEF012345);
        
        $display("Ciphertext: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        // Descriptografa
        decrypt(encrypted_v0, encrypted_v1,
                32'hA56BABCD, 32'hEF012345, 32'h6789ABCD, 32'hEF012345);
        
        $display("Decrypted:  v0=0x%h, v1=0x%h", v0_out, v1_out);
        
        if (v0_out == 32'h48454C4C && v1_out == 32'h4F212121) begin
            $display("✓ TESTE 4 PASSOU\n");
        end else begin
            $display("✗ TESTE 4 FALHOU\n");
        end
        
        // ==========================================
        // TESTE 5: Chave diferente deve gerar cifra diferente
        // ==========================================
        test_number = 5;
        $display("Teste %0d: Diferenciação de chaves", test_number);
        $display("------------------------------------------");
        
        // Criptografa com chave 1
        encrypt(32'h12345678, 32'h9ABCDEF0,
                32'h00000001, 32'h00000002, 32'h00000003, 32'h00000004);
        
        $display("Com chave 1: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        cipher1_v0 = encrypted_v0;
        cipher1_v1 = encrypted_v1;
        
        // Criptografa com chave 2
        encrypt(32'h12345678, 32'h9ABCDEF0,
                32'h00000005, 32'h00000006, 32'h00000007, 32'h00000008);
        
        $display("Com chave 2: v0=0x%h, v1=0x%h", encrypted_v0, encrypted_v1);
        
        if (cipher1_v0 != encrypted_v0 || cipher1_v1 != encrypted_v1) begin
            $display("✓ TESTE 5 PASSOU - Chaves diferentes geraram cifras diferentes\n");
        end else begin
            $display("✗ TESTE 5 FALHOU - Chaves diferentes geraram cifras iguais\n");
        end
        
        // ==========================================
        // Resumo
        // ==========================================
        $display("\n==============================================");
        $display("  Testes concluídos!");
        $display("==============================================\n");
        
        #100;
        $finish;
    end
    
    // Monitor para depuração
    // initial begin
    //     $monitor("Time=%0t | mode=%b | start=%b | done=%b | v0_in=0x%h | v1_in=0x%h | v0_out=0x%h | v1_out=0x%h",
    //              $time, mode, start, done, v0_in, v1_in, v0_out, v1_out);
    // end
    
    // Dump de forma de onda para análise
    initial begin
        $dumpfile("tea_tb.vcd");
        $dumpvars(0, tea_tb);
    end

endmodule