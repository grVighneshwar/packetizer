module uart_transmitter #(
    parameter BAUD_DIVISOR = 5  // 5 cycles/bit for simulation
)(
    input clk,
    input rst,
    input [7:0] data_in,
    input data_valid,
    input tx_ready,
    output serial_out,
    output fifo_full,
    output tx_busy
);

    wire fifo_empty;
    wire [7:0] fifo_data;
    wire rd_en;

    fifo u_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(data_valid),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(fifo_data),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    packetizer_fsm #(BAUD_DIVISOR) u_fsm (
        .clk(clk),
        .rst(rst),
        .fifo_empty(fifo_empty),
        .tx_ready(tx_ready),
        .fifo_data(fifo_data),
        .serial_out(serial_out),
        .tx_busy(tx_busy),
        .rd_en(rd_en)
    );

endmodule
