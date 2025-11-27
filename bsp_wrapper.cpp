#include "bsp_wrapper.h"
#include <vector>
#include <filesystem>

// Forward declaration
std::vector<Model> LoadModelsFromBSPFile(const std::filesystem::path& path);

// Internal structure to hold the models
struct BSPModelArray {
    std::vector<Model> models;
};

extern "C" {

BSPModelArray* LoadBSPFile(const char* filename)
{
    try {
        BSPModelArray* bsp = new BSPModelArray();
        bsp->models = LoadModelsFromBSPFile(filename);
        return bsp;
    } catch (...) {
        return nullptr;
    }
}

int GetBSPModelCount(BSPModelArray* bsp_models)
{
    if (bsp_models == nullptr) return 0;
    return (int)bsp_models->models.size();
}

Model* GetBSPModel(BSPModelArray* bsp_models, int index)
{
    if (bsp_models == nullptr) return nullptr;
    if (index < 0 || index >= (int)bsp_models->models.size()) return nullptr;
    return &bsp_models->models[index];
}

void UnloadBSPFile(BSPModelArray* bsp_models)
{
    if (bsp_models == nullptr) return;
    
    // Unload all raylib models
    for (auto& model : bsp_models->models) {
        UnloadModel(model);
    }
    
    delete bsp_models;
}

} // extern "C"
