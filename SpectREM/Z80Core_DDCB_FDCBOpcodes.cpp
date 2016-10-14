#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RLC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RLC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RRC_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RRC(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RR_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	RR(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SLA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SRA_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRA(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SLL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SLL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SRL_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	SRL(t);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	BitWithMemptr(t, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_RES_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_0_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_1_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_2_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_3_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_4_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_5_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_6_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regB = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regC = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regD = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regH = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regL = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_SET_7_off_IX_IY_d(unsigned char opcode)
{
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	unsigned char t = Z80CoreMemRead(m_MEMPTR);
	Z80CoreMemoryContention(m_MEMPTR, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_MEMPTR, t);

	m_CPURegisters.regs.regA = t;
}

//-----------------------------------------------------------------------------------------

