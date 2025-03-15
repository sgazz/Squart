import numpy as np
from typing import Tuple, List, Optional

class SquartGame:
    def __init__(self, size: int = 7):
        self.size = size
        self.board = np.zeros((size, size), dtype=int)  # 0: празно, 1: блокирано, 2: плави, 3: црвени
        self.current_player = 2  # 2: плави, 3: црвени
        self._initialize_board()
    
    def _initialize_board(self):
        """Иницијализује таблу са блокираним пољима"""
        total_cells = self.size * self.size
        blocked_count = int(total_cells * np.random.uniform(0.17, 0.19))
        blocked_positions = np.random.choice(total_cells, blocked_count, replace=False)
        
        for pos in blocked_positions:
            row = pos // self.size
            col = pos % self.size
            self.board[row, col] = 1
    
    def is_valid_move(self, row: int, column: int) -> bool:
        """Проверава да ли је потез валидан"""
        if not (0 <= row < self.size and 0 <= column < self.size):
            return False
            
        if self.board[row, column] != 0:
            return False
            
        # Провера за плавог играча (хоризонтално)
        if self.current_player == 2:
            if column + 1 >= self.size:
                return False
            return self.board[row, column + 1] == 0
            
        # Провера за црвеног играча (вертикално)
        else:
            if row + 1 >= self.size:
                return False
            return self.board[row + 1, column] == 0
    
    def make_move(self, row: int, column: int) -> bool:
        """Прави потез на табли"""
        if not self.is_valid_move(row, column):
            return False
            
        self.board[row, column] = self.current_player
        
        if self.current_player == 2:  # Плави играч
            self.board[row, column + 1] = self.current_player
        else:  # Црвени играч
            self.board[row + 1, column] = self.current_player
            
        self.current_player = 3 if self.current_player == 2 else 2
        return True
    
    def get_valid_moves(self) -> List[Tuple[int, int]]:
        """Враћа листу свих валидних потеза"""
        valid_moves = []
        for row in range(self.size):
            for col in range(self.size):
                if self.is_valid_move(row, col):
                    valid_moves.append((row, col))
        return valid_moves
    
    def is_game_over(self) -> bool:
        """Проверава да ли је игра завршена"""
        return len(self.get_valid_moves()) == 0
    
    def get_state(self) -> np.ndarray:
        """Враћа тренутно стање табле"""
        return self.board.copy()
    
    def get_current_player(self) -> int:
        """Враћа тренутног играча"""
        return self.current_player 