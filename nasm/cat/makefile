NASM    = nasm
LD      = ld
ASM     = cat.asm
OBJ     = cat.o
TARGET  = cat

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) $(OBJ) -o $(TARGET)

$(OBJ): $(ASM)
	$(NASM) -f elf64 $(ASM) -o $(OBJ)

clean:
	rm -f $(OBJ) $(TARGET)
