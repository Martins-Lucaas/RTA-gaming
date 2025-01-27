#Aprendendo como constrói uma rede neural na mão.

entradas = [1.0, 2.0, 3.0, 2.5]                  #entrada em um neurônio (valores de saída de três neurônios da camada anterior)
peso1 = [0.2, 0.8, -0.5, 1.0]                    #pesos de cada neurônio.
peso2 = [0.5, -0.91, 0.26, -0.5] 
peso3 = [-0.26, -0.27, 0.17, 0.87]
pesos = [peso1, peso2, peso3] 

tendencia1 = 2.0                                   #valor de tendência
tendencia2 = 3.0
tendencia3 = 0.5
tendencias = [tendencia1, tendencia2, tendencia3]

#Formula Básica de saída: saida = (entradas * peso) + tendencia
saidas = tendencias
num_neuronio_camada_prox = 3
num_neuronio_camada_atual = 4
print

for i in range(num_neuronio_camada_prox):
    for j in range(num_neuronio_camada_atual):
        saidas[i] = saidas[i] + (entradas[j]*pesos[i][j])

print(saidas)