//地址定义
`define CONV_CTRL_ADDR 32'h0            //可读可写
`define CONV_STAT_ADDR 32'h4            //只读
`define CONV_BASE_ADDR 32'h10040000     //基地址，原先的AXI设备地址
// 结果不会直接传给host，而是保存到专门的sram中，因此没有结果地址定义
// 同理，也么有input和weight

module conv_top 
(
    input                      clk,
    input                      rst_n,
// conv2mem的控制信号
    output                     conv_icb_cmd_valid,
    input                      conv_icb_cmd_ready,
    output  [32-1:0]           conv_icb_cmd_addr,
    output                     conv_icb_cmd_read,
    output  [32-1:0]           conv_icb_cmd_wdata,
    output  [4-1:0]            conv_icb_cmd_wmask,

    input                      conv_icb_rsp_valid,
    output                     conv_icb_rsp_ready,
    input [32-1:0]             conv_icb_rsp_rdata,
// host2conv的控制信号
    input                       conv_ctrl_icb_cmd_valid,
    output                      conv_ctrl_icb_cmd_ready,
    input  [32-1:0]             conv_ctrl_icb_cmd_addr,
    input                       conv_ctrl_icb_cmd_read,
    input  [32-1:0]             conv_ctrl_icb_cmd_wdata,
    input  [4-1:0]              conv_ctrl_icb_cmd_wmask,

    output reg                  conv_ctrl_icb_rsp_valid,
    input                       conv_ctrl_icb_rsp_ready,
    output reg [32-1:0]         conv_ctrl_icb_rsp_rdata
);
//ctrl信号识别
//0 stop
//1 start
reg [7:0] ctrl;
wire start;
assign start = ctrl[0];
//status状态记录
//[0:0] done [] 其他位置还没想好
wire [7:0] status;
wire done;
assign status = {7'b0,done};
//写
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ctrl <= 8'b0;
    else if ((conv_ctrl_icb_cmd_valid & conv_ctrl_icb_cmd_ready & (~conv_ctrl_icb_cmd_read)) && (conv_ctrl_icb_cmd_addr == `CONV_BASE_ADDR + `CONV_CTRL_ADDR))
        ctrl <= conv_ctrl_icb_cmd_wdata[7:0] & {8{conv_ctrl_icb_cmd_wmask[0]}};
    else //STAT只读，不想写err信号了
        ctrl <= ctrl;
end
//读
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        conv_ctrl_icb_rsp_rdata <= 0;
    else if ((conv_ctrl_icb_cmd_valid & conv_ctrl_icb_cmd_ready & conv_ctrl_icb_cmd_read) && (conv_ctrl_icb_cmd_addr == `CONV_BASE_ADDR + `CONV_CTRL_ADDR))
        conv_ctrl_icb_rsp_rdata <= {24'h0,ctrl};
    else if ((conv_ctrl_icb_cmd_valid & conv_ctrl_icb_cmd_ready & conv_ctrl_icb_cmd_read) && (conv_ctrl_icb_cmd_addr == `CONV_BASE_ADDR + `CONV_STAT_ADDR))
        conv_ctrl_icb_rsp_rdata <= {24'h0,status};
    else
        conv_ctrl_icb_rsp_rdata <= conv_ctrl_icb_rsp_rdata;
end
//ready信号就一直高好了
assign conv_ctrl_icb_cmd_ready = 1'b1;
//rsp信号
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        conv_ctrl_icb_rsp_valid <= 1'b0;
    else if ((~conv_ctrl_icb_rsp_valid) && (conv_ctrl_icb_cmd_valid & conv_ctrl_icb_cmd_ready) && ((conv_ctrl_icb_cmd_addr == `CONV_BASE_ADDR + `CONV_STAT_ADDR) || (conv_ctrl_icb_cmd_addr == `CONV_BASE_ADDR + `CONV_CTRL_ADDR)))
        conv_ctrl_icb_rsp_valid <= 1'b1;
    else if (conv_ctrl_icb_rsp_valid && conv_ctrl_icb_rsp_ready)
        conv_ctrl_icb_rsp_valid <= 1'b0;
    else
        conv_ctrl_icb_rsp_valid <= conv_ctrl_icb_rsp_valid;
end
//核心代码例化
conv conv_core(
    .clk(clk),
    .rst_n(rst_n),
    //conv2mems信号
    .conv_icb_cmd_valid(conv_icb_cmd_valid),
    .conv_icb_cmd_ready(conv_icb_cmd_ready),
    .conv_icb_cmd_addr (conv_icb_cmd_addr),
    .conv_icb_cmd_read (conv_icb_cmd_read),
    .conv_icb_cmd_wdata(conv_icb_cmd_wdata),
    .conv_icb_cmd_wmask(conv_icb_cmd_wmask),
    .conv_icb_rsp_valid(conv_icb_rsp_valid),
    .conv_icb_rsp_ready(conv_icb_rsp_ready),
    .conv_icb_rsp_rdata(conv_icb_rsp_rdata),
    //控制信号
    .start(start),
    .done(done)
);
endmodule
