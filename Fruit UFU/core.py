# core.py  === controlador de gestos + inicializador do jogo

import os, sys, subprocess, cv2, mediapipe as mp, pyautogui

BASE = os.path.dirname(os.path.abspath(sys.argv[0]))
GAME = os.path.join(BASE, "fruit_cutting_game.exe")
if not os.path.exists(GAME):
    sys.exit(f"[ERRO] Não achei o jogo em:\n{GAME}")

# Abre o jogo
game = subprocess.Popen(GAME)

# --- inicializa câmera -------------------------------------------------
mp_hands = mp.solutions.hands
mp_draw  = mp.solutions.drawing_utils
screen_w, screen_h = pyautogui.size()
clicking = False

# Tenta câmera 0, se falhar tenta 1
for cam_idx in (0, 1):
    cap = cv2.VideoCapture(cam_idx, cv2.CAP_DSHOW)
    if cap.isOpened():
        print(f"Usando webcam {cam_idx}")
        break
else:
    sys.exit("Nenhuma webcam disponível.")

with mp_hands.Hands(max_num_hands=1,
                    min_detection_confidence=0.5,
                    min_tracking_confidence=0.5) as hands:
    while cap.isOpened():
        ok, frame = cap.read()
        if not ok:
            break
        frame = cv2.flip(frame, 1)
        rgb   = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        res   = hands.process(rgb)

        if res.multi_hand_landmarks:
            lm = res.multi_hand_landmarks[0].landmark
            mp_draw.draw_landmarks(frame, res.multi_hand_landmarks[0],
                                   mp_hands.HAND_CONNECTIONS)

            # Move cursor
            x, y = int(lm[8].x * screen_w), int(lm[8].y * screen_h)
            pyautogui.moveTo(x, y, duration=0)

            # Punho fechado?
            fist = all(lm[i].y > lm[i-2].y for i in (8, 12, 16, 20))
            if fist and not clicking:
                pyautogui.mouseDown(); clicking = True
            elif not fist and clicking:
                pyautogui.mouseUp();   clicking = False

        cv2.imshow("Controle (Q sai)", frame)
        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

cap.release(); cv2.destroyAllWindows(); game.terminate()
