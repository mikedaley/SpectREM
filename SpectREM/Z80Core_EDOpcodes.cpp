#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_B_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regB = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_B(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_HL_BC(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Sbc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_BC(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regC);
	Z80CoreMemWrite(m_MEMPTR, m_CPURegisters.regs.regB);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::NEG(unsigned char opcode)
{
	unsigned char t = m_CPURegisters.regs.regA;
	m_CPURegisters.regs.regA = 0;
	Sub8(t);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RETN(unsigned char opcode)
{
	m_CPURegisters.IFF1 = m_CPURegisters.IFF2;

	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

	m_CPURegisters.regPC = m_MEMPTR;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IM_0(unsigned char opcode)
{
	m_CPURegisters.IM = 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_I_A(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regI = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_C_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regC = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_C(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_HL_BC(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Adc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_BC_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regC = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regs.regB = Z80CoreMemRead(m_MEMPTR);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RETI(unsigned char opcode)
{
	m_CPURegisters.IFF1 = m_CPURegisters.IFF2;

	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regSP++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regSP++) << 8;

	m_CPURegisters.regPC = m_MEMPTR;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_R_A(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regR = m_CPURegisters.regs.regA;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_D_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regD = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_D(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_HL_DE(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Sbc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regDE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_DE(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regs.regE);
	Z80CoreMemWrite(m_MEMPTR, m_CPURegisters.regs.regD);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IM_1(unsigned char opcode)
{
	m_CPURegisters.IM = 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_I(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regs.regA = m_CPURegisters.regI;
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & FLAG_C);
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= (m_CPURegisters.IFF2 == 0) ? 0 : FLAG_V;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_E_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regD = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_E(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_HL_DE(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Adc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regDE);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_DE_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regs.regE = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regs.regD = Z80CoreMemRead(m_MEMPTR);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IM_2(unsigned char opcode)
{
	m_CPURegisters.IM = 2;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_A_R(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	m_CPURegisters.regs.regA = m_CPURegisters.regR;
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & FLAG_C);
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= (m_CPURegisters.IFF2 == 0) ? 0 : FLAG_V;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_H_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regH = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_H(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regH);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_HL_HL(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Sbc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRD(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, (m_CPURegisters.regs.regA << 4) | (t >> 4));
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA & 0xf0) | (t & 0x0f);
	m_CPURegisters.regs.regF = m_CPURegisters.regs.regF & FLAG_C;
	m_CPURegisters.regs.regF |= m_ParityTable[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];

	m_MEMPTR = m_CPURegisters.reg_pairs.regHL + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_L_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regL = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_L(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_HL_HL(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Adc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.reg_pairs.regHL);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLD(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, (m_CPURegisters.regs.regA & 0x0f) | (t << 4));
	m_CPURegisters.regs.regA = (m_CPURegisters.regs.regA & 0xf0) | (t >> 4);
	m_CPURegisters.regs.regF = m_CPURegisters.regs.regF & FLAG_C;
	m_CPURegisters.regs.regF |= m_ParityTable[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];

	m_MEMPTR = m_CPURegisters.reg_pairs.regHL + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_F_off_C(unsigned char opcode)
{
	Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_0(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, 0);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SBC_HL_SP(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Sbc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regSP);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_off_nn_SP(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	Z80CoreMemWrite(m_MEMPTR++, m_CPURegisters.regSP & 0xff);
	Z80CoreMemWrite(m_MEMPTR, (m_CPURegisters.regSP >> 8) & 0xff);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IN_A_off_C(unsigned char opcode)
{
	m_CPURegisters.regs.regA = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
	m_MEMPTR = m_CPURegisters.reg_pairs.regBC + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUT_off_C_A(unsigned char opcode)
{
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, m_CPURegisters.regs.regA);
	m_MEMPTR = m_CPURegisters.reg_pairs.regBC + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::ADC_HL_SP(unsigned char opcode)
{
	// Handle contention
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);

	Adc16(m_CPURegisters.reg_pairs.regHL, m_CPURegisters.regSP);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LD_SP_off_nn(unsigned char opcode)
{
	m_MEMPTR = Z80CoreMemRead(m_CPURegisters.regPC++);
	m_MEMPTR |= Z80CoreMemRead(m_CPURegisters.regPC++) << 8;

	m_CPURegisters.regSP = Z80CoreMemRead(m_MEMPTR++);
	m_CPURegisters.regSP |= (Z80CoreMemRead(m_MEMPTR) << 8);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LDI(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regDE, t);

	// Get the temp stuff for flags
	t += m_CPURegisters.regs.regA;

	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE, 1);

	m_CPURegisters.reg_pairs.regDE++;
	m_CPURegisters.reg_pairs.regHL++;
	m_CPURegisters.reg_pairs.regBC--;

	m_CPURegisters.regs.regF &= (FLAG_C | FLAG_S | FLAG_Z);
	m_CPURegisters.regs.regF |= (m_CPURegisters.reg_pairs.regBC != 0) ? FLAG_V : 0;
	m_CPURegisters.regs.regF |= (t & (1 << 1)) ? FLAG_5 : 0;
	m_CPURegisters.regs.regF |= (t & (1 << 3)) ? FLAG_3 : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CPI(unsigned char opcode)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };

	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	unsigned short full_answer = m_CPURegisters.regs.regA - t;

	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);

	m_CPURegisters.reg_pairs.regHL++;
	m_CPURegisters.reg_pairs.regBC--;

	int lookup = ((m_CPURegisters.regs.regA & 0x08) >> 3) | ((t & 0x08) >> 2) | ((full_answer & 0x08) >> 1);
	m_CPURegisters.regs.regF &= FLAG_C;
	m_CPURegisters.regs.regF |= (full_answer == 0) ? FLAG_Z : 0;
	m_CPURegisters.regs.regF |= ((full_answer & 0x80) == 0x80) ? FLAG_S : 0;
	m_CPURegisters.regs.regF |= (halfcarry_lookup[lookup] | FLAG_N);
	m_CPURegisters.regs.regF |= (m_CPURegisters.reg_pairs.regBC != 0) ? FLAG_V : 0;

	if (m_CPURegisters.regs.regF & FLAG_H)
	{
		full_answer--;
	}

	m_CPURegisters.regs.regF |= (full_answer & (1 << 1)) ? FLAG_5 : 0;
	m_CPURegisters.regs.regF |= (full_answer & (1 << 3)) ? FLAG_3 : 0;

	m_MEMPTR++;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INI(unsigned char opcode)
{
	m_MEMPTR = m_CPURegisters.reg_pairs.regBC + 1;

	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	unsigned char t = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
	m_CPURegisters.reg_pairs.regHL++;
	m_CPURegisters.regs.regB--;

	unsigned short temp = ((m_CPURegisters.regs.regC + 1) & 0xff) + t;

	m_CPURegisters.regs.regF = m_SZ35Table[m_CPURegisters.regs.regB];
	m_CPURegisters.regs.regF |= ((t & 0x80) == 0x80) ? FLAG_N : 0;
	m_CPURegisters.regs.regF |= (temp > 255) ? (FLAG_H | FLAG_C) : 0;
	m_CPURegisters.regs.regF |= m_ParityTable[((temp & 7) ^ m_CPURegisters.regs.regB)];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUTI(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	m_CPURegisters.regs.regB--;
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, t);
	m_CPURegisters.reg_pairs.regHL++;

	unsigned short temp = m_CPURegisters.regs.regL + t;

	m_CPURegisters.regs.regF = m_SZ35Table[m_CPURegisters.regs.regB];
	m_CPURegisters.regs.regF |= ((t & 0x80) == 0x80) ? FLAG_N : 0;
	m_CPURegisters.regs.regF |= (temp > 255) ? (FLAG_H | FLAG_C) : 0;
	m_CPURegisters.regs.regF |= m_ParityTable[((temp & 7) ^ m_CPURegisters.regs.regB)];

	m_MEMPTR = m_CPURegisters.reg_pairs.regBC + 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LDD(unsigned char opcode)
{
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regDE, t);

	// Add for flags
	t += m_CPURegisters.regs.regA;

	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE, 1);

	m_CPURegisters.reg_pairs.regDE--;
	m_CPURegisters.reg_pairs.regHL--;
	m_CPURegisters.reg_pairs.regBC--;

	m_CPURegisters.regs.regF &= (FLAG_C | FLAG_S | FLAG_Z);
	m_CPURegisters.regs.regF |= (m_CPURegisters.reg_pairs.regBC != 0) ? FLAG_V : 0;
	m_CPURegisters.regs.regF |= (t & (1 << 1)) ? FLAG_5 : 0;
	m_CPURegisters.regs.regF |= (t & (1 << 3)) ? FLAG_3 : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CPD(unsigned char opcode)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };

	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	unsigned short full_answer = m_CPURegisters.regs.regA - t;

	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);
	Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL, 1);

	m_CPURegisters.reg_pairs.regHL--;
	m_CPURegisters.reg_pairs.regBC--;

	int lookup = ((m_CPURegisters.regs.regA & 0x08) >> 3) | ((t & 0x08) >> 2) | ((full_answer & 0x08) >> 1);
	m_CPURegisters.regs.regF &= FLAG_C;
	m_CPURegisters.regs.regF |= (full_answer == 0) ? FLAG_Z : 0;
	m_CPURegisters.regs.regF |= ((full_answer & 0x80) == 0x80) ? FLAG_S : 0;
	m_CPURegisters.regs.regF |= (halfcarry_lookup[lookup] | FLAG_N);
	m_CPURegisters.regs.regF |= (m_CPURegisters.reg_pairs.regBC != 0) ? FLAG_V : 0;

	if (m_CPURegisters.regs.regF & FLAG_H)
	{
		full_answer--;
	}

	m_CPURegisters.regs.regF |= (full_answer & (1 << 1)) ? FLAG_5 : 0;
	m_CPURegisters.regs.regF |= (full_answer & (1 << 3)) ? FLAG_3 : 0;

	m_MEMPTR--;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::IND(unsigned char opcode)
{
	m_MEMPTR = m_CPURegisters.reg_pairs.regBC - 1;

	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	unsigned char t = Z80CoreIORead(m_CPURegisters.reg_pairs.regBC);
	Z80CoreMemWrite(m_CPURegisters.reg_pairs.regHL, t);
	m_CPURegisters.reg_pairs.regHL--;
	m_CPURegisters.regs.regB--;

	unsigned short temp = ((m_CPURegisters.regs.regC - 1) & 0xff) + t;

	m_CPURegisters.regs.regF = m_SZ35Table[m_CPURegisters.regs.regB];
	m_CPURegisters.regs.regF |= ((t & 0x80) == 0x80) ? FLAG_N : 0;
	m_CPURegisters.regs.regF |= (temp > 255) ? (FLAG_H | FLAG_C) : 0;
	m_CPURegisters.regs.regF |= m_ParityTable[((temp & 7) ^ m_CPURegisters.regs.regB)];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OUTD(unsigned char opcode)
{
	Z80CoreMemoryContention((m_CPURegisters.regI << 8) | m_CPURegisters.regR, 1);
	unsigned char t = Z80CoreMemRead(m_CPURegisters.reg_pairs.regHL);
	m_CPURegisters.regs.regB--;
	Z80CoreIOWrite(m_CPURegisters.reg_pairs.regBC, t);
	m_CPURegisters.reg_pairs.regHL--;

	unsigned short temp = m_CPURegisters.regs.regL + t;

	m_CPURegisters.regs.regF = m_SZ35Table[m_CPURegisters.regs.regB];
	m_CPURegisters.regs.regF |= ((t & 0x80) == 0x80) ? FLAG_N : 0;
	m_CPURegisters.regs.regF |= (temp > 255) ? (FLAG_H | FLAG_C) : 0;
	m_CPURegisters.regs.regF |= m_ParityTable[((temp & 7) ^ m_CPURegisters.regs.regB)];

	m_MEMPTR = m_CPURegisters.reg_pairs.regBC - 1;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LDIR(unsigned char opcode)
{
	LDI(opcode);

	if (m_CPURegisters.reg_pairs.regBC != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE - 1, 1);
		m_CPURegisters.regPC -= 2;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CPIR(unsigned char opcode)
{
	CPI(opcode);

	if (m_CPURegisters.reg_pairs.regBC != 0 && (m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		m_CPURegisters.regPC -= 2;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INIR(unsigned char opcode)
{
	INI(opcode);

	if (m_CPURegisters.regs.regB != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL - 1, 1);
		m_CPURegisters.regPC -= 2;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OTIR(unsigned char opcode)
{
	OUTI(opcode);

	if (m_CPURegisters.regs.regB != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		m_CPURegisters.regPC -= 2;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::LDDR(unsigned char opcode)
{
	LDD(opcode);

	if (m_CPURegisters.reg_pairs.regBC != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regDE + 1, 1);
		m_CPURegisters.regPC -= 2;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::CPDR(unsigned char opcode)
{
	CPD(opcode);

	if (m_CPURegisters.reg_pairs.regBC != 0 && (m_CPURegisters.regs.regF & FLAG_Z) != FLAG_Z)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		m_CPURegisters.regPC -= 2;
		m_MEMPTR = m_CPURegisters.regPC + 1;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::INDR(unsigned char opcode)
{
	IND(opcode);

	if (m_CPURegisters.regs.regB != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regHL + 1, 1);
		m_CPURegisters.regPC -= 2;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::OTDR(unsigned char opcode)
{
	OUTD(opcode);

	if (m_CPURegisters.regs.regB != 0)
	{
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		Z80CoreMemoryContention(m_CPURegisters.reg_pairs.regBC, 1);
		m_CPURegisters.regPC -= 2;
	}
}

//-----------------------------------------------------------------------------------------

