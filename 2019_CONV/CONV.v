
`timescale 1ns/10ps

module  CONV(
	//input
	clk, reset, ready,
	idata, cdata_rd,
	//output
	busy, iaddr, cwr, 
	caddr_wr, cdata_wr, crd,
	caddr_rd, csel
	);
	input		clk;
	input		reset;
	output		busy;	
	input		ready;	
			
	output		[11:0]iaddr;
	input signed [19:0]idata;	
	
	output	 	cwr;
	output	 	[11:0]caddr_wr;
	output	 	[19:0]cdata_wr;
	
	output	 	crd;
	output	 	[11:0]caddr_rd;
	input signed [19:0]cdata_rd;
	
	output	 	csel;
//====================================================================

//==========================def port==================================
reg busy;
reg [3:0]cs, ns;
reg [3:0] csel;
reg [5:0] x, y, xp, yp;
reg [3:0] addr_count, inputdata_count, conv_count;
reg signed [19:0] idata_buffer;
reg signed [39:0] convolution_temp1 [0:8];
reg signed [43:0] convolution_sum1, REconvolution_sum1;
reg [43:0] convolution_sum;
reg [19:0] cdata_wr;
reg [11:0] caddr_wr, caddr_rd;
reg [11:0] iaddr;
reg cwr, crd;

reg [3:0] max_pooling_count;
reg signed [19:0] max_temp, max_temp0, max_temp1;
reg [9:0] i;
reg [11:0] flatten_addr, flatten_addr_L1;
//wire signed [19:0] convolution_sum;
wire signed [19:0] kernel0 [0:8];
wire signed [19:0] kernel1 [0:8];
wire signed [35:0] kparameter0;
wire signed [35:0] kparameter1;
//==========================assign kernel==================================
assign kernel0[0] = 20'h0A89E;
assign kernel0[1] = 20'h092D5;
assign kernel0[2] = 20'h06D43;
assign kernel0[3] = 20'h01004;
assign kernel0[4] = 20'hF8F71;
assign kernel0[5] = 20'hF6E54;
assign kernel0[6] = 20'hFA6D7;
assign kernel0[7] = 20'hFC834;
assign kernel0[8] = 20'hFAC19;
assign kparameter0 = 36'h0_1310_0000;

assign kernel1[0] = 20'hFDB55;
assign kernel1[1] = 20'h02992;
assign kernel1[2] = 20'hFC994;
assign kernel1[3] = 20'h050FD;
assign kernel1[4] = 20'h02F20;
assign kernel1[5] = 20'h0202D;
assign kernel1[6] = 20'h03BD7;
assign kernel1[7] = 20'hFD369;
assign kernel1[8] = 20'h05E68;
assign kparameter1 = 36'hF_7295_0000;
//==========================parameter==================================
parameter IDLE = 4'd0;
parameter Convolution_state = 4'd1;
parameter Output_consum_state = 4'd2;
parameter ReLU_state = 4'd3;
parameter Max_pooling = 4'd4;
parameter Write_max_pooling = 4'd5;
parameter Out_pooling = 4'd6;
parameter Convolution_state_L1 = 4'd7;
parameter Output_consum_state_L1 = 4'd8;
parameter ReLU_state_L1 = 4'd9;
parameter Max_pooling_L1 = 4'd10;
parameter Write_max_pooling_L1 = 4'd11;
parameter Out_pooling_L1 = 4'd12;
parameter Finish = 4'd14;
//==========================fsm==================================
always @(*) begin
    case (cs)
        IDLE :
            ns = (ready) ? Convolution_state : IDLE;
        Convolution_state :
            ns =  (conv_count == 10) ? Output_consum_state : Convolution_state;
        Output_consum_state :
            ns = ReLU_state;
		ReLU_state :
			ns = (x == 63 && y == 63) ? Max_pooling : Convolution_state;
		Max_pooling :
			ns = (max_pooling_count == 5) ? Write_max_pooling : Max_pooling;
		Write_max_pooling :
			ns = Out_pooling;
		Out_pooling :
			ns = (xp == 63 && yp == 63) ? Convolution_state_L1 : Max_pooling;
		Convolution_state_L1 :
			ns = (conv_count == 10) ? Output_consum_state_L1 : Convolution_state_L1;
		Output_consum_state_L1 :
			ns = ReLU_state_L1;
		ReLU_state_L1 :
			ns = (x == 63 && y == 63) ? Max_pooling_L1 : Convolution_state_L1;
		Max_pooling_L1 :
			ns = (max_pooling_count == 5) ? Write_max_pooling_L1 : Max_pooling_L1;
		Write_max_pooling_L1 :
			ns = Out_pooling_L1;
		Out_pooling_L1 :
			ns = (xp == 63 && yp == 63) ? Finish : Max_pooling_L1;
        Finish :
            ns = IDLE;
        default: 
            ns = IDLE;
    endcase
end
always @(posedge clk or posedge reset) begin
    if(reset)
        cs <= IDLE;
    else
        cs <= ns;
end
//==========================singal==================================
always @(posedge clk or posedge reset) begin
    if(reset)
        busy <= 0;
    else if(ready == 1)
        busy <= 1;
    else if(ns == Finish)
        busy <= 0;
end    
always @(*) begin
    case(cs)
		IDLE : begin
			csel = 3'b000;
			cwr = 0;
			crd = 0;
		end
		Convolution_state : begin
			csel = 3'b000;
			cwr = 0;
			crd = 0;
		end
		Output_consum_state : begin
			csel = 3'b000;
			cwr = 0;
			crd = 0;
		end
		ReLU_state : begin
			cwr = 1;
			crd = 0;
			csel = 3'b001;
		end
		Max_pooling : begin
			csel = 3'b001;
			cwr = 0;
			crd = 1;
		end
		Write_max_pooling : begin
			csel = 3'b011;
			cwr = 1;
			crd = 0;
		end
		Out_pooling : begin
			csel = 3'b101;
			cwr = 1;
			crd = 0;
		end
		Convolution_state_L1 : begin
			csel = 3'b000;
			cwr = 0;
			crd = 0;
		end
		Output_consum_state_L1 : begin
			csel = 3'b000;
			cwr = 0;
			crd = 0;
		end
		ReLU_state_L1 : begin
			cwr = 1;
			crd = 0;
			csel = 3'b010;
		end
		Max_pooling_L1 : begin
			csel = 3'b010;
			cwr = 0;
			crd = 1;
		end
		Write_max_pooling_L1 : begin
			csel = 3'b100;
			cwr = 1;
			crd = 0;
		end
		Out_pooling_L1 : begin
			csel = 3'b101;
			cwr = 1;
			crd = 0;
		end
		default : begin
			csel = 3'd000;
			cwr = 0;
			crd = 0;
		end
	endcase
end    
//==========================input_addr==================================
always @(posedge clk or posedge reset) begin
	if(reset)
		iaddr <= 12'b0;
	else if(cs == Convolution_state || cs == Convolution_state_L1) begin
		case(conv_count)
			0: iaddr <= {y - 6'd1, x - 6'd1};
			1: iaddr <= {y - 6'd1, x};
			2: iaddr <= {y - 6'd1, x + 6'd1};
			3: iaddr <= {y, x - 6'd1};
			4: iaddr <= {y, x};
			5: iaddr <= {y, x + 6'd1};
			6: iaddr <= {y + 6'd1, x - 6'd1};
			7: iaddr <= {y + 6'd1, x};
			8: iaddr <= {y + 6'd1, x + 6'd1};
			default :
				iaddr <= 12'd0;
		endcase
	end
end
//==========================input_data==================================
//idata_buffer
always @(posedge clk or posedge reset) begin
	if(reset)
		idata_buffer <= 20'd0;
	else begin
		case(conv_count)
			1: idata_buffer <= (y == 0 || x == 0) ? 20'd0 : idata;
			2: idata_buffer <= (y == 0) ? 20'd0 : idata;
			3: idata_buffer <= (y == 0 || x == 63) ? 20'd0 : idata;
			4: idata_buffer <= (x == 0) ? 20'd0 : idata;
			5: idata_buffer <= idata;
			6: idata_buffer <= (x == 63) ? 20'd0 : idata;
			7: idata_buffer <= (y == 63 || x == 0) ? 20'd0 : idata;
			8: idata_buffer <= (y == 63) ? 20'd0 : idata;
			9: idata_buffer <= (y == 63 || x == 63) ? 20'd0 : idata;
			default :
				idata_buffer <= 20'b0;
		endcase
	end
end

//==========================x, y_count==================================
always @(posedge clk or posedge reset) begin
    if(reset) begin
        x <= 0;
        y <= 0;
    end
    else if(cs == ReLU_state || cs == ReLU_state_L1) begin
        if(x == 63) begin
            y <= y + 1;
            x <= 0;
        end
        else
            x <= x + 1;
    end
end
//=========================convolution=====================================
//convolution_temp1
always @(posedge clk or posedge reset) begin
	if(reset)
		convolution_temp1[0] <= 20'd0;
	else if(cs == Convolution_state)
		case(conv_count)
			2 : convolution_temp1[0] <= idata_buffer * kernel0[0];
			3 : convolution_temp1[1] <= idata_buffer * kernel0[1];
			4 : convolution_temp1[2] <= idata_buffer * kernel0[2];
			5 : convolution_temp1[3] <= idata_buffer * kernel0[3];
			6 : convolution_temp1[4] <= idata_buffer * kernel0[4];
			7 : convolution_temp1[5] <= idata_buffer * kernel0[5];
			8 : convolution_temp1[6] <= idata_buffer * kernel0[6];
			9 : convolution_temp1[7] <= idata_buffer * kernel0[7];
			10 : convolution_temp1[8] <= idata_buffer * kernel0[8];
			default : begin
				convolution_temp1[0] <= 40'd0;
				convolution_temp1[1] <= 40'd0;
				convolution_temp1[2] <= 40'd0;
				convolution_temp1[3] <= 40'd0;
				convolution_temp1[4] <= 40'd0;
				convolution_temp1[5] <= 40'd0;
				convolution_temp1[6] <= 40'd0;
				convolution_temp1[7] <= 40'd0;
				convolution_temp1[8] <= 40'd0;
			end
		endcase
	else if(cs == Convolution_state_L1)
		case(conv_count)
			2 : convolution_temp1[0] <= idata_buffer * kernel1[0];
			3 : convolution_temp1[1] <= idata_buffer * kernel1[1];
			4 : convolution_temp1[2] <= idata_buffer * kernel1[2];
			5 : convolution_temp1[3] <= idata_buffer * kernel1[3];
			6 : convolution_temp1[4] <= idata_buffer * kernel1[4];
			7 : convolution_temp1[5] <= idata_buffer * kernel1[5];
			8 : convolution_temp1[6] <= idata_buffer * kernel1[6];
			9 : convolution_temp1[7] <= idata_buffer * kernel1[7];
			10 : convolution_temp1[8] <= idata_buffer * kernel1[8];
			default : begin
				convolution_temp1[0] <= 40'd0;
				convolution_temp1[1] <= 40'd0;
				convolution_temp1[2] <= 40'd0;
				convolution_temp1[3] <= 40'd0;
				convolution_temp1[4] <= 40'd0;
				convolution_temp1[5] <= 40'd0;
				convolution_temp1[6] <= 40'd0;
				convolution_temp1[7] <= 40'd0;
				convolution_temp1[8] <= 40'd0;
			end
		endcase
end
/*
always @(*) begin
	if(cs == Convolution_state)
		case(conv_count)
			2 : convolution_temp1[0] = idata_buffer * kernel0[0];
			3 : convolution_temp1[1] = idata_buffer * kernel0[1];
			4 : convolution_temp1[2] = idata_buffer * kernel0[2];
			5 : convolution_temp1[3] = idata_buffer * kernel0[3];
			6 : convolution_temp1[4] = idata_buffer * kernel0[4];
			7 : convolution_temp1[5] = idata_buffer * kernel0[5];
			8 : convolution_temp1[6] = idata_buffer * kernel0[6];
			9 : convolution_temp1[7] = idata_buffer * kernel0[7];
			10 : convolution_temp1[8] = idata_buffer * kernel0[8];
			default : begin
				convolution_temp1[0] = 40'd0;
				convolution_temp1[1] = 40'd0;
				convolution_temp1[2] = 40'd0;
				convolution_temp1[3] = 40'd0;
				convolution_temp1[4] = 40'd0;
				convolution_temp1[5] = 40'd0;
				convolution_temp1[6] = 40'd0;
				convolution_temp1[7] = 40'd0;
				convolution_temp1[8] = 40'd0;
			end
		endcase
	else if(cs == Convolution_state_L1)
		case(conv_count)
			2 : convolution_temp1[0] = idata_buffer * kernel1[0];
			3 : convolution_temp1[1] = idata_buffer * kernel1[1];
			4 : convolution_temp1[2] = idata_buffer * kernel1[2];
			5 : convolution_temp1[3] = idata_buffer * kernel1[3];
			6 : convolution_temp1[4] = idata_buffer * kernel1[4];
			7 : convolution_temp1[5] = idata_buffer * kernel1[5];
			8 : convolution_temp1[6] = idata_buffer * kernel1[6];
			9 : convolution_temp1[7] = idata_buffer * kernel1[7];
			10 : convolution_temp1[8] = idata_buffer * kernel1[8];
			default : begin
				convolution_temp1[0] = 40'd0;
				convolution_temp1[1] = 40'd0;
				convolution_temp1[2] = 40'd0;
				convolution_temp1[3] = 40'd0;
				convolution_temp1[4] = 40'd0;
				convolution_temp1[5] = 40'd0;
				convolution_temp1[6] = 40'd0;
				convolution_temp1[7] = 40'd0;
				convolution_temp1[8] = 40'd0;
			end
		endcase
end
*/
always @(*) begin
	if(cs == Output_consum_state || cs == Output_consum_state_L1)
		convolution_sum1 = convolution_temp1[0] + convolution_temp1[1] + convolution_temp1[2] + convolution_temp1[3] + convolution_temp1[4] +
                    		convolution_temp1[5] + convolution_temp1[6] + convolution_temp1[7] + convolution_temp1[8];
	else
		convolution_sum1 = 44'd0;
end
always @(*) begin
	if(cs == Output_consum_state)
		convolution_sum = convolution_sum1 + kparameter0;
	else if(cs == Output_consum_state_L1)
		convolution_sum = convolution_sum1 + kparameter1;
	else
		convolution_sum = 44'd0;
end
//conv_count
always @(posedge clk or posedge reset) begin
    if(reset)
        conv_count <= 0;
    else if(cs == Convolution_state || cs == Convolution_state_L1)
        if(conv_count == 10)
            conv_count <= 0;
        else
            conv_count <= conv_count + 1;
    else
        conv_count <= 0;
end
//=========================ReLU=====================================
//REconvolution_sum1
always @(posedge clk or posedge reset) begin
	if(reset)
		REconvolution_sum1 <= 44'd0;
	else if(cs == Output_consum_state || cs == Output_consum_state_L1)
		if(convolution_sum[43] == 1)
			REconvolution_sum1 <= 44'd0;
		else
			REconvolution_sum1 <= convolution_sum;
	else
		REconvolution_sum1 <= 44'd0;
end
//cdata_wrL0, L1
always @(*) begin
	if(cs == ReLU_state || cs == ReLU_state_L1)
		if(REconvolution_sum1[15] == 1)
			cdata_wr = REconvolution_sum1[35:16] + 20'd1;
		else
			cdata_wr = REconvolution_sum1[35:16];
	else if(cs == Write_max_pooling || cs == Write_max_pooling_L1 || cs == Out_pooling || cs == Out_pooling_L1)
		cdata_wr = max_temp;
	else
		cdata_wr = 20'd0;
end
//caddr_wrL0, L1
always @(*) begin
	if(cs == ReLU_state || cs == ReLU_state_L1)
		caddr_wr = {y, x};
	else if(cs == Write_max_pooling || cs == Write_max_pooling_L1)
		caddr_wr = i;
	else if(cs == Out_pooling)
		caddr_wr = flatten_addr;
	else if(cs == Out_pooling_L1)
		caddr_wr = flatten_addr_L1;
	else
		caddr_wr = 12'd0;
end
//=========================max_pooling=====================================
//max_pooling_data_r
always @(posedge clk or posedge reset) begin
	if(reset) begin
		max_temp <= 20'd0;
		max_temp0 <= 20'd0;
		max_temp1 <= 20'd0;
	end
	else if(cs == Max_pooling || cs == Max_pooling_L1)
		case(max_pooling_count)
			1 : max_temp <= cdata_rd;
			2 : max_temp0 <= (cdata_rd >= max_temp) ? cdata_rd : max_temp;
			3 : max_temp <= cdata_rd;
			4 : max_temp1 <= (cdata_rd >= max_temp) ? cdata_rd : max_temp;
			5 : max_temp <= (max_temp0 >= max_temp1) ? max_temp0 : max_temp1;
			default : begin
				max_temp <= 20'd0;
				max_temp0 <= 20'd0;
				max_temp1 <= 20'd0;
			end
		endcase
end
/*
always @(*) begin
	if(cs == Max_pooling || cs == Max_pooling_L1)
		case(max_pooling_count)
			1 : max_temp = cdata_rd;
			2 : max_temp0 = (cdata_rd >= max_temp) ? cdata_rd : max_temp;
			3 : max_temp = cdata_rd;
			4 : max_temp1 = (cdata_rd >= max_temp) ? cdata_rd : max_temp;
			5 : max_temp = (max_temp0 >= max_temp1) ? max_temp0 : max_temp1;
			default : begin
				max_temp = 20'd0;
				max_temp0 = 20'd0;
				max_temp1 = 20'd0;
			end
		endcase
	else begin
		//max_temp = 20'd0;
		max_temp0 = 20'd0;
		max_temp1 = 20'd0;
	end	
end
*/
//max_pooling_addr_r
always @(*) begin
	if(cs == Max_pooling || Max_pooling_L1)
		case(max_pooling_count)
			1 : caddr_rd = {yp - 6'd1, xp - 6'd1};
			2 : caddr_rd = {yp - 6'd1, xp};
			3 : caddr_rd = {yp, xp - 6'd1};
			4 : caddr_rd = {yp, xp};
			default :
				caddr_rd = 12'b0;
		endcase
end
always @(posedge clk or posedge reset) begin
	if(reset)
		i <= 6'd0;
	else if(cs == Write_max_pooling || cs == Write_max_pooling_L1)
		if(i == 10'd1023)
			i <= 0;
		else
			i <= i + 1;
end
//==========================max_pooling_count==================================
always @(posedge clk or posedge reset) begin
	if(reset)
		max_pooling_count <= 0;
	else if(cs == Max_pooling || cs == Max_pooling_L1)
		if(max_pooling_count == 5)
			max_pooling_count <= 0;
		else
			max_pooling_count <= max_pooling_count + 1;
	else
		max_pooling_count <= 0;
end
//==========================xp, yp_count==================================
always @(posedge clk or posedge reset) begin
	if(reset) begin
		xp <= 1;
		yp <= 1;
	end
	else if(cs == Out_pooling || cs == Out_pooling_L1)
		if(xp == 63) begin
			yp <= yp + 2;
			xp <= 1;
		end
		else
			xp <= xp + 2;
end
//==========================flatten==================================
always @(posedge clk or posedge reset) begin
	if(reset)
		flatten_addr <= 12'd0;
	else if(cs == Out_pooling)
		flatten_addr <= flatten_addr + 12'd2;
end
always @(posedge clk or posedge reset) begin
	if(reset)
		flatten_addr_L1 <= 12'd1;
	else if(cs == Out_pooling_L1)
		flatten_addr_L1 <= flatten_addr_L1 + 12'd2;
end
endmodule