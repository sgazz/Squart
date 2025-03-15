import numpy as np
from typing import List, Tuple
from game import SquartGame

class DataGenerator:
    def __init__(self, num_games: int = 1000):
        self.num_games = num_games
        
    def generate_training_data(self) -> Tuple[List[np.ndarray], List[float]]:
        """Генерише податке за тренирање играњем случајних игара"""
        states = []
        outcomes = []
        
        for _ in range(self.num_games):
            game_states, winner = self._play_random_game()
            
            # За сваку позицију у игри, додајемо стање и исход
            for state in game_states:
                states.append(state)
                outcomes.append(1.0 if winner == 2 else -1.0 if winner == 3 else 0.0)
                
        return states, outcomes
    
    def _play_random_game(self) -> Tuple[List[np.ndarray], int]:
        """Игра једну случајну игру и враћа стања и победника"""
        game = SquartGame()
        states = []
        
        while not game.is_game_over():
            # Чувамо тренутно стање
            states.append(game.get_state())
            
            # Узимамо случајан валидан потез
            valid_moves = game.get_valid_moves()
            if not valid_moves:
                break
                
            move = valid_moves[np.random.randint(len(valid_moves))]
            game.make_move(move[0], move[1])
        
        # Победник је претходни играч (онај који је последњи одиграо потез)
        winner = 3 if game.get_current_player() == 2 else 2
        
        return states, winner 