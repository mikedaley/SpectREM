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
- SNA snapshot loading
- Z80 snapshot loading
- Graphical memory viewer
- CPU view (registers and flags)
- Virtual tape browser
- Debugger (early days but being actively developed)

## Peripheral Emulation

- SpecDrum

## Todo list

- TAP insta-load
- ULAplus
- SNA/Z80 creation
- Full debugger/disassembler
