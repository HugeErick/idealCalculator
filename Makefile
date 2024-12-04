# Detect operating system
ifeq ($(OS),Windows_NT)
    CC = x86_64-w64-mingw32-gcc  # MSYS2 MinGW-w64 GCC
    EXE_EXT = .exe
    RM = del /Q
    RM_DIR = rmdir /S /Q
    MKDIR = mkdir
    TARGET = $(BIN_DIR)/idealCalcu$(EXE_EXT)
    RUN_CMD = $(BIN_DIR)/idealCalcu$(EXE_EXT)
else
    CC = gcc
    EXE_EXT =
    RM = rm -f
    RM_DIR = rm -rf
    MKDIR = mkdir -p
    TARGET = $(BIN_DIR)/idealCalcu$(EXE_EXT)
    RUN_CMD = ./$(BIN_DIR)/idealCalcu$(EXE_EXT)
endif

CFLAGS = -Wall -Wextra -lm -ggdb
SRC_DIR = src
HRD_DIR = hrd
OBJ_DIR = obj
BIN_DIR = bin
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -I$(HRD_DIR) -c $< -o $@

$(BIN_DIR) $(OBJ_DIR):
	$(MKDIR) $@

clean:
	$(RM_DIR) $(OBJ_DIR) $(BIN_DIR)

run: $(TARGET)
	$(RUN_CMD)

