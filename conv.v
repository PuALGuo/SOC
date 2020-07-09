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
    output  reg [32-1:0]       conv_icb_cmd_wdata,
    output  [4-1:0]            conv_icb_cmd_wmask,

    input                      conv_icb_rsp_valid,
    output                     conv_icb_rsp_ready,
    input [32-1:0]             conv_icb_rsp_rdata,
	// control signals
    input start,
    output reg done

);
//将start信号变成边沿信号，方便后续触发
reg old_start;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        old_start <= 0;
    else
        old_start <= start;
end
wire start_rise = start & ~old_start;
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
parameter SIZE = 1;

wire signed [7:0] input_data     [1:4]; //每次输入4*8bit的数据 分别是123行和234行，所以需要4个输入，23行复用
assign input_data[1] = conv_icb_rsp_rdata[ 7: 0];
assign input_data[2] = conv_icb_rsp_rdata[15: 8];
assign input_data[3] = conv_icb_rsp_rdata[23:16];
assign input_data[4] = conv_icb_rsp_rdata[31:24];
//wire signed [7:0] output_data    [1:4]; //每次输出4*8bit的数据 存疑

reg  signed [7:0] input_slice    [1:3][1:4]; //input_slice组成一个完整的3*3输入
reg  signed [7:0] weight_slice   [1:3][1:3]; //一次计算1个channal 
wire signed [7:0] output_slice   [1:6];

//reg signed [7:0] weight [1:16][1:3][1:3]  //权重本身
//assign weight_slice[1:3][1:3] = weight[out_rsp_cnt[13:9]] //算了不预存了
//////状态机控制
parameter IDLE = 2'b00;
parameter RWGT = 2'b01;
parameter RINP = 2'b10;
parameter WOUT = 2'b11;

reg [1:0] present;
wire rwgt_cmd_done;
wire rwgt_rsp_done;
wire rinp_rsp_done;
wire rinp_cmd_done;
wire wout_cmd_all_done;
wire wout_rsp_all_done;
wire wout_cmd_row_done;
wire wout_rsp_row_done;
wire wout_cmd_chn_done;
wire wout_rsp_chn_done;
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
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        present <= 2'b00;
    end
    else
    begin
        case(present)
        IDLE : if (start_rise) present <= RWGT; else present <= present;
        RWGT : if (rwgt_rsp_done) present <= RINP; else present <= present;
        RINP : if (rinp_rsp_done) present <= WOUT; else present <= present;
        WOUT :
            if (wout_rsp_row_done && ~wout_rsp_all_done && ~wout_rsp_chn_done) 
                present <= RINP;
            else if (wout_rsp_chn_done && ~wout_rsp_all_done)
                present <= RWGT;
            else if (wout_rsp_all_done) 
                present <= IDLE;
            else
                present <= present; 
        default : present <= present;
	endcase
    end
