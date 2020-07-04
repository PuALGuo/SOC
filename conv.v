module conv();

parameter SIZE = 16;

reg signed [7:0] input_data     [1:4]; //每次输入4*8bit的数据
reg signed [7:0] output_data    [1:4]; //每次输入4*8bit的数据

reg signed [7:0] input_slice    [1:3][1:4]; //input_slice组成一个完整的3*3输入
reg signed [7:0] weight_slice   [1:16][1:3][1:3];
reg signed [7:0] output_slice   [1:16][1:6];

reg [1:0] cnt;
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

generate 
    for (gv_i = 1; gv_i <=4; gv_i = gv_i +1)
    begin : reg_shift
        always@(posedge clk or posedge reset)
        begin
            if(reset)
            begin//寄存器清零
                input_slice [1][gv_i] <= 8'b0;
                input_slice [2][gv_i] <= 8'b0;
                input_slice [3][gv_i] <= 8'b0;
                input_slice [4][gv_i] <= 8'b0;
            end
            else if(rvalid)
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

always@(posedge clk or posedge reset)
begin
    if(reset)
        cnt <= 2'b0;
    else if(rvalid)
    begin
        
    end
