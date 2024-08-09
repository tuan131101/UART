module uart_rx #(
    parameter SEQ = 100000000,
    parameter BAUD_RATE = 9600,
    parameter n = 8
)(
input wire clk,rst_n,rd_en,RX,
output reg rd_done,
output reg [7:0] data_out
);

localparam t_baud = SEQ/BAUD_RATE;
reg [$clog2(t_baud) - 1:0] count_t;
reg [$clog2(n) - 1:0] index;
reg [1:0] STATE = IDLE;
reg [1:0] NEXT_STATE;
reg [n-1:0] data_reg;
wire t_eq_baud_half;
wire t_eq_baud;
wire bit_eq_8;
wire t_eq_1x5baud;

assign bit_eq_8 = (index == n-1)?1:0;
assign t_eq_baud = (count_t == t_baud -1)?1:0;
assign t_eq_baud_half = (count_t == (t_baud -1)/2)?1:0;
assign t_eq_1x5baud = (count_t == (t_baud + (t_baud -1)/2))?1:0;
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
        index <= 0;
        rd_done <= 1'b0;
        count_t <= 0;
        if (rd_en && ~RX) begin
            NEXT_STATE <= START_BIT;
        end
        end 
    START_BIT  : begin
        if(~t_eq_baud_half) begin
            count_t <= count_t + 1;
            end
        else begin
            count_t <= 0;
            NEXT_STATE <= DATA_BIT;
        end
        end
    DATA_BIT  : begin
        if(~t_eq_baud) begin
            count_t <= count_t + 1;
        end else  begin
            count_t <= 0;
            data_reg[index] <= RX;
            if(~bit_eq_8) begin
                index <= index + 1;
                end
            else begin
                NEXT_STATE <= STOP_BIT;
            end
            end
    end
    STOP_BIT  : begin
        if(~t_eq_1x5baud)begin
            count_t <= count_t + 1;
        end else begin 
            rd_done <= 1;
            data_out <= data_reg;
            NEXT_STATE <= IDLE;
        end
        end
    default: NEXT_STATE <= IDLE;
endcase
    end

endmodule