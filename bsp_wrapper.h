#ifndef BSP_WRAPPER_H
#define BSP_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <raylib.h>

// Opaque handle to BSP model array
typedef struct BSPModelArray BSPModelArray;

/**
 * Load all models from a Quake BSP file
 * Returns an opaque handle to the model array, or NULL on error
 */
BSPModelArray* LoadBSPFile(const char* filename);

/**
 * Get the number of models in the BSP file
 */
int GetBSPModelCount(BSPModelArray* bsp_models);

/**
 * Get a specific model from the BSP array
 * Returns a pointer to the Model (owned by the BSPModelArray)
 */
Model* GetBSPModel(BSPModelArray* bsp_models, int index);

/**
 * Free all resources associated with the BSP models
 */
void UnloadBSPFile(BSPModelArray* bsp_models);

#ifdef __cplusplus
}
#endif

#endif // BSP_WRAPPER_H
