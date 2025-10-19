/**
 * Game Logic Service - Core game mechanics
 * Ported from Flutter version
 */

import { GAME_CONSTANTS } from '../utils/Constants.js';
import { randomInt, shuffleArray, generateId } from '../utils/Helpers.js';
import { Cell } from './Cell.js';
import { Token } from './Token.js';

export class GameLogicService {
    constructor() {
        this.random = Math.random;
    }

    /**
     * Create a new game with given settings
     */
    createNewGame(settings) {
        const board = this._generateBoard(settings.boardSize);
        return {
            settings: settings,
            board: board,
            tokens: [],
            currentPlayer: settings.startingPlayer,
            gameStatus: GAME_CONSTANTS.STATE_PLAYING,
            blueTimeRemaining: settings.timePerPlayer,
            redTimeRemaining: settings.timePerPlayer,
            winner: null,
            winReason: null,
            startedAt: new Date(),
            finishedAt: null
        };
    }

    /**
     * Generate board with black cells
     */
    _generateBoard(size) {
        // Initialize empty board
        const board = [];
        for (let row = 0; row < size; row++) {
            board[row] = [];
            for (let col = 0; col < size; col++) {
                board[row][col] = new Cell(row, col);
            }
        }

        // Calculate number of black cells (17-19% of total)
        const totalCells = size * size;
        const minBlackCells = Math.round(totalCells * GAME_CONSTANTS.MIN_BLACK_CELLS_PERCENT);
        const maxBlackCells = Math.round(totalCells * GAME_CONSTANTS.MAX_BLACK_CELLS_PERCENT);
        const blackCellsCount = minBlackCells + randomInt(0, maxBlackCells - minBlackCells);

        // Randomly place black cells
        const availablePositions = [];
        for (let row = 0; row < size; row++) {
            for (let col = 0; col < size; col++) {
                availablePositions.push([row, col]);
            }
        }

        // Shuffle and pick black cells
        shuffleArray(availablePositions);
        for (let i = 0; i < blackCellsCount && i < availablePositions.length; i++) {
            const [row, col] = availablePositions[i];
            board[row][col] = new Cell(row, col, true);
        }

        return board;
    }

    /**
     * Validate if a move is legal
     */
    isValidMove(gameState, row, col) {
        // Check if position is within bounds
        if (row < 0 || row >= gameState.board.length || col < 0 || col >= gameState.board[0].length) {
            return false;
        }

        const orientation = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
            ? GAME_CONSTANTS.ORIENTATION_HORIZONTAL
            : GAME_CONSTANTS.ORIENTATION_VERTICAL;

        return this._canPlaceToken(gameState.board, row, col, orientation, gameState.board.length);
    }

    /**
     * Check if token can be placed at position
     */
    _canPlaceToken(board, row, col, orientation, boardSize) {
        if (orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL) {
            // Check horizontal (2 cells wide)
            if (col + 1 >= boardSize) return false;
            const cell1 = board[row][col];
            const cell2 = board[row][col + 1];
            return cell1.isAvailable && cell2.isAvailable;
        } else {
            // Check vertical (2 cells tall)
            if (row + 1 >= boardSize) return false;
            const cell1 = board[row][col];
            const cell2 = board[row + 1][col];
            return cell1.isAvailable && cell2.isAvailable;
        }
    }

    /**
     * Place a token on the board
     */
    placeToken(gameState, row, col) {
        if (!this.isValidMove(gameState, row, col)) {
            throw new Error(`Invalid move at position (${row}, ${col})`);
        }

        // Create new token
        const orientation = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
            ? GAME_CONSTANTS.ORIENTATION_HORIZONTAL
            : GAME_CONSTANTS.ORIENTATION_VERTICAL;

        const token = new Token(
            generateId(),
            gameState.currentPlayer,
            orientation,
            row,
            col
        );

        // Update board
        const newBoard = this._copyBoard(gameState.board);
        const occupiedCells = token.getOccupiedCells();

        for (const { row: r, col: c } of occupiedCells) {
            newBoard[r][c] = newBoard[r][c].copyWith({
                occupiedBy: gameState.currentPlayer,
                tokenId: token.id
            });
        }

        // Add token to list
        const newTokens = [...gameState.tokens, token];

        // Switch player
        const nextPlayer = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
            ? GAME_CONSTANTS.PLAYER_RED
            : GAME_CONSTANTS.PLAYER_BLUE;

        // Check win condition (opponent has no moves)
        const newState = {
            ...gameState,
            board: newBoard,
            tokens: newTokens,
            currentPlayer: nextPlayer
        };

        // Check if next player has valid moves
        if (!this.hasValidMoves(newState)) {
            // Current player wins (they made the last valid move)
            return {
                ...newState,
                gameStatus: GAME_CONSTANTS.STATE_FINISHED,
                winner: gameState.currentPlayer,
                winReason: GAME_CONSTANTS.WIN_NO_MOVES,
                finishedAt: new Date()
            };
        }

        return newState;
    }

