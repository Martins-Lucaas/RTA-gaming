import os
import cv2
import mediapipe as mp
import numpy as np
from collections import deque

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

mp_hands = mp.solutions.hands
mp_draw = mp.solutions.drawing_utils
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.6
)

cap = cv2.VideoCapture(0)

history = deque(maxlen=5)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(frame_rgb)
    frame_counter = np.zeros((frame.shape[0], 300, 3), dtype=np.uint8)
    dedos_levantados = 0

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            h, w, _ = frame.shape
            pontos = [(int(lm.x * w), int(lm.y * h)) for lm in hand_landmarks.landmark]

            def dedo_totalmente_levantado(ponta, meio, base):
                return pontos[ponta][1] < pontos[meio][1] < pontos[base][1]

            if dedo_totalmente_levantado(8, 6, 5):
                dedos_levantados += 1
            if dedo_totalmente_levantado(12, 10, 9):
                dedos_levantados += 1
            if dedo_totalmente_levantado(16, 14, 13):
                dedos_levantados += 1
            if dedo_totalmente_levantado(20, 18, 17):
                dedos_levantados += 1

            polegar_levantado = abs(pontos[4][0] - pontos[2][0]) > 40 and pontos[4][1] < pontos[3][1]

            if not polegar_levantado:
                threshold_x = abs(pontos[4][0] - pontos[2][0])
                if threshold_x > 35:
                    polegar_levantado = True

            if polegar_levantado:
                dedos_levantados += 1

    history.append(dedos_levantados)

    if len(history) > 1:
        dedos_levantados = round(sum(history) / len(history))

    texto = f"{dedos_levantados} dedos levantados"
    cv2.putText(frame_counter, texto, (30, frame.shape[0] // 2), cv2.FONT_HERSHEY_SIMPLEX, 
                1, (0, 255, 0), 2, cv2.LINE_AA)

    frame_final = np.hstack((frame, frame_counter))
    cv2.imshow("-", frame_final)

    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
