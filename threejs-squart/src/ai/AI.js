/**
 * AI System for Squart Game
 * Implements different difficulty levels with strategic gameplay
 */

import { GAME_CONSTANTS, AI_STRATEGIES } from '../utils/Constants.js';
import { randomInt, shuffleArray } from '../utils/Helpers.js';

export class AI {
    constructor(difficulty = GAME_CONSTANTS.AI_MEDIUM) {
        this.difficulty = difficulty;
        this.strategy = AI_STRATEGIES[difficulty] || AI_STRATEGIES.MEDIUM;
    }

    /**
     * Make AI move based on current game state
     */
    async makeMove(gameState, gameLogic) {
        // Simulate thinking delay
        await this.think();
        
        const validMoves = gameLogic.getValidMoves(gameState);
        
        if (validMoves.length === 0) {
            return null; // No valid moves
        }
        
        let selectedMove;
        
        switch (this.difficulty) {
            case GAME_CONSTANTS.AI_EASY:
                selectedMove = this.makeEasyMove(validMoves, gameState);
                break;
            case GAME_CONSTANTS.AI_MEDIUM:
                selectedMove = this.makeMediumMove(validMoves, gameState, gameLogic);
                break;
            case GAME_CONSTANTS.AI_HARD:
                selectedMove = this.makeHardMove(validMoves, gameState, gameLogic);
                break;
            case GAME_CONSTANTS.AI_EXPERT:
                selectedMove = this.makeExpertMove(validMoves, gameState, gameLogic);
                break;
            default:
                selectedMove = this.makeMediumMove(validMoves, gameState, gameLogic);
        }
        
        return selectedMove;
    }

    /**
     * Easy AI - mostly random moves
     */
    makeEasyMove(validMoves, gameState) {
        if (Math.random() < this.strategy.randomMoveChance) {
            return validMoves[randomInt(0, validMoves.length - 1)];
        }
        
        // Simple center preference
        return this.selectBestMoveByStrategy(validMoves, gameState, {
            centerPreference: this.strategy.centerPreference,
            edgeAvoidance: this.strategy.edgeAvoidance,
            blockingWeight: 0.1
        });
    }

    /**
     * Medium AI - basic strategy
     */
    makeMediumMove(validMoves, gameState, gameLogic) {
        if (Math.random() < this.strategy.randomMoveChance) {
            return validMoves[randomInt(0, validMoves.length - 1)];
        }
        
        return this.selectBestMoveByStrategy(validMoves, gameState, {
            centerPreference: this.strategy.centerPreference,
            edgeAvoidance: this.strategy.edgeAvoidance,
            blockingWeight: this.strategy.blockingWeight
        });
    }

    /**
     * Hard AI - advanced strategy
     */
    makeHardMove(validMoves, gameState, gameLogic) {
        if (Math.random() < this.strategy.randomMoveChance) {
            return validMoves[randomInt(0, validMoves.length - 1)];
        }
        
        // Look ahead one move
        const bestMove = this.minimax(gameState, gameLogic, 1, true);
        return bestMove.move || this.selectBestMoveByStrategy(validMoves, gameState, this.strategy);
    }

    /**
     * Expert AI - minimax with alpha-beta pruning
     */
    makeExpertMove(validMoves, gameState, gameLogic) {
        const depth = this.strategy.lookAheadDepth || 3;
        const result = this.minimax(gameState, gameLogic, depth, true);
        return result.move || this.selectBestMoveByStrategy(validMoves, gameState, this.strategy);
    }

    /**
     * Minimax algorithm with alpha-beta pruning
     */
    minimax(gameState, gameLogic, depth, isMaximizing, alpha = -Infinity, beta = Infinity) {
        // Base cases
        if (depth === 0 || gameLogic.isGameFinished(gameState)) {
            return {
                score: this.evaluatePosition(gameState, gameLogic),
                move: null
            };
        }
        
        const validMoves = gameLogic.getValidMoves(gameState);
        
        if (isMaximizing) {
            let maxEval = -Infinity;
            let bestMove = null;
            
            for (const move of validMoves) {
                const newState = gameLogic.placeToken(gameState, move[0], move[1]);
                const eval = this.minimax(newState, gameLogic, depth - 1, false, alpha, beta);
                
                if (eval.score > maxEval) {
                    maxEval = eval.score;
                    bestMove = move;
                }
                
                alpha = Math.max(alpha, eval.score);
                if (beta <= alpha) {
                    break; // Alpha-beta pruning
                }
            }
            
            return { score: maxEval, move: bestMove };
        } else {
            let minEval = Infinity;
            let bestMove = null;
            
            for (const move of validMoves) {
                const newState = gameLogic.placeToken(gameState, move[0], move[1]);
                const eval = this.minimax(newState, gameLogic, depth - 1, true, alpha, beta);
                
                if (eval.score < minEval) {
                    minEval = eval.score;
                    bestMove = move;
                }
                
                beta = Math.min(beta, eval.score);
                if (beta <= alpha) {
                    break; // Alpha-beta pruning
                }
            }
            
            return { score: minEval, move: bestMove };
        }
    }

