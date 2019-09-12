-----------------------------------------------------------------------
-- Authors      : Muhammed Tarık YILDIZ <muhammettarikyildiz@gmail.com>
--              : Murat Can Işık <kernet1@hotmail.com>
-- Project      : OSCILLOSCOPE
-- File Name    : signal_ram.vhd
-- Title        : Signal Ram
-- Description  :
------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SIGNAL_RAM IS
PORT(	
		CLK: IN STD_LOGIC;
		WRITE_ADRR: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		READ_ADDR:IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		DATA_IN: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_OUT:OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
END ENTITY SIGNAL_RAM;

ARCHITECTURE ARCH_SIGNAL_RAM OF SIGNAL_RAM IS
TYPE RAM IS ARRAY (0 TO 4095) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL SIGNAL_RAM: RAM;
BEGIN

PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
SIGNAL_RAM(TO_INTEGER(UNSIGNED(WRITE_ADRR))) <= DATA_IN;
DATA_OUT <= SIGNAL_RAM(TO_INTEGER(UNSIGNED(READ_ADDR)));
END IF;
END PROCESS;

END ARCHITECTURE ARCH_SIGNAL_RAM;