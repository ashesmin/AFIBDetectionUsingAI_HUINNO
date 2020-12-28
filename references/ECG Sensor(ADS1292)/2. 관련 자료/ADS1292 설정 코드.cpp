#include "main.h"
#include "string.h"


// �������� ���� (0���� ����)
u8 ADS1292_REG_testsignal_serial[11] = {    
        
        //
        // Global Settings Across Channels
        //
        0x03 ,  // 0x01: CONFIG1                      ,1 kSPS
        0xA0,   // 0x02: CONFIG2 
        0x10,    // 0x03: LOFF                           
        
        //
        // Channel Specific Settings
        //  
        0x60,   // 0x04: CH1SET                     
        0x60,   // 0x05: CH2SET
        
    
        0x60,   // 0x06: RLD_SENS
    
        
        0x00,   // 0x07: LOFF_SENS 

                
        //
        // Lead Off Status Registors
        //          
        0x40,   // 0x08: LOFF_STAT
    
        
        //
        // GPIO and Other Registers
        //      
        0x02,   // 0x09: RESP1
        0x03,   // 0x0A: RESP2      
        0x0F,   // 0x0B: GPIO
        
    
}; 



u8 ADS1292_REG_Read[12] =      {0,};

// ******************************************************************************
//
// �����ð� ������ 
//
// ******************************************************************************
void delay(__IO uint32_t DelayWait)
{ 
  while(DelayWait--);
}



// ******************************************************************************
//
// SPI�� ������ ���� 
//
// ******************************************************************************
u8 SPI_TXRX(SPI_TypeDef* SPIy, u8 x)
{
  /* Wait for SPIy Tx buffer empty */
//    while (SPI_I2S_GetFlagStatus(SPIy, SPI_I2S_FLAG_TXE) == RESET);
    while (!(SPIy->SR  & SPI_I2S_FLAG_TXE));
    
    /* Send SPIz data */
    //SPI_I2S_SendData16(SPIy, x);
    SPI_SendData8(SPIy,x);
    
    /* Wait for SPIz data reception */
    //while (SPI_I2S_GetFlagStatus(SPIy, SPI_I2S_FLAG_RXNE) == RESET);
    while (!(SPIy->SR  & SPI_I2S_FLAG_RXNE));
    
    
    /* Read SPIy received data */
   // return SPI_I2S_ReceiveData16(SPIy);
    
    
    return SPI_ReceiveData8(SPIy);
}



// ******************************************************************************
//���������� ���� ����.
//address : register address
//command : register�� �� �� 
// ******************************************************************************
void WREG(u8 address,u8 command)
{
  u8 reg = 0x40;
  u8 opcode =0;
  
  ADS1292_SPI_CS_L_LEVEL;
  
  opcode = reg | address;
  SPI_TXRX(SPI1,opcode);  // 0x40+���� �ּ� 
  SPI_TXRX(SPI1,0);            // �� ����Ʈ �� -1.  0�� ��� 1����Ʈ�� �� 
  
  SPI_TXRX(SPI1,command);  // �������Ϳ� �� ��
  delay(100);
  
  ADS1292_SPI_CS_H_LEVEL;
}



// ******************************************************************************
//���������� ���� �о�´�.
//address : register address
//num : ���� ���������� ����(�ִ� 12)
// ******************************************************************************
void RREG(u8 address, u8 num)
{
  unsigned char reg = 0x20;
  unsigned char opcode =0;
  unsigned char cnt=0;
 
  
  ADS1292_SPI_CS_L_LEVEL;
  opcode = reg | address;
  SPI_TXRX(SPI1,opcode);   // 0x20+���� �������� �ּ� 
  SPI_TXRX(SPI1,num-1);    // ���� ����Ʈ�� -1 

  for(cnt=0;cnt<num;cnt++)
  {
    ADS1292_REG_Read[cnt]= SPI_TXRX(SPI1,0);
  }
  delay(100);
  ADS1292_SPI_CS_H_LEVEL;
}

// ******************************************************************************
//
// ��� �������� ���� 
//
// ******************************************************************************
void AutoRegSet_Default(u8 * data)
{
  u8 cnt=0;
  for(cnt=0;cnt<11;cnt++)
  {
    WREG(cnt+1,data[cnt]);  // �������� 0x01~0x19���� ��� 
    delay(200);   // ��� ����, ���� us ����
  }
}
        
// ******************************************************************************
//
//Stop Read Data Continuous
//
// ******************************************************************************
void SDATAC()
{
  ADS1292_SPI_CS_L_LEVEL;
  SPI_TXRX(SPI1,0x11);
//  SPI_TXRX(SPI2,0);
  delay(10);
  ADS1292_SPI_CS_H_LEVEL;  
}


// ******************************************************************************
//
//Enable Read Data Continuous mode.
//
// ******************************************************************************
void RDATAC()
{
  ADS1292_SPI_CS_L_LEVEL;  
  SPI_TXRX(SPI1,0x10);
  delay(10);
  ADS1292_SPI_CS_H_LEVEL;  
}

// ******************************************************************************
//
//Read data by command
//
// ******************************************************************************
void RDATA()
{
  ADS1292_SPI_CS_L_LEVEL;  
  SPI_TXRX(SPI1,0x12);
  delay(10);
  ADS1292_SPI_CS_H_LEVEL;  
}

// ******************************************************************************
//
// ������ ȹ�� ���� 
//
// ******************************************************************************
void START()
{
  ADS1292_SPI_CS_L_LEVEL;  
  SPI_TXRX(SPI1,0x08);
  delay(10);
  ADS1292_SPI_CS_H_LEVEL;  
}

// ******************************************************************************
//
//Stop Conversion
//
// ******************************************************************************
void STOP()
{
  ADS1292_SPI_CS_L_LEVEL;  
  SPI_TXRX(SPI1,0x0A);
  delay(10);
  ADS1292_SPI_CS_H_LEVEL;  
}

// ******************************************************************************
//
// ADS1292 �ʱ�ȭ : 
//    ���� : 1 �������� ���� ������ �ٸ� , �� �κи� �����ϸ� ��, �������� ������
//
// ******************************************************************************
bool ADS1292_Initialize(void)
{
    ADS1292_SPI_CS_H_LEVEL;  //  SPI�� CS ���� High�� �� 
       
    ADS1292_RST_H_LEVEL;      //RESET ���� H�� ��
    delay(1000000);        
    ADS1292_RST_L_LEVEL;
    delay(1000000);        
    ADS1292_RST_H_LEVEL;        //���� ����
    delay(1000000);  
    

    // �������� ���� 
   AutoRegSet_Default(ADS1292_REG_testsignal_serial);    //���� ��ȣ ����� test signal �� ���

    // �������Ͱ� ���������� �о
    SDATAC();
    STOP();
    RREG(1, 11);
    
    
    for(UINT8 i=0; i<=6;i++)
    {
        if(ADS1292_REG_testsignal_serial[i]!=ADS1292_REG_Read[i])
            return 1;       
    }
    
    
    if(ADS1292_REG_testsignal_serial[7] & 0xE0 !=ADS1292_REG_Read[7] & 0xE0)
            return 1;   
    
    
    for(UINT8 i=8; i<=9;i++)
    {
        if(ADS1292_REG_testsignal_serial[i]!=ADS1292_REG_Read[i])
            return 1;       
    }
    
    if(ADS1292_REG_testsignal_serial[10] & 0xFC !=ADS1292_REG_Read[7] & 0xFC)  
            return 1;   
    
    
        
    // ���� ������ �б� ���� 
    RDATAC();
    START(); 
    
    return 0; 
}

