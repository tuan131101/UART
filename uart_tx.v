module uart_tx #(
parameter SEQ = 100000000,
parameter BAUD_RATE = 9600,
parameter n = 8
)(
    input wire clk,rst_n,wr_en,
    input wire [7:0] data_in,
    output wire [$clog2(t_baud) - 1:0] count,
    output reg wr_done,TX
 );
localparam t_baud = SEQ/BAUD_RATE;
reg [$clog2(t_baud) - 1:0] count_t;
reg [$clog2(n) - 1:0] index;
reg [n-1:0] data;
reg [1:0] STATE = IDLE;
reg [1:0] NEXT_STATE;
wire t_eq_baud;
wire bit_eq_8;
assign count = count_t;
assign bit_eq_8 = (index == n-1)?1:0;
assign t_eq_baud = (count_t == t_baud -1)?1:0;

localparam [1:0] IDLE = 2'b00;
localparam [1:0] START_BIT = 2'b01;
localparam [1:0] DATA_BIT = 2'b10;
localparam [1:0] STOP_BIT = 2'b11;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        STATE <= IDLE;
    end 
    else begin
        STATE <= NEXT_STATE;
        end
end

always @(posedge clk) begin
    NEXT_STATE <= STATE;
case (STATE)
    IDLE : begin
        data <= 8'b0;
        TX <= 1'b1;
        index <= 0;
        wr_done <= 1'b0;
        count_t <= 0;
        if (wr_en) begin
            data <= data_in;
            NEXT_STATE <= START_BIT;
        end
        end 
    START_BIT  : begin
        TX <= 1'b0;
        wr_done <= 1'b0;
        if(~t_eq_baud) begin
            count_t <= count_t + 1;
            end
        else begin
            count_t <= 0;
            NEXT_STATE <= DATA_BIT;
        end
        end
    DATA_BIT  : begin
        TX <= data[index];
        if(~t_eq_baud) begin
            count_t <= count_t + 1;
        end else begin
            count_t <= 0; 
            if(bit_eq_8) begin
                index <= 0;
                NEXT_STATE <= STOP_BIT;
            end else begin
                index <= index + 1;
                end
            end
    end
    STOP_BIT  : begin
        TX <= 1;
        if(~t_eq_baud) begin
            count_t <= count_t + 1;
        end else begin 
            count_t <= 0;
            wr_done <= 1;
            if(wr_en) begin
                NEXT_STATE <= START_BIT;
                end
            else begin
                NEXT_STATE <= IDLE;
                end
        end
        end
    default: NEXT_STATE <= IDLE;
endcase
end
endmodule

