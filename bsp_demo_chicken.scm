(import (chicken base)
        (chicken foreign)
        (chicken memory))
(foreign-declare "
#include \"raylib.h\"
#include \"raymath.h\"

// Helpers (implemented in raylib_helpers.c)
void ClearBackgroundWhite(void);
void DrawTextWhite(const char* s, int x, int y, int size);
void UpdateAndBeginCamera(void);
void EndMode3DWrap(void);
void DrawModelPtr(void* m);

// BSP wrapper (implemented in bsp_wrapper.cpp)
void* LoadBSPFile(const char* path);
int   GetBSPModelCount(void* bsp);
void* GetBSPModel(void* bsp, int index);
void  UnloadBSPFile(void* bsp);
void LogBanner(void);
")

(define LogBanner (foreign-lambda void "LogBanner"))
(LogBanner)

(define InitWindow        (foreign-lambda void "InitWindow" int int c-string))
(define SetTargetFPS      (foreign-lambda void "SetTargetFPS" int))
(define WindowShouldClose (foreign-lambda bool "WindowShouldClose"))
(define BeginDrawing      (foreign-lambda void "BeginDrawing"))
(define EndDrawing        (foreign-lambda void "EndDrawing"))
(define CloseWindow       (foreign-lambda void "CloseWindow"))
(define DrawGrid          (foreign-lambda void "DrawGrid" int float))

(define ClearBackgroundWhite (foreign-lambda void "ClearBackgroundWhite"))
(define DrawTextWhite        (foreign-lambda void "DrawTextWhite" c-string int int int))
(define UpdateAndBeginCamera (foreign-lambda void "UpdateAndBeginCamera"))
(define EndMode3DWrap        (foreign-lambda void "EndMode3DWrap"))

(define LoadBSPFile      (foreign-lambda c-pointer "LoadBSPFile" c-string))
(define GetBSPModelCount (foreign-lambda int "GetBSPModelCount" c-pointer))
(define GetBSPModel      (foreign-lambda c-pointer "GetBSPModel" c-pointer int))
(define UnloadBSPFile    (foreign-lambda void "UnloadBSPFile" c-pointer))
(define DrawModelPtr     (foreign-lambda void "DrawModelPtr" c-pointer))

(define (pointer-null? p) (eq? p #f))

(define (main)
  (let* ((w 1024) (h 768)
         (bsp-file "/Users/al/src/bspCrunch/level.bsp"))  ; temporarily absolute
    (InitWindow w h "Chicken FFI - BSP Viewer")
    (SetTargetFPS 60)
    (let ((bsp (LoadBSPFile bsp-file)))
      (if (pointer-null? bsp)
          (letrec ((loop
                    (lambda ()
                      (if (WindowShouldClose)
                          (CloseWindow)
                          (begin
                            (BeginDrawing)
                            (ClearBackgroundWhite)
                            (DrawTextWhite "Failed to load BSP file!" 10 10 20)
                            (DrawTextWhite bsp-file 10 40 20)
                            (DrawTextWhite "Press ESC to exit" 10 70 20)
                            (EndDrawing)
                            (loop))))))
            (loop))
          (let ((count (GetBSPModelCount bsp)))
            (letrec ((loop
                      (lambda ()
                        (if (WindowShouldClose)
                            (begin
                              (UnloadBSPFile bsp)
                              (CloseWindow))
                            (begin
                              (BeginDrawing)
                              (ClearBackgroundWhite)
                              (UpdateAndBeginCamera)
                              (let model-loop ((i 0))
                                (when (< i count)
                                  (let ((mp (GetBSPModel bsp i)))
                                    (DrawModelPtr mp))
                                  (model-loop (+ i 1))))
                              (DrawGrid 10 1.0)
                              (EndMode3DWrap)
                              (DrawTextWhite "Chicken FFI BSP Viewer" 10 10 20)
                              (DrawTextWhite (string-append "Models: " (number->string count)) 10 40 20)
                              (EndDrawing)
                              (loop))))))
              (loop)))))))

(main)