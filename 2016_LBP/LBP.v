
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  [13:0] 	gray_addr;
output         	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  [13:0] 	lbp_addr;
output  	lbp_valid;
output  [7:0] 	lbp_data;
output  	finish;
//====================================================================

reg [3:0]count;
reg [7:0]data, lbp_data;
reg [13:0]gray_addr_count, gray_addr_out, gray_addr, lbp_addr;
reg [7:0]lbp_sum;
reg gray_req, lbp_valid, finish;

//fsm
reg [2:0]cs, ns;
parameter IDLE = 3'd0;
parameter inputdata_state = 3'd1;
parameter square_state = 3'd2;
parameter outdata_state = 3'd3;
parameter finish_state = 3'd4;
always@(*) 
begin
    case(cs)
    IDLE:
        ns = inputdata_state;
    inputdata_state:
        ns = (gray_ready == 1) ? square_state : inputdata_state;//
    square_state:
        ns = (count == 8) ? outdata_state : square_state;
    outdata_state:
        ns =(lbp_addr == 16254) ? finish_state : inputdata_state;
    finish_state:
        ns = finish_state;
    default:
        ns = inputdata_state;
    endcase    
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        cs <= IDLE;
    else
        cs <= ns;
end

//singal control
//====================================================================
always@(*)
begin
    case(cs)
    IDLE: begin
        gray_req = 0;
        //lbp_valid = 0;
        finish = 0;
    end
    inputdata_state: begin
        gray_req = (cs == inputdata_state) ? 1 : 0;
        //lbp_valid = 0;
        finish = 0;
    end
    square_state: begin
        gray_req = (cs == square_state) ? 1 : 0;
        //lbp_valid = 0;
        finish = 0;
    end
    outdata_state: begin
        gray_req = 0;
        //lbp_valid = (cs == outdata_state) ? 1 : 0;
        finish = 0;
    end
    finish_state: begin
        gray_req = 0;
        //lbp_valid = 0;
        finish = (cs == finish_state) ? 1 : 0;
    end
    default: begin
        gray_req = 0;
        //lbp_valid = 0;
        finish = 0;
    end
    endcase
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        lbp_valid <= 0;
    else
        lbp_valid <= (cs == outdata_state) ? 1 : 0;
end
//====================================================================

//input data
always@(posedge clk or posedge reset)
begin
    if(reset)
        data <= 0;
    else if(cs == inputdata_state) //gray_ready == 1 &&
        data <= gray_data;
end
//address count
reg [7:0]x_count;
always@(posedge clk or posedge reset)
begin
    if(reset) begin
        gray_addr_count <= 14'd129;
        x_count <= 0;
    end
    else if(ns == outdata_state)
        if(x_count == 125) begin
            gray_addr_count <= gray_addr_count + 3;
            x_count <= 0;
        end
        else begin
            gray_addr_count <= gray_addr_count + 1;
            x_count <= x_count + 1;
        end
end

//count
always@(posedge clk or posedge reset)
begin
    if(reset)
        count <= 0;
    else if(ns == square_state) //maybe use ns
        count <= count + 1;
    else
        count <= 0;
end

//gray address
wire [13:0]gray_addr_temp [0:7];

assign gray_addr_temp[0] = gray_addr_count - 129;
assign gray_addr_temp[1] = gray_addr_count - 128;
assign gray_addr_temp[2] = gray_addr_count - 127;
assign gray_addr_temp[3] = gray_addr_count - 1;
assign gray_addr_temp[4] = gray_addr_count + 1;
assign gray_addr_temp[5] = gray_addr_count + 127;
assign gray_addr_temp[6] = gray_addr_count + 128;
assign gray_addr_temp[7] = gray_addr_count + 129;
always@(posedge clk or posedge reset)
begin
    if(reset)
        gray_addr <= 0;
    else if(ns == inputdata_state)
        gray_addr <= gray_addr_count;
    else if(ns == square_state)
        gray_addr <= gray_addr_temp[count];
end

//calculate
wire [7:0]data_buffer, lbp_mul;
wire [7:0]shift_reg [0:7];

assign shift_reg[0] = 1;    //2^count
assign shift_reg[1] = 2;
assign shift_reg[2] = 4;
assign shift_reg[3] = 8;
assign shift_reg[4] = 16;
assign shift_reg[5] = 32;
assign shift_reg[6] = 64;
assign shift_reg[7] = 128;

assign data_buffer = (data > gray_data) ? 0 : 1;
assign lbp_mul = (data_buffer * shift_reg[count - 1]);
always@(posedge clk or posedge reset)
begin
    if(reset)
        lbp_sum <= 0;
    else if(cs == square_state) //&& gray_addr_count < 16255
        if(lbp_addr == 16254)
            lbp_sum <= 0;
        else if(count == 1)
            lbp_sum <= data_buffer;
        else if(count > 1)
            lbp_sum <= lbp_sum + lbp_mul;
    //else
        //lbp_sum <= 0;
end

//output data
always@(posedge clk or posedge reset)
begin
    if(reset)
        lbp_data <= 0;
    else if(cs == outdata_state)
        lbp_data <= lbp_sum;
    //else
        //lbp_data <= 0;
end
//output address
always@(posedge clk or posedge reset)
begin
    if(reset)
        lbp_addr <= 0;
    else if(cs == outdata_state)
        lbp_addr <= gray_addr_out;
    //else
        //lbp_addr <= 0;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        gray_addr_out <= 14'd129;
    else
        gray_addr_out <= gray_addr_count;
end

//====================================================================
endmodule
