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
//////信号整合
//信号太多了，反正valid和ready信号基本上一起变的，所以写在一起了
wire conv_icb_cmd_rd    = conv_icb_cmd_valid & conv_icb_cmd_ready & conv_icb_cmd_read;
wire conv_icb_cmd_wr    = conv_icb_cmd_valid & conv_icb_cmd_ready & (~conv_icb_cmd_read);
/* //cmd_read和rsp_valid等信号可能是异步的，所以应该只要rsp就行了
wire conv_icb_rsp_rd    = conv_icb_rsp_valid & conv_icb_rsp_ready & conv_icb_cmd_read;
wire conv_icb_rsp_wr    = conv_icb_rsp_valid & conv_icb_rsp_ready & (~conv_icb_cmd_read);
*/
wire conv_icb_rsp       = conv_icb_rsp_valid & conv_icb_rsp_ready;
//////计算所需buffer/reg
parameter SIZE = 16;

reg signed [7:0] input_data     [1:4]; //每次输入4*8bit的数据 分别是123行和234行，所以需要4个输入，23行复用
reg signed [7:0] output_data    [1:4]; //每次输出4*8bit的数据 存疑

reg signed [7:0] input_slice    [1:3][1:4]; //input_slice组成一个完整的3*3输入
reg signed [7:0] weight_slice   [1:16][1:3][1:3]; 
reg signed [7:0] output_slice   [1:16][1:6];

//////状态机控制
parameter IDLE = 2'b00;
parameter RWGT = 2'b01;
parameter RINP = 2'b10;
parameter WOUT = 2'b11;

reg [1:0] present;
//reg [1:0] next;
//present控制
/*
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
*/
//next控制
always @(*)
begin
    if(!rst_n)
    begin
        present <= 2'b00;
    end
    else
    begin
        case(present)
        IDLE : if (start) present <= RWGT; else present <= present;
        RWGT : if (rwgt_rsp_done) present <= RINP; else present <= present;
        RINP : if (rinp_rsp_done) present <= WOUT; else present <= present;
        WOUT ：
            if (wout_row_done && ~wout_all_done) 
                present <= RINP;
            else if (wout_all_done) 
                present <= IDLE;
            else
                present <= present; 
        default : present <= present;
    end
end
//流程计数
//发送和接收应该是两回事情，一个负责控制发送的valid等信号，一个负责维护自身状态机
reg [ 5:0] wgt_cmd_cnt; // 16*9/4=36
reg [ 5:0] wgt_rsp_cnt; // 16*9/4=36
reg [ 9:0] inp_cmd_cnt; // 32/2*34=544
reg [ 9:0] inp_rsp_cnt; // 32/2*34=544
reg [13:0] out_cmd_cnt; // 32/2*32*16=8192
reg [13:0] out_rsp_cnt; // 32/2*32*16=8192
//weight计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wgt_cmd_cnt <= 6'b0;
    else if (wgt_cmd_cnt == 6'd36)
        wgt_cmd_cnt <= 6'b0;
    else if (present == RWGT && conv_icb_cmd_rd)
        wgt_cmd_cnt <= wgt_cmd_cnt + 1'b1;
    else
        wgt_cmd_cnt <= wgt_cmd_cnt;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wgt_rsp_cnt <= 6'b0;
    else if (wgt_rsp_cnt == 6'd36)
        wgt_rsp_cnt <= 6'b0;
    else if (present == RWGT && conv_icb_rsp)
        wgt_rsp_cnt <= wgt_rsp_cnt + 1'b1;
    else
        wgt_rsp_cnt <= wgt_rsp_cnt;
end
//read weight完成
wire rwgt_cmd_done;
assign rwgt_cmd_done = (wgt_cmd_cnt == 6'd36);
wire rwgt_rsp_done;
assign rwgt_rsp_done = (wgt_rsp_cnt == 6'd36);
//input计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        inp_cmd_cnt <= 10'b0;
    else if (inp_cmd_cnt == 10'd544)
        inp_cmd_cnt <= 10'b0;
    else if (present == RINP && conv_icb_cmd_rd)
        inp_cmd_cnt <= inp_cmd_cnt + 1;
    else
        inp_cmd_cnt <= inp_cmd_cnt; 
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        inp_rsp_cnt <= 10'b0;
    else if (inp_rsp_cnt == 10'd544)
        inp_rsp_cnt <= 10'b0;
    else if (present == RINP && conv_icb_rsp)
        inp_rsp_cnt <= inp_rsp_cnt + 1;
    else
        inp_rsp_cnt <= inp_rsp_cnt; 
end
//read input完成
wire rinp_cmd_done;
assign rinp_cmd_done = (inp_cmd_cnt == 10'd544);
wire rinp_rsp_done;
assign rinp_rsp_done = (inp_rsp_cnt == 10'd544);
//output计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        out_cmd_cnt <= 14'b0;
    else if (out_cmd_cnt == 14'b8192)
        out_cmd_cnt <= 14'b0;
    else if (present == WOUT && conv_icb_cmd_wr)
        out_cmd_cnt <= out_cmd_cnt + 1;
    else 
        out_cmd_cnt <= out_cmd_cnt;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        out_rsp_cnt <= 14'b0;
    else if (out_rsp_cnt == 14'b8192)
        out_rsp_cnt <= 14'b0;
    else if (present == WOUT && conv_icb_rsp)
        out_rsp_cnt <= out_rsp_cnt + 1;
    else 
        out_rsp_cnt <= out_rsp_cnt;
end
//write output完成
wire wout_cmd_all_done;
wire wout_rsp_all_done;
wire wout_cmd_row_done;
wire wout_rsp_row_done;
assign wout_cmd_row_done = (out_cmd_cnt[7:0] == 5'd00) && conv_icb_cmd_wr; //行上执行2*16*32/4=256
assign wout_rsp_row_done = (out_rsp_cnt[7:0] == 5'd00) && conv_icb_rsp;
assign wout_cmd_all_done = (out_cmd_cnt == 14'd8192) && conv_icb_cmd_wr;//数据全部存储完毕
assign wout_rsp_all_done = (out_rsp_cnt == 14'd8192) && conv_icb_rsp;
//全部计算完成
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        done <= 1'b0;
    else if (wout_rsp_all_done)
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
