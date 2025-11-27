# Makefile for CRUNCH Scheme raylib project with BSP loader

# Compiler and tools
CHICKEN_CRUNCH = /usr/local/bin/chicken-crunch
CC = cc
CXX = g++

# Source and output files
SCHEME_SRC = main.scm
C_SRC = main.c
OUTPUT = demo

# BSP demo files
BSP_SCHEME_SRC = bsp_demo.scm
BSP_C_SRC = bsp_demo.c
BSP_OUTPUT = bsp_demo

# BSP CRUNCH files
BSP_CRUNCH_SRC = bsp_crunch.scm
BSP_CRUNCH_C = bsp_crunch.c
BSP_CRUNCH_OUTPUT = bsp_crunch

# BSP library files
BSP_LIB_SRC = bsp.cpp bsp_wrapper.cpp
BSP_LIB_OBJ = bsp.o bsp_wrapper.o
BSP_LIB = libbsp.a

# BSP helper files
BSP_HELPER_OBJ = bsp_helpers.o

# Libraries and flags
CFLAGS = $(shell $(CHICKEN_CRUNCH) -cflags)
CXXFLAGS = -std=c++20 -I/usr/local/include
LDFLAGS = -L/usr/local/lib -L. -lraylib -lm -ldl -lGL -lX11 $(shell $(CHICKEN_CRUNCH) -libs)

# Default target
all: $(OUTPUT)

# Compile Scheme to C
$(C_SRC): $(SCHEME_SRC)
	$(CHICKEN_CRUNCH) $(SCHEME_SRC) -o $(C_SRC)

# Compile C to executable
$(OUTPUT): $(C_SRC)
	$(CC) $(C_SRC) $(CFLAGS) $(LDFLAGS) -o $(OUTPUT)

# BSP Library targets
bsp.o: bsp.cpp
	$(CXX) $(CXXFLAGS) -c bsp.cpp -o bsp.o

bsp_wrapper.o: bsp_wrapper.cpp bsp_wrapper.h
	$(CXX) $(CXXFLAGS) -c bsp_wrapper.cpp -o bsp_wrapper.o

$(BSP_LIB): $(BSP_LIB_OBJ)
	ar rcs $(BSP_LIB) $(BSP_LIB_OBJ)

# BSP helper targets
bsp_helpers.o: bsp_helpers.c bsp_helpers.h
	$(CC) -c bsp_helpers.c -I/usr/local/include -o bsp_helpers.o

# BSP demo targets
$(BSP_C_SRC): $(BSP_SCHEME_SRC)
	$(CHICKEN_CRUNCH) $(BSP_SCHEME_SRC) -o $(BSP_C_SRC)

$(BSP_OUTPUT): $(BSP_C_SRC) $(BSP_LIB)
	$(CC) $(BSP_C_SRC) $(CFLAGS) $(LDFLAGS) -lbsp -lstdc++ -o $(BSP_OUTPUT)

bsp_demo: $(BSP_OUTPUT)

# BSP CRUNCH viewer (Scheme bindings)
$(BSP_CRUNCH_C): $(BSP_CRUNCH_SRC)
	$(CHICKEN_CRUNCH) $(BSP_CRUNCH_SRC) -o $(BSP_CRUNCH_C)

$(BSP_CRUNCH_OUTPUT): $(BSP_CRUNCH_C) $(BSP_LIB) $(BSP_HELPER_OBJ)
	$(CC) $(BSP_CRUNCH_C) $(BSP_HELPER_OBJ) $(CFLAGS) $(LDFLAGS) -lbsp -lstdc++ -o $(BSP_CRUNCH_OUTPUT)

bsp_crunch: $(BSP_CRUNCH_OUTPUT)

# Simple C BSP viewer (no Scheme needed)
bsp_viewer: bsp_simple.c $(BSP_LIB)
	$(CC) bsp_simple.c -std=c11 -I/usr/local/include $(LDFLAGS) -lbsp -lstdc++ -o bsp_viewer

# Clean build artifacts
clean:
	rm -f $(C_SRC) $(OUTPUT) $(BSP_C_SRC) $(BSP_OUTPUT) $(BSP_CRUNCH_C) $(BSP_CRUNCH_OUTPUT) $(BSP_LIB_OBJ) $(BSP_HELPER_OBJ) $(BSP_LIB) bsp_viewer

# Phony targets
.PHONY: all clean bsp_demo bsp_crunch bsp_viewer run run_bsp run_crunch run_viewer

# Run the program
run: $(OUTPUT)
	./$(OUTPUT)

# Run the BSP demo
run_bsp: $(BSP_OUTPUT)
	./$(BSP_OUTPUT)

# Run the CRUNCH BSP viewer
run_crunch: bsp_crunch
	./bsp_crunch

# Run the simple BSP viewer
run_viewer: bsp_viewer
	./bsp_viewer
