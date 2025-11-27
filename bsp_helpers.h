#ifndef BSP_HELPERS_H
#define BSP_HELPERS_H

#ifdef __cplusplus
extern "C" {
#endif

// Initialize the BSP camera (called automatically)
void InitBSPCamera(void);

// Update the camera with first-person controls
void UpdateBSPCamera(void);

// Begin 3D mode with the BSP camera
void BeginBSP3DMode(void);

// Draw a BSP model from a pointer
void DrawBSPModel(void* model_ptr);

// Check if pointer is null
int IsNullPtr(void* ptr);

// Format model count string
char* FormatModelCount(int count);

// Clear background with RAYWHITE
void ClearBackgroundWhite(void);

#ifdef __cplusplus
}
#endif

#endif // BSP_HELPERS_H
