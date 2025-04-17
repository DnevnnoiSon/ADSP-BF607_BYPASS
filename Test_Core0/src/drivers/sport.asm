#include "asm_def.h"
#include "defBF607.h"
/*========== ��������� ��� ��������� ��� SPI ==================*/
/*=============================================================*/
/*                    ������ [SPORT]                           */
/*=============================================================*/
#include "sport.h"

//PD0
#define SPORT1_A_CS_REG_BITP	BITP_PORT_DATA_PX0
#define SPORT1_A_CS_REG_BITM	(1 << SPORT1_A_CS_REG_BITP)

/* ������������� SPORT1 */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_Init;
_SPORT_Init:
	[--SP] = RETS;
//��������� CS:	
   ldAddr(P0, REG_PORTE_FER);
//GPIO:  
   R0 = BITM_PORT_FER_PX3; 
   [P0 + LO(REG_PORTE_FER)] = R0;
//�� �����:
   R0 = BITM_PORT_POL_PX3; 
   [P0 + LO(REG_PORTE_DIR)] = R0;
   
      
   ldAddr(P0, REG_PORTF_FER);
// ��������� ������ GPIO - OUT:     
    R0 = SPORT1_A_CS_REG_BITM(Z);
    [P0+LO(REG_PORTD_FER_CLR)] = R0;
    [P0+LO(REG_PORTD_DIR_SET)] = R0;
    [P0+LO(REG_PORTD_DATA_SET)] = R0;             
              
    ldAddr(P0, REG_SPORT1_CTL_A);
// ������� ����������� ��������� sport:
    R0 = 0(z);
    [P0+LO(REG_SPORT1_CTL_A)] = R0;
    [P0+LO(REG_SPORT1_MCTL_A)] = R0;                
                                                   
    ld32( R0, ENUM_SPORT_CTL2_CLK_MUX_DIS | ENUM_SPORT_CTL2_FS_MUX_DIS ); //���������������� ������������������ 
                                                                          //�������� CLK � FS: �� �����������������
    [P0+LO(REG_SPORT1_CTL2_A)] = R0;
    
    //������� ������������ CLK = SCLK0 /( 1 + DIV)
    //������� ���������� ������� FS � �������� CLK  
    ld32( R0, (3  << BITP_SPORT_DIV_CLKDIV) | ( 24 << BITP_SPORT_DIV_FSDIV) );              
    
    [P0+LO(REG_SPORT1_DIV_A)] = R0;  
       
_SPORT_Init.exit:
	RETS = [SP++];
	RTS;
_SPORT_Init.end:


/*===========================================================*/
/*               ������� �������� ������ [SPI]               */
/*===========================================================*/
//R0 - cc���� �� ������ R1 - ������ ������ 
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_Tranmit_Data;
_SPORT_Tranmit_Data:
//half_A �� ��������
 
// CS �� ������ �������: 
	P0.L = LO(REG_PORTD_DATA);
	P0.H = HI(REG_PORTD_DATA); 
	R2 = [P0];
	R3 = SPORT1_A_CS_REG_BITM;
	R2 = R2 | R3;
	[P0] = R2; 	
//���� ��� ������������������� CS
		
//�������� �������� ������:
	R3 = [P1 + LO(REG_SPORT1_DIV_A)];
    R3.L = 0;
    R3 = R3 | R2;
    [P1 + LO(REG_SPORT1_DIV_A)] = R3;
 
//������������ ����� sport: 
   ld32(R3, ENUM_SPORT_CTL_TX|
            ENUM_SPORT_CTL_SECONDARY_EN|
            ENUM_SPORT_CTL_GCLK_EN|
            ENUM_SPORT_CTL_TXFIN_EN|
            ENUM_SPORT_CTL_LEVEL_FS|
            ENUM_SPORT_CTL_RJUST_DIS|
            ENUM_SPORT_CTL_LATE_FS|
            ENUM_SPORT_CTL_FS_HI|
            ENUM_SPORT_CTL_DATA_DEP_FS|
            ENUM_SPORT_CTL_INTERNAL_FS|
            ENUM_SPORT_CTL_FS_REQ|
            ENUM_SPORT_CTL_CLK_RISE_EDGE|
            ENUM_SPORT_CTL_SERIAL_MC_MODE|
            ENUM_SPORT_CTL_INTERNAL_CLK|
            ENUM_SPORT_CTL_PACK_DIS|
            ((24 - 1 ) << BITP_SPORT_CTL_SLEN)|
            ENUM_SPORT_CTL_MSB_FIRST|
            ENUM_SPORT_CTL_RJUSTIFY_ZFILL|
            ENUM_SPORT_CTL_EN    );
	[P1+LO(REG_SPORT1_CTL_A)] = R3;  
//�������� ������ - ��������� �� � ������:    
    [P1 + LO(REG_SPORT1_TXPRI_A)] = R0;
    [P1 + LO(REG_SPORT1_TXSEC_A)] = R1;
    
_SPORT_Tranmit_Data.exit: 
// CS �� ������� �������:  
	P0.L = LO(REG_PORTD_DATA);
	P0.H = HI(REG_PORTD_DATA); 
	R2 = [P0];
    R3 = ~SPORT1_A_CS_REG_BITM;
    R2 = R2 & R3;
    [P0] = R2;
      
	RTS;
_SPORT_Tranmit_Data.end:

/*===========================================================*/
/*               ������� ������ ������ [SPORT]                 */
/*===========================================================*/






