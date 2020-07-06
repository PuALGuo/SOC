// See LICENSE for license details.
#include <stdio.h> 
#include "encoding.h"
#include "platform.h"
#include "headers/bits.h"

#define CNN_CTRL_ADDR           _AC(0x10041000,UL)
#define CNN_REG(offset)        _REG32(CNN_CTRL_ADDR, offset)

int main(void)
{

  CNN_REG(0)=0x00000001;

  int t=1;
  int m=0;
  int p=0;
  while (t)
{
  p=p+1;
  m=CNN_REG(1);
  //printf("%d\n",m);
  if(m==1)
        {
        CNN_REG(0)=0x00000000;
        t=0;
        printf("CNN finish!\n");
        }
}
}


