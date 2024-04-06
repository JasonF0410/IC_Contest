module huffman(clk, reset, gray_data, gray_valid, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;

//========================def_port================================
reg [2:0] cs, ns;
reg [2:0] reorder1_E_count;
reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
reg [7:0] CNT1_temp, CNT2_temp, CNT3_temp, CNT4_temp, CNT5_temp, CNT6_temp;
reg [7:0] reorder_temp1, reorder_temp2, reorder_temp3, reorder_temp4, reorder_temp5, reorder_temp6;
reg [7:0] reorder_temp11, reorder_temp21, reorder_temp31, reorder_temp41, reorder_temp51, reorder_temp61;
//reg [7:0] comb_temp4;
reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
reg [7:0] M1, M2, M3, M4, M5, M6;
reg code_valid, CNT_valid;

wire gray_valid;
wire [7:0] gray_data;
wire [7:0] data_cnt [0:5];
wire [7:0] comb_temp4;
//========================def_parameter================================
parameter IDLE = 3'd0;
parameter Reset_cycle = 3'd1;
parameter Read_data = 3'd2;
parameter Check_num = 3'd3;
parameter Reorder1_E = 3'd4; 
parameter Combination = 3'd5;
parameter Finish = 3'd7;
//========================single================================
always @(*) begin
    case(cs)
        IDLE : begin
            CNT_valid = 0;
            code_valid = 0;
        end
        Reset_cycle : begin
            CNT_valid = 0;
            code_valid = 0;
        end
        Read_data : begin
            CNT_valid = 0;
            code_valid = 0;
        end
        Check_num : begin
            CNT_valid = 1;
            code_valid = 0;
        end
        Reorder1_E : begin
            CNT_valid = 0;
            code_valid = 0;
        end
        Combination : begin
            CNT_valid = 0;
            code_valid = 0;
        end
        Finish : begin
            CNT_valid = 0;
            code_valid = 1;
        end
        default : begin
            CNT_valid = 0;
            code_valid = 0;
        end
    endcase
end
//========================fsm================================
always @(*) begin
    case (cs)
        IDLE :
            ns = Reset_cycle;
        Reset_cycle :
            ns = Read_data;
        Read_data :
            ns = (gray_valid) ? Read_data : Check_num;
        Check_num :
            ns = Reorder1_E;
        Reorder1_E :
            ns = (reorder1_E_count == 3'd5) ? Combination : Reorder1_E;
        Combination :
            ns = Finish;
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
//========================Read_data================================
always @(posedge clk or posedge reset) begin
    if(reset) begin
        CNT1 <= 8'd0;
        CNT2 <= 8'd0;
        CNT3 <= 8'd0;
        CNT4 <= 8'd0;
        CNT5 <= 8'd0;
        CNT6 <= 8'd0;
    end
    else if(gray_valid)
        case(gray_data)
            8'h01 :
                CNT1 <= CNT1 + 8'd1;
            8'h02 :
                CNT2 <= CNT2 + 8'd1;
            8'h03 :
                CNT3 <= CNT3 + 8'd1;
            8'h04 :
                CNT4 <= CNT4 + 8'd1;
            8'h05 :
                CNT5 <= CNT5 + 8'd1;
            8'h06 :
                CNT6 <= CNT6 + 8'd1;
            default :
                CNT1 <= 8'd0;
    endcase
end
//========================Reorder1_E================================
//reorder0
always @(posedge clk or posedge reset) begin
    if(reset) begin
        CNT1_temp <= 8'd0;
        CNT2_temp <= 8'd0;
    end
    case (reorder1_E_count)
        0 : begin
            if(CNT1 >= CNT2) begin
                CNT1_temp <= CNT1;
                CNT2_temp <= CNT2;
            end
            else begin
                CNT1_temp <= CNT2;
                CNT2_temp <= CNT1;
            end
        end
        default: begin
            CNT1_temp <= 0;
            CNT2_temp <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        CNT3_temp <= 8'd0;
        CNT4_temp <= 8'd0;
    end
    case(reorder1_E_count)
        0 : begin
            if(CNT3 >= CNT4) begin
                CNT3_temp <= CNT3;
                CNT4_temp <= CNT4;
            end
            else begin
                CNT3_temp <= CNT4;
                CNT4_temp <= CNT3;
            end
        end
        default : begin
            CNT3_temp <= 0;
            CNT4_temp <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        CNT5_temp <= 8'd0;
        CNT6_temp <= 8'd0;
    end
   case(reorder1_E_count)
        0 : begin
            if(CNT5 >= CNT6) begin
                CNT5_temp <= CNT5;
                CNT6_temp <= CNT6;
            end
            else begin
                CNT5_temp <= CNT6;
                CNT6_temp <= CNT5;
            end
        end
        default : begin
            CNT5_temp <= 0;
            CNT6_temp <= 0;
        end
    endcase
end
//reorder2,4
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp1 <= 8'd0;
        reorder_temp2 <= 8'd0;
    end
    case(reorder1_E_count)
        2: begin
            if(reorder_temp11 >= reorder_temp21) begin
                reorder_temp1 <= reorder_temp11;
                reorder_temp2 <= reorder_temp21;
            end
            else begin
                reorder_temp1 <= reorder_temp21;
                reorder_temp2 <= reorder_temp11;
            end
        end
        4 : begin
            if(reorder_temp11 >= reorder_temp21) begin
                reorder_temp1 <= reorder_temp11;
                reorder_temp2 <= reorder_temp21;
            end
            else begin
                reorder_temp1 <= reorder_temp21;
                reorder_temp2 <= reorder_temp11;
            end
        end
        default : begin
            reorder_temp1 <= 0;
            reorder_temp2 <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp3 <= 8'd0;
        reorder_temp4 <= 8'd0;
    end
    case(reorder1_E_count)
        2 : begin
            if(reorder_temp31 >= reorder_temp41) begin
                reorder_temp3 <= reorder_temp31;
                reorder_temp4 <= reorder_temp41;
            end
            else begin
                reorder_temp3 <= reorder_temp41;
                reorder_temp4 <= reorder_temp31;
            end
        end
        4 : begin
            if(reorder_temp31 >= reorder_temp41) begin
                reorder_temp3 <= reorder_temp31;
                reorder_temp4 <= reorder_temp41;
            end
            else begin
                reorder_temp3 <= reorder_temp41;
                reorder_temp4 <= reorder_temp31;
            end
        end
        default : begin
            reorder_temp3 <= 0;
            reorder_temp4 <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp5 <= 8'd0;
        reorder_temp6 <= 8'd0;
    end
    case(reorder1_E_count)
        2 : begin
            if(reorder_temp51 >= reorder_temp61) begin
                reorder_temp5 <= reorder_temp51;
                reorder_temp6 <= reorder_temp61;
            end
            else begin
                reorder_temp5 <= reorder_temp61;
                reorder_temp6 <= reorder_temp51;
            end
        end
        4 : begin
            if(reorder_temp51 >= reorder_temp61) begin
                reorder_temp5 <= reorder_temp51;
                reorder_temp6 <= reorder_temp61;
            end
            else begin
                reorder_temp5 <= reorder_temp61;
                reorder_temp6 <= reorder_temp51;
            end
        end
        default : begin
            reorder_temp5 <= 0;
            reorder_temp6 <= 0;
        end
    endcase
end
//order1,3
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp21 <= 8'd0;
        reorder_temp31 <= 8'd0;
    end
    case(reorder1_E_count)
        1 : begin
            if(CNT2_temp >= CNT3_temp) begin
                reorder_temp21 <= CNT2_temp;
                reorder_temp31 <= CNT3_temp;
            end
            else begin
                reorder_temp21 <= CNT3_temp;
                reorder_temp31 <= CNT2_temp;
            end
        end
        3 : begin
            if(reorder_temp2 >= reorder_temp3) begin
                reorder_temp21 <= reorder_temp2;
                reorder_temp31 <= reorder_temp3;
            end
            else begin
                reorder_temp21 <= reorder_temp3;
                reorder_temp31 <= reorder_temp2;
            end
        end
        default : begin
             reorder_temp21 <= 0;
            reorder_temp31 <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp41 <= 8'd0;
        reorder_temp51 <= 8'd0;
    end
    case(reorder1_E_count)
        1 : begin
            if(CNT4_temp >= CNT5_temp) begin
                reorder_temp41 <= CNT4_temp;
                reorder_temp51 <= CNT5_temp;
            end
            else begin
                reorder_temp41 <= CNT5_temp;
                reorder_temp51 <= CNT4_temp;
            end
        end
        3 : begin
            if(reorder_temp4 >= reorder_temp5) begin
                reorder_temp41 <= reorder_temp4;
                reorder_temp51 <= reorder_temp5;
            end
            else begin
                reorder_temp41 <= reorder_temp5;
                reorder_temp51 <= reorder_temp4;
            end
        end
        default : begin
            reorder_temp41 <= 0;
            reorder_temp51 <= 0;
        end
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset) begin
        reorder_temp11 <= 8'd0;
        reorder_temp61 <= 8'd0;
    end
    case(reorder1_E_count)
        1 : begin
            if(CNT1_temp >= CNT6_temp) begin
                reorder_temp11 <= CNT1_temp;
                reorder_temp61 <= CNT6_temp;
            end
            else begin
                reorder_temp11 <= CNT6_temp;
                reorder_temp61 <= CNT1_temp;
            end
        end
        3 : begin
            if(reorder_temp1 >= reorder_temp6) begin
                reorder_temp11 <= reorder_temp1;
                reorder_temp61 <= reorder_temp6;
            end
            else begin
                reorder_temp11 <= reorder_temp6;
                reorder_temp61 <= reorder_temp1;
            end
        end
        default : begin
            reorder_temp11 <= 0;
            reorder_temp61 <= 0;
        end
    endcase
end

//bubble_sort_count
always @(posedge clk or posedge reset) begin
    if(reset)
        reorder1_E_count <= 3'd0;
    else if(cs == Reorder1_E)
        if(reorder1_E_count == 3'd5)
            reorder1_E_count <= 3'd0;
        else
            reorder1_E_count <= reorder1_E_count + 3'd1;
    else
        reorder1_E_count <= 3'd0;
end
//========================Combination================================
//assign comb_temp4 = reorder_temp5 + reorder_temp6;

endmodule



