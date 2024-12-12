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
INCLUDE_DIRS = -I./hdr -I../hdr -I../../hdr
CFLAGS += $(INCLUDE_DIRS)
LIBS = -lraylib -lGL -lm -lpthread -ldl -lrt -lX11 

SRC_DIR = src
BACKE_DIR = $(SRC_DIR)/backe
HRD_DIR = hdr
OBJ_DIR = obj
BIN_DIR = bin

# Find source files in both src and src/backe directories
SRCS = $(wildcard $(SRC_DIR)/*.c) $(wildcard $(BACKE_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(filter $(SRC_DIR)/%.c,$(SRCS))) \
       $(patsubst $(BACKE_DIR)/%.c,$(OBJ_DIR)/backe/%.o,$(filter $(BACKE_DIR)/%.c,$(SRCS)))

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/backe/%.o: $(BACKE_DIR)/%.c | $(OBJ_DIR)/backe
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR) $(OBJ_DIR) $(OBJ_DIR)/backe:
	$(MKDIR) $@

clean:
	$(RM_DIR) $(OBJ_DIR) $(BIN_DIR)

run: $(TARGET)
	$(RUN_CMD)
