#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Squart ML model training script.

This script takes JSON data exported from the Squart app and
trains a machine learning model to evaluate board positions.
"""

import os
import sys
import json
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import coremltools as ct
import argparse

# Definišemo argumente komandne linije
parser = argparse.ArgumentParser(description='Treniraj ML model za Squart')
parser.add_argument('--input', type=str, required=True, help='Putanja do JSON fajla sa trening podacima')
parser.add_argument('--output', type=str, required=True, help='Putanja za čuvanje CoreML modela')
parser.add_argument('--verbose', action='store_true', help='Prikaži detaljne informacije o treningu')

# Funkcija za konverziju stanja table u numeričke odlike (features)
def board_to_features(board_state, board_size, current_player):
    """Konvertuje stanje table u odlike za ML model."""
    # Flattened board state
    features = []
    
    # Ravnamo tablu u vektor
    flat_board = []
    for row in board_state:
        flat_board.extend(row)
    
    # Dodajemo vrednosti stanja table
    features.extend(flat_board)
    
    # Dodajemo informaciju o trenutnom igraču (1 za plavog, 2 za crvenog)
    features.append(1 if current_player == 'blue' else 2)
    
    # Dodajemo izvedene odlike
    # Broj praznih polja
    features.append(flat_board.count(0))
    
    # Broj blokiranih polja
    features.append(flat_board.count(-1))
    
    # Broj plavih polja
    features.append(flat_board.count(1))
    
    # Broj crvenih polja
    features.append(flat_board.count(2))
    
    # Dodajemo odlike za kontrolu ivica
    edge_indices = []
    # Gornja i donja ivica
    edge_indices.extend([i for i in range(board_size)])
    edge_indices.extend([i for i in range(board_size * (board_size - 1), board_size * board_size)])
    # Leva i desna ivica
    for i in range(board_size):
        edge_indices.append(i * board_size)
        edge_indices.append(i * board_size + (board_size - 1))
    
    # Broj plavih na ivicama
    blue_edge = sum(1 for i in edge_indices if i < len(flat_board) and flat_board[i] == 1)
    features.append(blue_edge)
    
    # Broj crvenih na ivicama
    red_edge = sum(1 for i in edge_indices if i < len(flat_board) and flat_board[i] == 2)
    features.append(red_edge)
    
    # Kontrola centra
    center_start = board_size // 3
    center_end = board_size - center_start
    center_indices = []
    for r in range(center_start, center_end):
        for c in range(center_start, center_end):
            center_indices.append(r * board_size + c)
    
    # Broj plavih u centru
    blue_center = sum(1 for i in center_indices if i < len(flat_board) and flat_board[i] == 1)
    features.append(blue_center)
    
    # Broj crvenih u centru
    red_center = sum(1 for i in center_indices if i < len(flat_board) and flat_board[i] == 2)
    features.append(red_center)
    
    return features

# Funkcija za učitavanje i obradu JSON fajla sa podacima
def load_training_data(json_path):
    """Učitava i obrađuje trening podatke iz JSON fajla."""
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
        
        X = []  # Odlike
        y = []  # Ciljne vrednosti
        
        for game_record in data:
            winner = game_record.get('winner')
            board_size = game_record.get('boardSize', 9)  # Default veličina 9x9
            board_states = game_record.get('boardStates', [])
            moves = game_record.get('moves', [])
            current_players = game_record.get('currentPlayers', [])
            
            # Preskačemo partije koje nemaju dovoljno podataka
            if not board_states or not current_players or len(board_states) < 2:
                continue
            
            # Obrađujemo svaki potez i procenjujemo kvalitet poteza
            for i in range(len(board_states) - 1):
                current_board = board_states[i]
                next_board = board_states[i+1]
                current_player = current_players[i]
                
                # Preskačemo ako nema dovoljno informacija
                if not current_board or not next_board or not current_player:
                    continue
                
                # Konvertujemo stanje table u odlike
                features = board_to_features(current_board, board_size, current_player)
                
                # Ako je pobednik igrač koji je napravio ovaj potez, dajemo veći skor
                is_winner_move = (current_player == winner)
                
                # Računamo skor za potez
                move_score = 1.0 if is_winner_move else -1.0
                
                # Ako je potez blizu kraja partije, ima veći značaj
                move_position = i / len(board_states)
                if move_position > 0.7:  # Poslednjih 30% poteza
                    move_score *= (1 + move_position)
                
                X.append(features)
                y.append(move_score)
        
        return np.array(X), np.array(y)
    
    except Exception as e:
        print(f"Greška pri učitavanju podataka: {e}")
        return None, None

# Glavna funkcija za trening modela
def train_model(input_path, output_path, verbose=False):
    """Trenira ML model i čuva CoreML model."""
    if verbose:
        print(f"Učitavanje podataka iz: {input_path}")
    
    # Učitavanje podataka
    X, y = load_training_data(input_path)
    
    if X is None or len(X) == 0:
        print("Nema dostupnih podataka za trening ili podaci nisu validni.")
        return False
    
    if verbose:
        print(f"Učitano {len(X)} uzoraka za trening.")
    
    # Podela na trening i test skup
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Inicijalizacija i trening modela
    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluacija modela
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)
    
    if verbose:
        print(f"Tačnost na trening skupu: {train_score:.4f}")
        print(f"Tačnost na test skupu: {test_score:.4f}")
    
    # Konverzija u CoreML format
    try:
        # Određujemo imena odlika
        feature_names = [f"cell_{i}" for i in range(X.shape[1] - 10)]
        feature_names.extend(["current_player", "empty_count", "blocked_count", 
                             "blue_count", "red_count", "blue_edge", "red_edge",
                             "blue_center", "red_center"])
        
        # Kreiramo CoreML model
        coreml_model = ct.converters.sklearn.convert(model, 
                                                     feature_names, 
                                                     "position_score")
        
        # Dodajemo metapodatke
        coreml_model.short_description = "Squart Position Evaluator"
        coreml_model.input_description["input"] = "Stanje table za Squart"
        coreml_model.output_description["position_score"] = "Ocena pozicije na tabli"
        
        # Čuvamo model
        coreml_model.save(output_path)
        
        if verbose:
            print(f"CoreML model uspešno sačuvan na: {output_path}")
        
        return True
    
    except Exception as e:
        print(f"Greška pri konverziji modela: {e}")
        return False

# Glavna funkcija
def main():
    args = parser.parse_args()
    
    # Provera da li ulazni fajl postoji
    if not os.path.exists(args.input):
        print(f"Ulazni fajl ne postoji: {args.input}")
        return 1
    
    # Kreiramo direktorijum za izlazni fajl ako ne postoji
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Treniramo model
    success = train_model(args.input, args.output, args.verbose)
    
    if success:
        print("Trening uspešno završen!")
        return 0
    else:
        print("Trening nije uspeo.")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 