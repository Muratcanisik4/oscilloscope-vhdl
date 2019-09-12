-----------------------------------------------------------------------
-- Authors      : Muhammed Tarık YILDIZ <muhammettarikyildiz@gmail.com>
--              : Murat Can Işık <kernet1@hotmail.com>
-- Project      : OSCILLOSCOPE
-- File Name    : vga_buffer.vhd
-- Title        : VGA Signal Graphics Pixel Buffer Memory
-- Description  :
-----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY VGA_BUFFER IS

PORT(
		CLK:IN STD_LOGIC;
		WR_ADDR:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		RD_ADDR_X:IN INTEGER RANGE 0 TO 359;
		DATA_IN:IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		DATA_OUT:OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
);

END ENTITY VGA_BUFFER;

ARCHITECTURE ARCH_VGA_BUFFER OF VGA_BUFFER IS
TYPE VGA_BUFFER_RAM IS ARRAY (0 TO 359) OF STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL VGA_RAM:VGA_BUFFER_RAM;
BEGIN
PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
	VGA_RAM(TO_INTEGER(UNSIGNED(WR_ADDR))) <= DATA_IN;
	DATA_OUT <= VGA_RAM(RD_ADDR_X);
END IF;
END PROCESS;
END ARCHITECTURE ARCH_VGA_BUFFER;