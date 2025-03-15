import numpy as np
from sklearn.neural_network import MLPRegressor
from typing import List, Tuple
import joblib

class SquartModel:
    def __init__(self):
        self.model = MLPRegressor(
            hidden_layer_sizes=(128, 64),
            activation='relu',
            solver='adam',
            max_iter=1000,
            random_state=42
        )
        
    def prepare_input(self, state: np.ndarray) -> np.ndarray:
        """Припрема улазне податке за модел"""
        # Претварамо 2D таблу у 1D низ
        return state.flatten()
        
    def train(self, states: List[np.ndarray], outcomes: List[float]):
        """Тренира модел на датим подацима"""
        # Припремамо податке
        X = np.array([self.prepare_input(state) for state in states])
        y = np.array(outcomes)
        
        # Тренирамо модел
        self.model.fit(X, y)
        
    def predict(self, state: np.ndarray) -> float:
        """Предвиђа вредност за дато стање табле"""
        X = self.prepare_input(state).reshape(1, -1)
        return self.model.predict(X)[0]
    
    def save(self, filename: str):
        """Чува модел у фајл"""
        joblib.dump(self.model, filename)
    
    def load(self, filename: str):
        """Учитава модел из фајла"""
        self.model = joblib.load(filename) 