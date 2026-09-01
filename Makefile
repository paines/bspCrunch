CSC := csc

# Homebrew raylib paths
RAYLIB_INC := $(shell pkg-config --cflags raylib)
RAYLIB_LIBS_CHICKEN := $(shell pkg-config --libs raylib)

# Chicken runtime lib (adjust if different)
CHICKEN_LIB := -L/opt/homebrew/lib -lchicken

# C++ standard for BSP sources
CXXFLAGS := -std=c++20

# Chicken-friendly link flags for raylib (-L <flag> per item)
RAYLIB_L_FLAGS := $(foreach x,$(RAYLIB_LIBS_CHICKEN),-L $(x))

bsp_demo_chicken: bsp_demo_chicken.o raylib_helpers.o bsp_wrapper.o bsp.o
	$(CXX) -std=c++20 -o $@ bsp_demo_chicken.o raylib_helpers.o bsp_wrapper.o bsp.o \
	$(RAYLIB_LIBS_CHICKEN) $(CHICKEN_LIB) -lc++ -Wl,-rpath

bsp_demo_chicken.o: bsp_demo_chicken.scm
	$(CSC) -c -O3 $(RAYLIB_INC) $< -o $@

raylib_helpers.o: raylib_helpers.c
	$(CC) $(RAYLIB_INC) -c -O3 raylib_helpers.c

bsp_wrapper.o: bsp_wrapper.cpp bsp_wrapper.h
	$(CXX) $(CXXFLAGS) $(RAYLIB_INC) -c bsp_wrapper.cpp -o bsp_wrapper.o

bsp.o: bsp.cpp
	$(CXX) $(CXXFLAGS) $(RAYLIB_INC) -c bsp.cpp -o bsp.o

.PHONY: bsp_demo_chicken run_bsp_chicken
run_bsp_chicken: bsp_demo_chicken
	./bsp_demo_chicken

# Build REPL-loadable module for csi
bsp-viewer.so: bsp_viewer.scm raylib_helpers.o bsp_wrapper.o bsp.o
	$(CSC) -s -j bsp-viewer -o bsp-viewer.so \
	  bsp_viewer.scm raylib_helpers.o bsp_wrapper.o bsp.o \
	  $(RAYLIB_L_FLAGS) -L -lc++

.PHONY: repl
repl: bsp-viewer.so
	# Start csi from repo root without DYLD overrides (macOS GL issues)
	unset DYLD_LIBRARY_PATH; csi

clean:
	rm -f bsp_demo_chicken bsp_demo_chicken.o raylib_helpers.o bsp_wrapper.o bsp.o bsp-viewer.so demo

crunch-demo: raylib-example.c bsp_helpers.o bsp_wrapper.o bsp.o
	gcc -c -I/opt/homebrew/Cellar/chicken/6.0.0/include/chicken -I/opt/homebrew/Cellar/raylib/6.0/include raylib-example.c
	$(CXX) -std=c++20 -o $@ raylib-example.o bsp_helpers.o bsp_wrapper.o bsp.o -L/opt/homebrew/Cellar/raylib/6.0/lib -lraylib -lc++
	
raylib-example.c: bsp_crunch.scm
	/opt/homebrew/Cellar/chicken/6.0.0/bin/chicken-crunch bsp_crunch.scm -o raylib-example.c