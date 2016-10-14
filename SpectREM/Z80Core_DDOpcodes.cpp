#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IX_BC(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIX, m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IX_DE(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIX, m_CPURegisters.reg_pairs.regDE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IX_nn(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regIXh = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_IX(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regIXl);
	Z80CoreMemWrite(m_MEMPTR, m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IX(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regIX++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IXh(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IXh(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_n(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IX_IX(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIX, m_CPURegisters.reg_pairs.regIX);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IX_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regIXl = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regs.regIXh = Z80CoreMemRead(m_MEMPTR);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IX(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regIX--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IXl(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IXl(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_n(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regIX + offset, 1);
	Inc(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regIX + offset, 1);
	Dec(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_n(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	unsigned char val = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, val);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IX_SP(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIX, m_CPURegisters.regSP);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_B(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_C(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_D(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_E(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXh_A(unsigned char opcode)
{
	m_CPURegisters.regs.regIXh = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_B(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_C(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_D(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_E(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IXl_A(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_B(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_C(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_D(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_E(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_H(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_L(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IX_d_A(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIX + offset, m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_IXh(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regIXh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_IXl(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regIXl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_IXh(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_IXl(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Add8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_IXh(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_IXl(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Adc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_IXh(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_IXl(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Sub8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_IXh(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_IXl(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Sbc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_IXh(unsigned char opcode)
{
	And(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_IXl(unsigned char opcode)
{
	And(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	And(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_IXh(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_IXl(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Xor(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_IXh(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_IXl(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Or(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_IXh(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regIXh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_IXl(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_off_IX_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIX + offset);
	Cp(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_IX(unsigned char opcode)
{
	m_CPURegisters.regs.regIXl = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regIXh = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EX_off_SP_IX(unsigned char opcode)
{
	unsigned char tl = Z80CoreMemRead(m_CPURegisters.regSP + 0);
	unsigned char th = Z80CoreMemRead(m_CPURegisters.regSP + 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP + 1, 1);
	Z80CoreMemWrite(m_CPURegisters.regSP + 1, m_CPURegisters.regs.regIXh);
	Z80CoreMemWrite(m_CPURegisters.regSP + 0, m_CPURegisters.regs.regIXl);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	m_CPURegisters.regs.regIXh = th;
	m_CPURegisters.regs.regIXl = tl;

	m_MEMPTR = m_CPURegisters.reg_pairs.regIX;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_IX(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regIXh);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regIXl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_off_IX(unsigned char opcode)
{
	m_CPURegisters.regPC = m_CPURegisters.reg_pairs.regIX;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_SP_IX(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regSP = m_CPURegisters.reg_pairs.regIX;
}

//-----------------------------------------------------------------------------------------

