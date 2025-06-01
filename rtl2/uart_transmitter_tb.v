
module uart_transmitter_tb;
    reg clk = 0;
    reg rst;
    reg [7:0] data_in;
    reg data_valid;
    reg tx_ready;
    wire serial_out;
    wire fifo_full;
    wire tx_busy;
    
    uart_transmitter #(.BAUD_DIVISOR(5)) uut (
        .clk(clk), .rst(rst),
        .data_in(data_in), .data_valid(data_valid),
        .tx_ready(tx_ready), .serial_out(serial_out),
        .fifo_full(fifo_full), .tx_busy(tx_busy)
    );
    
    // Clock generation (50MHz = 20ns period)
    always #10 clk = ~clk;
    
    // VCD file dump
    initial begin
        $dumpfile("uart_transmitter.vcd");
        $dumpvars(0, uart_transmitter_tb);
        $dumpvars(1, uut.u_fsm);
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        data_in = 0;
        data_valid = 0;
        tx_ready = 1;
        
        // Reset sequence
        #20 rst = 0;
        #20;
        
        // Test 1: Write data to FIFO
        $display("Writing data 0x55 to FIFO");
        data_in = 8'h55;
        data_valid = 1;
        #20 data_valid = 0;
        
        // Verify state transitions and data capture
        @(posedge uut.u_fsm.state[0]); // WAIT_RDY state
        #1; // Small delta delay for signal update
        if (uut.u_fsm.data_reg !== 8'h55)
            $error("Data not captured! Got %h, expected 55", uut.u_fsm.data_reg);
        
        @(posedge uut.u_fsm.state[1]); // START state
        #1;
        if (serial_out !== 1'b0)
            $error("Start bit not low");
            
        // Verify data bits at baud ticks
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b1) $error("Bit0 should be 1");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b0) $error("Bit1 should be 0");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b1) $error("Bit2 should be 1");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b0) $error("Bit3 should be 0");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b1) $error("Bit4 should be 1");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b0) $error("Bit5 should be 0");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b1) $error("Bit6 should be 1");
        
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b0) $error("Bit7 should be 0");
        
        // Verify stop bit
        @(posedge uut.u_fsm.baud_tick);
        #1;
        if (serial_out !== 1'b1)
            $error("Stop bit not high");
            
        $display("All tests passed!");
        $finish;
    end
    
    // State monitor
    always @(posedge clk) begin
        $display("Time=%0t: state=%b tx_busy=%b serial_out=%b data_reg=%h baud_tick=%b", 
                $time, uut.u_fsm.state, tx_busy, serial_out, 
                uut.u_fsm.data_reg, uut.u_fsm.baud_tick);
    end
endmodule
