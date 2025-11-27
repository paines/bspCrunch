;;  Quake BSP Loader Example for CRUNCH
;;
;;  This example demonstrates loading and rendering a Quake BSP level file
;;  using the BSP wrapper library with raylib.
;;
;;  compile and link like this:
;;
;;  $ make bsp_demo

(module bsp-demo (main)

(import (scheme base))
(import (crunch c)
        (crunch memory)
        (crunch aggregate-types))

(c-include "raylib.h")
(c-include "raymath.h")
(c-include "bsp_wrapper.h")

;; Bindings to raylib functions
(define InitWindow (c-external InitWindow (integer integer (pointer char)) void))
(define SetTargetFPS (c-external SetTargetFPS (integer) void))
(define WindowShouldClose (c-external WindowShouldClose () boolean))
(define BeginDrawing (c-external BeginDrawing () void))
(define EndDrawing (c-external EndDrawing () void))
(define CloseWindow (c-external CloseWindow () void))
(define DrawGrid (c-external DrawGrid (integer float) void))
(define EndMode3D (c-external EndMode3D () void))

;; Wrapper for ClearBackground
(define clear-background-white
  (c-lambda () void
    "ClearBackground(RAYWHITE);"))

;; Wrapper for DrawText with WHITE color
(define draw-text-white
  (c-lambda ((pointer char) integer integer integer) void
    "DrawText(___arg1, ___arg2, ___arg3, ___arg4, WHITE);"))

;; Helper to draw a model from a pointer with inline colors
(define draw-model-ptr
  (c-lambda ((pointer void)) void
    "if (___arg1) { DrawModel(*(Model*)___arg1, (Vector3){0.0f, 0.0f, 0.0f}, 1.0f, WHITE); }"))

;; BSP loader bindings
(define LoadBSPFile (c-external LoadBSPFile ((pointer char)) (pointer void)))
(define GetBSPModelCount (c-external GetBSPModelCount ((pointer void)) integer))
(define GetBSPModel (c-external GetBSPModel ((pointer void) integer) (pointer void)))
(define UnloadBSPFile (c-external UnloadBSPFile ((pointer void)) void))

;; Helper to check if pointer is null
(define pointer-null?
  (c-lambda ((pointer void)) boolean
    "return(___arg1 == NULL);"))

;; Helper to convert CRUNCH strings to char pointers
(define (str s) (string->pointer s))

;; Inline C for camera management (using static camera in C)
(define update-and-begin-camera
  (c-lambda () void
    "static Camera3D camera = { 0 }; static int initialized = 0; if (!initialized) { camera.position = (Vector3){ 0.0f, 10.0f, 10.0f }; camera.target = (Vector3){ 0.0f, 0.0f, 0.0f }; camera.up = (Vector3){ 0.0f, 1.0f, 0.0f }; camera.fovy = 60.0f; camera.projection = CAMERA_PERSPECTIVE; initialized = 1; } UpdateCamera(&camera, CAMERA_FIRST_PERSON); BeginMode3D(camera);"))

;; Main program
(define (main)
  (let* ((screen-width 1024)
         (screen-height 768)
         (bsp-file "level.bsp"))  ; Change to your BSP file path
    
    (InitWindow screen-width screen-height
      (str "CRUNCH - Quake BSP Viewer"))
    (SetTargetFPS 60)
    
    ;; Load BSP file
    (let ((bsp-models (LoadBSPFile (str bsp-file))))
      (if (pointer-null? bsp-models)
          (begin
            (draw-text-white (str "Failed to load BSP file!") 10 10 20)
            (CloseWindow))
          (begin
            (let ((model-count (GetBSPModelCount bsp-models)))
              
              ;; Main loop
              (do ()
                  ((WindowShouldClose)
                    (UnloadBSPFile bsp-models)
                    (CloseWindow))
                
                ;; Draw
                (BeginDrawing)
                (clear-background-white)
                
                ;; Update camera and begin 3D mode
                (update-and-begin-camera)
                
                ;; Draw all BSP models
                (do ((i 0 (+ i 1)))
                    ((>= i model-count))
                  (let ((model-ptr (GetBSPModel bsp-models i)))
                    (draw-model-ptr model-ptr)))
                
                ;; Draw grid for reference
                (DrawGrid 10 1.0)
                
                (EndMode3D)
                
                ;; Draw info text
                (draw-text-white (str "WASD to move, Mouse to look") 10 10 20)
                (draw-text-white (str (string-append "Models: " (number->string model-count)))
                  10 40 20)
                
                (EndDrawing))))))))

)
