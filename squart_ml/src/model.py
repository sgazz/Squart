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
        return state.flatten()
        
    def train(self, states: List[np.ndarray], outcomes: List[float]):
        X = np.array([self.prepare_input(state) for state in states])
        y = np.array(outcomes)
        
        self.model.fit(X, y)
        
    def predict(self, state: np.ndarray) -> float:
        X = self.prepare_input(state).reshape(1, -1)
        return self.model.predict(X)[0]
    
    def save(self, filename: str):
        joblib.dump(self.model, filename)
    
    def load(self, filename: str):
        self.model = joblib.load(filename)