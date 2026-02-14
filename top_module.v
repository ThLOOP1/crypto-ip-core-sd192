`timescale 1ns / 1ps

module top_module (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [63:0] plaintext,
    input  wire [79:0] key_input,
    output reg  [63:0] ciphertext,
    output reg         ready
);

    reg  [63:0] state;
    reg  [4:0]  round_counter;
    reg  [2:0]  current_state;

    reg load_key;
    reg update_key;

    localparam ST_IDLE        = 3'd0;
    localparam ST_INIT        = 3'd1;
    localparam ST_ADD_KEY     = 3'd2;
    localparam ST_SBOX_PLAYER = 3'd3;
    localparam ST_KEYUPDATE   = 3'd4;
    localparam ST_FINAL_XOR   = 3'd5;

    wire [63:0] round_key_wire;
    wire [63:0] data_after_xor;
    wire [63:0] data_after_sbox;
    wire [63:0] data_after_player;

    // =============================
    // KEY SCHEDULE
    // =============================
    key_schedule u_key_sched (
        .clk           (clk),
        .rst_n         (rst_n),
        .load_key      (load_key),
        .update_key    (update_key),
        .round_counter (round_counter),
        .key_input     (key_input),
        .round_key     (round_key_wire)
    );

    // =============================
    // ADD ROUND KEY (COMBINACIONAL)
    // =============================
    assign data_after_xor = state ^ round_key_wire;

    // =============================
    // S-BOX LAYER (16 S-Boxes)
    // =============================
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sbox_layer
            sbox u_sbox (
                .in_nibble (data_after_xor[4*i+3 : 4*i]),
                .out_nibble(data_after_sbox[4*i+3 : 4*i])
            );
        end
    endgenerate

    // =============================
    // PERMUTATION LAYER
    // =============================
    player u_player (
        .in_block  (data_after_sbox),
        .out_block (data_after_player)
    );

    // =============================
    // FSM - CORRIGIDA (PIPELINE)
    // update_key é ativado no estado ST_SBOX_PLAYER,
    // para que o key schedule o veja no próximo ciclo.
    // =============================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= ST_IDLE;
            state         <= 64'b0;
            round_counter <= 5'd0;
            ready         <= 1'b0;
            load_key      <= 1'b0;
            update_key    <= 1'b0;
            ciphertext    <= 64'b0;
        end
        else begin
            case (current_state)

                // -------------------------
                ST_IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        round_counter <= 5'd1;        // K1
                        current_state <= ST_INIT;
                    end
                end

                // -------------------------
                ST_INIT: begin
                    state    <= plaintext;
                    load_key <= 1'b1;                // Carrega K1 (próximo ciclo)
                    current_state <= ST_ADD_KEY;
                end

                // -------------------------
                ST_ADD_KEY: begin
                    load_key   <= 1'b0;              // Desativa load_key
                    current_state <= ST_SBOX_PLAYER;
                end

                // -------------------------
                ST_SBOX_PLAYER: begin
                    state <= data_after_player;      // S-Box + Player
                    
                    // Gera a próxima chave (K_{round_counter+1})
                    if (round_counter <= 5'd31) begin
                        update_key <= 1'b1;          // Ativa update_key para o próximo ciclo
                    end
                    
                    current_state <= ST_KEYUPDATE;
                end

                // -------------------------
                ST_KEYUPDATE: begin
                    update_key <= 1'b0;              // Desativa update_key
                    
                    if (round_counter == 5'd31) begin
                        // Última rodada: K32 já foi gerado no ciclo anterior
                        current_state <= ST_FINAL_XOR;
                    end
                    else begin
                        // Próxima rodada
                        round_counter <= round_counter + 5'd1;
                        current_state <= ST_ADD_KEY;
                    end
                end

                // -------------------------
                ST_FINAL_XOR: begin
                    // K32 está pronto em round_key_wire
                    ciphertext <= state ^ round_key_wire;
                    ready      <= 1'b1;
                    current_state <= ST_IDLE;
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

endmodule