#include "asm_def.h"
#include "defBF607.h"
/*========== ��������� ��� ��������� ��� SPI ==================*/
/*=============================================================*/
/*                    ������ [SPORT]                           */
/*=============================================================*/
#include "sport.h"

/* ������������� SPORT1 */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_Init;
_SPORT_Init:
	[--SP] = RETS;
//��������� ������������� �����:     
    //CALL _SPORT_GPIO_Init;
    
    ldAddr(P0, REG_SPORT1_CTL_B);
// ������� ����������� ��������� sport:
    R0 = 0(z);
    [P0+LO(REG_SPORT1_CTL_B)] = R0;	 //..OPMODE 
    [P0+LO(REG_SPORT1_MCTL_B)] = R0; //..MCE               
                                                   
    [P0+LO(REG_SPORT1_CTL_B)] = R0;
    
    //CLK = SCLK0 /( 1 + DIV)
    //������� ���������� ������� FS � �������� CLK  
    ld32( R0, (3  << BITP_SPORT_DIV_CLKDIV) | ( 24 << BITP_SPORT_DIV_FSDIV) );              
    [P0+LO(REG_SPORT1_DIV_B)] = R0;  
    
    //������������ ����� sport: 
 	//ld32(R0, ENUM_SPORT_CTL_TX           |	//����� ��������
    //         ENUM_SPORT_CTL_GCLK_DIS      |	//��������� CLK
    //         ENUM_SPORT_CTL_CLK_RISE_EDGE|	//�������� ������ �� ����������� ������
    //         ENUM_SPORT_CTL_INTERNAL_CLK |	//������������� �����. ���������� ��� CLK
    //         ENUM_SPORT_CTL_INTERNAL_FS  |	//������������� �����. ���������� ��� FS 
    //         ENUM_SPORT_CTL_DATA_DEP_FS  |	//FS ������� ����� ���������� ������
    //         ENUM_SPORT_CTL_LEVEL_FS     |	//FS - �������
    //         ENUM_SPORT_CTL_FS_HI        |	//FS - ������� �  ������� ������
    //         ((16 - 1) << BITP_SPORT_CTL_SLEN)| //����� ������ ����� ������
    //         ENUM_SPORT_CTL_EN );   //��������� SPORT
       
   ld32(R0,    ENUM_SPORT_CTL_TX|
                ENUM_SPORT_CTL_SECONDARY_DIS|
                ENUM_SPORT_CTL_GCLK_DIS|
                ENUM_SPORT_CTL_TXFIN_EN|
                ENUM_SPORT_CTL_LEVEL_FS|
                ENUM_SPORT_CTL_RJUST_DIS|
                ENUM_SPORT_CTL_LATE_FS|
                ENUM_SPORT_CTL_FS_HI|
                ENUM_SPORT_CTL_DATA_INDP_FS|
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
                    
	[P0+LO(REG_SPORT1_CTL_B)] = R0;	
	
_SPORT_Init.exit:
	RETS = [SP++];
	RTS;
_SPORT_Init.end:

/* ��������� SPORT ����� */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_GPIO_Init;
_SPORT_GPIO_Init:
//PE4 ---> CLK:	
	// ������������
	P0.H = HI(REG_PORTE_FER);
	P0.L = LO(REG_PORTE_FER);
	R0 = [P0];
	R1 = BITM_PORT_FER_PX4;
	R0 = R0 | R1;          
	[P0] = R0;
	
	P0.H = HI(REG_PORTE_MUX);
	P0.L = LO(REG_PORTE_MUX);
	R0 = [P0];

	R1 = 2<<BITP_PORT_MUX_MUX4;  
	R0 = R0 | R1;
	
	[P0] = R0;
	
	RTS;
_SPORT_GPIO_Init.end: 

/*===========================================================*/
/*               ������� �������� ������ [SPI]               */
/*===========================================================*/
//R0 - cc���� �� ������ R1 - ������ ������ 
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_Tranmit_Data;
_SPORT_Tranmit_Data:
//half_B �� ��������

  ldAddr(P0, REG_SPORT1_CTL_B);
// CS �� ������ �������: 
		
//�������� �������� ������:
	//R3 = [P0 + LO(REG_SPORT1_DIV_B)];
    //R3.L = 0;
    //R3 = R3 | R2;
    //[P0 + LO(REG_SPORT1_DIV_B)] = R3;
 	
//�������� ������ - ��������� �� � ������:    
    [P0 + LO(REG_SPORT1_TXPRI_B)] = R0;
    
_SPORT_Tranmit_Data.exit: 
// CS �� ������� �������:  
      
	RTS;
_SPORT_Tranmit_Data.end:

/*===========================================================*/
/*               ������� ������ ������ [SPORT]                 */
/*===========================================================*/






