#include "defBF607.h"
#include "SystClock.h"


// R0 - ������������ �������
// R1 - �������� �����
#define  REG_SET_MASKOR(Reg1, Reg2)			Reg1 = Reg1 & Reg2; //OR MASK										
#define  REG_SET_MASKANDK(Reg1, Reg2)		Reg1 = Reg1 | Reg2; //AND MASK
												
.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	//�������� �������� ��������� CGU_STAT:
	 CALL _Check_temp_SystClock;
	 	
	//��������� ������������ �������:
	 CALL _Set_Kofficient;
	 
    //��������� ������� PLL:
	 RTS;
_SystClock.error:
//����� ����� ������
//...
//��������� ������
	RTS; 
_SystClock.end:



//============================================================================
.GLOBAL _Set_Kofficient;	
.SECTION program
.ALIGN 4;
_Set_Kofficient:
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    
    R0 = [P0];
    BITCLR(R0, BITP_CGU_CTL_MSEL);	
    R0 = R0 | 20;
    
    [P0] = R0; 
_Set_Kofficient.wait:
	P0.L = LO(REG_CGU0_STAT);
	P0.L = LO(REG_CGU0_STAT);
	R0 = [P0];
	
	//�������� �������� ���� PLOCK = 1
	CC = BITTST(R0, BITP_CGU_STAT_PLOCK );
	IF CC JUMP _Set_Kofficient.wait;
	
	//��������� ���������:
	 P0.L = LO(CGU_DIV);
     P0.H = HI(CGU_DIV);
     R0 = [P0];
	
	 BITCLR(R0, BITP_CGU_DIV_SYSSEL);
	 R0 = R0 | (4 << 4);
	 [P0] = R0; 
	 
	
_Set_Kofficient.end:



