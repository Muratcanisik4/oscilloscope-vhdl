------------------------------------------------------------------------
-- Authors      : Muhammed Tarık YILDIZ <muhammettarikyildiz@gmail.com>
--              : Murat Can Işık <kernet1@hotmail.com>
-- Project      : OSCILLOSCOPE
-- File Name    : vga_driver.vhd
-- Title        : VGA Drive with Calculated Values and Signal Graphics
-- Description  :
------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VGA_DRIVER IS

PORT
(
		CLK:IN STD_LOGIC;
		SIGNAL_RAM_ADDR1,SIGNAL_RAM_ADDR2:OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		SIGNAL_RAM_DATA1,SIGNAL_RAM_DATA2:IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		VPPMAX1,VPPMAX2,VPPMIN1,VPPMIN2,PERIODE1,PERIODE2:IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		VGA_R,VGA_G,VGA_B:OUT STD_LOGIC;
		VGA_HSYNC,VGA_VSYNC:OUT STD_LOGIC
);

END ENTITY VGA_DRIVER;


ARCHITECTURE ARCH_VGA_DRIVER OF VGA_DRIVER IS

COMPONENT VGA_BUFFER IS 

PORT(
		CLK:IN STD_LOGIC;
		WR_ADDR:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		RD_ADDR_X:IN INTEGER RANGE 0 TO 359;
		DATA_IN:IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		DATA_OUT:OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
);

END COMPONENT VGA_BUFFER;

COMPONENT VGA_SYNC IS

PORT(
	CLK: IN STD_LOGIC;
	HSYNC, VSYNC: OUT STD_LOGIC;
	R_OUT, G_OUT, B_OUT: OUT STD_LOGIC;
	R_IN: IN STD_LOGIC;
	G_IN: IN STD_LOGIC;
	B_IN: IN STD_LOGIC;
	PIXEL_H: OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
	PIXEL_V: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	VPPMIN1,VPPMAX1,VPPMIN2,VPPMAX2: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
	PERIODE1,PERIODE2: IN STD_LOGIC_VECTOR(12 DOWNTO 0)
);

END COMPONENT VGA_SYNC;
------------------------BUFFER RAM 1 SIGNALS --------------------------------
SIGNAL BUFFER_RAM_WR_ADDR1:STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL BUFFER_RAM_RD_ADDR1:INTEGER RANGE 0 TO 359;
SIGNAL BUFFER_RAM_DATA_IN1:STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL BUFFER_RAM_DATA_OUT1:STD_LOGIC_VECTOR(47 DOWNTO 0);
------------------------BUFFER RAM 2 SIGNALS-----------------------------------
SIGNAL BUFFER_RAM_WR_ADDR2:STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL BUFFER_RAM_RD_ADDR2:INTEGER RANGE 0 TO 359;
SIGNAL BUFFER_RAM_DATA_IN2:STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL BUFFER_RAM_DATA_OUT2:STD_LOGIC_VECTOR(47 DOWNTO 0);
------------------------------------------------------------------------------
SIGNAL PIXEL_H: STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL PIXEL_V: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL R_IN,G_IN,B_IN:STD_LOGIC;
SIGNAL CNT:INTEGER RANGE 0 TO 4095 := 0;
SIGNAL CNT_T:INTEGER RANGE 0 TO 359 := 0;
SIGNAL CNT_SEC:INTEGER RANGE 0 TO 500_000_000 := 0;
SIGNAL BOOL_UPDATE: STD_LOGIC := '1';

BEGIN
VGA_BUFFER_C1:VGA_BUFFER PORT MAP(CLK,BUFFER_RAM_WR_ADDR1,BUFFER_RAM_RD_ADDR1,BUFFER_RAM_DATA_IN1,BUFFER_RAM_DATA_OUT1);
VGA_BUFFER_C2:VGA_BUFFER PORT MAP(CLK,BUFFER_RAM_WR_ADDR2,BUFFER_RAM_RD_ADDR2,BUFFER_RAM_DATA_IN2,BUFFER_RAM_DATA_OUT2);
VGA_SYNC_C:VGA_SYNC PORT MAP(CLK,VGA_HSYNC,VGA_VSYNC,VGA_R,VGA_G,VGA_B,R_IN,G_IN,B_IN,PIXEL_H,PIXEL_V,VPPMIN1,VPPMAX1,VPPMIN2,VPPMAX2,PERIODE1,PERIODE2);

PROCESS(CLK)
 VARIABLE COMP_TMP1,COMP_TMP2:INTEGER RANGE 0 TO 255;
 VARIABLE TMP1,TMP2:STD_LOGIC_VECTOR(47 DOWNTO 0);
 VARIABLE X:INTEGER RANGE 0 TO 1200;
 VARIABLE Y:INTEGER RANGE 0 TO 500;
BEGIN
	IF RISING_EDGE(CLK) THEN
	------------------------------WRITE BUFFER BEGIN----------------------------------------
	--------------------------UPDATE BUFFER AFTER 1 SEC-------------------------------------
	IF CNT_SEC = 1_000_000 THEN
		CNT_SEC <= 0;
	SIGNAL_RAM_ADDR1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(CNT/11,12));
	SIGNAL_RAM_ADDR2 <= STD_LOGIC_VECTOR(TO_UNSIGNED(CNT/11,12));
	BUFFER_RAM_WR_ADDR1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(CNT_T,10));
	BUFFER_RAM_WR_ADDR2 <= STD_LOGIC_VECTOR(TO_UNSIGNED(CNT_T,10));
	
	COMP_TMP1 := TO_INTEGER(UNSIGNED(SIGNAL_RAM_DATA1));
	COMP_TMP1 := COMP_TMP1/6;
	
	COMP_TMP2 := TO_INTEGER(UNSIGNED(SIGNAL_RAM_DATA2));
	COMP_TMP2 := COMP_TMP2/6;
	
	L1:FOR I IN 0 TO 47 LOOP
		IF I <= COMP_TMP1 THEN
			TMP1(I) := '1';
		ELSE 
			TMP1(I) := '0';
		END IF;
	END LOOP L1;
	--------------------------------------
	
	--------------------------------------
	L2:FOR I1 IN 0 TO 47 LOOP
		IF I1 = COMP_TMP2 THEN
			TMP2(I1) := '1';
		ELSE 
			TMP2(I1) := '0';
		END IF;
	END LOOP L2;
	-----------------------------------
	BUFFER_RAM_DATA_IN1 <= TMP1;
	BUFFER_RAM_DATA_IN2 <= TMP2;
	-----------------------------------
		IF CNT > 4095 THEN
			CNT <= 0;
		ELSE
			CNT <= CNT;
		END IF;
		
		IF CNT_T = 359 THEN
			CNT_T <= 0;
		ELSE 
			CNT_T <= CNT_T + 1;
		END IF;
		CNT_SEC <= 0;
		-------------------------
		
	ELSE
		CNT_SEC <= CNT_SEC + 1;
	END IF;
	-------------------------WRITE BUFFER END------------------------------------------------
	-------------------------READ BUFFER BEGIN-----------------------------------------------
	X := TO_INTEGER(UNSIGNED(PIXEL_H)) - 240;
	Y := TO_INTEGER(UNSIGNED(PIXEL_V)) - 66;
	
	IF X<=360 THEN
		BUFFER_RAM_RD_ADDR1 <= X;
		BUFFER_RAM_RD_ADDR2 <= X;
		TMP1 := BUFFER_RAM_DATA_OUT1;
		TMP2 := BUFFER_RAM_DATA_OUT2;
		IF Y>0 AND Y<=200 THEN
		R_IN <= TMP1(47 - ((Y/4)- 2));
		END IF;
		IF Y<=400 AND Y>200 THEN
		B_IN <= TMP2(47 - ((Y/4)- 50));
		END IF;
	END IF;
	--------------------------READ BUFFER END-------------------------------------------------
	END IF;
END PROCESS;
END ARCHITECTURE ARCH_VGA_DRIVER;