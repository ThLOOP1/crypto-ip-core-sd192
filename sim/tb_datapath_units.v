//////////////////////////////////////////////////////////////////////////////////
// Pós Graduação em Microeletronica - Universidade Estadual do Maranhão (UEMA)
// Equipe A - IP Core Criptografia PRESENT-80
// 
// Descrição: 
//    Testbench para validar isoladamente os módulos combinacionais:
//    1. S-Box (Substituição)
//    2. P-Layer (Permutação)
// 
//    Se aparecer "PASS" no console, os módulos estão prontos para integração.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module tb_datapath_units;

    // ==========================================
    // Sinais para Teste da S-Box
    // ==========================================
    reg  [3:0] sb_in;
    wire [3:0] sb_out;
    integer erros_sbox = 0;

    // Instância da S-Box (Unit Under Test)
    sbox uut_sbox (
        .in_nibble(sb_in), 
        .out_nibble(sb_out)
    );

    // ==========================================
    // Sinais para Teste da P-Layer
    // ==========================================
    reg  [63:0] pl_in;
    wire [63:0] pl_out;
    integer erros_player = 0;

    // Instância da P-Layer (Unit Under Test)
    player uut_player (
        .in_block(pl_in), 
        .out_block(pl_out)
    );

    // ==========================================
    // Início dos Testes
    // ==========================================
    initial begin
        // --- LINHAS PARA O EDA PLAYGROUND ---
        // $dumpfile("dump.vcd");       // Cria o arquivo de ondas
        // $dumpvars(0, tb_datapath_units); // Grava todos os sinais deste módulo

        $display("------------------------------------------------");
        $display("INICIANDO TESTE UNITARIO: S-BOX e P-LAYER");
        $display("------------------------------------------------");

        // -------------------------------------------------------------
        // --- TESTE 1: Validando a S-Box ---
        // -------------------------------------------------------------
        $display("\n[TESTE 1] Verificando S-Box...");
        
        // Caso 1: Entrada 0 -> Esperado C
        sb_in = 4'h0; #10;
        if (sb_out !== 4'hC) begin
            $display("ERRO S-Box [0]: Esperado C, Recebido %h", sb_out);
            erros_sbox = erros_sbox + 1;
        end else $display("S-Box [0] -> C: OK");

        // Caso 2: Entrada F -> Esperado 2
        sb_in = 4'hF; #10;
        if (sb_out !== 4'h2) begin
            $display("ERRO S-Box [F]: Esperado 2, Recebido %h", sb_out);
            erros_sbox = erros_sbox + 1;
        end else $display("S-Box [F] -> 2: OK");

        // Caso 3: Entrada 5 -> Esperado 0
        sb_in = 4'h5; #10;
        if (sb_out !== 4'h0) begin
            $display("ERRO S-Box [5]: Esperado 0, Recebido %h", sb_out);
            erros_sbox = erros_sbox + 1;
        end else $display("S-Box [5] -> 0: OK");

        // -------------------------------------------------------------
        // --- TESTE 2: Validando a P-Layer ---
        // -------------------------------------------------------------
        $display("\n[TESTE 2] Verificando P-Layer...");

        // CASO 1: Teste do Bit 0 (Simples)
        // Matemática: 0 * 16 = 0. 0 mod 63 = 0
        pl_in = 64'h0;
        pl_in[0] = 1'b1; // Liga apenas o bit de índice 0 (Valor 1)
        #10;
        
        if (pl_out[0] === 1'b1) 
            $display("[SUCESSO] Bit 0 -> Bit 0 mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 0. Esperado: Bit 0 ligado.");
            erros_player = erros_player + 1;
        end

        // Caso 2: Teste do Bit 1 (Simples)
        // Matemática: 1 * 16 = 16. 16 mod 63 = 16
        pl_in = 64'h0;
        pl_in[1] = 1'b1; // Liga apenas o bit de índice 1 (Valor 2)
        #10;
        
        if (pl_out[16] === 1'b1) 
            $display("[SUCESSO] Bit 1 -> Bit 16 mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 1. Esperado: Bit 16 ligado.");
            erros_player = erros_player + 1;
        end

        // CASO 3: Teste do Bit 2 (Simples)
        // Matemática: 2 * 16 = 32. 32 mod 63 = 32
        pl_in = 64'h0;
        pl_in[2] = 1'b1; // Liga apenas o bit de índice 2 (Valor 4)
        #10;
        
        if (pl_out[32] === 1'b1) 
            $display("[SUCESSO] Bit 2 -> Bit 32 mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 2. Esperado: Bit 32 ligado.");
            erros_player = erros_player + 1;
        end

        // CASO 4: Teste do Bit 3 (Simples)
        // Matemática: 3 * 16 = 48
        pl_in = 64'h0;
        pl_in[3] = 1'b1;
        #10;
        
        if (pl_out[48] === 1'b1) 
            $display("[SUCESSO] Bit 3 -> Bit 48 mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 3. Esperado: Bit 48 ligado.");
            erros_player = erros_player + 1;
        end

        // CASO 5: Teste do Bit 4 (Wrap Around - A volta)
        // Matemática: 4 * 16 = 64. 
        // Como 64 > 63, fazemos 64 mod 63 = RESTO 1.
        // Destino deve ser o Bit 1.
        pl_in = 64'h0;
        pl_in[4] = 1'b1; // Liga bit 4 (Valor 16 ou 'h10)
        #10;
        
        if (pl_out[1] === 1'b1) 
            $display("[SUCESSO] Bit 4 -> Bit 1 (Wrap Around) mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 4. Esperado: Bit 1 ligado.");
            erros_player = erros_player + 1;
        end

        // CASO 6: Teste do Bit 15 (Fim do primeiro grupo)
        // Matemática: 15 * 16 = 240.
        // 240 / 63 = 3 com resto 51. (3 * 63 = 189. 240 - 189 = 51)
        // Destino deve ser o Bit 51
        pl_in = 64'h0;
        pl_in[15] = 1'b1;
        #10;
        
        if (pl_out[51] === 1'b1) 
            $display("[SUCESSO] Bit 15 -> Bit 51 mapeado corretamente.");
        else begin
            $display("[ERRO] Falha no Bit 15. Esperado: Bit 51 ligado.");
            erros_player = erros_player + 1;
        end

        // CASO 7: Teste de Padrão (Vários bits juntos)
        // Entrada: FFFFFFFFFFFFFFFF (Todos ligados)
        // Saída:   FFFFFFFFFFFFFFFF (Todos devem continuar ligados)
        // Se algum fio estiver desconectado (Z), isso vai falhar
        pl_in = 64'hFFFFFFFFFFFFFFFF;
        #10;
        
        if (pl_out === 64'hFFFFFFFFFFFFFFFF) 
            $display("[SUCESSO] Teste de Carga Total (All Ones) mapeado corretamente.");
        else begin
            $display("[ERRO] Teste de Carga Total falhou. Saída: %h", pl_out);
            erros_player = erros_player + 1;
        end
        
        // -------------------------------------------------------------
        // --- RESULTADO FINAL ---
        // -------------------------------------------------------------
        $display("------------------------------------------------");
        if (erros_sbox == 0 && erros_player == 0) begin
            $display("RESULTADO: SUCESSO TOTAL! Modulos prontos.");
        end else begin
            $display("RESULTADO: FALHA. Verifique erros acima.");
        end
        $display("------------------------------------------------");
        $finish;
    end

endmodule