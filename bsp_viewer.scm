(module bsp-viewer
  (init step run shutdown load-bsp models-count start-loop! stop-loop!)
  (import (scheme base) (chicken foreign) (chicken memory))
  (import (scheme write))
  (import (srfi 18))

(define render-thread #f)

(define (start-loop!)
  (unless render-thread
    (set! render-thread
      (thread-start! (make-thread
        (lambda ()
          (let loop ()
            (when (step)
              (loop))))))))
  'started)

(define (stop-loop!)
  (when render-thread
    (thread-terminate! render-thread)
    (set! render-thread #f))
  (shutdown)
  'stopped)

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
  void DrawHUD(void);
  ")

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

  (define DrawHUD           (foreign-lambda void "DrawHUD"))

  (define (pointer-null? p) (eq? p #f))

  ;; Mutable state
  (define window-initialized #f)
  (define bsp #f)
  (define model-count 0)
  (define bsp-file "./level.bsp")

  (define (models-count) model-count)

  (define (load-bsp path)
    (when bsp (UnloadBSPFile bsp) (set! bsp #f) (set! model-count 0))
    (set! bsp-file path)
    (set! bsp (LoadBSPFile bsp-file))
    (set! model-count (if (pointer-null? bsp) 0 (GetBSPModelCount bsp)))
    bsp)

  ;; init: optionally pass a path; e.g. (init "./level.bsp")
  (define (init . maybe-path)
    (unless window-initialized
      (InitWindow 1024 768 "Chicken FFI - BSP Viewer (REPL)")
      (SetTargetFPS 60)
      (set! window-initialized #t))
    (when (pair? maybe-path)
      (load-bsp (car maybe-path)))
    window-initialized)

  ;; One frame; returns #f when window closes (and calls shutdown)
  (define (step)
    (if (not window-initialized)
        (begin (display "Call (init [path]) first")(newline) #f)
        (if (WindowShouldClose)
            (begin (shutdown) #f)
            (begin
              (BeginDrawing)
              (ClearBackgroundWhite)
              (if (pointer-null? bsp)
                  (begin
                    (DrawTextWhite "No BSP loaded or failed to load" 10 10 20)
                    (DrawTextWhite bsp-file 10 40 20)
                    (DrawTextWhite "Use (load-bsp \"./level.bsp\")" 10 70 20))
                  (begin
                    (UpdateAndBeginCamera)
                    (let loop ((i 0))
                      (when (< i model-count)
                        (let ((mp (GetBSPModel bsp i)))
                          (DrawModelPtr mp))
                        (loop (+ i 1))))
                    (DrawGrid 10 1.0)
                    (EndMode3DWrap)
                    (DrawTextWhite "Chicken FFI BSP Viewer" 10 10 20)
                    (DrawTextWhite (string-append "Models: " (number->string model-count)) 10 40 20)))
                    (EndMode3DWrap)
(DrawHUD)
(DrawTextWhite "Chicken FFI BSP Viewer" 10 84 20)
(DrawTextWhite (string-append "Models: " (number->string model-count)) 10 108 20)
                (DrawHUD)
                (EndDrawing)
              #t))))

  (define (run)
    (let loop () (when (step) (loop))))

  (define (shutdown)
    (when bsp (UnloadBSPFile bsp) (set! bsp #f))
    (when window-initialized (CloseWindow) (set! window-initialized #f))))