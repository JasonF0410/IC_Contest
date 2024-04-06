`timescale 1ns/10ps
module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output IRAM_valid;
output [7:0] IRAM_D;
output [5:0] IRAM_A;
output busy;
output done;


//=======================def_port=======================
wire cmd_valid;

reg [2:0]cs, ns;
reg [2:0] x, y, x_out, y_out;
reg [2:0] input_cnt;
reg [7:0] pixel_tmp [0:4];
reg [7:0] IRAM_Q_tmp [0:63];
reg [7:0] IRAM_D;
reg [5:0]IROM_A, IRAM_A;
reg IROM_rd, IRAM_valid, busy;
reg done;
//=========================fsm=======================
parameter IDLE = 3'd0;
parameter Input_data = 3'd1; 
parameter Tmp_state = 3'd2;
parameter cmd_state = 3'd3;
parameter Output_data = 3'd4;
parameter Finish = 3'd7;
//cmd parameter
parameter wirte = 4'd0;
parameter shift_up = 4'd1;
parameter shift_down = 4'd2;
parameter shift_left = 4'd3;
parameter shift_right = 4'd4;
parameter max = 4'd5;
parameter min = 4'd6;
parameter average = 4'd7;
parameter counterclockwise_rotation = 4'd8;
parameter clockwise_rotation = 4'd9;
parameter mirror_x = 4'd10;
parameter mirror_y = 4'd11;

always@(*) begin
    case(cs)
    IDLE :
        ns = Input_data;
    Input_data :
        ns = (x == 3'd7 && y == 3'd7) ? Tmp_state : Input_data;
    Tmp_state : 
        ns = cmd_state;
    cmd_state :
        ns = (cmd) ? cmd_state : Output_data;
    Output_data :
        ns = (x == 3'd7 && y == 3'd7) ? Finish : Output_data;
    Finish :
        ns = Finish;
    default :
        ns = IDLE;
    endcase
end
always@(posedge clk or posedge reset) begin
    if(reset)
        cs = IDLE;
    else
        cs = ns;
end
//=======================control_singal=======================
always@(*) begin
    case(cs)
		IDLE: begin
			IROM_rd = 0;
            IRAM_valid = 0;
			busy = 1;
			done = 0;
		end
		Input_data: begin
			IROM_rd = 1;
            IRAM_valid = 0;
			busy = 1;
			done = 0;
		end
		cmd_state: begin
			IROM_rd = 1;
            IRAM_valid = 0;
			busy = 0;
			done = 0;
		end
		Output_data: begin
			IROM_rd = 0;
            IRAM_valid = 1;
			busy = 0;
			done = 0;
		end
		Finish: begin
			IROM_rd = 0;
            IRAM_valid = 0;
			busy = 0;
			done = 1;
		end
		default:begin 
			IROM_rd = 0;
            IRAM_valid = 0;
			busy = 1;
			done = 0;
		end
    endcase
end
//=======================input_data=======================
always @(posedge clk or posedge reset) begin
    if(reset) begin
        x <= 3'd0;
        y <= 3'd0;
    end
    else if(cs == Input_data || cs == Output_data) begin
        if(x == 3'd7) begin
            y <= y + 3'd1;
            x <= 3'd0;
        end
        else
            x <= x + 3'd1;
    end
    else begin
        x <= 3'd0;
        y <= 3'd0;
    end
end
//input_cnt
always @(posedge clk or posedge reset) begin
    if(reset)
        input_cnt <= 3'd0;
    else if(cs == Input_data)
        if(input_cnt == 3'd3)
            input_cnt <= 3'd0;
        else
            input_cnt <= input_cnt + 3'd1;
    else
        input_cnt <= 3'd0;
end
//get initial address
always @(*) begin
    if(cs == Input_data)
        IROM_A = {y, x};
    else if(cmd == 4'd1 || cmd == 4'd2 || cmd == 4'd3 || cmd == 4'd4)
        IROM_A = {y_out, x_out};
    else
        IROM_A = 6'd0;
end

always @(*) begin
    if(cs == Input_data)
        IRAM_Q_tmp[IROM_A] = IROM_Q;    //get initial data
    else if(cs == cmd_state) begin      //change IRAM_Q_tmp value
        case(cmd)
            max : IRAM_Q_tmp[IROM_A] = IROM_Q;
            min : 
            average :
            counterclockwise_rotation :
            clockwise_rotation :
            mirror_x :
            mirror_y :
            default :
        endcase
    end
    else
        IRAM_Q_tmp[0] = 8'd0;
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        pixel_tmp[0] = 8'd0;
        pixel_tmp[1] = 8'd0;
        pixel_tmp[2] = 8'd0;
        pixel_tmp[3] = 8'd0;
        pixel_tmp[4] = 8'd0;
        pixel_tmp[5] = 8'd0;
        pixel_tmp[6] = 8'd0;
    end
    else if(cs == cmd_state) begin
        case(cmd)
            max : begin
                pixel_tmp[4] = (pixel_tmp[0] >= pixel_tmp[1]) ? pixel_tmp[0] : pixel_tmp[1];
                pixel_tmp[5] = (pixel_tmp[2] >= pixel_tmp[3]) ? pixel_tmp[2] : pixel_tmp[3];
                pixel_tmp[6] = (pixel_tmp[4] >= pixel_tmp[5]) ? pixel_tmp[4] : pixel_tmp[5];
            end
            min : 
            average :
            counterclockwise_rotation :
            clockwise_rotation :
            mirror_x :
            mirror_y :
            default :
        endcase
    end
end
//=======================cmd=======================
//x_out, y_out check point
always@(*) begin
    case(cmd)
		shift_up:
			y_out = (y_out == 3'd0) ? 3'd1 : (y_out - 3'd1);
		shift_down:
			y_out = (y_out > 3'd7) ? 3'd7 : (y_out + 3'd1);
		default:
			y_out = 3'd3;
    endcase
end
always@(*) begin
    case(cmd)
		shift_left: 
			x_out = (x_out == 3'd0) ? 3'd1 : (x_out - 3'd1);
		shift_right: 
			x_out = (x_out > 3'd7) ? 3'd7 : (x_out + 3'd1);
		default:
			x_out = 3'd2;
    endcase
end
/*
always @(posedge clk or posedge reset) begin
    if(reset) begin
        pixel_tmp[0] = 8'd0;
        pixel_tmp[1] = 8'd0;
        pixel_tmp[2] = 8'd0;
        pixel_tmp[3] = 8'd0;
    end
    else if(cmd == 4'd1 || cmd == 4'd2 || cmd == 4'd3 || cmd == 4'd4) begin
        case(check_cnt)
            0 : pixel_tmp[0] = IROM_Q;
            1 : pixel_tmp[1] = IROM_Q;
            2 : pixel_tmp[2] = IROM_Q;
            3 : pixel_tmp[3] = IROM_Q;
            default : begin
                pixel_tmp[0] = 8'd0;
                pixel_tmp[1] = 8'd0;
                pixel_tmp[2] = 8'd0;
                pixel_tmp[3] = 8'd0;
            end
        endcase
    end
end
*/
//=======================output_data=======================
//output_addr
always @(*) begin
    if(cs == Output_data)
        IRAM_A = {y, x};
    else
        IRAM_A = 6'd0;
end
//ouyput data in IRAM_D MEM
always @(*) begin
    if(cs == Output_data)
        IRAM_D = IRAM_Q_tmp[IRAM_A];
    else
        IRAM_D = 8'd0;
end
/*
always @(*) begin
    case(cms)
        max : IROM_Q_tmp[]
end
*/

        
endmodule

//(x-1,y-1)=(x*8+y)-8 |  (x-1,y)=(x*8+y)-7
//------------------- | -------------------
//(x,y-1)= (x*8+y)-1  |  (x,y)=(x*8+y)