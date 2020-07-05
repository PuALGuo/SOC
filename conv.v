
//地址定义
`define WGT_ADDR 32'h0000_2000
`define INP_ADDR 32'h4000_0000
`define OUT_ADDR 32'h6000_0000

module conv
(
    input                      clk,
    input                      rst_n,
	// conv icb signals
    output  reg                conv_icb_cmd_valid,
    input                      conv_icb_cmd_ready,
    output   [32-1:0]          conv_icb_cmd_addr,
    output  reg                conv_icb_cmd_read,
    output   [32-1:0]          conv_icb_cmd_wdata,
    output  [4-1:0]            conv_icb_cmd_wmask,

    input                      conv_icb_rsp_valid,
    output                     conv_icb_rsp_ready,
    input [32-1:0]             conv_icb_rsp_rdata,
	// control signals
    input start,
    output reg done

);

parameter SIZE = 16;

reg signed [7:0] input_data     [1:4]; //每次输入4*8bit的数据 分别是123行和234行，所以需要4个输入，23行复用
reg signed [7:0] output_data    [1:4]; //每次输入4*8bit的数据 存疑

reg signed [7:0] input_slice    [1:3][1:4]; //input_slice组成一个完整的3*3输入
reg signed [7:0] weight_slice   [1:16][1:3][1:3]; 
reg signed [7:0] output_slice   [1:16][1:6];

//////状态机控制
parameter IDLE = 2'b00;
parameter RWGT = 2'b01;
parameter RINP = 2'b10;
parameter WOUT = 2'b11;

reg [1:0] present;
reg [1:0] next;
//present控制
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        present <= 2'b00;
    end
    else 
    begin
        present <= next;    
    end
end
//next控制
always @(*)
begin
    if(!rst_n)
    begin
        next <= 2'b00;
    end
    else
    begin
        case(present)
        IDLE : 
        RWGT :
        RINP :
        WOUT ：
        default : next <= next;
    end
end
//流程计数
reg [5:0] wgt_cnt; // 16*9/4=36
reg [9:0] inp_cnt; // 32/2*34
reg [9:0] out_cnt; // 32/2*32
//weight计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wgt_cnt <= 6'b0;
    else if (wgt_cnt == 6'd36)
        wgt_cnt <= 6'b0;
    else if (present == RWGT)
        wgt_cnt <= wgt_cnt + 1'b1;
    else
        wgt_cnt <= wgt_cnt;
end
//read weight完成
wire rwgt_done;
assign rwgt_done = (wgt_cnt == 6'd36);
//input计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        inp_cnt <= 10'b0;
    else if (inp_cnt == 10'd544)
        inp_cnt <= 10'b0;
    else if (present == RINP)
        inp_cnt <= inp_cnt + 1;
    else
        inp_cnt <= inp_cnt; 
end
//read input完成
wire rinp_done;
assign rinp_done = (inp_cnt == 10'd544);
//output计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        out_cnt <= 10'b0;
    else if (out_cnt == 10'd512)
        out_cnt <= 10'b0;
    else if (present == WOUT)
        out_cnt <= out_cnt + 1;
    else 
        out_cnt <= out_cnt;
end
wire wout_done;
assign wout_done = (out_cnt == 10'd512) //数据全部存储完毕
//全部计算完成
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        done <= 1'b0;
    else if (wout_done)
        done <= 1'b1;
    else
        done <= done; 
end
//////计算流程
genvar gv_i;
generate 
    for (gv_i = 1; gv_i <= SIZE; gv_i = gv_i + 1)
    begin : conv_compute
        assign output_slice[i][1] = input_slice[1][1]*weight_slice[i][1][1] + input_slice[1][2]*weight_slice[i][1][2] + input_slice[1][3]*weight_slice[i][1][3];
        assign output_slice[i][2] = input_slice[2][1]*weight_slice[i][2][1] + input_slice[2][2]*weight_slice[i][2][2] + input_slice[2][3]*weight_slice[i][2][3];
        assign output_slice[i][3] = input_slice[3][1]*weight_slice[i][3][1] + input_slice[3][2]*weight_slice[i][3][2] + input_slice[3][3]*weight_slice[i][3][3];
        assign output_slice[i][4] = input_slice[1][2]*weight_slice[i][1][1] + input_slice[1][3]*weight_slice[i][1][2] + input_slice[1][4]*weight_slice[i][1][3];
        assign output_slice[i][5] = input_slice[2][2]*weight_slice[i][2][1] + input_slice[2][3]*weight_slice[i][2][2] + input_slice[2][4]*weight_slice[i][2][3];
        assign output_slice[i][6] = input_slice[3][2]*weight_slice[i][3][1] + input_slice[3][3]*weight_slice[i][3][2] + input_slice[3][4]*weight_slice[i][3][3];
    end
endgenerate
//////卷积核互连传递
generate 
    for (gv_i = 1; gv_i <=4; gv_i = gv_i +1)
    begin : reg_shift
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin//寄存器清零
                input_slice [1][gv_i] <= 8'b0;
                input_slice [2][gv_i] <= 8'b0;
                input_slice [3][gv_i] <= 8'b0;
                input_slice [4][gv_i] <= 8'b0;
            end
            else if(present == RINP)
            begin
                input_slice [1][gv_i] <= input_data  [gv_i];
                input_slice [2][gv_i] <= input_slice [1][gv_i];
                input_slice [3][gv_i] <= input_slice [2][gv_i];
            end
            else
            begin
                input_slice [1][gv_i] <= input_slice [1][gv_i];
                input_slice [2][gv_i] <= input_slice [2][gv_i];
                input_slice [3][gv_i] <= input_slice [3][gv_i];
            end
        end
    end
endgenerate
//////ICB
//valid
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        conv_icb_cmd_valid <= 1'b0;
    else if (rinp_done || rwgt_done || wout_done)
end
