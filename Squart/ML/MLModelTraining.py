import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Conv2D, MaxPooling2D, Flatten
import json
import os
import coremltools as ct
import argparse

# Argumenti komandne linije
parser = argparse.ArgumentParser(description='Treniranje ML modela za igru Squart')
parser.add_argument('--data', type=str, required=True, help='Putanja do JSON fajla sa podacima za trening')
parser.add_argument('--output', type=str, default='SquartMLModel.mlmodel', help='Putanja za izlazni CoreML model')
parser.add_argument('--epochs', type=int, default=50, help='Broj epoha za trening')
parser.add_argument('--batch_size', type=int, default=32, help='Veličina batch-a za trening')
args = parser.parse_args()

# Učitavanje podataka iz JSON fajla
def load_data(json_path):
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    return data

# Konverzija JSON podataka u NumPy nizove
def prepare_data(data):
    X = []  # Input features (game board states)
    y = []  # Output labels (evaluation scores)
    
    for game_record in data:
        board_size = game_record['boardSize']
        moves = game_record['moves']
        winner = 1 if game_record['winner'] == 'blue' else 2
        
        # Kreiranje prazne table
        board = np.zeros((board_size, board_size))
        current_player = 1  # Blue starts
        
        # Simuliranje igre
        for i, move in enumerate(moves):
            row = move['row']
            col = move['column']
            
            # Postavljanje figure na tablu
            if current_player == 1:  # Blue player (horizontal)
                board[row][col] = 1
                if col + 1 < board_size:
                    board[row][col + 1] = 1
            else:  # Red player (vertical)
                board[row][col] = 2
                if row + 1 < board_size:
                    board[row + 1][col] = 2
            
            # Dodajemo trenutno stanje table kao primer za treniranje
            # ali samo ako nije prvi potez
            if i > 0:
                # Flatten the board as input
                board_flat = board.flatten()
                X.append(np.append(board_flat, current_player))
                
                # Izračunavanje cilja (score)
                # 1.0 ako je trenutni igrač pobednik, -1.0 ako je gubitnik, 0.0 inače
                if i == len(moves) - 1:  # Poslednji potez
                    if winner == current_player:
                        y.append(1.0)  # Pobednik
                    else:
                        y.append(-1.0)  # Gubitnik
                else:
                    # Za poteze u sredini, dajemo neutralnu vrednost sa malim pomakom ka pobedniku
                    if winner == current_player:
                        y.append(0.1)
                    else:
                        y.append(-0.1)
            
            # Promena igrača
            current_player = 3 - current_player  # Toggles between 1 and 2
    
    return np.array(X), np.array(y)

# Kreiranje modela
def create_model(input_shape):
    model = Sequential([
        Dense(128, activation='relu', input_shape=(input_shape,)),
        Dropout(0.3),
        Dense(64, activation='relu'),
        Dropout(0.3),
        Dense(32, activation='relu'),
        Dense(1, activation='tanh')  # Izlaz između -1 i 1
    ])
    
    model.compile(optimizer='adam',
                  loss='mse',
                  metrics=['mae'])
    
    return model

# Treniranje modela
def train_model(model, X, y, epochs=args.epochs, batch_size=args.batch_size):
    # Podela na trening i validacioni skup
    split_idx = int(len(X) * 0.8)
    X_train, X_val = X[:split_idx], X[split_idx:]
    y_train, y_val = y[:split_idx], y[split_idx:]
    
    # Trening
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        verbose=1
    )
    
    return history

# Konverzija u CoreML model
def convert_to_coreml(model, input_shape):
    # Definisanje ulaznih i izlaznih specifikacija
    input_spec = [
        ct.TensorType(shape=(1, input_shape), name='gameState', dtype=np.float32)
    ]
    
    # Konverzija modela
    coreml_model = ct.convert(
        model,
        inputs=input_spec,
        convert_to='mlprogram',
        minimum_deployment_target=ct.target.iOS15
    )
    
    # Dodavanje metapodataka
    coreml_model.author = 'Squart AI Team'
    coreml_model.license = 'MIT'
    coreml_model.short_description = 'A model for evaluating Squart game positions'
    coreml_model.version = '1.0'
    
    return coreml_model

# Glavna funkcija
def main():
    # Učitavanje podataka
    print("Učitavanje podataka...")
    data = load_data(args.data)
    
    # Priprema podataka
    print("Priprema podataka za trening...")
    X, y = prepare_data(data)
    
    if len(X) == 0:
        print("Greška: Nema dovoljno podataka za trening!")
        return
    
    print(f"Ukupno primera za trening: {len(X)}")
    
    # Kreiranje modela
    input_shape = X.shape[1]
    print(f"Ulazna dimenzija: {input_shape}")
    model = create_model(input_shape)
    model.summary()
    
    # Treniranje modela
    print("Započinjem trening...")
    history = train_model(model, X, y)
    
    # Konverzija u CoreML
    print("Konvertujem model u CoreML format...")
    coreml_model = convert_to_coreml(model, input_shape)
    
    # Čuvanje modela
    print(f"Čuvam model u: {args.output}")
    coreml_model.save(args.output)
    
    print("Gotovo!")

if __name__ == "__main__":
    main() 