    /**
     * Copy board for immutability
     */
    _copyBoard(board) {
        return board.map(row => row.map(cell => cell.copyWith({})));
    }

    /**
     * Get all valid moves for current player
     */
    getValidMoves(gameState) {
        const validMoves = [];
        const orientation = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
            ? GAME_CONSTANTS.ORIENTATION_HORIZONTAL
            : GAME_CONSTANTS.ORIENTATION_VERTICAL;

        for (let row = 0; row < gameState.board.length; row++) {
            for (let col = 0; col < gameState.board[0].length; col++) {
                if (this._canPlaceToken(gameState.board, row, col, orientation, gameState.board.length)) {
                    validMoves.push([row, col]);
                }
            }
        }

        return validMoves;
    }

    /**
     * Check if current player has any valid moves
     */
    hasValidMoves(gameState) {
        return this.getValidMoves(gameState).length > 0;
    }

    /**
     * Check if game is over due to timeout
     */
    checkTimeout(gameState) {
        if (!gameState.settings.hasTimer) return gameState;
        if (gameState.gameStatus === GAME_CONSTANTS.STATE_FINISHED) return gameState;

        const currentTime = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
            ? gameState.blueTimeRemaining
            : gameState.redTimeRemaining;

        if (currentTime <= 0) {
            // Current player loses due to timeout
            const winner = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE
                ? GAME_CONSTANTS.PLAYER_RED
                : GAME_CONSTANTS.PLAYER_BLUE;

            return {
                ...gameState,
                gameStatus: GAME_CONSTANTS.STATE_FINISHED,
                winner: winner,
                winReason: GAME_CONSTANTS.WIN_TIMEOUT,
                finishedAt: new Date()
            };
        }

        return gameState;
    }

    /**
     * Update timer (decrement by 1 second)
     */
    updateTimer(gameState) {
        if (!gameState.settings.hasTimer) return gameState;
        if (gameState.gameStatus === GAME_CONSTANTS.STATE_FINISHED || 
            gameState.gameStatus === GAME_CONSTANTS.STATE_PAUSED) return gameState;

        if (gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE) {
            const newTime = Math.max(0, gameState.blueTimeRemaining - 1);
            return { ...gameState, blueTimeRemaining: newTime };
        } else {
            const newTime = Math.max(0, gameState.redTimeRemaining - 1);
            return { ...gameState, redTimeRemaining: newTime };
        }
    }

    /**
     * Pause game
     */
    pauseGame(gameState) {
        if (gameState.gameStatus === GAME_CONSTANTS.STATE_FINISHED) return gameState;
        return { ...gameState, gameStatus: GAME_CONSTANTS.STATE_PAUSED };
    }

    /**
     * Resume game
     */
    resumeGame(gameState) {
        if (gameState.gameStatus === GAME_CONSTANTS.STATE_FINISHED) return gameState;
        return { ...gameState, gameStatus: GAME_CONSTANTS.STATE_PLAYING };
    }

    /**
     * Get count of black cells on board
     */
    getBlackCellsCount(board) {
        let count = 0;
        for (const row of board) {
            for (const cell of row) {
                if (cell.isBlack) count++;
            }
        }
        return count;
    }

    /**
     * Get percentage of black cells
     */
    getBlackCellsPercentage(board) {
        const total = board.length * board.length;
        const blackCount = this.getBlackCellsCount(board);
        return blackCount / total;
    }

    /**
     * Get game statistics
     */
    getGameStats(gameState) {
        const validMoves = this.getValidMoves(gameState);
        const blackCells = this.getBlackCellsCount(gameState.board);
        const totalCells = gameState.board.length * gameState.board.length;
        
        return {
            currentPlayer: gameState.currentPlayer,
            validMoves: validMoves.length,
            blackCells: blackCells,
            blackCellsPercentage: (blackCells / totalCells * 100).toFixed(1),
            tokensPlaced: gameState.tokens.length,
            gameStatus: gameState.gameStatus,
            blueTimeRemaining: gameState.blueTimeRemaining,
            redTimeRemaining: gameState.redTimeRemaining
        };
    }

    /**
     * Check if game is finished
     */
    isGameFinished(gameState) {
        return gameState.gameStatus === GAME_CONSTANTS.STATE_FINISHED;
    }

    /**
     * Check if game is paused
     */
    isGamePaused(gameState) {
        return gameState.gameStatus === GAME_CONSTANTS.STATE_PAUSED;
    }

    /**
     * Check if game is playing
     */
    isGamePlaying(gameState) {
        return gameState.gameStatus === GAME_CONSTANTS.STATE_PLAYING;
    }

    /**
     * Get winner information
     */
    getWinner(gameState) {
        if (!this.isGameFinished(gameState)) return null;
        
        return {
            player: gameState.winner,
            reason: gameState.winReason,
            finishedAt: gameState.finishedAt
        };
    }
}
