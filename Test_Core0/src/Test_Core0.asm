.EXTERN _adi_initpinmux;
.EXTERN _adi_core_enable;

.EXTERN _GPIO_Control;
.EXTERN _GPIO_Triger_Overflow;
.EXTERN _Trigger_Init;
.EXTERN _Timer0_Init;
.EXTERN _Timer_Run;
.EXTERN _Timer0_Overflow;
.EXTERN _SystClock;
.EXTERN _SEC_Init;

.SECTION L1_code;
.ALIGN 4;
.GLOBAL _main;
_main:
_main.Init:	
	CALL _SystClock;
	
	CALL _Timer0_Init;
	
	CALL _SEC_Init;
	
	CALL _GPIO_Control;
	
	CALL _Trigger_Init; 
	
	//CALL _Timer_Run;
	
_main.Loop:
	//�� ����������� �����:
	
//������ �� ������ ����� �������� ��. �������: 
    //CALL _Timer0_Overflow;
    
//������ �� ������ ����� ������������ �������: 
	//CALL _GPIO_Triger_Overflow;
	
	JUMP _main.Loop;
_main.end: 
/* � sec.asm - ���������� ������ �� ���������� �� ������� */
