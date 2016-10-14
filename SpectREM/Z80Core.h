//
// TZT ZX Spectrum Emulator
//

#ifndef __Z80CORE_H__
#define __Z80CORE_H__

//-----------------------------------------------------------------------------------------

#ifndef NULL
#ifdef __cplusplus
#define NULL    0
#else
#define NULL    ((void *)0)
#endif
#endif

//-----------------------------------------------------------------------------------------

typedef unsigned char (*Z80CoreRead)(unsigned short address, int param);
typedef void (* Z80CoreWrite)(unsigned short address, unsigned char data, int param);
typedef void (* Z80CoreContention)(unsigned short address, unsigned int tstates, int param);

//-----------------------------------------------------------------------------------------

class CZ80Core
{
public:
	typedef enum
	{
		eREG_A,
		eREG_F,
		eREG_B,
		eREG_C,
		eREG_D,
		eREG_E,
		eREG_H,
		eREG_L,

		eREG_ALT_A,
		eREG_ALT_F,
		eREG_ALT_B,
		eREG_ALT_C,
		eREG_ALT_D,
		eREG_ALT_E,
		eREG_ALT_H,
		eREG_ALT_L,

		eREG_I,
		eREG_R,
	} eZ80BYTEREGISTERS;

	typedef enum
	{
		eREG_AF,
		eREG_HL,
		eREG_BC,
		eREG_DE,
		eREG_ALT_AF,
		eREG_ALT_HL,
		eREG_ALT_BC,
		eREG_ALT_DE,

		eREG_IX,
		eREG_IY,
		eREG_SP,
		eREG_PC,

	} eZ80WORDREGISTERS;

	const unsigned char FLAG_C = 0x01;
	const unsigned char FLAG_N = 0x02;
	const unsigned char FLAG_P = 0x04;
	const unsigned char FLAG_V = FLAG_P;
	const unsigned char FLAG_3 = 0x08;
	const unsigned char FLAG_H = 0x10;
	const unsigned char FLAG_5 = 0x20;
	const unsigned char FLAG_Z = 0x40;
	const unsigned char FLAG_S = 0x80;

	typedef struct
	{
		union
		{
			struct
			{
				// Start with the main regs
				unsigned short	regAF;
				unsigned short	regBC;
				unsigned short	regDE;
				unsigned short	regHL;
				unsigned short	regIX;
				unsigned short	regIY;

				// Exchange registers
				unsigned short	regAF_;
				unsigned short	regBC_;
				unsigned short	regDE_;
				unsigned short	regHL_;
			} reg_pairs;

			// These are the initial byte registers
			struct
			{
				unsigned char	regF;
				unsigned char	regA;
				unsigned char	regC;
				unsigned char	regB;
				unsigned char	regE;
				unsigned char	regD;
				unsigned char	regL;
				unsigned char	regH;
				unsigned char	regIXl;
				unsigned char	regIXh;
				unsigned char	regIYl;
				unsigned char	regIYh;
				unsigned char	regF_;
				unsigned char	regA_;
				unsigned char	regC_;
				unsigned char	regB_;
				unsigned char	regE_;
				unsigned char	regD_;
				unsigned char	regL_;
				unsigned char	regH_;
			} regs;
		};

		// These dont have byte pairs
		unsigned short	regSP;
		unsigned short	regPC;

		unsigned char	regI;
		unsigned char	regR;

		unsigned char	IFF1;
		unsigned char	IFF2;
		unsigned char	IM;

		bool			Halted;
		bool			EIHandled;
		bool			IntReq;

		unsigned int	TStates;
	} Z80State;

	typedef struct
	{
		void (CZ80Core::*function)(unsigned char opcode);
		const char* format;
	} Z80Opcode;

	typedef struct
	{
		Z80Opcode entries[256];
	} Z80OpcodeTable;


public:
	CZ80Core();
	~CZ80Core();
	
public:
	void					Initialise(Z80CoreRead mem_read, Z80CoreWrite mem_write, Z80CoreRead io_read, Z80CoreWrite io_write, Z80CoreContention mem_contention_handling, Z80CoreContention io_contention_handling, int member_class);

	void					Reset(bool hardReset = true);
	void					Debug();
	int						Execute(int num_tstates = -1, int int_t_states = 32);

	void					SignalInterrupt();

	bool					IsInterruptRequesting() const { return (m_CPURegisters.IntReq != 0); }

