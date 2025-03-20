#include "defBF607.h"
#include "SystClock.h"

.GLOBAL _Check_temp_SystClock;
.GLOBAL _Set_Kofficient;
.GLOBAL _Change_PLL_Frequency;

// R0 - ������������ �������
// R1 - �������� �����
#define  REG_SET_MASKAND(Reg1, Reg2) 	Reg2 = Reg1 & Reg2  //AND MASK								
#define  REG_SET_MASKOR(Reg1, Reg2)		Reg2 = Reg1 | Reg2  //OR MASK
						
												
.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	//�������� �������� ��������� CGU_STAT:
	 R0 = 1;
	 CALL _Check_temp_SystClock;
	 	
	//��������� ������������ �������:
	 CALL _Set_Kofficient;
	 
    //��������� ������� PLL:
     CALL _Change_PLL_Frequency;
    
    //�������� ���������� ��������:
     R0 = 0;
     CALL _Check_temp_SystClock;
	 RTS;
_SystClock.error:
//����� ����� ������
//...
//��������� ������
	RTS; 
_SystClock.end:


//================= �������� �������� ��������� ===================
//����������: R0 - ������� ���������� �� ��������� �����
.GLOBAL _Check_temp_SystClock;	
.SECTION program
.ALIGN 4;
_Check_temp_SystClock:
	R3 = R0;	//�������� ������ ��������� �����
_Check_temp_SystClock.Start:
    P0.L =  LO(REG_CGU0_STAT);	
    P0.H =  HI(REG_CGU0_STAT);
	R0 = [P0];
//============ ��������� ����� =================
	R1.L = LO(BITM_CGU_STAT_PLLEN);	
	R1.H = HI(BITM_CGU_STAT_PLLEN);
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//============ ��������� ����� =================	
	R1.L = LO(BITM_CGU_STAT_PLOCK);
	R1.H = HI(BITM_CGU_STAT_PLOCK);
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//=========== ����� ��������� ����� ============================
	R1 = 0(Z);
	CC = R3 == R1;
	IF CC JUMP _Check_temp_SystClock.PLLBP;
//============ ��������� ����� =================
_Check_temp_SystClock.PLOCKERR:
	R1.L = LO(BITM_CGU_STAT_PLOCKERR);	
	R1.H = HI(BITM_CGU_STAT_PLOCKERR);	
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//============ ��������� ����� =================	
	JUMP _Check_temp_SystClock.CLKSALGN;
_Check_temp_SystClock.PLLBP:
	R1.L = LO(BITM_CGU_STAT_PLLBP);	
	R1.H = HI(BITM_CGU_STAT_PLLBP);	
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//===============================================================
//============ ��������� ����� =================
_Check_temp_SystClock.CLKSALGN:
	R1.L = LO(BITM_CGU_STAT_CLKSALGN);	
	R1.H = HI(BITM_CGU_STAT_CLKSALGN);	
	REG_SET_MASKAND(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
	
	[P0] = R0;
	RTS;
_Check_temp_SystClock.end:

//================ ��������� ������� ������� ===================
.GLOBAL _Set_Kofficient;	
.SECTION program
.ALIGN 4;
_Set_Kofficient:
//============= ���������� PLL =======================
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
   
    R0 = [P0];
    BITCLR(R0, BITP_CGU_STAT_PLLEN);	
    [P0] = R0; 
//=== ��������� ������������� �������/���������� =====
	P0.L = LO(REG_CGU0_DIV);
    P0.H = HI(REG_CGU0_DIV);
	R0 = [P0];
	//���������:
	R1 = ((40 << BITP_CGU_CTL_MSEL)
	    | ( 2 << BITP_CGU_CTL_DF)
	    | ( 1 << BITP_CGU_DIV_CSEL));
	R0 = R0 | R1; 
	[P0] = R0; 
//============= ��������� PLL =======================	
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    
    R0 = [P0];
    BITSET(R0, BITP_CGU_STAT_PLLEN);	
    [P0] = R0;
//============= �������� ������������ ===============
_Set_Kofficient.WaitPLOCK:
    P0.L = LO(REG_CGU0_STAT);
    P0.H = HI(REG_CGU0_STAT);
    R0 = [P0];
    
    R1.L = LO(BITM_CGU_STAT_PLOCK);
    R1.H = HI(BITM_CGU_STAT_PLOCK);
    REG_SET_MASKOR(R0, R1);
    CC = R0 == R1;
//����� �� ������ ��������:
    IF !CC JUMP _Set_Kofficient.WaitPLOCK;
    
	RTS;
_Set_Kofficient.end:

//================ ��������� ������� PLL ===================
.GLOBAL _Change_PLL_Frequency;
.SECTION program
.ALIGN 4;
_Change_PLL_Frequency:
 
    RTS; 
_Change_PLL_Frequency.end:



