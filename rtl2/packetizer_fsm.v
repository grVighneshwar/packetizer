module packetizer_fsm #(
    parameter BAUD_DIVISOR = 5
)(
    input clk,
    input rst,
    input fifo_empty,
    input tx_ready,
    input [7:0] fifo_data,
    output reg serial_out,
    output reg tx_busy,
    output reg rd_en
);

    // FSM states
    localparam IDLE     = 3'b000;
    localparam WAIT_RDY = 3'b001;
    localparam START    = 3'b010;
    localparam DATA     = 3'b011;
    localparam STOP     = 3'b100;
    
    reg [2:0] state = IDLE;
    reg [15:0] baud_counter = 0;
    reg [3:0] bit_counter = 0;
    reg [7:0] data_reg = 0;
    reg baud_tick;

    // Baud rate generator - FIXED TIMING
    always @(posedge clk) begin
        if (rst) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            baud_tick <= 0;  // Default
            if (state != IDLE) begin
                if (baud_counter == BAUD_DIVISOR - 1) begin
                    baud_counter <= 0;
                    baud_tick <= 1;
                end else begin
                    baud_counter <= baud_counter + 1;
                end
            end else begin
                baud_counter <= 0;
            end
        end
    end

    // FSM logic - COMPLETELY REVISED
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            serial_out <= 1'b1;
            tx_busy <= 1'b0;
            rd_en <= 1'b0;
            bit_counter <= 0;
            data_reg <= 0;
        end else begin
            rd_en <= 1'b0;  // Default
            
            case (state)
                IDLE: begin
                    serial_out <= 1'b1;
                    tx_busy <= 1'b0;
                    bit_counter <= 0;
                    
                    if (!fifo_empty && tx_ready) begin
                        state <= WAIT_RDY;
                        tx_busy <= 1'b1;
                    end
                end
                
                WAIT_RDY: begin
                    // Immediately capture data when tx_ready is detected
                    data_reg <= fifo_data;
                    if (tx_ready) begin
                        rd_en <= 1'b1;  // Assert read enable
                        state <= START;
                    end
                end
                
                START: begin
                    serial_out <= 1'b0;  // Start bit
                    if (baud_tick) begin
                        state <= DATA;
                        bit_counter <= 0;
                    end
                end
                
                DATA: begin
                    // Output current bit
                    serial_out <= data_reg[bit_counter];
                    
                    if (baud_tick) begin
                        if (bit_counter == 7) begin
                            state <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                STOP: begin
                    serial_out <= 1'b1;  // Stop bit
                    if (baud_tick) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

