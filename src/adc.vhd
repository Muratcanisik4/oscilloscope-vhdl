-----------------------------------------------------------------------
-- Authors      : Muhammed Tarık YILDIZ <muhammettarikyildiz@gmail.com>
--              : Murat Can Işık <kernet1@hotmail.com>
-- Project      : OSCILLOSCOPE
-- File Name    : adc.vhd
-- Title        : Analog to Digital Converter Interfacing
-- Description  :
-----------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
ENTITY ADC IS 
	PORT ( M_CLK:IN  STD_LOGIC:='0'; 
	INT : IN  STD_LOGIC:='1'; 
	RD  : OUT  STD_LOGIC:='1';
	WR  :OUT STD_LOGIC:='0'; 
	ADC_DATA_IN:IN STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000"; 
	ADC_INT:OUT INTEGER RANGE 0 TO 255;
	ADC_DATA_OUT:OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	ADC_ENABLE:OUT STD_LOGIC
	); 
END ADC; 

ARCHITECTURE BEHAVIORAL OF ADC IS 
	SIGNAL CLK_SIG1:STD_LOGIC:='0'; 
BEGIN
	PROCESS(M_CLK) 
		VARIABLE CNT1:INTEGER:=1;
	 BEGIN 
		 IF RISING_EDGE(M_CLK) THEN 
			 IF(CNT1=2000)THEN 
				CLK_SIG1<= NOT(CLK_SIG1); 
				CNT1:=1; 
			 ELSE 
				CNT1:= CNT1 + 1; 
			 END IF; 
		 END IF; 
	 END PROCESS; 
	 PROCESS(CLK_SIG1,ADC_DATA_IN) 
		VARIABLE CNT:INTEGER:=1; 
	 BEGIN 
		 IF RISING_EDGE(CLK_SIG1) THEN 
			 IF(CNT=1) THEN  
			 WR<='1';
			 CNT:=CNT+1; 
			  ADC_ENABLE <= '0';
			 ELSIF (CNT=2) THEN 
				 IF INT='1' THEN 
					CNT:=2; 
				 ELSE 
					CNT:=CNT+1; 
				 END IF; 
				 ADC_ENABLE <= '0';
			 ELSIF (CNT=3)THEN   
				RD<='0'; 
				CNT:=CNT+1;
				ADC_ENABLE <= '0';
			 ELSIF (CNT=4) THEN   
				 ADC_INT<=TO_INTEGER(UNSIGNED(ADC_DATA_IN)); 
				 ADC_DATA_OUT <= ADC_DATA_IN;
				 CNT:=CNT+1; 
				 ADC_ENABLE <= '1';
			 ELSIF (CNT=5) THEN 
				 RD<='1'; 
				 CNT:=CNT+1;
				 ADC_ENABLE <= '0';				 
			 ELSIF (CNT=6) THEN 
				 WR<='0'; 
				 CNT:=CNT+1; 
				 ADC_ENABLE <= '0';
			 ELSIF (CNT=7)THEN 
				CNT:=1; 
				ADC_ENABLE <= '0';
			 ELSE  
				CNT:=1; 
				ADC_ENABLE <= '0';
			 END IF; 
		 END IF; 
	 END PROCESS; 
 END BEHAVIORAL;