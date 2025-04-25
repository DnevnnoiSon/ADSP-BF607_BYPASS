#include "sport.h"
//#include "asm_def.h"
#include "defBF607.h"

#include "lmx2571.h"

#define BITM_LMX_REG0_RESET	0x1000




.SECTION data1
.ALIGN 4;

/*====== ������������� LMX2571 ======*/
.SECTION program
.ALIGN 4;
.GLOBAL _LMX2571_Init;
_LMX2571_Init:
	[--SP] = RETS;
/* �����: [R/W - 1���] [Addr - 7 ���] [Data - 16���] */
/* LMX2571 Reg R0 = 0x00 */
	R0 = BITM_LMX_REG0_RESET(Z);
	

	//����������� ���������� �� ����


	//����� ������ ������
	
	
_LMX2571_Init.exit:
	RETS = [SP++];
	RTS;
_LMX2571_Init.end:
