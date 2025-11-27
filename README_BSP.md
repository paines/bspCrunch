# Quake BSP Loader for CRUNCH/Raylib

This library allows you to load and render Quake BSP level files using raylib and optionally CRUNCH Scheme.

## Files

- `bsp.cpp` - Core BSP file parser and mesh generator (C++)
- `bsp_wrapper.h` - C API wrapper header
- `bsp_wrapper.cpp` - C API wrapper implementation
- `bsp_simple.c` - Simple C viewer example (recommended)
- `bsp_demo.scm` - CRUNCH Scheme example (work in progress)
- `Makefile` - Build configuration

## Building

### Build the BSP library:
```bash
make libbsp.a
```

### Build and run the simple C viewer (recommended):
```bash
make bsp_viewer
./bsp_viewer
```

### Build the CRUNCH Scheme demo (currently has FFI issues):
```bash
make bsp_demo  # Note: Currently not working due to CRUNCH FFI complexities
```

## Usage

### Simple C Example

The easiest way to use the BSP loader is with plain C (see `bsp_simple.c`):

```c
#include <raylib.h>
#include "bsp_wrapper.h"

int main(void) {
    InitWindow(1024, 768, "BSP Viewer");
    
    // Load BSP file
    BSPModelArray* bsp = LoadBSPFile("level.bsp");
    int count = GetBSPModelCount(bsp);
    
    // Setup camera
    Camera camera = {
        .position = { 0.0f, 10.0f, 10.0f },
        .target = { 0.0f, 0.0f, 0.0f },
        .up = { 0.0f, 1.0f, 0.0f },
        .fovy = 60.0f,
        .projection = CAMERA_PERSPECTIVE
    };
    
    // Main loop
    while (!WindowShouldClose()) {
        UpdateCamera(&camera, CAMERA_FIRST_PERSON);
        
        BeginDrawing();
            ClearBackground(RAYWHITE);
            BeginMode3D(camera);
                for (int i = 0; i < count; i++) {
                    Model* model = GetBSPModel(bsp, i);
                    DrawModel(*model, (Vector3){0, 0, 0}, 1.0f, WHITE);
                }
            EndMode3D();
        EndDrawing();
    }
    
    UnloadBSPFile(bsp);
    CloseWindow();
    return 0;
}
```
```

## API Functions

- `LoadBSPFile(filename)` - Loads BSP file, returns handle or NULL on error
- `GetBSPModelCount(bsp_models)` - Returns number of models in the BSP
- `GetBSPModel(bsp_models, index)` - Returns pointer to Model at index
- `UnloadBSPFile(bsp_models)` - Frees all resources

## Requirements

- CRUNCH (chicken-crunch compiler)
- raylib (installed in /usr/local/lib)
- C++20 compatible compiler
- A Quake BSP file to load

## Credits

BSP loader code based on: https://github.com/bytesiz3d/quake-level-viewer
