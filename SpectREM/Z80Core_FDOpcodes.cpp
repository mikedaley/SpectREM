#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IY_BC(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIY, m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IY_DE(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIY, m_CPURegisters.reg_pairs.regDE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IY_nn(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regIYh = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_IY(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regIYl);
	Z80CoreMemWrite(m_MEMPTR, m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IY(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regIY++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IYh(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IYh(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_n(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IY_IY(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIY, m_CPURegisters.reg_pairs.regIY);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IY_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regIYl = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regs.regIYh = Z80CoreMemRead(m_MEMPTR);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IY(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regIY--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_IYl(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_IYl(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_n(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regIY + offset, 1);
	Inc(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regIY + offset, 1);
	Dec(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_n(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	unsigned char val = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, val);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_IY_SP(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regIY, m_CPURegisters.regSP);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_B(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_C(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_D(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_E(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYh_A(unsigned char opcode)
{
	m_CPURegisters.regs.regIYh = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_B(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_C(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_D(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_E(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_IYl_A(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_B(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_C(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_D(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_E(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_H(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_L(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_IY_d_A(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regIY + offset, m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_IYh(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regIYh;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_IYl(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regIYl;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_IYh(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_IYl(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Add8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_IYh(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_IYl(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Adc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_IYh(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_IYl(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Sub8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_IYh(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_IYl(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Sbc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_IYh(unsigned char opcode)
{
	And(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_IYl(unsigned char opcode)
{
	And(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	And(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_IYh(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_IYl(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Xor(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_IYh(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_IYl(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Or(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_IYh(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regIYh);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_IYl(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_off_IY_d(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regIY + offset);
	Cp(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_IY(unsigned char opcode)
{
	m_CPURegisters.regs.regIYl = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regIYh = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EX_off_SP_IY(unsigned char opcode)
{
	unsigned char tl = Z80CoreMemRead(m_CPURegisters.regSP + 0);
	unsigned char th = Z80CoreMemRead(m_CPURegisters.regSP + 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP + 1, 1);
	Z80CoreMemWrite(m_CPURegisters.regSP + 1, m_CPURegisters.regs.regIYh);
	Z80CoreMemWrite(m_CPURegisters.regSP + 0, m_CPURegisters.regs.regIYl);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	m_CPURegisters.regs.regIYh = th;
	m_CPURegisters.regs.regIYl = tl;

	m_MEMPTR = m_CPURegisters.reg_pairs.regIY;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_IY(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regIYh);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regIYl);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_off_IY(unsigned char opcode)
{
	m_CPURegisters.regPC = m_CPURegisters.reg_pairs.regIY;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_SP_IY(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regSP = m_CPURegisters.reg_pairs.regIY;
}

//-----------------------------------------------------------------------------------------

