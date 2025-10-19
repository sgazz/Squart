/**
 * Game Constants - Ported from Flutter version
 * Contains all game rules, settings, and configuration
 */

export const GAME_CONSTANTS = {
    // ========== Board Size ==========
    MIN_BOARD_SIZE: 5,
    MAX_BOARD_SIZE: 20,
    DEFAULT_BOARD_SIZE: 7,
    
    // Black cells percentage
    MIN_BLACK_CELLS_PERCENT: 0.17, // 17%
    MAX_BLACK_CELLS_PERCENT: 0.19, // 19%
    
    // ========== Players ==========
    PLAYER_BLUE: 'BLUE',
    PLAYER_RED: 'RED',
    
    // ========== Token Orientation ==========
    ORIENTATION_HORIZONTAL: 'HORIZONTAL',
    ORIENTATION_VERTICAL: 'VERTICAL',
    
    // ========== Timer Options (in seconds) ==========
    TIMER_1_MIN: 60,
    TIMER_3_MIN: 180,
    TIMER_5_MIN: 300,
    TIMER_10_MIN: 600,
    TIMER_UNLIMITED: 0, // 0 means unlimited
    
    // Timer warning thresholds
    TIMER_WARNING_THRESHOLD: 10,
    
    // Timer labels
    TIMER_LABELS: {
        60: '1 min',
        180: '3 min',
        300: '5 min',
        600: '10 min',
        0: 'Unlimited'
    },
    
    // Available timer options
    TIMER_OPTIONS: [60, 180, 300, 600, 0],
    
    // ========== AI Difficulty ==========
    AI_EASY: 'EASY',
    AI_MEDIUM: 'MEDIUM',
    AI_HARD: 'HARD',
    AI_EXPERT: 'EXPERT',
    
    AI_DIFFICULTIES: ['EASY', 'MEDIUM', 'HARD', 'EXPERT'],
    
    // AI thinking delay ranges (milliseconds)
    AI_DELAYS: {
        EASY: { min: 500, max: 1000 },
        MEDIUM: { min: 1000, max: 1500 },
        HARD: { min: 1500, max: 2000 },
        EXPERT: { min: 2000, max: 3000 }
    },
    
    // ========== Game Mode ==========
    MODE_PLAYER_VS_PLAYER: 'PVP',
    MODE_PLAYER_VS_AI: 'PVE',
    
    // ========== Storage Keys ==========
    STORAGE_KEYS: {
        CURRENT_GAME: 'current_game',
        SETTINGS: 'settings',
        THEME: 'theme',
        SHOW_HINTS: 'show_hints',
        SOUND_ENABLED: 'sound_enabled',
        VIBRATION_ENABLED: 'vibration_enabled',
        FIRST_LAUNCH: 'first_launch'
    },
    
    // ========== Game States ==========
    STATE_SETUP: 'SETUP',
    STATE_PLAYING: 'PLAYING',
    STATE_PAUSED: 'PAUSED',
    STATE_FINISHED: 'FINISHED',
    
    // ========== Win Conditions ==========
    WIN_NO_MOVES: 'NO_MOVES', // Opponent has no valid moves
    WIN_TIMEOUT: 'TIMEOUT', // Opponent ran out of time
    
    // ========== Audio Files ==========
    SOUND_FILES: {
        TOKEN_PLACE: 'assets/sounds/token_place.wav',
        WIN: 'assets/sounds/win.wav',
        LOSE: 'assets/sounds/lose.wav',
        INVALID: 'assets/sounds/invalid.wav',
        TICK: 'assets/sounds/tick.wav'
    },
    
    // ========== Colors ==========
    COLORS: {
        BLUE: '#3B82F6',
        RED: '#EF4444',
        BLACK: '#1F2937',
        WHITE: '#FFFFFF',
        GRAY: '#6B7280',
        GREEN: '#10B981',
        YELLOW: '#F59E0B',
        PURPLE: '#8B5CF6',
        INDIGO: '#6366F1'
    },
    
    // ========== UI Constants ==========
    UI: {
        CELL_SIZE: 1.0,
        CELL_GAP: 0.1,
        BOARD_HEIGHT: 0.1,
        TOKEN_HEIGHT: 0.2,
        ANIMATION_DURATION: 0.5,
        CAMERA_DISTANCE: 15,
        CAMERA_HEIGHT: 8,
        LIGHT_INTENSITY: 1.0,
        AMBIENT_LIGHT_INTENSITY: 0.4
    }
};