	unsigned char			GetRegister(eZ80BYTEREGISTERS reg) const;
	unsigned short			GetRegister(eZ80WORDREGISTERS reg) const;
	void					SetRegister(eZ80BYTEREGISTERS reg, unsigned char data);
	void					SetRegister(eZ80WORDREGISTERS reg, unsigned short data);

	void					SetIMMode(unsigned char im) { m_CPURegisters.IM = im; m_CPURegisters.IntReq = 0; }
	unsigned char			GetIMMode() const { return m_CPURegisters.IM; }
	void					SetIFF1(unsigned char iff1) { m_CPURegisters.IFF1 = iff1; }
	unsigned char			GetIFF1(void) const { return m_CPURegisters.IFF1;  }
	void					SetIFF2(unsigned char iff2) { m_CPURegisters.IFF2 = iff2; }
	unsigned char			GetIFF2(void) const { return m_CPURegisters.IFF2; }
	bool					GetHalted(void) const { return m_CPURegisters.Halted; }
	void					SetHalted(bool halted) { m_CPURegisters.Halted = halted; }
		 
	void					AddContentionTStates(unsigned int extra_tstates) { m_CPURegisters.TStates += extra_tstates; }
	void					AddTStates(unsigned int extra_tstates) { m_CPURegisters.TStates += extra_tstates; }

	unsigned int			GetTStates() const { return m_CPURegisters.TStates; }
	void					ResetTStates() { m_CPURegisters.TStates = 0; }
	void					ResetTStates(unsigned int tstates_per_frame) { m_CPURegisters.TStates -= tstates_per_frame; }

	unsigned char			Z80CoreMemRead(unsigned short address, unsigned int tstates = 3);
	void					Z80CoreMemWrite(unsigned short address, unsigned char data, unsigned int tstates = 3);
	unsigned char			Z80CoreIORead(unsigned short address);
	void					Z80CoreIOWrite(unsigned short address, unsigned char data);
	void					Z80CoreMemoryContention(unsigned short address, unsigned int t_states);
	void					Z80CoreIOContention(unsigned short address, unsigned int t_states);

protected:
	#include "Z80Core_MainOpcodes.h"
	#include "Z80Core_CBOpcodes.h"
	#include "Z80Core_DDOpcodes.h"
	#include "Z80Core_EDOpcodes.h"
	#include "Z80Core_FDOpcodes.h"
	#include "Z80Core_DDCB_FDCBOpcodes.h"

	void					Inc(unsigned char &r);
	void					Dec(unsigned char &r);
	void					Add8(unsigned char &r);
	void					Adc8(unsigned char &r);
	void					Sub8(unsigned char &r);
	void					Sbc8(unsigned char &r);
	void					Add16(unsigned short &r1, unsigned short &r2);
	void					Adc16(unsigned short &r1, unsigned short &r2);
	void					Sbc16(unsigned short &r1, unsigned short &r2);
	void					And(unsigned char &r);
	void					Or(unsigned char &r);
	void					Xor(unsigned char &r);
	void					Cp(unsigned char &r);
	void					RLC(unsigned char &r);
	void					RRC(unsigned char &r);
	void					RL(unsigned char &r);
	void					RR(unsigned char &r);
	void					SLA(unsigned char &r);
	void					SRA(unsigned char &r);
	void					SRL(unsigned char &r);
	void					SLL(unsigned char &r);
	void					Bit(unsigned char &r, unsigned char b);
	void					BitWithMemptr(unsigned char &r, unsigned char b);
	void					Set(unsigned char &r, unsigned char b);
	void					Res(unsigned char &r, unsigned char b);

protected:
	static Z80OpcodeTable	Main_Opcodes;
	static Z80OpcodeTable	CB_Opcodes;
	static Z80OpcodeTable	DD_Opcodes;
	static Z80OpcodeTable	ED_Opcodes;
	static Z80OpcodeTable	FD_Opcodes;
	static Z80OpcodeTable	DDCB_Opcodes;
	static Z80OpcodeTable	FDCB_Opcodes;

	Z80State				m_CPURegisters;
	unsigned char			m_ParityTable[256];
	unsigned char			m_SZ35Table[256];
	unsigned short			m_MEMPTR;

	int						m_Param;
	Z80CoreRead				m_MemRead;
	Z80CoreWrite			m_MemWrite;
	Z80CoreRead				m_IORead;
	Z80CoreWrite			m_IOWrite;
	Z80CoreContention		m_MemContentionHandling;
	Z80CoreContention		m_IOContentionHandling;
};


//-----------------------------------------------------------------------------------------

#endif
