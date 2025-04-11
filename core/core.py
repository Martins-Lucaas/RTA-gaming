import cv2
import mediapipe as mp
import pyautogui

# Inicializações do MediaPipe e pyautogui:
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

# Obter resolução da tela para mapear as coordenadas da câmera
screen_w, screen_h = pyautogui.size()

# Inicializa captura de vídeo da webcam.
cap = cv2.VideoCapture(0)

clicking = False  # Estado para monitorar se o clique já está ativo

with mp_hands.Hands(max_num_hands=1,
                    min_detection_confidence=0.5,
                    min_tracking_confidence=0.5) as hands:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Espelha a imagem para funcionar como um "espelho"
        frame = cv2.flip(frame, 1)
        
        # Converter BGR para RGB para processamento pelo MediaPipe
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False  # Melhora performance
        results = hands.process(image)
        image.flags.writeable = True
        # Converter de volta para BGR
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

        if results.multi_hand_landmarks:
            # Considera apenas a primeira mão detectada
            hand_landmarks = results.multi_hand_landmarks[0]
            
            # Desenha as landmarks na imagem para visualização
            mp_drawing.draw_landmarks(image, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            
            # Obtém as dimensões da imagem capturada
            h, w, c = image.shape
            # Localiza a ponta do dedo indicador (landmark 8)
            index_finger_tip = hand_landmarks.landmark[8]
            # Converte a posição normalizada para coordenadas da tela
            x_index = int(index_finger_tip.x * screen_w)
            y_index = int(index_finger_tip.y * screen_h)
            # Move o mouse para a posição definida
            pyautogui.moveTo(x_index, y_index)

            # Heurística para detectar punho fechado:
            # Compara a posição y dos dedos com a dos respectivos nós intermediários.
            # Nota: não estamos tratando o polegar, pois sua orientação é diferente.
            dedos_dobrados = []
            # Dedo indicador: landmark 8 (ponta) vs landmark 6 (no intermediário)
            if hand_landmarks.landmark[8].y > hand_landmarks.landmark[6].y:
                dedos_dobrados.append(True)
            else:
                dedos_dobrados.append(False)
            # Dedo médio: landmark 12 vs landmark 10
            if hand_landmarks.landmark[12].y > hand_landmarks.landmark[10].y:
                dedos_dobrados.append(True)
            else:
                dedos_dobrados.append(False)
            # Dedo anelar: landmark 16 vs landmark 14
            if hand_landmarks.landmark[16].y > hand_landmarks.landmark[14].y:
                dedos_dobrados.append(True)
            else:
                dedos_dobrados.append(False)
            # Dedo mínimo: landmark 20 vs landmark 18
            if hand_landmarks.landmark[20].y > hand_landmarks.landmark[18].y:
                dedos_dobrados.append(True)
            else:
                dedos_dobrados.append(False)

            # Se todos os dedos (exceto o polegar) estiverem dobrados, considera mão fechada
            punho_fechado = all(dedos_dobrados)

            # Controle do clique do mouse baseado no gesto
            if punho_fechado and not clicking:
                pyautogui.mouseDown()  # Pressiona o botão esquerdo do mouse
                clicking = True
            elif not punho_fechado and clicking:
                pyautogui.mouseUp()    # Libera o botão
                clicking = False

        # Exibe a imagem com as landmarks
        cv2.imshow('Controle de Mouse com Mão', image)
        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

cap.release()
cv2.destroyAllWindows()
