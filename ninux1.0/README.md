# Ninux

Ninux is a simple operating system written in NASM. The bootloader loads the kernel (typically `KERNEL.BIN`) from a FAT12-formatted disk image. It uses BIOS interrupts for disk and screen I/O, demonstrating basic low-level programming techniques and system bootstrapping.

## Setup

Install wcc, wlink, and qemu

## Usage

Run `./scripts/run.sh` to build and boot the system using qemu

## Overview

- **Bootloader:**  
  Written in assembly, the bootloader initializes the system, sets up the environment, and loads the kernel into memory from a FAT12 disk image. It makes extensive use of BIOS interrupts for video and disk operations.

- **Kernel:**  
  The kernel is a combination of assembly and C code. It provides essential functionality and serves as a foundation for further operating system development.

- **Disk Image:**  
  The OS is built into a floppy disk image that is formatted as FAT12. The bootloader is written at the beginning of the image, and the kernel is copied into the image file with a fixed filename (e.g., `KERNEL.BIN`).

## Build Process

The project uses a Makefile to automate the build process, which includes:

1. **Cleaning:**  
   The build directory is cleaned to ensure a fresh build environment.

2. **Assembling the Bootloader:**  
   The bootloader is assembled from NASM source files to produce a binary file.

3. **Compiling and Assembling the Kernel:**  
   The kernel's assembly parts are assembled using NASM, and the C parts are compiled using a 16-bit C compiler. The resulting object files are linked together to produce `kernel.bin`.

4. **Creating the Floppy Image:**  
   A 1.44 MB floppy image is created, formatted with FAT12, and the bootloader is written to it. The kernel binary is then copied into the image as `KERNEL.BIN`.

### Commands

- **Build the OS:**  
  Run `make` to clean previous builds and generate the new floppy image along with the bootloader and kernel.

- **Clean Build Artifacts:**  
  Run `make clean` to remove all generated build files.

## Requirements

- **NASM:**  
  The NASM assembler is used for all assembly files.

- **16-bit C Compiler and Linker:**  
  A 16-bit C compiler (like `wcc`) and a compatible linker (such as `wlink`) are required to compile and link the C portions of the kernel.

- **FAT12 Tools:**  
  Tools like `mkfs.fat` and `mcopy` are used to format the disk image and copy files onto it.

## Usage

Once built, you can run the generated floppy disk image (`main.img`) in an emulator like QEMU, Bochs, or VirtualBox, or write it to a physical floppy disk if you have the necessary hardware.

Example command to run with QEMU:
```bash
qemu-system-i386 -fda build/main.img
```

## Project Structure

- `src/bootloader/`: Contains the NASM source for the bootloader.
- `src/kernel/`: Contains the kernel source, both assembly (`*.asm`) and C (`*.c`).
- `build/`: Directory where all build artifacts (object files, binaries, disk images) are generated.
- `Makefile`: Automates the build process for the entire project.
