#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::NOP(unsigned char opcode)
{
	// Nothing to do...
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_BC_nn(unsigned char opcode)
{
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_BC_A(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regA);

	m_MEMPTR = (m_CPURegisters.reg_pairs.regBC + 1) & 0x00ff;
	m_MEMPTR |= m_CPURegisters.regs.regA << 8;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_BC(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regBC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_B(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_B(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_n(unsigned char opcode)
{
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLCA(unsigned char opcode)
{
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA << 1) | (m_CPURegisters.regs.regA >> 7);
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & (FLAG_P | FLAG_Z | FLAG_S));
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EX_AF_AF_(unsigned char opcode)
{
	unsigned short t = m_CPURegisters.reg_pairs.regAF;
	m_CPURegisters.reg_pairs.regAF = m_CPURegisters.reg_pairs.regAF_;
	m_CPURegisters.reg_pairs.regAF_ = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_HL_BC(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_BC(unsigned char opcode)
{
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.reg_pairs.regBC);
	m_MEMPTR = m_CPURegisters.reg_pairs.regBC + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_BC(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regBC--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_C(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_C(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_n(unsigned char opcode)
{
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRCA(unsigned char opcode)
{
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA >> 1) | (m_CPURegisters.regs.regA << 7);
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & (FLAG_P | FLAG_Z | FLAG_S));
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DJNZ_off_PC_e(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	// See if we should branch
	m_CPURegisters.regs.regB--;

	if (m_CPURegisters.regs.regB != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		m_CPURegisters.regPC += offset;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}

	// Do this here because of the contention
	m_CPURegisters.regPC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_DE_nn(unsigned char opcode)
{
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_DE_A(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regDE, m_CPURegisters.regs.regA);

	m_MEMPTR = (m_CPURegisters.reg_pairs.regDE + 1) & 0x00ff;
	m_MEMPTR |= m_CPURegisters.regs.regA << 8;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_DE(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regDE++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_D(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_D(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_n(unsigned char opcode)
{
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLA(unsigned char opcode)
{
	unsigned char old_a = m_CPURegisters.regs.regA;
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA << 1) | ((m_CPURegisters.regs.regF & FLAG_C) ? 0x01 : 0x00) ;
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & (FLAG_P | FLAG_Z | FLAG_S));
	m_CPURegisters.regs.regF |= ((old_a & 0x80) == 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JR_off_PC_e(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
	Z80CoreMemoryContention(m_CPURegisters.regPC, 1);

	m_CPURegisters.regPC += offset;
	m_CPURegisters.regPC++;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_HL_DE(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regDE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_DE(unsigned char opcode)
{
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.reg_pairs.regDE);
	m_MEMPTR = m_CPURegisters.reg_pairs.regDE + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_DE(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regDE--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_E(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_E(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_n(unsigned char opcode)
{
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRA(unsigned char opcode)
{
	unsigned char old_a = m_CPURegisters.regs.regA;
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA >> 1) | ((m_CPURegisters.regs.regF & FLAG_C) ? 0x80 : 0x00);
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & (FLAG_P | FLAG_Z | FLAG_S));
	m_CPURegisters.regs.regF |= ((old_a & 0x01) == 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JR_NZ_off_PC_e(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	if ((m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);

		m_CPURegisters.regPC += offset;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}

	m_CPURegisters.regPC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_HL_nn(unsigned char opcode)
{

	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_HL(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regL);
	Z80CoreMemWrite(m_MEMPTR, m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_HL(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regHL++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_H(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_H(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_n(unsigned char opcode)
{
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DAA(unsigned char opcode)
{
	unsigned char daa_value = 0;
	unsigned char flags = (m_CPURegisters.regs.regF & FLAG_C);

	if ((m_CPURegisters.regs.regA & 0x0f) > 0x09 || (m_CPURegisters.regs.regF & FLAG_H) == FLAG_H)
	{
		daa_value |= 0x06;
	}

	if (m_CPURegisters.regs.regA > 0x99)
	{
		flags = FLAG_C;
		daa_value |= 0x60;
	}
	else if ((m_CPURegisters.regs.regF & FLAG_C) == FLAG_C)
	{
		daa_value |= 0x60;
	}

	if ((m_CPURegisters.regs.regF & FLAG_N) == FLAG_N)
	{
		Sub8(daa_value);
	}
	else
	{
		Add8(daa_value);
	}
	
	m_CPURegisters.regs.regF &= ~(FLAG_C | FLAG_P);
	m_CPURegisters.regs.regF |= flags;
	m_CPURegisters.regs.regF |= m_ParityTable[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JR_Z_off_PC_e(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	if ((m_CPURegisters.regs.regF & FLAG_Z) == FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);

		m_CPURegisters.regPC += offset;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}

	m_CPURegisters.regPC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_HL_HL(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_HL_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regL = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_MEMPTR);

}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_HL(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.reg_pairs.regHL--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_L(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_L(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_n(unsigned char opcode)
{
	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CPL(unsigned char opcode)
{
	m_CPURegisters.regs.regA ^= 0xff;
	m_CPURegisters.regs.regF &= (FLAG_C | FLAG_P | FLAG_Z | FLAG_S);
	m_CPURegisters.regs.regF |= (FLAG_N | FLAG_H);
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JR_NC_off_PC_e(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	if ((m_CPURegisters.regs.regF & FLAG_C) != FLAG_C)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);

		m_CPURegisters.regPC += offset;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}

	m_CPURegisters.regPC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_SP_nn(unsigned char opcode)
{
	unsigned char t1 = Z80CoreMemRead(m_CPURegisters.regPC++);
	unsigned char t2 = Z80CoreMemRead(m_CPURegisters.regPC++);

	m_CPURegisters.regSP = (((unsigned short)t2) << 8) | t1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_A(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regA);

	m_MEMPTR &= 0x00ff;
	m_MEMPTR |= m_CPURegisters.regs.regA << 8;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_SP(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regSP++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_off_HL(unsigned char opcode)
{
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Inc(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_off_HL(unsigned char opcode)
{
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Dec(temp);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_n(unsigned char opcode)
{
	unsigned char temp = Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, temp);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SCF(unsigned char opcode)
{
	m_CPURegisters.regs.regF &= (FLAG_P | FLAG_S | FLAG_Z);
	m_CPURegisters.regs.regF |= FLAG_C;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JR_C_off_PC_e(unsigned char opcode)
{
	signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);

	if ((m_CPURegisters.regs.regF & FLAG_C) == FLAG_C)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);
		Z80CoreMemoryContention(m_CPURegisters.regPC, 1);

		m_CPURegisters.regPC += offset;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}

	m_CPURegisters.regPC++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_HL_SP(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Add16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regSP);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regA = Z80CoreMemRead(m_MEMPTR++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_SP(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regSP--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INC_A(unsigned char opcode)
{
	Inc(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DEC_A(unsigned char opcode)
{
	Dec(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_n(unsigned char opcode)
{
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.regPC++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CCF(unsigned char opcode)
{
	unsigned char tf = m_CPURegisters.regs.regF;
	m_CPURegisters.regs.regF &= (FLAG_P | FLAG_S | FLAG_Z);
	m_CPURegisters.regs.regF |= (tf & FLAG_C) ? FLAG_H : FLAG_C;
	m_CPURegisters.regs.regF |= (m_CPURegisters.regs.regA & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_B(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_C(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_D(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_E(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_H(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_L(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_B_A(unsigned char opcode)
{
	m_CPURegisters.regs.regB = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_B(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_C(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_D(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_E(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_H(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_L(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_C_A(unsigned char opcode)
{
	m_CPURegisters.regs.regC = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_B(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_C(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_D(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_E(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_H(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_L(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_D_A(unsigned char opcode)
{
	m_CPURegisters.regs.regD = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_B(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_C(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_D(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_E(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_H(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_L(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_E_A(unsigned char opcode)
{
	m_CPURegisters.regs.regE = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_B(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_C(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_D(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_E(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_H(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_L(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_H_A(unsigned char opcode)
{
	m_CPURegisters.regs.regH = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_B(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_C(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_D(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_E(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_H(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_L(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_L_A(unsigned char opcode)
{
	m_CPURegisters.regs.regL = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_B(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_C(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_D(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_E(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_H(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_L(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::HALT(unsigned char opcode)
{
	m_CPURegisters.Halted = 1;
	m_CPURegisters.regPC--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_HL_A(unsigned char opcode)
{
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_B(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regB;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_C(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_D(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regD;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_E(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regE;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_H(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regH;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_L(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_off_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_A(unsigned char opcode)
{
	m_CPURegisters.regs.regA = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_B(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_C(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regC);

}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_D(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_E(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_H(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_L(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Add8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_A(unsigned char opcode)
{
	Add8(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_B(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_C(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_D(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_E(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_H(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_L(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Adc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_A(unsigned char opcode)
{
	Adc8(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_B(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_C(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_D(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_E(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_H(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_L(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Sub8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_A(unsigned char opcode)
{
	Sub8(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_B(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_C(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_D(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_E(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_H(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_L(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Sbc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_A(unsigned char opcode)
{
	Sbc8(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_B(unsigned char opcode)
{
	And(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_C(unsigned char opcode)
{
	And(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_D(unsigned char opcode)
{
	And(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_E(unsigned char opcode)
{
	And(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_H(unsigned char opcode)
{
	And(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_L(unsigned char opcode)
{
	And(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	And(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_A(unsigned char opcode)
{
	And(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_B(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_C(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_D(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_E(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_H(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_L(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Xor(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_A(unsigned char opcode)
{
	Xor(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_B(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_C(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_D(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_E(unsigned char opcode)
{
Or(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_H(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_L(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Or(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_A(unsigned char opcode)
{
	Or(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_B(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_C(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_D(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_E(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_H(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_L(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_off_HL(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Cp(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_A(unsigned char opcode)
{
	Cp(m_CPURegisters.regs.regA);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_NZ(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	
	if ((m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_BC(unsigned char opcode)
{
	m_CPURegisters.regs.regC = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_NZ_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regPC = m_MEMPTR;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_NZ_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_BC(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regB);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADD_A_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Add8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_0H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0000;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_Z(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_Z) == FLAG_Z)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

	m_CPURegisters.regPC = m_MEMPTR;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_Z_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_Z) == FLAG_Z)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_Z_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_Z) == FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

	m_CPURegisters.regPC = m_MEMPTR;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_A_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Adc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_8H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0008;
	
	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_NC(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_C) != FLAG_C)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_DE(unsigned char opcode)
{
	m_CPURegisters.regs.regE = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_NC_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_C) != FLAG_C)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_n_A(unsigned char opcode)
{
	unsigned short address = (((unsigned short)m_CPURegisters.regs.regA) << 8) | Z80CoreMemRead(m_CPURegisters.regPC++);
	Z80CoreIOWrite(address, m_CPURegisters.regs.regA);

	m_MEMPTR = (m_CPURegisters.regs.regA << 8) + ((address + 1) & 0xff);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_NC_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_C) != FLAG_C)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_DE(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regD);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SUB_A_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Sub8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_10H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0010;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_C(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_C) == FLAG_C)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EXX(unsigned char opcode)
{
	unsigned short t = m_CPURegisters.reg_pairs.regBC;
	m_CPURegisters.reg_pairs.regBC = m_CPURegisters.reg_pairs.regBC_;
	m_CPURegisters.reg_pairs.regBC_ = t;

	t = m_CPURegisters.reg_pairs.regDE;
	m_CPURegisters.reg_pairs.regDE = m_CPURegisters.reg_pairs.regDE_;
	m_CPURegisters.reg_pairs.regDE_ = t;

	t = m_CPURegisters.reg_pairs.regHL;
	m_CPURegisters.reg_pairs.regHL = m_CPURegisters.reg_pairs.regHL_;
	m_CPURegisters.reg_pairs.regHL_ = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_C_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_C) == FLAG_C)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_A_off_n(unsigned char opcode)
{
	m_MEMPTR = (((unsigned short)m_CPURegisters.regs.regA) << 8) | Z80CoreMemRead(m_CPURegisters.regPC++);
	m_CPURegisters.regs.regA = Z80CoreIORead(m_MEMPTR++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_C_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_C) == FLAG_C)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_A_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Sbc8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_18H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0018;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_PO(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_P) != FLAG_P)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_HL(unsigned char opcode)
{
	m_CPURegisters.regs.regL = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regH = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_PO_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_P) != FLAG_P)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EX_off_SP_HL(unsigned char opcode)
{
	unsigned char tl = Z80CoreMemRead(m_CPURegisters.regSP + 0);
	unsigned char th = Z80CoreMemRead(m_CPURegisters.regSP + 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP + 1, 1);
	Z80CoreMemWrite(m_CPURegisters.regSP + 1, m_CPURegisters.regs.regH);
	Z80CoreMemWrite(m_CPURegisters.regSP + 0, m_CPURegisters.regs.regL);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	Z80CoreMemoryContention(m_CPURegisters.regSP, 1);
	m_CPURegisters.regs.regH = th;
	m_CPURegisters.regs.regL = tl;

	m_MEMPTR = m_CPURegisters.reg_pairs.regHL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_PO_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_P) != FLAG_P)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_HL(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regH);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::AND_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	And(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_20H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0020;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_PE(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_P) == FLAG_P)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_off_HL(unsigned char opcode)
{
	m_CPURegisters.regPC = m_CPURegisters.reg_pairs.regHL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_PE_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_P) == FLAG_P)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EX_DE_HL(unsigned char opcode)
{
	unsigned short t = m_CPURegisters.reg_pairs.regHL;
	m_CPURegisters.reg_pairs.regHL = m_CPURegisters.reg_pairs.regDE;
	m_CPURegisters.reg_pairs.regDE = t;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_PE_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_P) == FLAG_P)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::XOR_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Xor(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_28H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0028;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_P(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_S) != FLAG_S)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::POP_AF(unsigned char opcode)
{
	m_CPURegisters.regs.regF = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_CPURegisters.regs.regA = Z80CoreMemRead(m_CPURegisters.regSP++);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_P_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_S) != FLAG_S)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::DI(unsigned char opcode)
{
	m_CPURegisters.IFF1 = 0;
	m_CPURegisters.IFF2 = 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_P_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_S) != FLAG_S)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::PUSH_AF(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regA);
	Z80CoreMemWrite(--m_CPURegisters.regSP, m_CPURegisters.regs.regF);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OR_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Or(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_30H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0030;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RET_M(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	if ((m_CPURegisters.regs.regF & FLAG_S) == FLAG_S)
	{
		m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
		m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_SP_HL(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regSP = m_CPURegisters.reg_pairs.regHL;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::JP_M_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_S) == FLAG_S)
	{
		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::EI(unsigned char opcode)
{
	m_CPURegisters.IFF1 = 1;
	m_CPURegisters.IFF2 = 1;
	m_CPURegisters.EIHandled = true;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CALL_M_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	if ((m_CPURegisters.regs.regF & FLAG_S) == FLAG_S)
	{
		Z80CoreMemoryContention(m_CPURegisters.regPC - 1, 1);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
		Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);

		m_CPURegisters.regPC = m_MEMPTR;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CP_n(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.regPC++);
	Cp(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RST_38H(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
	Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
	m_CPURegisters.regPC = 0x0038;

	m_MEMPTR = m_CPURegisters.regPC;
}

//-----------------------------------------------------------------------------------------

