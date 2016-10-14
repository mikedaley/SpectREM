//
// TZT ZX Spectrum Emulator
//

#include <iostream>

#include "Z80Core.h"

//-----------------------------------------------------------------------------------------

#include "Z80CoreOpcodeTables.h"

//-----------------------------------------------------------------------------------------

CZ80Core::CZ80Core()
{
	m_MemRead = NULL;
	m_MemWrite = NULL;
	m_IORead = NULL;
	m_IOWrite = NULL;
	m_MemContentionHandling = NULL;
	m_IOContentionHandling = NULL;

	Reset();

}

//-----------------------------------------------------------------------------------------

CZ80Core::~CZ80Core()
{
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Initialise(Z80CoreRead mem_read, Z80CoreWrite mem_write, Z80CoreRead io_read, Z80CoreWrite io_write, Z80CoreContention mem_contention_handling, Z80CoreContention io_contention_handling, int param)
{
	// Store our settings
	m_Param = param;
	m_MemRead = mem_read;
	m_MemWrite = mem_write;
	m_IORead = io_read;
	m_IOWrite = io_write;
	m_MemContentionHandling = mem_contention_handling;
	m_IOContentionHandling = io_contention_handling;

	// Setup the flags tables
	for (int i = 0; i < 256; i++)
	{
		m_SZ35Table[i] = (i == 0) ? FLAG_Z : 0;
		m_SZ35Table[i] |= ((i & 0x80) == 0x80) ? FLAG_S : 0;
		m_SZ35Table[i] |= i & (FLAG_3 | FLAG_5);

		unsigned char parity = 0;
		unsigned char v = i;
		for (int b = 0; b < 8; b++)
		{
			parity ^= v & 1; 
			v >>= 1;
		}

		m_ParityTable[i] = (parity ? 0 : FLAG_P);
	}
}

//-----------------------------------------------------------------------------------------

unsigned char CZ80Core::Z80CoreMemRead(unsigned short address, unsigned int tstates)
{
	// First handle the contention
	Z80CoreMemoryContention(address, tstates);

	if (m_MemRead != NULL)
	{
		return m_MemRead(address, m_Param);
	}

	return 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Z80CoreMemWrite(unsigned short address, unsigned char data, unsigned int tstates)
{
	// First handle the contention
	Z80CoreMemoryContention(address, tstates);

	if (m_MemWrite != NULL)
	{
		m_MemWrite(address, data, m_Param);
	}
}

//-----------------------------------------------------------------------------------------

unsigned char CZ80Core::Z80CoreIORead(unsigned short address)
{
	if (m_IORead != NULL)
	{
		return m_IORead(address, m_Param);
	}

	return 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Z80CoreIOWrite(unsigned short address, unsigned char data)
{
	if (m_IOWrite != NULL)
	{
		m_IOWrite(address, data, m_Param);
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Z80CoreMemoryContention(unsigned short address, unsigned int t_states)
{
	if (m_MemContentionHandling != NULL)
	{
		m_MemContentionHandling(address, t_states, m_Param);
	}

	m_CPURegisters.TStates += t_states;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Z80CoreIOContention(unsigned short address, unsigned int t_states)
{
	if (m_IOContentionHandling != NULL)
	{
		m_IOContentionHandling(address, t_states, m_Param);
	}

	m_CPURegisters.TStates += t_states;
}

//-----------------------------------------------------------------------------------------

int CZ80Core::Execute(int num_tstates, int int_t_states)
{
	int tstates = m_CPURegisters.TStates;

	do
	{
		// First process an interrupt
        if (m_CPURegisters.IntReq)
        {
            if (m_CPURegisters.EIHandled == false && m_CPURegisters.IFF1 != 0 )
            {
                // First see if we are halted?
                if ( m_CPURegisters.Halted )
                {
                    m_CPURegisters.Halted = false;
                    m_CPURegisters.regPC++;
                }
                
                // Process the int required
                m_CPURegisters.IFF1 = 0;
                m_CPURegisters.IFF2 = 0;
                m_CPURegisters.IntReq = false;
                m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);
                
                switch (m_CPURegisters.IM)
                {
                    case 0:
                    case 1:
                    default:
                        Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
                        Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
                        
                        m_CPURegisters.regPC = 0x0038;
                        m_MEMPTR = m_CPURegisters.regPC;
                        m_CPURegisters.TStates += 7;
                        break;
                        
                    case 2:
                        Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
                        Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
                        
                        // Should handle the bus
                        unsigned short address = (m_CPURegisters.regI << 8) | 0;
                        m_CPURegisters.regPC = Z80CoreMemRead(address + 0);
                        m_CPURegisters.regPC |= Z80CoreMemRead(address + 1) << 8;
                        
                        m_MEMPTR = m_CPURegisters.regPC;
                        m_CPURegisters.TStates += 7;
                        break;
                }
            }
        }
        else if (m_CPURegisters.TStates > int_t_states)
        {
            m_CPURegisters.IntReq = false;
        }
        
        // Clear the EIHandle flag
		m_CPURegisters.EIHandled = false;

		Z80OpcodeTable *table = &Main_Opcodes;

		// Read the opcode
		unsigned char opcode = Z80CoreMemRead(m_CPURegisters.regPC, 4);
		m_CPURegisters.regPC++;
		m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);

		// Handle the main bits
		switch (opcode)
		{
		case 0xcb:
			table = &CB_Opcodes;

			// Get the next byte
			opcode = Z80CoreMemRead(m_CPURegisters.regPC, 4);
			m_CPURegisters.regPC++;
			m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);
			break;

		case 0xdd:
			// Get the next byte
			opcode = Z80CoreMemRead(m_CPURegisters.regPC, 4);
			m_CPURegisters.regPC++;
			m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);

			if ( opcode == 0xcb )
			{
				table = &DDCB_Opcodes;

				// Read the offset
				signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);
				m_CPURegisters.regPC++;
				m_MEMPTR = m_CPURegisters.reg_pairs.regIX + offset;

				// Get the next byte
				opcode = Z80CoreMemRead(m_CPURegisters.regPC);
				m_CPURegisters.regPC++;
			}
			else
			{
                table = &DD_Opcodes;
			}
			break;

		case 0xed:
			table = &ED_Opcodes;

			// Get the next byte
			opcode = Z80CoreMemRead(m_CPURegisters.regPC, 4);
			m_CPURegisters.regPC++;
			m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);
			break;

		case 0xfd:
			// Get the next byte
			opcode = Z80CoreMemRead(m_CPURegisters.regPC, 4);
			m_CPURegisters.regPC++;
			m_CPURegisters.regR = (m_CPURegisters.regR & 0x80) | ((m_CPURegisters.regR + 1) & 0x7f);

			if (opcode == 0xcb)
			{
				table = &FDCB_Opcodes;

				// Read the offset
				signed char offset = Z80CoreMemRead(m_CPURegisters.regPC);
				m_CPURegisters.regPC++;
				m_MEMPTR = m_CPURegisters.reg_pairs.regIY + offset;

				// Get the next byte
				opcode = Z80CoreMemRead(m_CPURegisters.regPC);
				m_CPURegisters.regPC++;
			}
			else
			{
                table = &FD_Opcodes;
            }
            break;
		}

		// We can now execute the instruction
		if (table->entries[opcode].function != NULL)
		{
			(this->*table->entries[opcode].function)(opcode);
		}
		
	} while (m_CPURegisters.TStates - tstates < num_tstates);
	
	return m_CPURegisters.TStates - tstates;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SignalInterrupt()
{
	m_CPURegisters.IntReq = true;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Reset(bool hardReset)
{
	// Reset the cpu
	m_CPURegisters.regPC = 0x0000;
	m_CPURegisters.regR = 0;
	m_CPURegisters.regI = 0;

	m_CPURegisters.reg_pairs.regAF = 0xffff;
	m_CPURegisters.reg_pairs.regAF_ = 0xffff;
	m_CPURegisters.regSP = 0xffff;

	m_CPURegisters.IFF1 = 0;
	m_CPURegisters.IFF2 = 0;
	m_CPURegisters.IM = 0;
	m_CPURegisters.Halted = false;
	m_CPURegisters.EIHandled = false;
	m_CPURegisters.IntReq = false;
	m_CPURegisters.TStates = 0;

	if (hardReset == true)
	{
		m_CPURegisters.reg_pairs.regBC = 0x0000;
		m_CPURegisters.reg_pairs.regDE = 0x0000;
		m_CPURegisters.reg_pairs.regHL = 0x0000;
		m_CPURegisters.reg_pairs.regBC_ = 0x0000;
		m_CPURegisters.reg_pairs.regDE_ = 0x0000;
		m_CPURegisters.reg_pairs.regHL_ = 0x0000;
		m_CPURegisters.reg_pairs.regIX = 0x0000;
		m_CPURegisters.reg_pairs.regIY = 0x0000;
	}
}

//-----------------------------------------------------------------------------------------

unsigned char CZ80Core::GetRegister(eZ80BYTEREGISTERS reg) const
{
	unsigned char data;

	switch (reg)
	{
	case eREG_A:		data = m_CPURegisters.regs.regA; break;
	case eREG_F:		data = m_CPURegisters.regs.regF; break;
	case eREG_B:		data = m_CPURegisters.regs.regB; break;
	case eREG_C:		data = m_CPURegisters.regs.regC; break;
	case eREG_D:		data = m_CPURegisters.regs.regD; break;
	case eREG_E:		data = m_CPURegisters.regs.regE; break;
	case eREG_H:		data = m_CPURegisters.regs.regH; break;
	case eREG_L:		data = m_CPURegisters.regs.regL; break;
	case eREG_ALT_A:	data = m_CPURegisters.regs.regA_; break;
	case eREG_ALT_F:	data = m_CPURegisters.regs.regF_; break;
	case eREG_ALT_B:	data = m_CPURegisters.regs.regB_; break;
	case eREG_ALT_C:	data = m_CPURegisters.regs.regC_; break;
	case eREG_ALT_D:	data = m_CPURegisters.regs.regD_; break;
	case eREG_ALT_E:	data = m_CPURegisters.regs.regE_; break;
	case eREG_ALT_H:	data = m_CPURegisters.regs.regH_; break;
	case eREG_ALT_L:	data = m_CPURegisters.regs.regL_; break;
	case eREG_I:		data = m_CPURegisters.regI; break;
	case eREG_R:		data = m_CPURegisters.regR; break;
	}

	return data;
}

//-----------------------------------------------------------------------------------------

unsigned short CZ80Core::GetRegister(eZ80WORDREGISTERS reg) const
{
	unsigned short data;

	switch (reg)
	{
	case eREG_AF:		data = m_CPURegisters.reg_pairs.regAF; break;
	case eREG_HL:		data = m_CPURegisters.reg_pairs.regHL; break;
	case eREG_BC:		data = m_CPURegisters.reg_pairs.regBC; break;
	case eREG_DE:		data = m_CPURegisters.reg_pairs.regDE; break;
	case eREG_ALT_AF:	data = m_CPURegisters.reg_pairs.regAF_; break;
	case eREG_ALT_HL:	data = m_CPURegisters.reg_pairs.regHL_; break;
	case eREG_ALT_BC:	data = m_CPURegisters.reg_pairs.regBC_; break;
	case eREG_ALT_DE:	data = m_CPURegisters.reg_pairs.regDE_; break;
	case eREG_IX:		data = m_CPURegisters.reg_pairs.regIX; break;
	case eREG_IY:		data = m_CPURegisters.reg_pairs.regIY; break;
	case eREG_SP:		data = m_CPURegisters.regSP; break;
	case eREG_PC:		data = m_CPURegisters.regPC; break;
	}

	return data;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SetRegister(eZ80BYTEREGISTERS reg, unsigned char data)
{
	switch (reg)
	{
	case eREG_A:		m_CPURegisters.regs.regA = data; break;
	case eREG_F:		m_CPURegisters.regs.regF = data; break;
	case eREG_B:		m_CPURegisters.regs.regB = data; break;
	case eREG_C:		m_CPURegisters.regs.regC = data; break;
	case eREG_D:		m_CPURegisters.regs.regD = data; break;
	case eREG_E:		m_CPURegisters.regs.regE = data; break;
	case eREG_H:		m_CPURegisters.regs.regH = data; break;
	case eREG_L:		m_CPURegisters.regs.regL = data; break;
	case eREG_ALT_A:	m_CPURegisters.regs.regA_ = data; break;
	case eREG_ALT_F:	m_CPURegisters.regs.regF_ = data; break;
	case eREG_ALT_B:	m_CPURegisters.regs.regB_ = data; break;
	case eREG_ALT_C:	m_CPURegisters.regs.regC_ = data; break;
	case eREG_ALT_D:	m_CPURegisters.regs.regD_ = data; break;
	case eREG_ALT_E:	m_CPURegisters.regs.regE_ = data; break;
	case eREG_ALT_H:	m_CPURegisters.regs.regH_ = data; break;
	case eREG_ALT_L:	m_CPURegisters.regs.regL_ = data; break;
	case eREG_I:		m_CPURegisters.regI = data; break;
	case eREG_R:		m_CPURegisters.regR = data; break;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SetRegister(eZ80WORDREGISTERS reg, unsigned short data)
{
	switch (reg)
	{
	case eREG_AF:		m_CPURegisters.reg_pairs.regAF = data; break;
	case eREG_HL:		m_CPURegisters.reg_pairs.regHL = data; break;
	case eREG_BC:		m_CPURegisters.reg_pairs.regBC = data; break;
	case eREG_DE:		m_CPURegisters.reg_pairs.regDE = data; break;
	case eREG_ALT_AF:	m_CPURegisters.reg_pairs.regAF_ = data; break;
	case eREG_ALT_HL:	m_CPURegisters.reg_pairs.regHL_ = data; break;
	case eREG_ALT_BC:	m_CPURegisters.reg_pairs.regBC_ = data; break;
	case eREG_ALT_DE:	m_CPURegisters.reg_pairs.regDE_ = data; break;
	case eREG_IX:		m_CPURegisters.reg_pairs.regIX = data; break;
	case eREG_IY:		m_CPURegisters.reg_pairs.regIY = data; break;
	case eREG_SP:		m_CPURegisters.regSP = data; break;
	case eREG_PC:		m_CPURegisters.regPC = data; break;
	}
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Debug()
{
	// TO DO
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Inc(unsigned char &r)
{
	// Increase the register
	r++;

	// Now sort the flags
	m_CPURegisters.regs.regF = m_CPURegisters.regs.regF & FLAG_C;
	m_CPURegisters.regs.regF |= (r == 0x80) ? FLAG_V : 0;
	m_CPURegisters.regs.regF |= ((r & 0x0f) == 0x00) ? FLAG_H : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Dec(unsigned char &r)
{
	// Sort the initial flags
	m_CPURegisters.regs.regF = m_CPURegisters.regs.regF & FLAG_C;
	m_CPURegisters.regs.regF |= FLAG_N;
	m_CPURegisters.regs.regF |= ((r & 0x0f) == 0x00) ? FLAG_H : 0;

	// Decrease the register
	r--;

	// Now sort the flags
	m_CPURegisters.regs.regF |= (r == 0x7f) ? FLAG_V : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Add8(unsigned char &r)
{
	static unsigned char halfcarry_lookup[] = { 0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, 0, 0, FLAG_V, FLAG_V, 0, 0, 0 };

	// Get the full answer
	unsigned short full_answer = m_CPURegisters.regs.regA + r;

	// Work out the half carry
	int lookup = ((m_CPURegisters.regs.regA & 0x88) >> 3) | ((r & 0x88) >> 2) | ((full_answer & 0x88) >> 1);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4];

	// Set the answer
	m_CPURegisters.regs.regA = (full_answer & 0xff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x100) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Adc8(unsigned char &r)
{
	static unsigned char halfcarry_lookup[] = { 0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, 0, 0, FLAG_V, FLAG_V, 0, 0, 0 };

	// Get the full answer
	unsigned short full_answer = m_CPURegisters.regs.regA + r;
	full_answer += ((m_CPURegisters.regs.regF & FLAG_C) ? 1 : 0);

	// Work out the half carry
	int lookup = ((m_CPURegisters.regs.regA & 0x88) >> 3) | ((r & 0x88) >> 2) | ((full_answer & 0x88) >> 1);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4];

	// Set the answer
	m_CPURegisters.regs.regA = (full_answer & 0xff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x100) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Sub8(unsigned char &r)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, FLAG_V, 0, 0, 0, 0, FLAG_V, 0 };

	// Get the full answer
	unsigned short full_answer = m_CPURegisters.regs.regA - r;

	// Work out the half carry
	int lookup = ((m_CPURegisters.regs.regA & 0x88) >> 3) | ((r & 0x88) >> 2) | ((full_answer & 0x88) >> 1);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4] | FLAG_N;

	// Set the answer
	m_CPURegisters.regs.regA = (full_answer & 0xff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x100) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Sbc8(unsigned char &r)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, FLAG_V, 0, 0, 0, 0, FLAG_V, 0 };

	// Get the full answer
	unsigned short full_answer = m_CPURegisters.regs.regA - r;
	full_answer -= ((m_CPURegisters.regs.regF & FLAG_C) ? 1 : 0);

	// Work out the half carry
	int lookup = ((m_CPURegisters.regs.regA & 0x88) >> 3) | ((r & 0x88) >> 2) | ((full_answer & 0x88) >> 1);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4] | FLAG_N;

	// Set the answer
	m_CPURegisters.regs.regA = (full_answer & 0xff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x100) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Add16(unsigned short &r1, unsigned short &r2)
{
	static unsigned char halfcarry_lookup[] = { 0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H };

	// Set memptr
	m_MEMPTR = r1 + 1;

	// Get the full answer
	unsigned int full_answer = r1 + r2;

	// Work out the half carry
	int lookup = ((r1 & 0x0800) >> 11) | ((r2 & 0x0800) >> 10) | ((full_answer & 0x0800) >> 9);
	m_CPURegisters.regs.regF = (m_CPURegisters.regs.regF & (FLAG_P | FLAG_Z | FLAG_S)) | halfcarry_lookup[lookup];

	// Set the answer
	r1 = (full_answer & 0xffff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x10000) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= ((full_answer >> 8) & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Adc16(unsigned short &r1, unsigned short &r2)
{
	static unsigned char halfcarry_lookup[] = { 0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, 0, 0, FLAG_V, FLAG_V, 0, 0, 0 };

	// Set memptr
	m_MEMPTR = r1 + 1;

	// Get the full answer
	unsigned int full_answer = r1 + r2;
	full_answer += ((m_CPURegisters.regs.regF & FLAG_C) ? 1 : 0);

	// Work out the half carry
	int lookup = ((r1 & 0x8800) >> 11) | ((r2 & 0x8800) >> 10) | ((full_answer & 0x8800) >> 9);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4];

	// Set the answer
	r1 = (full_answer & 0xffff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x10000) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= (r1 >> 8) & (FLAG_3 | FLAG_5);
	m_CPURegisters.regs.regF |= ((r1 & 0x8000) == 0x8000) ? FLAG_S : 0;
	m_CPURegisters.regs.regF |= (r1 == 0x0000) ? FLAG_Z : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Sbc16(unsigned short &r1, unsigned short &r2)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, FLAG_V, 0, 0, 0, 0, FLAG_V, 0 };

	// Set memptr
	m_MEMPTR = r1 + 1;

	// Get the full answer
	unsigned int full_answer = r1 - r2;
	full_answer -= ((m_CPURegisters.regs.regF & FLAG_C) ? 1 : 0);

	// Work out the half carry
	int lookup = ((r1 & 0x8800) >> 11) | ((r2 & 0x8800) >> 10) | ((full_answer & 0x8800) >> 9);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4] | FLAG_N;

	// Set the answer
	r1 = (full_answer & 0xffff);

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x10000) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= (r1 >> 8) & (FLAG_3 | FLAG_5);
	m_CPURegisters.regs.regF |= ((r1 & 0x8000) == 0x8000) ? FLAG_S : 0;
	m_CPURegisters.regs.regF |= (r1 == 0x0000) ? FLAG_Z : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::And(unsigned char &r)
{
	m_CPURegisters.regs.regA &= r;
	m_CPURegisters.regs.regF = m_ParityTable[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA] | FLAG_H;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Or(unsigned char &r)
{
	m_CPURegisters.regs.regA |= r;
	m_CPURegisters.regs.regF = m_ParityTable[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Xor(unsigned char &r)
{
	m_CPURegisters.regs.regA ^= r;
	m_CPURegisters.regs.regF = m_ParityTable[m_CPURegisters.regs.regA];
	m_CPURegisters.regs.regF |= m_SZ35Table[m_CPURegisters.regs.regA];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Cp(unsigned char &r)
{
	static unsigned char halfcarry_lookup[] = { 0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H };
	static unsigned char overflow_lookup[] = { 0, FLAG_V, 0, 0, 0, 0, FLAG_V, 0 };

	// Get the full answer
	unsigned short full_answer = m_CPURegisters.regs.regA - r;

	// Work out the half carry
	int lookup = ((m_CPURegisters.regs.regA & 0x88) >> 3) | ((r & 0x88) >> 2) | ((full_answer & 0x88) >> 1);
	m_CPURegisters.regs.regF = halfcarry_lookup[lookup & 7] | overflow_lookup[lookup >> 4] | FLAG_N;

	// Finish the flags
	m_CPURegisters.regs.regF |= (full_answer & 0x100) == 0 ? 0 : FLAG_C;
	m_CPURegisters.regs.regF |= (full_answer == 0x00) ? FLAG_Z : 0;
	m_CPURegisters.regs.regF |= ((full_answer & 0x80) == 0x80) ? FLAG_S : 0;
	m_CPURegisters.regs.regF |= (r & (FLAG_3 | FLAG_5));
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RLC(unsigned char &r)
{
	r = (r << 1) | (r >> 7);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (r & 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RRC(unsigned char &r)
{
	r = (r >> 1) | (r << 7);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (r & 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RL(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r << 1) | ((m_CPURegisters.regs.regF & FLAG_C) ? 0x01 : 0x00);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RR(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r >> 1) | ((m_CPURegisters.regs.regF & FLAG_C) ? 0x80 : 0x00);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLA(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r << 1);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRA(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r & 0x80) | (r >> 1);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SRL(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r >> 1);
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x01) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::SLL(unsigned char &r)
{
	unsigned char old_r = r;
	r = (r << 1) | 0x01;
	m_CPURegisters.regs.regF = m_ParityTable[r];
	m_CPURegisters.regs.regF |= (old_r & 0x80) ? FLAG_C : 0;
	m_CPURegisters.regs.regF |= m_SZ35Table[r];
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Bit(unsigned char &r, unsigned char b)
{
	m_CPURegisters.regs.regF &= FLAG_C;
	m_CPURegisters.regs.regF |= FLAG_H;
	m_CPURegisters.regs.regF |= (r & (FLAG_3 | FLAG_5));
	m_CPURegisters.regs.regF |= !(r & (1 << b)) ? (FLAG_Z | FLAG_P) : 0;
	m_CPURegisters.regs.regF |= (b == 7 && (r & 0x80)) ? FLAG_S : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::BitWithMemptr(unsigned char &r, unsigned char b)
{
	m_CPURegisters.regs.regF &= FLAG_C;
	m_CPURegisters.regs.regF |= FLAG_H;
	m_CPURegisters.regs.regF |= (m_MEMPTR >> 8) & (FLAG_3 | FLAG_5);
	m_CPURegisters.regs.regF |= !(r & (1 << b)) ? (FLAG_Z | FLAG_P) : 0;
	m_CPURegisters.regs.regF |= (b == 7 && (r & 0x80)) ? FLAG_S : 0;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Set(unsigned char &r, unsigned char b)
{
	r |= (1 << b);
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Res(unsigned char &r, unsigned char b)
{
	r &= ~(1 << b);
}

//-----------------------------------------------------------------------------------------
