#include "defBF607.h"
#include "SystClock.h"

.GLOBAL _Check_temp_SystClock;
.GLOBAL _Change_PLL_Frequency;

// R0 - ������������ �������
// R1 - �������� �����
#define  REG_SET_MASKAND(Reg1, Reg2) 	Reg2 = Reg2 & Reg1  //AND MASK								
#define  REG_SET_MASKOR(Reg1, Reg2)		Reg2 = Reg1 | Reg2  //OR MASK
																	
.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	[--SP] = RETS;
	//�������� �������� ��������� CGU_STAT:
	 R0 = 1;
	 CALL _Check_temp_SystClock;
	 	
    //��������� ������� PLL:
     CALL _Change_PLL_Frequency;
    
    //�������� ���������� ��������:
     R0 = 0;
     CALL _Check_temp_SystClock;
     
     RETS = [SP++];
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
 _Check_temp_SystClock.PLOCK:
 	R1.L = LO(BITM_CGU_STAT_PLOCK);
	R1.H = HI(BITM_CGU_STAT_PLOCK);
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//=========== ����� ��������� ����� ============================
	R1 = 1(Z);
	CC = R3 == R1;
	IF CC JUMP _Check_temp_SystClock.CLKSALGN;
//============ ��������� ����� =================	
_Check_temp_SystClock.PLLBP:
	R1.L = LO(BITM_CGU_STAT_PLLBP);	
	R1.H = HI(BITM_CGU_STAT_PLLBP);	
	REG_SET_MASKAND(R0, R1);
	CC = R1 == 0;
	IF !CC JUMP _Check_temp_SystClock.Start;
//===============================================================
//============ ��������� ����� =================
_Check_temp_SystClock.CLKSALGN:
	R1.L = LO(BITM_CGU_STAT_CLKSALGN);	
	R1.H = HI(BITM_CGU_STAT_CLKSALGN);	
	REG_SET_MASKAND(R0, R1);
	CC = R1 == 0;
	IF !CC JUMP _Check_temp_SystClock.Start;
	
	[P0] = R0;
	RTS;
_Check_temp_SystClock.end:


//================ ��������� ������������� ��� ������� PLL ===================
.GLOBAL _Change_PLL_Frequency;
.SECTION program
.ALIGN 4;
_Change_PLL_Frequency:
//============= ���������� PLL =======================
	P0.L = LO(REG_CGU0_CTL);	
    P0.H = HI(REG_CGU0_CTL);
//============= ��������� ������ bypass =======================
    R0 = [P0];  
    
    BITCLR(R0, BITP_CGU_STAT_PLLEN);  //����������
    BITSET(R0, BITP_CGU_STAT_PLLBP);  //bypass ON 
    
    [P0] = R0; 
//=== ��������� ������������� �������/���������� =====
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    R0 = [P0];
	// ������� ����� MSEL, DF
	R2 = ~((BITM_CGU_CTL_MSEL) | (BITM_CGU_CTL_DF)); 
	R0 = R0 & R2;
	//���������: 
	R1 = ((40 << BITP_CGU_CTL_MSEL) | ( 1 << BITP_CGU_CTL_DF));    
	R0 = R0 | R1; 
	
	BITCLR(R0, BITP_CGU_CTL_LOCK);  //��� LOCK -> CGU_CTL
	[P0] = R0;
//������� PLL[����] = 480 ���
	
	P0.L = LO(REG_CGU0_DIV);
    P0.H = HI(REG_CGU0_DIV);
	R0 = [P0];
	// ������� ����� SCEL, S0SEL
	R2.H = HI(~((BITM_CGU_DIV_CSEL) | (BITM_CGU_DIV_S0SEL) | (BITM_CGU_DIV_S1SEL) | (BITM_CGU_DIV_SYSSEL)));
	R2.L = LO(~((BITM_CGU_DIV_CSEL) | (BITM_CGU_DIV_S0SEL) | (BITM_CGU_DIV_S1SEL) | (BITM_CGU_DIV_SYSSEL)));
	R0 = R0 & R2;
	//���������: 
	R1.L = LO((( 1 << BITP_CGU_DIV_CSEL)|
	         ( 4 << BITP_CGU_DIV_S0SEL) | 
	         ( 4 << BITP_CGU_DIV_S1SEL) |
	         ( 1 << BITP_CGU_DIV_SYSSEL)));   
	R1.H = HI((( 1 << BITP_CGU_DIV_CSEL)|
	         ( 4 << BITP_CGU_DIV_S0SEL) | 
	         ( 4 << BITP_CGU_DIV_S1SEL) |
	         ( 1 << BITP_CGU_DIV_SYSSEL)));             
	     
	R0 = R0 | R1;
	
	BITSET(R0, BITP_CGU_DIV_UPDT);	//��� UPDT -> CGU_DIV
	[P0] = R0;
//������� �� ������ SOCLK: 120���
//============= ��������� PLL =======================	
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    R0 = [P0];
    //============= ���������� ������ bypass =======================   
    BITCLR(R0, BITP_CGU_STAT_PLLBP);  //bypass OFF (PLLBP = 0)
    BITSET(R0, BITP_CGU_STAT_PLLEN);  //����������
    
    [P0] = R0; 
	
	RTS;
_Change_PLL_Frequency.end:







