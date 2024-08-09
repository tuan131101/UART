`timescale 1ns/1ps
module uart_rx_tb;
reg RX;
wire rd_done;
reg clk;
reg rst_n;
reg rd_en;
wire [7:0] data_out;
parameter SEQ = 100000000;
parameter BAUD_RATE = 9600;
localparam T_baud = SEQ / BAUD_RATE;
uart_rx dut(
.clk(clk),
.rd_en(rd_en),
.rst_n(rst_n),
.data_out(data_out),
.rd_done(rd_done),
.RX(RX)
);
 initial begin
        clk = 0;
        forever #0.5 clk = ~clk; // Tạo chu kỳ đồng hồ
    end
initial begin
        rst_n = 1;
        #1 rst_n = 0;
        #1 rst_n = 1;
    end
initial begin
        #2;
        repeat(5) begin
            RX = 0;
            rd_en = 1; // start_bit
            #T_baud
            repeat(8) begin
                RX = $random;
                #T_baud;    
            end
            RX = 1; // stop_bit
            #T_baud;
            

        end
    end

    
endmodule