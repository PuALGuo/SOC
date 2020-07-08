#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#include <stdio.h> 
#include "encoding.h"
#include "platform.h"
#include "headers/bits.h"
#include <string.h>
//#include<time.h>
#define N 1
#define C 1
#define H 32
#define W 32
#define I  1
#define O  16
#define KH 3
#define KW 3
#define WGT_ADDR           _AC(0x00002000,UL)
#define WGT(offset)        _REG32(WGT_ADDR, offset)
#define INP_ADDR           _AC(0x40000000,UL)
#define INP(offset)        _REG32(INP_ADDR, offset)
#define OUT_ADDR           _AC(0x60000000,UL)
#define OUT(offset)        _REG32(OUT_ADDR, offset)

//x需要运算的矩阵
//y卷积核
//z
signed char x[N][C][H][W];//需要运算矩阵 
signed char y[I][O][KH][KW];//卷积核 
signed short z[N][O][H][W];
 
void conv2(signed char x[N][C][H][W],signed char y[I][O][KH][KW],signed short z[N][O][H][W])
{
    int i,j,o;
    int ki,kj;
	for(i=0;i<H;i++)
		for(j=0;j<W;j++)
			//C只有1，不循环了吧
			for(o=0;o<O;o++)
			{
				int tmp;
				tmp = 0;
				for(ki=0;ki<KH;ki++)
					if (((ki + i - (KH-1)/2) >= 0) && ((ki + i - (KH-1)/2) < H))
						for(kj=0;kj<KW;kj++)
							if (((kj + j - (KW-1)/2) >= 0) && (((kj + j - (KW-1)/2)) < W))
								tmp += x[0][0][ki + i - (KH-1)/2][kj + j - (KW-1)/2] * y[0][o][ki][kj];
				//relu				
				if (tmp > 127)
					tmp = 127;
				else if (tmp < 0)
					tmp = 0;			
				z[0][o][i][j] = tmp;	
/*			
			if (o % 4 == 3)
			{
				OUT(0) = z[0][o][i][j];
			}		
*/
			}			
}
 
 
int main()
{
	int i,j,p,q;
	srand(0);
	printf("输入需要运算的矩阵：\n");
	int tmp;
	for(i=0;i<N;i++)
	{
		for(j=0;j<C;j++) // 
		{
			for(p=0;p<H;p++)
			{
				for(q=0;q<8;q++)
				{
					tmp = INP(0);
					x[i][j][p][4*q+0] = tmp % 128;
  					x[i][j][p][4*q+1] = (tmp / 128) % 128;
					x[i][j][p][4*q+2] = (tmp /128 /128) % 128;
					x[i][j][p][4*q+3] = (tmp /128 /128 / 128) % 128;
					//printf("%d\t", x[i][j][p][q]);
				}
				//printf("\n");
					tmp = INP(0);
					x[i][j][p][32] = tmp % 128;
  					x[i][j][p][33] = (tmp / 128) % 128;
			}
		}
	}

	printf("输入卷积核：\n");
	for(i=0;i<I;i++)
	{
		for(j=0;j<O;j++)
		{
			for(p=0;p<KH;p++)
			{
					tmp = WGT(0);
					y[i][j][p][0] = tmp % 128;
  					y[i][j][p][1] = (tmp / 128) % 128;
					y[i][j][p][2] = (tmp /128 /128) % 128;
			}
		}
	}
	
	conv2(x,y,z);//卷积运算 
	
	for(i=0;i<H;i++)
		for(j=0;j<W;j++)
			for(int o=0;o<4;o++)
				OUT(0) = z[0][o][i][j];
	printf("I'm ok\n");
	
	return 0;
 } 
