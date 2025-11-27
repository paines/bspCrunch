;;  raylib [core] examples - basic screen manager
;;
;;   NOTE: This example illustrates a very simple screen manager based on a states machines
;;   Example originally created with raylib 4.0, last time updated with raylib 4.0
;;
;;  Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
;;  BSD-like license that allows static linking with closed source software
;;
;;  Copyright (c) 2021-2024 Ramon Santamaria (@raysan5)
;;
;;  ported to CRUNCH by Felix L. Winkelmann
;;
;;  compile and link like this (required libraries may vary according to
;;  platform):
;;
;;  $ chicken-crunch core_basic_screen_manager.scm -o a.c
;;  $ cc a.c $(chicken-crunch -cflags) -lraylib -lm -ldl -lGl -lX11

(module main (main)

(import (scheme base))
(import (chicken syntax))                       ; for er-macro-transformer
(import (crunch c)                              ; for c-external, c-lambda
        (crunch memory)                         ; for string->pointer
        (crunch aggregate-types))               ; for define-enum
(import (except miscmacros define-enum))        ; for select, inc!

(c-include "raylib.h")  ; include raylib header

;; Bindings to raylib functions
(define InitWindow (c-external InitWindow (integer integer (pointer char)) void))
(define SetTargetFPS (c-external SetTargetFPS (integer) void))
(define WindowShouldClose (c-external WindowShouldClose () boolean))
(define IsKeyPressed (c-external IsKeyPressed (integer) boolean))
(define IsGestureDetected (c-external IsGestureDetected (integer) boolean))
(define BeginDrawing (c-external BeginDrawing () boolean))
(define EndDrawing (c-external EndDrawing () boolean))
(define ClearBackground (c-external ClearBackground (integer) boolean))
(define CloseWindow (c-external CloseWindow () void))
(define DrawText (c-external DrawText ((pointer char) integer integer integer (typename Color)) void))
(define DrawRectangle (c-external DrawRectangle (integer integer integer integer (typename Color)) void))
(define SetWindowTitle (c-external SetWindowTitle (string) void))

(define-enum game-screen (LOGO TITLE GAMEPLAY ENDING))

;; macros for easy access to constant values

(define-syntax get-constant
  (er-macro-transformer
    (lambda (x r c)
      `(,(r 'c-value) integer ,(cadr x)))))

(define-syntax get-color
  (er-macro-transformer
    (lambda (x r c)
      `(,(r 'c-value) (typename Color) ,(cadr x)))))

;; convert CRUNCH strings to char-pointers
(define (str s) (string->pointer s))

;; example to access c-structs

(declare-struct (typename Vector2)
  (x float)
  (y float))

(define-compound-accessors (typename Vector2)
  (make-Vector2 x y)
  (x get-x set-x)
  (y get-y set-y))

(define GetMousePosition (c-external GetMousePosition () (struct Vector2)))

;; main program

(define (main)
  (let ((screen-width 800)
        (screen-height 450)
        (current-screen (game-screen LOGO))
        (frames-counter 0)  ; Useful to count frames
        (KEY_ENTER (get-constant "KEY_ENTER"))
        (GESTURE_TAP (get-constant "GESTURE_TAP")))
    (InitWindow screen-width screen-height
      (str "raylib [core] example - basic screen manager"))
    (SetTargetFPS 60)               ; Set desired framerate (frames-per-second)
    (do ()
        ((WindowShouldClose)            ; Detect window close button or ESC key
          (CloseWindow))
      ;; Update
      (select current-screen
        (((game-screen LOGO))
          (inc! frames-counter)         ; Count frames
          ;; Wait for 2 seconds (120 frames) before jumping to TITLE screen
          (when (> frames-counter 120)
            (set! current-screen (game-screen TITLE))))
        (((game-screen TITLE))
                  ;; Press enter to change to GAMEPLAY screen
          (when (or (IsKeyPressed KEY_ENTER)
                            (IsGestureDetected GESTURE_TAP))
             (set! current-screen (game-screen GAMEPLAY))))
        (((game-screen GAMEPLAY))
          ;; Press enter to change to ENDING screen
          (when (or (IsKeyPressed KEY_ENTER)
                            (IsGestureDetected GESTURE_TAP))
            (set! current-screen (game-screen ENDING))))
        (((game-screen ENDING))
                  ;; Press enter to return to TITLE screen
          (when (or (IsKeyPressed KEY_ENTER)
                            (IsGestureDetected GESTURE_TAP))
            (set! current-screen (game-screen TITLE)))))

      (let* ((mousePos (GetMousePosition))
            (windowTitle (string-append "mouse x: "
                         (number->string (get-x mousePos))
                         " y:" (number->string (get-x mousePos)))))
        (SetWindowTitle (str windowTitle)))


      ;; Draw
      (BeginDrawing)
      (ClearBackground (get-color "RAYWHITE"))
      (select current-screen
        (((game-screen LOGO))
          (DrawText (str "LOGO SCREEN") 20 20 40 (get-color "LIGHTGRAY"))
          (DrawText (str "WAIT for 2 SECONDS...") 290 220 20 (get-color "GRAY")))
        (((game-screen TITLE))
          (DrawRectangle 0 0 screen-width screen-height (get-color "GREEN"))
          (DrawText (str "TITLE SCREEN") 20 20 40 (get-color "DARKGREEN"))
          (DrawText (str "PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN") 120 220 20
            (get-color "DARKGREEN")))
        (((game-screen GAMEPLAY))
          (DrawRectangle 0 0 screen-width screen-height (get-color "PURPLE"))
          (DrawText (str "GAMEPLAY SCREEN") 20 20 40 (get-color "MAROON"))
          (DrawText (str "PRESS ENTER or TAP to JUMP to ENDING SCREEN") 130 220 20
            (get-color "MAROON")))
        (((game-screen ENDING))
          (DrawRectangle 0 0 screen-width screen-height (get-color "BLUE"))
          (DrawText (str "ENDING SCREEN") 20 20 40 (get-color "DARKBLUE"))
          (DrawText (str "PRESS ENTER or TAP to RETURN to TITLE SCREEN") 120 220 20
            (get-color "DARKBLUE"))))
       (EndDrawing))))

)