end
//流程计数
//发送和接收应该是两回事情，一个负责控制发送的valid等信号，一个负责维护自身状态机
reg [ 5:0] wgt_cmd_cnt; // 16*9/3=48 //每次读3个
reg [ 5:0] wgt_rsp_cnt; // 16*9/3=48
reg [ 9:0] inp_cmd_cnt; // 32/2*34=544
reg [ 9:0] inp_rsp_cnt; // 32/2*34=544
reg [12:0] out_cmd_cnt; // 32*32*16/4=4096 // 前5位代表了当前的channal
reg [12:0] out_rsp_cnt; // 32*32*16/4=4096
//weight计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        wgt_cmd_cnt <= 6'b0;
    else if (wgt_cmd_cnt == 6'd47 && conv_icb_cmd_rd)
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
    else if (wgt_rsp_cnt == 6'd47 && conv_icb_rsp)
        wgt_rsp_cnt <= 6'b0;
    else if (present == RWGT && conv_icb_rsp)
        wgt_rsp_cnt <= wgt_rsp_cnt + 1'b1;
    else
        wgt_rsp_cnt <= wgt_rsp_cnt;
end
//read weight完成
assign rwgt_cmd_done = (wgt_cmd_cnt % 3 == 2) && conv_icb_cmd_rd;
assign rwgt_rsp_done = (wgt_rsp_cnt % 3 == 2) && conv_icb_rsp;
//input计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        inp_cmd_cnt <= 10'b0;
    else if (inp_cmd_cnt == 10'd543 && conv_icb_cmd_rd) 
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
    else if (inp_rsp_cnt == 10'd543 && conv_icb_rsp)
        inp_rsp_cnt <= 10'b0;
    else if (present == RINP && conv_icb_rsp)
        inp_rsp_cnt <= inp_rsp_cnt + 1;
    else
        inp_rsp_cnt <= inp_rsp_cnt; 
end
//read input完成
assign rinp_cmd_done = (inp_cmd_cnt %34 == 33) && conv_icb_cmd_rd;
assign rinp_rsp_done = (inp_rsp_cnt %34 == 33) && conv_icb_rsp;
//output计数控制
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        out_cmd_cnt <= 13'b0;
    else if (out_cmd_cnt == 13'd4095 && conv_icb_cmd_wr)
        out_cmd_cnt <= 13'b0;
    else if (present == WOUT && conv_icb_cmd_wr)
        out_cmd_cnt <= out_cmd_cnt + 1;
    else 
        out_cmd_cnt <= out_cmd_cnt;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        out_rsp_cnt <= 13'b0;
    else if (out_rsp_cnt == 13'd4095 && conv_icb_rsp)
        out_rsp_cnt <= 13'b0;
    else if (present == WOUT && conv_icb_rsp)
        out_rsp_cnt <= out_rsp_cnt + 1;
    else 
        out_rsp_cnt <= out_rsp_cnt;
end
//write output完成
assign wout_cmd_row_done = (out_cmd_cnt[ 3:0] == 4'd15) && conv_icb_cmd_wr; //行上执行2*32/4=16
assign wout_rsp_row_done = (out_rsp_cnt[ 3:0] == 4'd15) && conv_icb_rsp;
assign wout_cmd_chn_done = (out_cmd_cnt[ 7:0] == 8'd255)&& conv_icb_cmd_wr; //chn上执行32*32/4=256
assign wout_rsp_chn_done = (out_rsp_cnt[ 7:0] == 8'd255)&& conv_icb_rsp;
assign wout_cmd_all_done = (out_cmd_cnt == 13'd4095) && conv_icb_cmd_wr;    //数据全部存储完毕
assign wout_rsp_all_done = (out_rsp_cnt == 13'd4095) && conv_icb_rsp;
//wire [5:0] cnl_cnt;
//assign cnl_cnt = out_cmd_cnt[13:9];
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
/*
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
*/
assign output_slice[1] = input_slice[1][1]*weight_slice[1][1] + input_slice[1][2]*weight_slice[1][2] + input_slice[1][3]*weight_slice[1][3];
assign output_slice[2] = input_slice[2][1]*weight_slice[2][1] + input_slice[2][2]*weight_slice[2][2] + input_slice[2][3]*weight_slice[2][3];
assign output_slice[3] = input_slice[3][1]*weight_slice[3][1] + input_slice[3][2]*weight_slice[3][2] + input_slice[3][3]*weight_slice[3][3];
assign output_slice[4] = input_slice[1][2]*weight_slice[1][1] + input_slice[1][3]*weight_slice[1][2] + input_slice[1][4]*weight_slice[1][3];
assign output_slice[5] = input_slice[2][2]*weight_slice[2][1] + input_slice[2][3]*weight_slice[2][2] + input_slice[2][4]*weight_slice[2][3];
assign output_slice[6] = input_slice[3][2]*weight_slice[3][1] + input_slice[3][3]*weight_slice[3][2] + input_slice[3][4]*weight_slice[3][3];
//////卷积核互连传递
genvar gv_i;
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
            end
            else if(present == RINP && conv_icb_rsp)
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
//////weight输入
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
	weight_slice[wgt_rsp_cnt % 3 + 1][1] <= 8'b0;
	weight_slice[wgt_rsp_cnt % 3 + 1][2] <= 8'b0;
	weight_slice[wgt_rsp_cnt % 3 + 1][3] <= 8'b0;
    end
    else if (present == RWGT && conv_icb_rsp)
    begin
        weight_slice[wgt_rsp_cnt % 3 + 1][1] <= input_data[1];
        weight_slice[wgt_rsp_cnt % 3 + 1][2] <= input_data[2];
        weight_slice[wgt_rsp_cnt % 3 + 1][3] <= input_data[2];
    end
    else
    begin
        weight_slice[wgt_rsp_cnt % 3 + 1][1] <= weight_slice[wgt_rsp_cnt % 3 + 1][1];
        weight_slice[wgt_rsp_cnt % 3 + 1][2] <= weight_slice[wgt_rsp_cnt % 3 + 1][2];
        weight_slice[wgt_rsp_cnt % 3 + 1][3] <= weight_slice[wgt_rsp_cnt % 3 + 1][3];
    end
end
//////ICB
//valid
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        conv_icb_cmd_valid <= 1'b0;
    else if (rinp_cmd_done || rwgt_cmd_done || wout_cmd_row_done)
        conv_icb_cmd_valid <= 1'b0;
    else if (rinp_rsp_done || rwgt_rsp_done || start_rise || (wout_rsp_row_done && ~wout_rsp_chn_done) || (wout_rsp_chn_done && ~wout_rsp_all_done))
        conv_icb_cmd_valid <= 1'b1;
    else
        conv_icb_cmd_valid <= conv_icb_cmd_valid;
end
//read
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        conv_icb_cmd_read <= 1'b0;
    else if (rinp_cmd_done || rwgt_cmd_done || wout_cmd_row_done)
        conv_icb_cmd_read <= 1'b0;
    else if (rwgt_rsp_done || start_rise || (wout_rsp_row_done && ~wout_rsp_chn_done) || (wout_rsp_chn_done && ~wout_rsp_all_done))
        conv_icb_cmd_read <= 1'b1;
    else if (rinp_rsp_done)
	conv_icb_cmd_read <= 1'b0;
    else
        conv_icb_cmd_read <= conv_icb_cmd_read;
end
//ready
assign conv_icb_rsp_ready = 1'b1;
//////地址计算
reg [31:0] weight_addr;
reg [31:0] image_addr;
reg [31:0] output_addr;
//其他信号
assign conv_icb_cmd_addr = ((present == RWGT)?weight_addr:((present == RINP)?image_addr:((present == WOUT)? output_addr:32'h0))) & {32{conv_icb_cmd_valid}};
//assign conv_icb_cmd_wdata = output_data;
//assign conv_icb_cmd_wdata = {output_data[1],output_data[2],output_data[3],output_data[4]};
assign conv_icb_cmd_wmask = 4'b1111;
//weight //可能有问题
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        weight_addr <= 32'h0;
    else if(start_rise && wgt_cmd_cnt == 6'h0)
        weight_addr <= `WGT_ADDR;
    else if(present == RWGT && conv_icb_cmd_rd && ~rwgt_cmd_done)
        weight_addr <= `WGT_ADDR + 32'h4 + {wgt_cmd_cnt,2'b0};
    else 
        weight_addr <= weight_addr;
end
//input
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        image_addr <= 32'h0;
    else if (rwgt_rsp_done && inp_cmd_cnt == 10'h0)
        image_addr <= `INP_ADDR;
    else if (present == RINP && conv_icb_cmd_rd && ~rinp_cmd_done) 
        image_addr <= `INP_ADDR + 32'h4 + {inp_cmd_cnt,2'b0};
    else
        image_addr <= image_addr;
end
//output
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        output_addr <= 32'h0;
    else if (rinp_rsp_done && out_cmd_cnt == 13'b0)
        output_addr <= `OUT_ADDR;
    else if (present == WOUT && conv_icb_cmd_wr && ~wout_cmd_row_done)
        output_addr <= `OUT_ADDR + 32'h4 + {out_cmd_cnt,2'b0};
    else
        output_addr <= output_addr;
end
//output_slice 汇聚
reg signed [7:0] output_buffer [1:2][1:32];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        output_buffer[1][(inp_rsp_cnt - 2) % 34] <= 0;
        output_buffer[2][(inp_rsp_cnt - 2) % 34] <= 0;
    end
    //else if (present == RINP && (inp_rsp_cnt % 34 != 2) && (inp_rsp_cnt % 34 != 1) && conv_icb_rsp)
    else if (present == RINP && (inp_rsp_cnt % 34 != 2) && (inp_rsp_cnt % 34 != 1))
    begin
        output_buffer[1][(inp_rsp_cnt - 2) % 34] <= output_slice[1] + output_slice[2] + output_slice[3];
        output_buffer[2][(inp_rsp_cnt - 2) % 34] <= output_slice[4] + output_slice[5] + output_slice[6];
    end
    else
    begin
        output_buffer[1][(inp_rsp_cnt - 2) % 34] <= output_buffer[1][(inp_rsp_cnt - 2) % 34 + 1];
        output_buffer[2][(inp_rsp_cnt - 2) % 34] <= output_buffer[2][(inp_rsp_cnt - 2) % 34 + 1];
    end
end
//output输出
wire [1:0]row_cnt;
assign row_cnt = out_cmd_cnt[3] + 2'b1;
wire [2:0]col_cnt;
assign col_cnt = out_cmd_cnt[2:0];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        conv_icb_cmd_wdata <= 32'b0;
    else if (rinp_rsp_done && out_cmd_cnt == 13'b0)
        conv_icb_cmd_wdata <= {output_buffer[1][1],output_buffer[1][2],output_buffer[1][3],output_buffer[1][4]};
    else if (present == WOUT && conv_icb_cmd_wr)
        conv_icb_cmd_wdata <= {output_buffer[row_cnt][{col_cnt,2'b00} + 1],output_buffer[row_cnt][{col_cnt,2'b00} + 2],output_buffer[row_cnt][{col_cnt,2'b00} + 3],output_buffer[row_cnt][{col_cnt,2'b00} + 4]};
    else
        conv_icb_cmd_wdata <= conv_icb_cmd_wdata;
end
endmodule
