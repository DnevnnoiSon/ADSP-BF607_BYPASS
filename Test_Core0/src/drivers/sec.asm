#include "defBF607.h"
#include "timer.h"
#include "sec.h"

.EXTERN _Timer0_ISR;

#define ld32(R,value) 				R##.L = LO(value); R##.H = HI(value)						
#define ldAddr(P, value)			P##.L = 0; P##.H = HI(value)

.SECTION program
.ALIGN 4;
.GLOBAL _SEC_Init;	
/* ��������: [EVENT <==> _sec_dispetcher] */
_SEC_Init:
	ldAddr(P0,REG_SEC0_GCTL);      
	                        
     R0 = ENUM_SEC_GCTL_EN;	  //��������� SEC
    [P0+LO(REG_SEC0_GCTL)] = R0;   
     
    R0 = ENUM_SEC_CCTL_EN;    //���������� ���������� �� ����
    [P0 + LO(REG_SEC0_CCTL0)] = R0;     
                            
// ����������� ��������� � �������� ����������:
	R0 =(0<<BITP_SEC_SCTL_CTG)                      
          | ENUM_SEC_SCTL_SRC_EN
          | ENUM_SEC_SCTL_INT_EN;      
// C������������ ��������� � ��������������� SCI:                
    [P0+LO(REG_SEC0_SCTL12)] = R0; 
    [P0+LO(REG_SEC0_SCTL23)] = R0; 
                 
_SEC_Init.exit:
	RTS;	
_SEC_Init.end:

//===== ����������(���������) ������� ������ ===================
.GLOBAL __sec_int_dispatcher;
__sec_int_dispatcher:
//���������� ���������:
	[--sp] = (R7:0, P5:0);
	[--sp] = ASTAT;
    [--sp] = RETS;
//ID �������� ����������:
	ldAddr(P5, REG_SEC0_CSID0);
	R7 = [P5 + LO(REG_SEC0_CSID0)];	
	[p5+lo(REG_SEC0_CSID0)] = r7; 
	
__sec_int_dispatcher.timer:																		
	//���������� �� TIM0?
	R0 = INTR_TIMER0_TMR0;
	CC = R7 == R0;
	IF !CC JUMP __sec_int_dispatcher.exit; 
	//���������� (TIM0) �������� ������:
	CALL _Timer0_ISR;
	
	JUMP __sec_int_dispatcher.exit;
//.....	
__sec_int_dispatcher.exit:
    //������������� ��������� ����������:       	
	W[P5 + LO(REG_SEC0_END)] = R7;
	
	RETS = [sp++];
	ASTAT = [sp++];
	(R7:0, P5:0) = [sp++];	
	RTI;
__sec_int_dispatcher.end:


