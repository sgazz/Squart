/**
 * Utility functions for the Squart game
 */

import { GAME_CONSTANTS } from './Constants.js';

/**
 * Generate a random integer between min and max (inclusive)
 */
export function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * Shuffle an array in place using Fisher-Yates algorithm
 */
export function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}

/**
 * Deep clone an object
 */
export function deepClone(obj) {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Date) return new Date(obj.getTime());
    if (obj instanceof Array) return obj.map(item => deepClone(item));
    if (typeof obj === 'object') {
        const clonedObj = {};
        for (const key in obj) {
            if (obj.hasOwnProperty(key)) {
                clonedObj[key] = deepClone(obj[key]);
            }
        }
        return clonedObj;
    }
    return obj;
}

/**
 * Format time in MM:SS format
 */
export function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

/**
 * Check if two positions are equal
 */
export function positionsEqual(pos1, pos2) {
    return pos1[0] === pos2[0] && pos1[1] === pos2[1];
}

/**
 * Calculate distance between two 2D points
 */
export function distance2D(x1, y1, x2, y2) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    return Math.sqrt(dx * dx + dy * dy);
}

/**
 * Linear interpolation between two values
 */
export function lerp(start, end, factor) {
    return start + (end - start) * factor;
}

/**
 * Clamp a value between min and max
 */
export function clamp(value, min, max) {
    return Math.min(Math.max(value, min), max);
}

/**
 * Convert degrees to radians
 */
export function degreesToRadians(degrees) {
    return degrees * (Math.PI / 180);
}

/**
 * Convert radians to degrees
 */
export function radiansToDegrees(radians) {
    return radians * (180 / Math.PI);
}

/**
 * Generate a unique ID
 */
export function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

/**
 * Debounce function to limit function calls
 */
export function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Throttle function to limit function calls
 */
export function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

/**
 * Check if device supports vibration
 */
export function supportsVibration() {
    return 'vibrate' in navigator;
}

/**
 * Trigger device vibration
 */
export function vibrate(pattern = 100) {
    if (supportsVibration()) {
        navigator.vibrate(pattern);
    }
}

/**
 * Check if device is mobile
 */
export function isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
}

/**
 * Check if device supports touch
 */
export function isTouchDevice() {
    return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
}

/**
 * Get device pixel ratio
 */
export function getPixelRatio() {
    return window.devicePixelRatio || 1;
}

/**
 * Local storage helpers with error handling
 */
export const Storage = {
    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (error) {
            console.warn('Failed to save to localStorage:', error);
            return false;
        }
    },

    get(key, defaultValue = null) {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (error) {
            console.warn('Failed to read from localStorage:', error);
            return defaultValue;
        }
    },

    remove(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (error) {
            console.warn('Failed to remove from localStorage:', error);
            return false;
        }
    },

    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (error) {
            console.warn('Failed to clear localStorage:', error);
            return false;
        }
    }
};

/**
 * Audio context helpers
 */
export class AudioContextManager {
    static instance = null;
    static context = null;

    static getInstance() {
        if (!AudioContextManager.instance) {
            AudioContextManager.instance = new AudioContextManager();
        }
        return AudioContextManager.instance;
    }

    static getContext() {
        if (!AudioContextManager.context) {
            AudioContextManager.context = new (window.AudioContext || window.webkitAudioContext)();
        }
        return AudioContextManager.context;
    }

    static resume() {
        const context = AudioContextManager.getContext();
        if (context.state === 'suspended') {
            return context.resume();
        }
        return Promise.resolve();
    }

    static suspend() {
        const context = AudioContextManager.getContext();
        if (context.state === 'running') {
            return context.suspend();
        }
        return Promise.resolve();
    }
}

/**
 * Performance monitoring
 */
export class PerformanceMonitor {
    static startTime = null;
    static marks = [];

    static start(label) {
        PerformanceMonitor.startTime = performance.now();
        PerformanceMonitor.marks.push({ label, start: PerformanceMonitor.startTime });
        console.log(`⏱️ Started: ${label}`);
    }

    static end(label) {
        const endTime = performance.now();
        const mark = PerformanceMonitor.marks.find(m => m.label === label);
        if (mark) {
            const duration = endTime - mark.start;
            console.log(`⏱️ ${label}: ${duration.toFixed(2)}ms`);
            PerformanceMonitor.marks = PerformanceMonitor.marks.filter(m => m.label !== label);
        }
    }

    static mark(label) {
        const time = performance.now();
        console.log(`📍 ${label}: ${time.toFixed(2)}ms`);
    }
}

/**
 * Error handling utilities
 */
export function handleError(error, context = 'Unknown') {
    console.error(`❌ Error in ${context}:`, error);
    
    // Could send to error reporting service here
    // Example: Sentry.captureException(error);
    
    return {
        message: error.message || 'An unknown error occurred',
        context,
        timestamp: new Date().toISOString()
    };
}

/**
 * Validation utilities
 */
export const Validator = {
    isValidPosition(row, col, boardSize) {
        return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
    },

    isValidBoardSize(size) {
        return size >= GAME_CONSTANTS.MIN_BOARD_SIZE && 
               size <= GAME_CONSTANTS.MAX_BOARD_SIZE;
    },

    isValidTimer(time) {
        return GAME_CONSTANTS.TIMER_OPTIONS.includes(time);
    },

    isValidPlayer(player) {
        return player === GAME_CONSTANTS.PLAYER_BLUE || 
               player === GAME_CONSTANTS.PLAYER_RED;
    },

    isValidOrientation(orientation) {
        return orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL ||
               orientation === GAME_CONSTANTS.ORIENTATION_VERTICAL;
    }
};

/**
 * Math utilities for game calculations
 */
export const MathUtils = {
    /**
     * Calculate center position of board
     */
    getBoardCenter(boardSize) {
        return {
            x: (boardSize - 1) / 2,
            z: (boardSize - 1) / 2
        };
    },

    /**
     * Calculate world position from board coordinates
     */
    boardToWorld(row, col, boardSize, cellSize = GAME_CONSTANTS.UI.CELL_SIZE) {
        const center = MathUtils.getBoardCenter(boardSize);
        return {
            x: (col - center.x) * cellSize,
            z: (row - center.z) * cellSize
        };
    },

    /**
     * Calculate board coordinates from world position
     */
    worldToBoard(x, z, boardSize, cellSize = GAME_CONSTANTS.UI.CELL_SIZE) {
        const center = MathUtils.getBoardCenter(boardSize);
        const col = Math.round(x / cellSize + center.x);
        const row = Math.round(z / cellSize + center.z);
        return { row, col };
    },

    /**
     * Calculate optimal camera position for board
     */
    getCameraPosition(boardSize, distance = GAME_CONSTANTS.UI.CAMERA_DISTANCE) {
        const center = MathUtils.getBoardCenter(boardSize);
        return {
            x: center.x + distance * Math.cos(degreesToRadians(45)),
            y: GAME_CONSTANTS.UI.CAMERA_HEIGHT,
            z: center.z + distance * Math.sin(degreesToRadians(45))
        };
    }
};
