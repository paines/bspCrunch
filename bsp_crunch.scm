;;  Quake BSP Loader Example for CRUNCH
;;
;;  Load and render Quake BSP files with raylib
;;
;;  compile: make bsp_crunch

(module bsp-viewer (main)

(import (scheme base))
(import (crunch c)
        (crunch memory))

(c-include "raylib.h")
(c-include "rcamera.h")
(c-include "bsp_wrapper.h")
(c-include "bsp_helpers.h")

;; Bindings to raylib functions
(define InitWindow (c-external InitWindow (integer integer (pointer char)) void))
(define SetTargetFPS (c-external SetTargetFPS (integer) void))
(define WindowShouldClose (c-external WindowShouldClose () boolean))
(define BeginDrawing (c-external BeginDrawing () void))
(define EndDrawing (c-external EndDrawing () void))
(define ClearBackground (c-external ClearBackground (integer) void))
(define CloseWindow (c-external CloseWindow () void))
(define DrawText (c-external DrawText ((pointer char) integer integer integer (typename Color)) void))
(define DrawGrid (c-external DrawGrid (integer float) void))
(define EndMode3D (c-external EndMode3D () void))
(define DisableCursor (c-external DisableCursor () void))
(define DrawFPS (c-external DrawFPS (integer integer) void))

;; BSP helper bindings
(define ClearBackgroundWhite (c-external ClearBackgroundWhite () void))
(define UpdateBSPCamera (c-external UpdateBSPCamera () void))
(define BeginBSP3DMode (c-external BeginBSP3DMode () void))
(define DrawBSPModel (c-external DrawBSPModel ((pointer void)) void))
(define IsNullPtr (c-external IsNullPtr ((pointer void)) integer))
(define FormatModelCount (c-external FormatModelCount (integer) (pointer char)))

;; BSP loader bindings
(define LoadBSPFile (c-external LoadBSPFile ((pointer char)) (pointer void)))
(define GetBSPModelCount (c-external GetBSPModelCount ((pointer void)) integer))
(define GetBSPModel (c-external GetBSPModel ((pointer void) integer) (pointer void)))
(define UnloadBSPFile (c-external UnloadBSPFile ((pointer void)) void))

;; Helper to convert CRUNCH strings to char pointers
(define (str s) (string->pointer s))

;; Main program
(define (main)
  (let ((screen-width 1024)
        (screen-height 768)
        (bsp-file "level.bsp"))
    
    (InitWindow screen-width screen-height (str "CRUNCH - Quake BSP Viewer"))
    (SetTargetFPS 60)
    
    ;; Load BSP file
    (let ((bsp-models (LoadBSPFile (str bsp-file))))
      (if (not (= 0 (IsNullPtr bsp-models)))
          (begin
            (DrawText (str "Failed to load BSP file!") 10 10 20 
                      (c-value (typename Color) "WHITE"))
            (CloseWindow))
          (begin
            (let ((model-count (GetBSPModelCount bsp-models))
                  (black (c-value (typename Color) "BLACK")))
              
              (DisableCursor)
              
              ;; Main loop
              (do ()
                  ((WindowShouldClose)
                    (UnloadBSPFile bsp-models)
                    (CloseWindow))
                
                ;; Update camera
                (UpdateBSPCamera)
                
                ;; Draw
                (BeginDrawing)
                (ClearBackgroundWhite)
                
                ;; Start 3D mode
                (BeginBSP3DMode)
                
                ;; Draw all BSP models
                (do ((i 0 (+ i 1)))
                    ((>= i model-count))
                  (DrawBSPModel (GetBSPModel bsp-models i)))
                
                ;; Draw grid for reference
                (DrawGrid 10 1.0)
                
                (EndMode3D)
                
                ;; Draw UI
                (DrawText (str "WASD to move, Mouse to look, ESC to exit") 
                          10 10 20 black)
                (DrawText (FormatModelCount model-count) 10 40 20 black)
                (DrawFPS 10 70)
                
                (EndDrawing))))))))

)
