`include "DW_sqrt.v"

module geofence (clk, reset, X, Y, R, valid, is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;
output is_inside;

//=====================def reg============================
reg valid;
reg is_inside;
reg [2:0] cs, ns;
reg [9:0] X_addr [0:5];
reg [9:0] Y_addr [0:5];
reg [10:0] R_addr[0:5];
reg [9:0] X_seq [0:5];
reg [9:0] Y_seq [0:5];
reg [10:0] R_seq [0:5];
reg signed [10:0] X_length [0:5];
reg signed [10:0] Y_length [0:5];
reg signed [21:0] cross_temp;
reg [10:0] R_temp[0:5];
reg [2:0] addr_count, cross_count, cross_count1, cross_count2, cross_count3, cross_count4;
reg [2:0] seq_cnt, sign_cnt, vector_cnt, side_cnt, index0, index1;
reg [23:0] total_area1, total_area;
reg [21:0] area_temp1;

wire [9:0] X, Y;
wire signed [10:0] x[0:4];
wire signed [10:0] y[0:4];
wire [10:0] R, S;
wire signed [21:0] a, ssa, sbsc;
wire [10:0] b, ssa_out, sbsc_out;
wire [21:0] area_temp;
wire [23:0] area;

DW_sqrt  Sqrt_unit0 (.a(a), .root(b));
DW_sqrt  Sqrt_unit1 (.a(ssa), .root(ssa_out));
DW_sqrt  Sqrt_unit2 (.a(sbsc), .root(sbsc_out));

//=====================def parameter============================
parameter IDLE = 3'd0;
parameter Read_addr = 3'd1;
parameter Cross = 3'd2;
parameter Vector_seq = 3'd3; 
parameter Side_length = 3'd4;
parameter Finish = 3'd7;
//=====================single============================
always @(*) begin
    case(cs)
        IDLE : begin
            is_inside = 0;
            valid = 0;
        end
        Read_addr : begin
            is_inside = 0;
            valid = 0;
        end
        Cross : begin
            is_inside = 0;
            valid = 0;
        end
        Vector_seq : begin
            is_inside = 0;
            valid = 0;
        end
        Side_length : begin
            is_inside = 0;
            valid = 0;
        end
        Finish : begin
            if(total_area1 < total_area)
                is_inside = 1;
            else
                is_inside = 0;
            //is_inside = (total_area1 < total_area) ? 1 : 0;
            valid = 1;
        end
        default : begin
            is_inside = 0;
            valid = 0;
        end
    endcase
end
//=====================fsm============================
always @(*) begin
    case (cs)
        IDLE :
            ns = Read_addr;
        Read_addr :
            ns = (addr_count == 6) ? Cross : Read_addr;
        Cross :
            ns = (cross_count == 5) ? Vector_seq : Cross;
        Vector_seq :
            ns = (seq_cnt == 5) ? Side_length : Cross;
        Side_length :
            ns = (side_cnt == 6) ? Finish : Side_length;
        Finish :
            ns = IDLE;
        default :
            ns = IDLE;
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset)
        cs <= IDLE;
    else
        cs <= ns;
end
//=====================Read_addr============================
//read X, Y, R addr

always @(posedge clk or posedge reset) begin
    if(reset) begin
        X_addr[0] <= 11'd0;
        X_addr[1] <= 11'd0;
        X_addr[2] <= 11'd0;
        X_addr[3] <= 11'd0;
        X_addr[4] <= 11'd0;
        X_addr[5] <= 11'd0;
    end
    else begin
        if(ns == Read_addr) begin
            case(addr_count)
                0 : X_addr[0] <= X;
                1 : X_addr[1] <= X;
                2 : X_addr[2] <= X;
                3 : X_addr[3] <= X;
                4 : X_addr[4] <= X;
                5 : X_addr[5] <= X;
                default : begin
                    X_addr[0] <= 11'd0;
                    X_addr[1] <= 11'd0;
                    X_addr[2] <= 11'd0;
                    X_addr[3] <= 11'd0;
                    X_addr[4] <= 11'd0;
                    X_addr[5] <= 11'd0;
                end
            endcase
        end
    end
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        Y_addr[0] <= 11'd0;
        Y_addr[1] <= 11'd0;
        Y_addr[2] <= 11'd0;
        Y_addr[3] <= 11'd0;
        Y_addr[4] <= 11'd0;
        Y_addr[5] <= 11'd0;
    end
    else begin
        if(ns == Read_addr) begin
            case(addr_count)
                0 : Y_addr[0] <= Y;
                1 : Y_addr[1] <= Y;
                2 : Y_addr[2] <= Y;
                3 : Y_addr[3] <= Y;
                4 : Y_addr[4] <= Y;
                5 : Y_addr[5] <= Y;
                default : begin
                    Y_addr[0] <= 11'd0;
                    Y_addr[1] <= 11'd0;
                    Y_addr[2] <= 11'd0;
                    Y_addr[3] <= 11'd0;
                    Y_addr[4] <= 11'd0;
                    Y_addr[5] <= 11'd0;
                end
            endcase
        end
    end
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        R_addr[0] <= 11'd0;
        R_addr[1] <= 11'd0;
        R_addr[2] <= 11'd0;
        R_addr[3] <= 11'd0;
        R_addr[4] <= 11'd0;
        R_addr[5] <= 11'd0;
    end
    else begin
        if(ns == Read_addr) begin
            case(addr_count)
                0 : R_addr[0] <= R;
                1 : R_addr[1] <= R;
                2 : R_addr[2] <= R;
                3 : R_addr[3] <= R;
                4 : R_addr[4] <= R;
                5 : R_addr[5] <= R;
                default : begin
                    R_addr[0] <= 11'd0;
                    R_addr[1] <= 11'd0;
                    R_addr[2] <= 11'd0;
                    R_addr[3] <= 11'd0;
                    R_addr[4] <= 11'd0;
                    R_addr[5] <= 11'd0;
                end
            endcase
        end
    end
end
//addr_count
always @(posedge clk or posedge reset) begin
    if(reset)
        addr_count <= 3'd0;
    else if(ns == Read_addr)
        if(addr_count == 6)
            addr_count <= 3'd0;
        else
            addr_count <= addr_count + 1;
    else
        addr_count <= 3'd0;
end
//=====================find_vector_Axy, Bxy, Cxy, Dxy, Exy============================
assign x[0] = X_addr[1] - X_addr[0];
assign y[0] = Y_addr[1] - Y_addr[0];
//
assign x[1] = X_addr[2] - X_addr[0];
assign y[1] = Y_addr[2] - Y_addr[0];
//
assign x[2] = X_addr[3] - X_addr[0];
assign y[2] = Y_addr[3] - Y_addr[0];
//
assign x[3] = X_addr[4] - X_addr[0];
assign y[3] = Y_addr[4] - Y_addr[0];
//
assign x[4] = X_addr[5] - X_addr[0];
assign y[4] = Y_addr[5] - Y_addr[0];
//=====================CROSS============================
//cross_temp
always @(*) begin
    if(cs == Cross) begin
        case(seq_cnt)
            0 : cross_temp = x[0] * y[cross_count] - x[cross_count] * y[0];
            1 : cross_temp = x[1] * y[cross_count1] - x[cross_count1] * y[1];
            2 : cross_temp = x[2] * y[cross_count2] - x[cross_count2] * y[2];
            3 : cross_temp = x[3] * y[cross_count3] - x[cross_count3] * y[3];
            4 : cross_temp = x[4] * y[cross_count4] - x[cross_count4] * y[4];
            default :
                cross_temp = 21'd0;
        endcase
    end
    else
        cross_temp = 21'd0;
end
//cross_count
always @(posedge clk or posedge reset) begin
    if(reset)
        cross_count <= 3'd0;
    else if(cs == Cross)
        if(cross_count == 3'd5)
            cross_count <= 3'd1;
        else
            cross_count <= cross_count + 3'd1;
    else
        cross_count <= 3'd1;
end
//cross_count1
always @(posedge clk or posedge reset) begin
    if(reset)
        cross_count1 <= 3'd0;
    else if(cs == Cross)
        if(cross_count1 == 3'd4)
            cross_count1 <= 3'd0;
        else
            cross_count1 <= cross_count1 + 3'd1;
    else
        cross_count1 <= 3'd2;
end
//cross_count2
always @(posedge clk or posedge reset) begin
    if(reset)
        cross_count2 <= 3'd0;
    else if(cs == Cross)
        if(cross_count2 == 3'd4)
            cross_count2 <= 3'd0;
        else
            cross_count2 <= cross_count2 + 3'd1;
    else
        cross_count2 <= 3'd3;
end
//cross_count3
always @(posedge clk or posedge reset) begin
    if(reset)
        cross_count3 <= 3'd0;
    else if(cs == Cross)
        if(cross_count3 == 3'd4)
            cross_count3 <= 3'd0;
        else
            cross_count3 <= cross_count3 + 3'd1;
    else
        cross_count3 <= 3'd4;
end
//cross_count4
always @(posedge clk or posedge reset) begin
    if(reset)
        cross_count4 <= 3'd0;
    else if(cs == Cross)
        if(cross_count4 == 3'd3)
            cross_count4 <= 3'd0;
        else
            cross_count4 <= cross_count4 + 3'd1;
    else
        cross_count4 <= 3'd0;
end
//seq_cnt
always @(posedge clk or posedge reset) begin
    if(reset)
        seq_cnt <= 3'd0;
    else begin
        if(ns == Vector_seq)
            seq_cnt <= seq_cnt + 3'd1;
        else if(cs == Finish)
            seq_cnt <= 3'd0;
    end
end
//sign_count
always @(posedge clk or posedge reset) begin
    if(reset)
        sign_cnt <= 3'd0;
    else if(cs == Cross)
        if(cross_temp < 0)
            sign_cnt <= sign_cnt + 3'd1;
        else
            sign_cnt <= sign_cnt + 3'd0;
    else
        sign_cnt <= 3'd0;
end
//=====================vector_sequence============================
//X_seq
always @(posedge clk or posedge reset) begin
    if(reset) begin
        X_seq[0] <= 10'd0;
        X_seq[1] <= 10'd0;
        X_seq[2] <= 10'd0;
        X_seq[3] <= 10'd0;
        X_seq[4] <= 10'd0;
        X_seq[5] <= 10'd0;
    end
    else if(ns == Vector_seq) begin
        case(sign_cnt)
            0 : begin
                X_seq[0] <= X_addr[0];
                X_seq[1] <= X_addr[seq_cnt + 1];
            end
            1 : X_seq[2] <= X_addr[seq_cnt + 1];
            2 : X_seq[3] <= X_addr[seq_cnt + 1];
            3 : X_seq[4] <= X_addr[seq_cnt + 1];
            4 : X_seq[5] <= X_addr[seq_cnt + 1];
            default : begin
                X_seq[0] <= 10'd0;
                X_seq[1] <= 10'd0;
                X_seq[2] <= 10'd0;
                X_seq[3] <= 10'd0;
                X_seq[4] <= 10'd0;
                X_seq[5] <= 10'd0;
            end
        endcase
    end
end
//Y_seq
always @(posedge clk or posedge reset) begin
    if(reset) begin
        Y_seq[0] <= 10'd0;
        Y_seq[1] <= 10'd0;
        Y_seq[2] <= 10'd0;
        Y_seq[3] <= 10'd0;
        Y_seq[4] <= 10'd0;
        Y_seq[5] <= 10'd0;
    end
    else if(ns == Vector_seq) begin
        case(sign_cnt)
            0 : begin
                Y_seq[0] <= Y_addr[0];
                Y_seq[1] <= Y_addr[seq_cnt + 1];
            end
            1 : Y_seq[2] <= Y_addr[seq_cnt + 1];
            2 : Y_seq[3] <= Y_addr[seq_cnt + 1];
            3 : Y_seq[4] <= Y_addr[seq_cnt + 1];
            4 : Y_seq[5] <= Y_addr[seq_cnt + 1];
            default : begin
                Y_seq[0] <= 10'd0;
                Y_seq[1] <= 10'd0;
                Y_seq[2] <= 10'd0;
                Y_seq[3] <= 10'd0;
                Y_seq[4] <= 10'd0;
                Y_seq[5] <= 10'd0;
            end
        endcase
    end
end
//R_seq
always @(posedge clk or posedge reset) begin
    if(reset) begin
        R_seq[0] <= 11'd0;
        R_seq[1] <= 11'd0;
        R_seq[2] <= 11'd0;
        R_seq[3] <= 11'd0;
        R_seq[4] <= 11'd0;
        R_seq[5] <= 11'd0;
    end
    else if(ns == Vector_seq) begin
        case(sign_cnt)
            0 : begin
                R_seq[0] <= R_addr[0];
                R_seq[1] <= R_addr[seq_cnt + 1];
            end
            1 : R_seq[2] <= R_addr[seq_cnt + 1];
            2 : R_seq[3] <= R_addr[seq_cnt + 1];
            3 : R_seq[4] <= R_addr[seq_cnt + 1];
            4 : R_seq[5] <= R_addr[seq_cnt + 1];
            default : begin
                R_seq[0] <= 11'd0;
                R_seq[1] <= 11'd0;
                R_seq[2] <= 11'd0;
                R_seq[3] <= 11'd0;
                R_seq[4] <= 11'd0;
                R_seq[5] <= 11'd0;
            end
        endcase
    end
end
//=====================total_area============================
assign area_temp = (side_cnt > 3'd0) ? (X_seq[index0] * Y_seq[index1] - X_seq[index1] * Y_seq[index0]) : 22'd0;

always @(posedge clk or posedge reset)begin
    if(reset)
        area_temp1 <= 22'd0;
    else if(cs == Side_length)
        area_temp1 <= area_temp + area_temp1;
    else
        area_temp1 <= 22'd0;
end 
always @(*) begin
    total_area = area_temp1 >> 1;
end
//=====================side_length============================
//side_cnt
always @(posedge clk or posedge reset) begin
    if(reset)
        side_cnt <= 3'd0;
    else if(cs == Side_length)
        if(side_cnt == 3'd6)
            side_cnt <= 3'd0;
        else
            side_cnt <= side_cnt + 3'd1;
    else
        side_cnt <= 3'd0;
end
//index
always @(*) begin
    if(cs == Side_length)
        case(side_cnt)
            1 : begin
                index0 = 3'd0;
                index1 = 3'd1;
            end
            2 : begin
                index0 = 3'd1;
                index1 = 3'd2;
            end
            3 : begin
                index0 = 3'd2;
                index1 = 3'd3;
            end
            4 : begin
                index0 = 3'd3;
                index1 = 3'd4;
            end
            5 : begin
                index0 = 3'd4;
                index1 = 3'd5;
            end
            6 : begin
                index0 = 3'd5;
                index1 = 3'd0;
            end
            default : begin
                index0 = 3'd0;
                index1 = 3'd0;
            end
        endcase
    else begin
        index0 = 3'd0;
        index1 = 3'd0;
    end
end
//X_vector
always @(posedge clk or posedge reset) begin
    if(reset) begin
        X_length[0] <= 11'd0;
        X_length[1] <= 11'd0;
        X_length[2] <= 11'd0;
        X_length[3] <= 11'd0;
        X_length[4] <= 11'd0;
        X_length[5] <= 11'd0;
    end
    else if(cs == Side_length) begin
        case(side_cnt)
            0 : X_length[0] <= X_seq[1] - X_seq[0];
            1 : X_length[1] <= X_seq[2] - X_seq[1];
            2 : X_length[2] <= X_seq[3] - X_seq[2];
            3 : X_length[3] <= X_seq[4] - X_seq[3];
            4 : X_length[4] <= X_seq[5] - X_seq[4];
            5 : X_length[5] <= X_seq[0] - X_seq[5];
            default : begin
                X_length[0] <= 11'd0;
                X_length[1] <= 11'd0;
                X_length[2] <= 11'd0;
                X_length[3] <= 11'd0;
                X_length[4] <= 11'd0;
                X_length[5] <= 11'd0;
            end
        endcase
    end
end
//Y_vector
always @(posedge clk or posedge reset) begin
    if(reset) begin
        Y_length[0] <= 11'd0;
        Y_length[1] <= 11'd0;
        Y_length[2] <= 11'd0;
        Y_length[3] <= 11'd0;
        Y_length[4] <= 11'd0;
        Y_length[5] <= 11'd0;
    end
    else if(cs == Side_length) begin
        case(side_cnt)
            0 : Y_length[0] <= Y_seq[1] - Y_seq[0];
            1 : Y_length[1] <= Y_seq[2] - Y_seq[1];
            2 : Y_length[2] <= Y_seq[3] - Y_seq[2];
            3 : Y_length[3] <= Y_seq[4] - Y_seq[3];
            4 : Y_length[4] <= Y_seq[5] - Y_seq[4];
            5 : Y_length[5] <= Y_seq[0] - Y_seq[5];
            default : begin
                Y_length[0] <= 11'd0;
                Y_length[1] <= 11'd0;
                Y_length[2] <= 11'd0;
                Y_length[3] <= 11'd0;
                Y_length[4] <= 11'd0;
                Y_length[5] <= 11'd0;
            end
        endcase
    end
end

assign a = (X_length[index0] * X_length[index0]) + (Y_length[index0] * Y_length[index0]);

//assign S = (side_cnt > 0) ? ((side_cnt == 3'd6) ? (b + R_seq[5] + R_seq[0]) >> 1 : (b + R_seq[side_cnt - 1] + R_seq[side_cnt]) >> 1) : 11'd0;
assign S = (side_cnt > 0) ? ((b + R_seq[index0] + R_seq[index1]) >> 1) : 11'd0;

assign ssa = (side_cnt > 0) ? (S * (S - b)) : 22'd0;
assign sbsc = (side_cnt > 0) ? ((S - R_seq[index0]) * (S - R_seq[index1])) : 22'd0;

assign area = (side_cnt > 3'd0) ? ssa_out * sbsc_out : 23'd0;

always @(posedge clk or posedge reset)begin
    if(reset)
        total_area1 <= 24'd0;
    else if(cs == Side_length)
        total_area1 <= area + total_area1;
    else
        total_area1 <= 24'd0;
end 

endmodule


