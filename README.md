The latest version of the emulator is under branch 0.7

# SpectREM (Spectrum Retro EMulator)

This is a ZX Spectrum emulator written for MacOS 10.10+

Currently the ZX Spectrum 48k and ZX Spectrum 128k machines are emulated.

## Features

- Extremely accurate Z80 core (developed by Adrian Brown)
  - Passes all emulator based tests for Z80 core accuracy including FLAGS, MEMPTR and SCF/CCF Q register
- Cycle accurate emulation of the ULA allowing all advanced colour demos to work correctly (the ones tested ;o) )
- Beeper emulation
- AY emulation
- TAP file loading and saving
- TAP Insta loading
- SNA snapshot loading
- Z80 snapshot loading
- Graphical memory viewer
- CPU view (registers and flags)
- Virtual tape browser
- Debugger (early days but being actively developed)
- ULAplus

## Peripheral Emulation

- SpecDrum
- Multiface 1
- Multiface 128

## Todo list

- SZX
- SNA/Z80 creation
- Full debugger/disassembler
  - Step In
  - Step Over (Step over a CALL nn and run until a RET is hit)
  - Breakpoints
  - Break on Read/Write/Execute of a memory location
  - Import Labels and other info from assemblers such as Pasmo
  - Screen debugger that shows what has been drawn to screen even when single stepping instructions
  - Screen debugger that can be used to show a specific memory page for 128k screen debugging e.g. look at the page updating that is going to be flipped too
  - Show on screen where the screen refresh location is for debugging colour effects
