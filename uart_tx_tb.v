`timescale 1ns/1ps
module uart_tx_tb;
wire TX;
wire wr_done;
reg clk;
reg rst_n;
reg wr_en;
reg [7:0] data_in;
wire [7:0] count;
uart_tx dut(
.clk(clk),
.wr_en(wr_en),
.rst_n(rst_n),
.data_in(data_in),
.wr_done(wr_done),
.TX(TX),
.count(count)
);
 initial begin
        clk = 0;
        forever #1 clk = ~clk; // Tạo chu kỳ đồng hồ
    end
initial begin
        rst_n = 1;
        #1 rst_n = 0;
        #1 rst_n = 1;
    end
initial begin
		clk=0;
		wr_en = 1'b0;
		#20;
			data_in = 8'b01101001;
			wr_en = 1'b1;
			#1000;
			wait(wr_done);
		end
    
endmodule