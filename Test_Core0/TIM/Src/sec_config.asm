#include "defBF607.h"
#include "tim.h"
#include "sec_config.h"

.EXTERN _Timer0_ISR;

#define ld32(R,value) 				R##.L = LO(value); R##.H = HI(value)						
#define ldAddr(P, value)			P##.L = 0; P##.H = HI(value)

.SECTION program
.ALIGN 4;
.GLOBAL _SEC_Init;	// ��������: [EVENT <==> _sec_dispetcher]
_SEC_Init:
	ldAddr(P0,REG_SEC0_GCTL);      
	                        
     R0 = ENUM_SEC_GCTL_EN;	 //��������� SEC
    [P0+LO(REG_SEC0_GCTL)] = R0;   
     
    R0 = ENUM_SEC_CCTL_EN;    //���������� ���������� �� ����
    [P0 + LO(REG_SEC0_CCTL0)] = R0;     
                            
   //����������� ��������� � �������� ����������
	R0 =(0<<BITP_SEC_SCTL_CTG)                      
          | ENUM_SEC_SCTL_SRC_EN
          | ENUM_SEC_SCTL_INT_EN;      
                 
    [P0+LO(REG_SEC0_SCTL12)] = R0;            // C������������ ��������� � ��������������� SCI                

	RTS;	
_SEC_Init.end:

//======================================================================
.SECTION program
.ALIGN 4;
.GLOBAL _SEC_Dispetcher;
_SEC_Dispetcher:
	ldAddr(P5, REG_SEC0_CSID0);
	R5 = [P0 + LO(REG_SEC0_CSID0)];
																		
	//������ ����� ��������:
	//���������� �� TIM0?
	R0 = INTR_TIMER0_TMR0;
	CC = R5 == R0;
	IF !CC JUMP _SEC_Dispetcher.exit; 
	
	CALL _Timer0_ISR;
	
_SEC_Dispetcher.exit:
	//����� ��������� ������� �����
	ldAddr(P5, REG_SEC0_END);  
	[P5 + LO(REG_SEC0_END)] = R5;
	
	RTI;
_SEC_Dispetcher.end:


