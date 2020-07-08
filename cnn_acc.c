// See LICENSE for license details.
#include <stdio.h> 
#include "encoding.h"
#include "platform.h"
#include "headers/bits.h"

#define CNN_CTRL_ADDR           _AC(0x10040000,UL)
#define CNN_REG(offset)        _REG32(CNN_CTRL_ADDR, offset)

int main(void)
{
  printf("start conv\n");
  CNN_REG(0)=0x00000001;

  int t=1;
  int m=0;
  int p=0;
  
  return 0;
}


