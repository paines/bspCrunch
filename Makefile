CHICKEN_BIN ?= /Users/al/chicken/bin
CSC := $(CHICKEN_BIN)/csc

# Homebrew raylib paths
RAYLIB_INC := $(shell pkg-config --cflags raylib)
RAYLIB_LIBS_CHICKEN := $(shell pkg-config --libs raylib)

# Chicken runtime lib (adjust if different)
CHICKEN_LIB := -L/Users/al/chicken/lib -lchicken

# C++ standard for BSP sources
CXXFLAGS := -std=c++20

bsp_demo_chicken: bsp_demo_chicken.o raylib_helpers.o bsp_wrapper.o bsp.o
	$(CXX) -std=c++20 -o $@ bsp_demo_chicken.o raylib_helpers.o bsp_wrapper.o bsp.o \
	$(RAYLIB_LIBS_CHICKEN) $(CHICKEN_LIB) -Wl,-rpath,/Users/al/chicken/lib

bsp_demo_chicken.o: bsp_demo_chicken.scm
	$(CSC) -c -O3 $< -o $@

raylib_helpers.o: raylib_helpers.c
	$(CC) $(RAYLIB_INC) -c -O3 raylib_helpers.c

bsp_wrapper.o: bsp_wrapper.cpp bsp_wrapper.h
	$(CXX) $(CXXFLAGS) $(RAYLIB_INC) -c bsp_wrapper.cpp -o bsp_wrapper.o

bsp.o: bsp.cpp
	$(CXX) $(CXXFLAGS) $(RAYLIB_INC) -c bsp.cpp -o bsp.o

.PHONY: bsp_demo_chicken run_bsp_chicken
run_bsp_chicken: bsp_demo_chicken
	./bsp_demo_chicken