    /**
     * Evaluate current game position
     */
    evaluatePosition(gameState, gameLogic) {
        const validMoves = gameLogic.getValidMoves(gameState);
        
        // Base score from valid moves count
        let score = validMoves.length * 10;
        
        // Center control bonus
        score += this.evaluateCenterControl(gameState, validMoves);
        
        // Edge control penalty
        score -= this.evaluateEdgeControl(gameState, validMoves);
        
        // Blocking opponent moves
        score += this.evaluateBlocking(gameState, gameLogic);
        
        // Positional value
        score += this.evaluatePositionalValue(gameState, validMoves);
        
        return score;
    }

    /**
     * Evaluate center control
     */
    evaluateCenterControl(gameState, validMoves) {
        const boardSize = gameState.board.length;
        const center = Math.floor(boardSize / 2);
        
        let centerScore = 0;
        
        validMoves.forEach(([row, col]) => {
            const distanceFromCenter = Math.abs(row - center) + Math.abs(col - center);
            centerScore += (boardSize - distanceFromCenter) * 2;
        });
        
        return centerScore;
    }

    /**
     * Evaluate edge control (avoid edges)
     */
    evaluateEdgeControl(gameState, validMoves) {
        const boardSize = gameState.board.length;
        let edgeScore = 0;
        
        validMoves.forEach(([row, col]) => {
            if (row === 0 || row === boardSize - 1 || col === 0 || col === boardSize - 1) {
                edgeScore += 5; // Penalty for edge moves
            }
        });
        
        return edgeScore;
    }

    /**
     * Evaluate blocking opponent moves
     */
    evaluateBlocking(gameState, gameLogic) {
        // This would require simulating opponent moves
        // For now, return a simple heuristic
        return 0;
    }

    /**
     * Evaluate positional value of moves
     */
    evaluatePositionalValue(gameState, validMoves) {
        let positionalScore = 0;
        
        validMoves.forEach(([row, col]) => {
            // Corner moves are valuable
            const boardSize = gameState.board.length;
            if ((row === 0 || row === boardSize - 1) && (col === 0 || col === boardSize - 1)) {
                positionalScore += 15;
            }
            
            // Near-center moves are valuable
            const center = Math.floor(boardSize / 2);
            const distanceFromCenter = Math.abs(row - center) + Math.abs(col - center);
            if (distanceFromCenter <= 1) {
                positionalScore += 10;
            }
        });
        
        return positionalScore;
    }

    /**
     * Select best move based on strategy
     */
    selectBestMoveByStrategy(validMoves, gameState, strategy) {
        if (validMoves.length === 0) return null;
        
        const moveScores = validMoves.map(move => ({
            move: move,
            score: this.calculateMoveScore(move, gameState, strategy)
        }));
        
        // Sort by score (descending)
        moveScores.sort((a, b) => b.score - a.score);
        
        // Return best move, or random if tied
        const bestScore = moveScores[0].score;
        const bestMoves = moveScores.filter(m => m.score === bestScore);
        
        return bestMoves[randomInt(0, bestMoves.length - 1)].move;
    }

    /**
     * Calculate score for a specific move
     */
    calculateMoveScore(move, gameState, strategy) {
        const [row, col] = move;
        const boardSize = gameState.board.length;
        
        let score = 0;
        
        // Center preference
        if (strategy.centerPreference > 0) {
            const center = Math.floor(boardSize / 2);
            const distanceFromCenter = Math.abs(row - center) + Math.abs(col - center);
            score += (boardSize - distanceFromCenter) * strategy.centerPreference;
        }
        
        // Edge avoidance
        if (strategy.edgeAvoidance > 0) {
            if (row === 0 || row === boardSize - 1 || col === 0 || col === boardSize - 1) {
                score -= strategy.edgeAvoidance * 10;
            }
        }
        
        // Random variation
        score += (Math.random() - 0.5) * 5;
        
        return score;
    }

    /**
     * Simulate AI thinking delay
     */
    async think() {
        const delays = GAME_CONSTANTS.AI_DELAYS[this.difficulty];
        const delay = randomInt(delays.min, delays.max);
        
        return new Promise(resolve => setTimeout(resolve, delay));
    }

    /**
     * Set AI difficulty
     */
    setDifficulty(difficulty) {
        this.difficulty = difficulty;
        this.strategy = AI_STRATEGIES[difficulty] || AI_STRATEGIES.MEDIUM;
    }

    /**
     * Get AI difficulty
     */
    getDifficulty() {
        return this.difficulty;
    }

    /**
     * Get AI move description for UI
     */
    getMoveDescription(move, gameState) {
        if (!move) return "No valid moves";
        
        const [row, col] = move;
        const orientation = gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE 
            ? "horizontal" : "vertical";
        
        return `AI places ${orientation} token at position (${row}, ${col})`;
    }
}

// Create global AI instance
export const ai = new AI();
