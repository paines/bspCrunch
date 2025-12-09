;; Quake BSP Loader Example for CRUNCH

(module bsp-demo (main)

(import (crunch c)
        (crunch memory)
        (crunch aggregate-types))
(import (chicken syntax))
(import (except miscmacros define-enum))

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

;; Helper: convert CRUNCH strings to char pointers
(define (str s) (string->pointer s))

;; Wrapper for ClearBackground(RAYWHITE)
(define clear-background-white
  (c-lambda () void
    "ClearBackground(RAYWHITE);"))

;; Wrapper for DrawText(..., WHITE)
(define draw-text-white
  (c-lambda ((pointer char) integer integer integer) void
    "DrawText(___arg1, ___arg2, ___arg3, ___arg4, WHITE);"))

;; Helper to draw a model from a pointer
(define draw-model-ptr
  (c-lambda ((pointer void)) void
    "if (___arg1) { DrawModel(*(Model*)___arg1, (Vector3){0.0f, 0.0f, 0.0f}, 1.0f, WHITE); }"))

;; BSP loader bindings
(define LoadBSPFile (c-external LoadBSPFile ((pointer char)) (pointer void)))
(define GetBSPModelCount (c-external GetBSPModelCount ((pointer void)) integer))
(define GetBSPModel (c-external GetBSPModel ((pointer void) integer) (pointer void)))
(define UnloadBSPFile (c-external UnloadBSPFile ((pointer void)) void))

;; Helper: check null pointer
(define pointer-null?
  (c-lambda ((pointer void)) boolean
    "return(___arg1 == NULL);"))

;; Inline C: simple camera setup and begin 3D mode
(define update-and-begin-camera
  (c-lambda () void
    "static Camera3D camera = { 0 };
     static int initialized = 0;
     if (!initialized) {
       camera.position = (Vector3){ 0.0f, 10.0f, 10.0f };
       camera.target   = (Vector3){ 0.0f,  0.0f,  0.0f };
       camera.up       = (Vector3){ 0.0f,  1.0f,  0.0f };
       camera.fovy = 60.0f;
       camera.projection = CAMERA_PERSPECTIVE;
       initialized = 1;
     }
     UpdateCamera(&camera, CAMERA_FIRST_PERSON);
     BeginMode3D(camera);"))

;; Main
(define (main)
  (let* ((screen-width 1024)
         (screen-height 768)
         (bsp-file "level.bsp"))
    (InitWindow screen-width screen-height (str "CRUNCH - Quake BSP Viewer"))
    (SetTargetFPS 60)

    (let ((bsp-models (LoadBSPFile (str bsp-file))))
      (if (pointer-null? bsp-models)
          (begin
            (BeginDrawing)
            (clear-background-white)
            (draw-text-white (str "Failed to load BSP file!") 10 10 20)
            (EndDrawing)
            (CloseWindow))
          (let ((model-count (GetBSPModelCount bsp-models)))
            (letrec ((loop
                       (lambda ()
                         (if (WindowShouldClose)
                             (begin
                               (UnloadBSPFile bsp-models)
                               (CloseWindow))
                             (begin
                               (BeginDrawing)
                               (clear-background-white)

                               (update-and-begin-camera)

                               ;; Draw all BSP models
                               (let model-loop ((i 0))
                                 (when (< i model-count)
                                   (let ((model-ptr (GetBSPModel bsp-models i)))
                                     (draw-model-ptr model-ptr))
                                   (model-loop (+ i 1))))

                               (DrawGrid 10 1.0)
                               (EndMode3D)

                               (draw-text-white (str "WASD to move, Mouse to look") 10 10 20)
                               (draw-text-white (str (string-append "Models: " (number->string model-count))) 10 40 20)

                               (EndDrawing)
                               (loop)))))))
+              (loop))))))))