/**
 * Get timer label from seconds
 */
export function getTimerLabel(seconds) {
    return GAME_CONSTANTS.TIMER_LABELS[seconds] || `${Math.floor(seconds / 60)} min`;
}

/**
 * Calculate maximum board size based on screen width
 */
export function getMaxBoardSizeForScreen(screenWidth) {
    const minCellSize = 20.0;
    const boardPadding = 32.0; // 16px * 2
    const cellGap = 2.0;
    
    const availableWidth = screenWidth - boardPadding;
    const calculatedMax = Math.floor((availableWidth + cellGap) / (minCellSize + cellGap));
    
    return Math.max(GAME_CONSTANTS.MIN_BOARD_SIZE, 
                   Math.min(calculatedMax, GAME_CONSTANTS.MAX_BOARD_SIZE));
}

/**
 * Default game settings
 */
export const DEFAULT_SETTINGS = {
    boardSize: GAME_CONSTANTS.DEFAULT_BOARD_SIZE,
    timePerPlayer: GAME_CONSTANTS.TIMER_5_MIN,
    hasTimer: true,
    gameMode: GAME_CONSTANTS.MODE_PLAYER_VS_PLAYER,
    startingPlayer: GAME_CONSTANTS.PLAYER_BLUE,
    aiDifficulty: GAME_CONSTANTS.AI_MEDIUM,
    showHints: false,
    soundEnabled: true,
    vibrationEnabled: true,
    theme: 'light' // 'light' or 'dark'
};

/**
 * Tutorial slides data
 */
export const TUTORIAL_SLIDES = [
    {
        title: 'Welcome to Squart!',
        description: 'Squart is a strategic board game where two players compete to limit each other\'s moves.\nThe player who can\'t make a move loses!\nOf course, you can play against AI too!\nBoards are sized from 5×5 to 20×20.',
        icon: '🎮',
        color: '#6366F1'
    },
    {
        title: 'Blue Player - Horizontal',
        description: 'Blue player places horizontal tokens.\nThese tokens block vertical moves for the opponent.',
        icon: '➡️',
        color: '#3B82F6'
    },
    {
        title: 'Red Player - Vertical',
        description: 'Red player places vertical tokens.\nThese tokens block horizontal moves for the opponent.',
        icon: '⬇️',
        color: '#EF4444'
    },
    {
        title: 'How to Win',
        description: 'You win when your opponent has no valid moves left!\nOptional timer adds extra challenge - run out of time and you lose!',
        icon: '🏆',
        color: '#FBBF24'
    }
];

/**
 * AI strategy weights for different difficulties
 */
export const AI_STRATEGIES = {
    EASY: {
        randomMoveChance: 0.7,
        centerPreference: 0.3,
        edgeAvoidance: 0.2,
        blockingWeight: 0.1
    },
    MEDIUM: {
        randomMoveChance: 0.4,
        centerPreference: 0.4,
        edgeAvoidance: 0.3,
        blockingWeight: 0.3
    },
    HARD: {
        randomMoveChance: 0.2,
        centerPreference: 0.5,
        edgeAvoidance: 0.4,
        blockingWeight: 0.5
    },
    EXPERT: {
        randomMoveChance: 0.0,
        centerPreference: 0.6,
        edgeAvoidance: 0.5,
        blockingWeight: 0.7,
        lookAheadDepth: 3
    }
};
