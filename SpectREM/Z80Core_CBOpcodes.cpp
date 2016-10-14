#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_B(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_C(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_D(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_E(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_H(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_L(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	RLC(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC_A(unsigned char opcode)
{
	RLC(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_B(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_C(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_D(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_E(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_H(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_L(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	RRC(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC_A(unsigned char opcode)
{
	RRC(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_B(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_C(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_D(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_E(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_H(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_L(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	RL(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL_A(unsigned char opcode)
{
	RL(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_B(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_C(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_D(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_E(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_H(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_L(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	RR(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR_A(unsigned char opcode)
{
	RR(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_B(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_C(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_D(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_E(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_H(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_L(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	SLA(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA_A(unsigned char opcode)
{
	SLA(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_B(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_C(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_D(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_E(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_H(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_L(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	SRA(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA_A(unsigned char opcode)
{
	SRA(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_B(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_C(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_D(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_E(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_H(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_L(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	SLL(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL_A(unsigned char opcode)
{
	SLL(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_B(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_C(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_D(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_E(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_H(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_L(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	SRL(t);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL_A(unsigned char opcode)
{
	SRL(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_0_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_1_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_2_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_3_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_4_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_5_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_6_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_B(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regB, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_C(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regC, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_D(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regD, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_E(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regE, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_H(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regH, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_L(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regL, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	BitWithMemptr(t, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BIT_7_A(unsigned char opcode)
{
	Bit(m_CPURegisters.regs.regA, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 0);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_0_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_1_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 2);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_2_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 3);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_3_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 4);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_4_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 5);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_5_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 6);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_6_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_B(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regB, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_C(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regC, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_D(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regD, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_E(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regE, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_H(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regH, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_L(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regL, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Res(t, 7);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RES_7_A(unsigned char opcode)
{
	Res(m_CPURegisters.regs.regA, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 0);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_0_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_1_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 1);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 2);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_2_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 2);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 3);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_3_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 3);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 4);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_4_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 4);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 5);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_5_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 5);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 6);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_6_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 6);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_B(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regB, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_C(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regC, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_D(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regD, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_E(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regE, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_H(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regH, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_L(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regL, 7);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Set(t, 7);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SET_7_A(unsigned char opcode)
{
	Set(m_CPURegisters.regs.regA, 7);
}

//-----------------------------------------------------------------------------------------
