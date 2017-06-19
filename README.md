# SpectREM (Spectrum Retro EMulator)

This is a ZX Spectrum emulator written for MacOS 10.10+

## Features

- Emulates the 48k and 128k ZX Spectrum
- Extremely accurate Z80 core (developed by Adrian Brown)
  - Passes all emulator based tests for Z80 core accuracy including FLAGS, MEMPTR and SCF/CCF Q register
- Cycle accurate emulation of the ULA allowing all advanced colour demos to work correctly (the ones tested ;o) )
- Beeper emulation
- AY emulation
- TAP file loading and saving
- TAP Insta loading
- SNA 48k snapshot loading/saving
- Z80 48k/128k snapshot loading/saving
- Virtual tape browser
- Debugger (Under active development)
  - Graphical memory viewer
  - CPU view (registers and flags)
  - Pause, Resume
  - Step In
- ULAplus
- Automatically restores your last session
- Allows selection of the default 48k/128k ROM
- Imports labels generated when compiling with Pasmo and displays them in the disassembly window
  - Automatically looks for a file with the same name as the snapshot being loaded but with a .dbg extension

## Peripheral Emulation

- SpecDrum
- Multiface 1
- Multiface 128

## SmartLINK

- SmartLINK being developed by Paul Tankard. This uses an Arduino connected to a Retroleum SD card to allow input from the emulator to a real Spectrum e.g. keyboard and joystick. It also supports the ability to send what is running on the emulator directly to a real Spectrum in under 1 second.
- Currently only works on 48k Spectrum hardware
- Development goal is to use this as a development/debugger tool for the Spectrum

## Todo list

- SZX
- Full debugger/disassembler
  - Step Over
  - Breakpoints
  - Break on Read/Write/Execute of a memory location
  - Screen debugger that shows what has been drawn to screen even when single stepping instructions
  - Screen debugger that can be used to show a specific memory page for 128k screen debugging e.g. look at the page updating that is going to be flipped too
  - Show on screen where the screen refresh location is for debugging colour effects
