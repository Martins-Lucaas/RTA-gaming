import cv2
import mediapipe as mp
import pyautogui
import math
import time

# Inicializa o Mediapipe Holistic para detectar pose e mãos
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(min_detection_confidence=0.8, min_tracking_confidence=0.9)
mp_draw = mp.solutions.drawing_utils

# Captura de vídeo
cap = cv2.VideoCapture(0)

# Pega tamanho da tela para mapear os movimentos da mão para o cursor
screen_width, screen_height = pyautogui.size()

# Variáveis de controle
primary_hand = None  # "left" ou "right"
selection_done = False

# Variáveis para cliques sustentados
left_button_pressed = False
right_button_pressed = False

def is_hand_closed(hand_landmarks, image_height):
    """
    Verifica se os 4 dedos (exceto o polegar) estão dobrados,
    comparando a posição do tip com a posição do PIP.
    """
    fingers = [(8, 6), (12, 10), (16, 14), (20, 18)]
    closed_count = 0
    for tip, pip in fingers:
        tip_y = hand_landmarks.landmark[tip].y * image_height
        pip_y = hand_landmarks.landmark[pip].y * image_height
        if tip_y > pip_y:  # no sistema de coordenadas da imagem, y aumenta para baixo
            closed_count += 1
    return closed_count == 4

def is_left_click(hand_landmarks, image_width, image_height):
    """
    Detecta gesto de pinça: distância entre o dedo indicador (landmark 8)
    e o polegar (landmark 4) menor que um limiar.
    """
    x1, y1 = hand_landmarks.landmark[8].x * image_width, hand_landmarks.landmark[8].y * image_height
    x2, y2 = hand_landmarks.landmark[4].x * image_width, hand_landmarks.landmark[4].y * image_height
    distance = math.hypot(x2 - x1, y2 - y1)
    return distance < 40  # limiar em pixels (pode precisar de ajuste)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)  # espelha a imagem para interação mais natural
    h, w, _ = frame.shape
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = holistic.process(frame_rgb)

    # Durante a seleção do braço primário: verifica ambas as mãos
    if not selection_done:
        hand_candidates = []
        if results.left_hand_landmarks:
            if is_hand_closed(results.left_hand_landmarks, h):
                hand_candidates.append("left")
        if results.right_hand_landmarks:
            if is_hand_closed(results.right_hand_landmarks, h):
                hand_candidates.append("right")
        if hand_candidates:
            primary_hand = hand_candidates[0]  # o primeiro que fechar a mão
            selection_done = True
            print(f"Braço primário definido: {primary_hand}")
            time.sleep(1)  # pausa breve para evitar detecção múltipla

    # Se o braço primário já foi definido, usar essa mão para controlar o mouse
    if selection_done:
        # Seleciona os landmarks da mão primária
        hand_landmarks = None
        if primary_hand == "left" and results.left_hand_landmarks:
            hand_landmarks = results.left_hand_landmarks
        elif primary_hand == "right" and results.right_hand_landmarks:
            hand_landmarks = results.right_hand_landmarks

        if hand_landmarks:
            # Movimenta o cursor: utiliza o dedo indicador (landmark 8)
            index_finger = hand_landmarks.landmark[8]
            # Mapeia as coordenadas da câmera para as coordenadas da tela
            cursor_x = int(index_finger.x * screen_width)
            cursor_y = int(index_finger.y * screen_height)
            pyautogui.moveTo(cursor_x, cursor_y, duration=0.01)

            # --- Lógica para clique direito (mão fechada) ---
            if is_hand_closed(hand_landmarks, h):
                if not right_button_pressed:
                    pyautogui.mouseDown(button='right')
                    right_button_pressed = True
                    print("Clique direito pressionado")
            else:
                if right_button_pressed:
                    pyautogui.mouseUp(button='right')
                    right_button_pressed = False
                    print("Clique direito liberado")

            # --- Lógica para clique esquerdo (pinça) ---
            if is_left_click(hand_landmarks, w, h):
                if not left_button_pressed:
                    pyautogui.mouseDown(button='left')
                    left_button_pressed = True
                    print("Clique esquerdo pressionado")
            else:
                if left_button_pressed:
                    pyautogui.mouseUp(button='left')
                    left_button_pressed = False
                    print("Clique esquerdo liberado")

            # Desenha os landmarks da mão primária para feedback visual
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_holistic.HAND_CONNECTIONS)

    # Exibe a janela com os resultados
    cv2.imshow("Controle de Mouse", frame)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
