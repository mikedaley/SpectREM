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
	m_DebugRead = NULL;
	m_OpcodeCallback = NULL;
	m_DebugCallback = NULL;
    m_CPUType = eCPUTYPE_Zilog;
	m_PrevOpcodeFlags = 0;

	Reset();

}

//-----------------------------------------------------------------------------------------

CZ80Core::~CZ80Core()
{
}

//-----------------------------------------------------------------------------------------

void CZ80Core::Initialise(Z80CoreRead mem_read, Z80CoreWrite mem_write, Z80CoreRead io_read, Z80CoreWrite io_write, Z80CoreContention mem_contention_handling, Z80CoreDebugRead debug_read_handler, Z80CoreDebugWrite debug_write_handler,void *param)
{
	// Store our settings
	m_Param = param;
	m_MemRead = mem_read;
	m_MemWrite = mem_write;
	m_IORead = io_read;
	m_IOWrite = io_write;
	m_MemContentionHandling = mem_contention_handling;
	m_DebugRead = debug_read_handler;
	m_Debugwrite = debug_write_handler;

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

void CZ80Core::RegisterOpcodeCallback(Z80OpcodeCallback callback)
{
	// Set the callback
	m_OpcodeCallback = callback;
}

//-----------------------------------------------------------------------------------------

void CZ80Core::RegisterDebugCallback(Z80DebugCallback callback)
{
	// Set the callback
	m_DebugCallback = callback;
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

unsigned char CZ80Core::Z80CoreDebugMemRead(unsigned int address, void *data)
{
	if (m_DebugRead != NULL)
	{
		return m_DebugRead(address, m_Param, data);
	}

	return 0;
}

//-----------------------------------------------------------------------------------------
void CZ80Core::Z80CoreDebugMemWrite(unsigned int address, unsigned char byte, void *data)
{
	if (m_Debugwrite != NULL)
	{
		m_Debugwrite(address, byte, m_Param, data);
	}
}


//-----------------------------------------------------------------------------------------

int CZ80Core::Execute(unsigned int num_tstates, unsigned int int_t_states)
{
	unsigned int tstates = m_CPURegisters.TStates;
    
	do
	{
		// Check if an NMI has been requested
		if (m_CPURegisters.NMIReq)
		{
			m_CPURegisters.NMIReq = false;
			m_CPURegisters.IFF1 = 0;
			if (!m_CPURegisters.IntReq)
			{
				m_CPURegisters.IFF2 = 0;
			}
			Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 8) & 0xff);
			Z80CoreMemWrite(--m_CPURegisters.regSP, (m_CPURegisters.regPC >> 0) & 0xff);
			
			if ( m_CPURegisters.Halted )
			{
				m_CPURegisters.Halted = false;
			}
			
			m_CPURegisters.regPC = 0x0066;
			
		}
		else if (m_CPURegisters.IntReq)
        {
            if (m_CPURegisters.EIHandled == false &&
                m_CPURegisters.DDFDmultiByte == false &&
                m_CPURegisters.IFF1 != 0 &&
                m_CPURegisters.TStates < int_t_states )
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
                        
                        // Hardware would normally put a value on the bus to be used with regI when working out
                        // the address for the IM 2 jump table. With no hardware connected this is defaulted to
                        // 0xff
                        unsigned short address = (m_CPURegisters.regI << 8) | 0xff;
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
        
        // Clear the multibyte flags in case the next instruction is not part of a multibyte instruction
        m_CPURegisters.DDFDmultiByte = false;

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

		// Handle if the callback wants to skip over this instruction
		bool skip_instruction = false;
		
		// Handle a callback if needed
		if (m_OpcodeCallback != NULL)
		{
			// Callback before doing the opcode
			skip_instruction = m_OpcodeCallback(opcode, m_CPURegisters.regPC - 1, m_Param);
		}
		
		if ( !skip_instruction )
		{
        	// We can now execute the instruction
        	if (table->entries[opcode].function != NULL)
        	{
        	    // Execute the opcode
        	    (this->*table->entries[opcode].function)(opcode);
				
				// Remember the details of if we updated flags
				m_PrevOpcodeFlags = table->entries[opcode].flags;
        	}
        	else
        	{
        	    // If no function has been found for the second opcode of a DD/FD multibyte instruction
        	    // then use it as a prefix. Drop the PC back 1 and carry on processing the next opcode and set
        	    // the chaining flag so we can stop interrupts until the chain has finished
				
        	    // TODO: This could be run if an undocumented opcode is found which would break!!!
        	    m_CPURegisters.DDFDmultiByte = true;
        	    m_CPURegisters.regPC--;
        	    m_CPURegisters.regR--;
        	    m_CPURegisters.TStates -= 4;
			}
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

unsigned int CZ80Core::Debug_Disassemble(char *pStr, unsigned int StrLen, unsigned int address, bool hexFormat, void *data)
{
	// Why would you do this! ;)
	if (pStr == NULL)
	{
		return 0;
	}

	// Get the details we need
	unsigned int start_address = address;
	const char *pDisassembleString = Debug_GetOpcodeDetails(address, data);

	// If we dont have a valid instruction - skip
	if ( pDisassembleString != NULL )
	{
		// Now write out the string including the extra bits
		while (StrLen > 1 && *pDisassembleString != '\0')
		{
			// Is this a special command
			if (*pDisassembleString == '%')
			{
				// Yes - See which
				pDisassembleString++;

				switch (*pDisassembleString++)
				{
				case '\0':
				default:
					break;

				case 'O':
					// This is an offset byte - always 2 bytes passed the start
					pStr = Debug_WriteData(eVARIABLETYPE_IndexOffset, pStr, StrLen, start_address + 2, hexFormat, data);
					break;

				case 'B':
					// This is a data byte - always the previous byte
					pStr = Debug_WriteData(eVARIABLETYPE_Byte, pStr, StrLen, address - 1, hexFormat, data);
					break;

				case 'W':
					// This is a data word - always the previous word
					pStr = Debug_WriteData(eVARIABLETYPE_Word, pStr, StrLen, address - 2, hexFormat, data);
					break;

				case 'R':
					// Write the relative offset
					pStr = Debug_WriteData(eVARIABLETYPE_RelativeOffset, pStr, StrLen, address - 1, hexFormat, data);
					break;
				}
			}
			else
			{
				// No just copy
				*pStr++ = *pDisassembleString++;
				StrLen--;
			}
		}
	}

	// Terminate the string
	if ( StrLen > 0 )
	{
		*pStr++ = '\0';
	}

	return (address - start_address);
}

//-----------------------------------------------------------------------------------------

char *CZ80Core::Debug_WriteData(unsigned int variableType, char *pStr, unsigned int &StrLen, unsigned int address, bool hexFormat, void *data)
{
	// Get the number
	unsigned short num = 0;
	char number_buffer[64];
	char *buffer = number_buffer;
	
	switch (variableType)
	{
		case eVARIABLETYPE_IndexOffset:
		case eVARIABLETYPE_Byte:
			num = Z80CoreDebugMemRead(address, data);
			if ( hexFormat )
			{
				sprintf(number_buffer, "$%02X", num);
			}
			else
			{
				sprintf(number_buffer, "%02i", num);
			}
			break;
			
		case eVARIABLETYPE_RelativeOffset:
		{
			signed char rnum = Z80CoreDebugMemRead(address, data);
			num = Z80CoreDebugMemRead(address, data);
			if (hexFormat)
			{
				sprintf(number_buffer, "$%04X", address + rnum + 1);
			}
			else
			{
				sprintf(number_buffer, "%04i", address + rnum + 1);
			}
			break;
		}
			
		case eVARIABLETYPE_Word:
			num = Z80CoreDebugMemRead(address, data) | (Z80CoreDebugMemRead(address + 1, data) << 8);
			if ( hexFormat )
			{
				sprintf(number_buffer, "$%04X", num);
			}
			else
			{
				sprintf(number_buffer, "%04i", num);
			}
			break;
	}
	
	// See if the program wants to alter the display
	if ( m_DebugCallback != NULL )
	{
		buffer = m_DebugCallback(buffer, variableType, address, num, m_Param, data);
	}

	// Now copy it
	if ( buffer != NULL )
	{
		while (StrLen > 1 && *buffer != '\0')
		{
			*pStr++ = *buffer++;
			StrLen--;
		}
	}

	return pStr;
}

//-----------------------------------------------------------------------------------------

unsigned int CZ80Core::Debug_GetOpcodeLength(unsigned int address, void *data)
{
	// Remember the start
	unsigned int start_address = address;

	// Get the details
	Debug_GetOpcodeDetails(address, data);

	return (address - start_address);
}

//-----------------------------------------------------------------------------------------

bool CZ80Core::Debug_HasValidOpcode(unsigned int address, void *data)
{
	if (Debug_GetOpcodeDetails(address, data) == NULL)
	{
		return false;
	}

	return true;
}

//-----------------------------------------------------------------------------------------

const char *CZ80Core::Debug_GetOpcodeDetails(unsigned int &address, void *data)
{
	Z80OpcodeTable *table = &Main_Opcodes;

	// Read the opcode
	unsigned int opcode_length = 0;
	unsigned char opcode = Z80CoreDebugMemRead(address + opcode_length, data);
	opcode_length++;

	// Handle the main bits
	switch (opcode)
	{
	case 0xcb:
		table = &CB_Opcodes;
		opcode = Z80CoreDebugMemRead(address + opcode_length, data);
		opcode_length++;
		break;

	case 0xdd:
		opcode = Z80CoreDebugMemRead(address + opcode_length, data);
		opcode_length++;

		if (opcode == 0xcb)
		{
			table = &DDCB_Opcodes;

			// Get the next byte
			opcode = Z80CoreDebugMemRead(address + opcode_length + 1, data);
			opcode_length++;
		}
		else
		{
			table = &DD_Opcodes;
		}
		break;

	case 0xed:
		table = &ED_Opcodes;
		opcode = Z80CoreDebugMemRead(address + opcode_length, data);
		opcode_length++;
		break;

	case 0xfd:
		opcode = Z80CoreDebugMemRead(address + opcode_length, data);
		opcode_length++;

		if (opcode == 0xcb)
		{
			table = &FDCB_Opcodes;

			// Get the next byte
			opcode = Z80CoreDebugMemRead(address + opcode_length + 1, data);
			opcode_length++;
		}
		else
		{
			table = &FD_Opcodes;
		}
		break;
	}

	// If this is invalid - return 0
	if (table->entries[opcode].function == NULL)
	{
		return NULL;
	}

	// Now we need to scan the string for any extra bytes needed
	const char *pDisassembleString = table->entries[opcode].format;

	while (*pDisassembleString != '\0')
	{
		// Extra data
		if (*pDisassembleString == '%')
		{
			pDisassembleString++;

			switch (*pDisassembleString)
			{
			case '\0':
			default:
				break;

			case 'B':
			case 'O':
			case 'R':
				opcode_length++;
				break;

			case 'W':
				opcode_length += 2;
				break;
			}
		}

		pDisassembleString++;
	}

	// Offset the address
	address += opcode_length;

	// Return the string
	return table->entries[opcode].format;
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
