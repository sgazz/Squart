/**
 * Main application entry point
 * Three.js Squart Game
 */

import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { GAME_CONSTANTS, DEFAULT_SETTINGS } from './utils/Constants.js';
import { GameLogicService } from './game/GameLogic.js';
import { GameBoard } from './game/GameBoard.js';
import { audioManager } from './audio/AudioManager.js';
import { ai } from './ai/AI.js';
import { Storage, PerformanceMonitor, MathUtils } from './utils/Helpers.js';

class SquartGame {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.gameBoard = null;
        this.gameLogic = null;
        this.gameState = null;
        this.settings = null;
        
        // UI elements
        this.loadingScreen = null;
        this.gameContainer = null;
        this.menuOverlay = null;
        this.uiOverlay = null;
        
        // Game state
        this.isGameActive = false;
        this.isPaused = false;
        this.timerInterval = null;
        this.showHints = false;
        
        // Performance
        this.clock = new THREE.Clock();
        this.frameCount = 0;
        
        this.init();
    }

    /**
     * Initialize the game
     */
    async init() {
        PerformanceMonitor.start('Game Initialization');
        
        try {
            // Setup DOM elements
            this.setupDOM();
            
            // Initialize Three.js
            this.initThreeJS();
            
            // Initialize game logic
            this.initGameLogic();
            
            // Load settings
            this.loadSettings();
            
            // Initialize audio
            await this.initAudio();
            
            // Setup event listeners
            this.setupEventListeners();
            
            // Start render loop
            this.startRenderLoop();
            
            // Show menu
            this.showMenu();
            
            PerformanceMonitor.end('Game Initialization');
            console.log('🎮 Squart Game initialized successfully!');
            
        } catch (error) {
            console.error('❌ Failed to initialize game:', error);
            this.showError('Failed to initialize game. Please refresh the page.');
        }
    }

    /**
     * Setup DOM elements
     */
    setupDOM() {
        this.loadingScreen = document.getElementById('loading-screen');
        this.gameContainer = document.getElementById('game-container');
        this.menuOverlay = document.getElementById('menu-overlay');
        this.uiOverlay = document.getElementById('ui-overlay');
        
        // Hide loading screen
        setTimeout(() => {
            if (this.loadingScreen) {
                this.loadingScreen.classList.add('hidden');
            }
        }, 1000);
    }

    /**
     * Initialize Three.js scene
     */
    initThreeJS() {
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x1a1a2e);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            75,
            window.innerWidth / window.innerHeight,
            0.1,
            1000
        );
        
        // Renderer
        this.renderer = new THREE.WebGLRenderer({
            canvas: document.getElementById('game-canvas'),
            antialias: true,
            alpha: true
        });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(window.devicePixelRatio);
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        
        // Controls
        this.controls = new OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.enableZoom = true;
        this.controls.enablePan = false;
        this.controls.minDistance = 5;
        this.controls.maxDistance = 30;
        
        // Position camera
        this.updateCameraPosition();
    }

    /**
     * Initialize game logic
     */
    initGameLogic() {
        this.gameLogic = new GameLogicService();
        this.gameBoard = new GameBoard(this.scene, this.settings?.boardSize || DEFAULT_SETTINGS.boardSize);
    }

    /**
     * Initialize audio
     */
    async initAudio() {
        try {
            await audioManager.init();
            audioManager.setupAudioContextWarning();
        } catch (error) {
            console.warn('⚠️ Audio initialization failed:', error);
        }
    }

    /**
     * Load game settings
     */
    loadSettings() {
        this.settings = Storage.get('squart_settings', DEFAULT_SETTINGS);
        console.log('⚙️ Settings loaded:', this.settings);
    }

    /**
     * Save game settings
     */
    saveSettings() {
        Storage.set('squart_settings', this.settings);
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Window resize
        window.addEventListener('resize', () => this.onWindowResize());
        
        // Canvas click
        this.renderer.domElement.addEventListener('click', (event) => this.onCanvasClick(event));
        
        // UI buttons
        this.setupUIEventListeners();
        
        // Keyboard shortcuts
        this.setupKeyboardShortcuts();
    }

    /**
     * Setup UI event listeners
     */
    setupUIEventListeners() {
        // Menu buttons
        document.getElementById('play-btn')?.addEventListener('click', () => this.startNewGame());
        document.getElementById('settings-menu-btn')?.addEventListener('click', () => this.showSettings());
        document.getElementById('tutorial-menu-btn')?.addEventListener('click', () => this.showTutorial());
        
        // Game controls
        document.getElementById('new-game-btn')?.addEventListener('click', () => this.startNewGame());
        document.getElementById('pause-btn')?.addEventListener('click', () => this.togglePause());
        document.getElementById('hint-btn')?.addEventListener('click', () => this.toggleHints());
        document.getElementById('settings-btn')?.addEventListener('click', () => this.showSettings());
        document.getElementById('theme-btn')?.addEventListener('click', () => this.toggleTheme());
        document.getElementById('tutorial-btn')?.addEventListener('click', () => this.showTutorial());
        
        // Modal close buttons
        document.getElementById('close-settings')?.addEventListener('click', () => this.hideSettings());
        document.getElementById('close-tutorial')?.addEventListener('click', () => this.hideTutorial());
        
        // Game over buttons
        document.getElementById('play-again-btn')?.addEventListener('click', () => this.startNewGame());
        document.getElementById('main-menu-btn')?.addEventListener('click', () => this.showMenu());
    }

    /**
     * Setup keyboard shortcuts
     */
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (event) => {
            if (event.target.tagName === 'INPUT') return;
            
            switch (event.key) {
                case ' ':
                    event.preventDefault();
                    this.togglePause();
                    break;
                case 'h':
                    this.toggleHints();
                    break;
                case 'n':
                    this.startNewGame();
                    break;
                case 't':
                    this.toggleTheme();
                    break;
                case 'Escape':
                    if (this.isGameActive) {
                        this.showMenu();
                    }
                    break;
            }
        });
    }

    /**
     * Start new game
     */
    startNewGame() {
        PerformanceMonitor.start('New Game');
        
        try {
            // Create new game state
            this.gameState = this.gameLogic.createNewGame(this.settings);
            
            // Update game board
            this.gameBoard.updateBoard(this.gameState);
            
            // Update UI
            this.updateUI();
            
            // Start timer if enabled
            this.startTimer();
            
            // Hide menu
            this.hideMenu();
            
            // Set game as active
            this.isGameActive = true;
            this.isPaused = false;
            
            PerformanceMonitor.end('New Game');
            console.log('🎮 New game started');
            
        } catch (error) {
            console.error('❌ Failed to start new game:', error);
        }
    }

    /**
     * Handle canvas click
     */
    onCanvasClick(event) {
        if (!this.isGameActive || this.isPaused) return;
        
        const clickResult = this.gameBoard.handleClick(event, this.camera);
        if (clickResult) {
            this.handleCellClick(clickResult.row, clickResult.col);
        }
    }

    /**
     * Handle cell click
     */
    handleCellClick(row, col) {
        try {
            // Validate move
            if (!this.gameLogic.isValidMove(this.gameState, row, col)) {
                audioManager.playInvalid();
                return;
            }
            
            // Place token
            this.gameState = this.gameLogic.placeToken(this.gameState, row, col);
            
            // Play sound
            audioManager.playTokenPlace();
            
            // Update board
            this.gameBoard.updateBoard(this.gameState);
            
            // Update UI
            this.updateUI();
            
            // Check if game is finished
            if (this.gameLogic.isGameFinished(this.gameState)) {
                this.handleGameEnd();
                return;
            }
            
            // Clear hints
            this.gameBoard.clearHighlights();
            
            // AI move if playing against AI
            if (this.gameState.settings.gameMode === GAME_CONSTANTS.MODE_PLAYER_VS_AI) {
                this.makeAIMove();
            }
            
        } catch (error) {
            console.error('❌ Failed to handle cell click:', error);
            audioManager.playInvalid();
        }
    }

    /**
     * Make AI move
     */
    async makeAIMove() {
        try {
            // Set AI difficulty
            ai.setDifficulty(this.gameState.settings.aiDifficulty);
            
            // Show AI thinking indicator
            const gameStatusEl = document.getElementById('game-status');
            if (gameStatusEl) {
                gameStatusEl.textContent = 'AI is thinking...';
            }
            
            // Make AI move
            const aiMove = await ai.makeMove(this.gameState, this.gameLogic);
            
            if (aiMove) {
                // Place AI token
                this.gameState = this.gameLogic.placeToken(this.gameState, aiMove[0], aiMove[1]);
                
                // Play sound
                audioManager.playTokenPlace();
                
                // Update board
                this.gameBoard.updateBoard(this.gameState);
                
                // Update UI
                this.updateUI();
                
                // Check if game is finished
                if (this.gameLogic.isGameFinished(this.gameState)) {
                    this.handleGameEnd();
                }
            }
            
        } catch (error) {
            console.error('❌ AI move failed:', error);
        }
    }

    /**
     * Handle game end
     */
    handleGameEnd() {
        this.isGameActive = false;
        this.stopTimer();
        
        const winner = this.gameLogic.getWinner(this.gameState);
        
        // Play appropriate sound
        if (winner.player === this.settings.startingPlayer) {
            audioManager.playWin();
        } else {
            audioManager.playLose();
        }
        
        // Show game over modal
        this.showGameOver(winner);
        
        console.log('🏆 Game ended:', winner);
    }

    /**
     * Update UI elements
     */
    updateUI() {
        if (!this.gameState) return;
        
        // Update current player
        const currentPlayerEl = document.getElementById('current-player');
        if (currentPlayerEl) {
            currentPlayerEl.textContent = this.gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE ? 'Blue Player' : 'Red Player';
            currentPlayerEl.className = `current-player ${this.gameState.currentPlayer.toLowerCase()}`;
        }
        
        // Update game status
        const gameStatusEl = document.getElementById('game-status');
        if (gameStatusEl) {
            gameStatusEl.textContent = this.isPaused ? 'Paused' : 'Game in Progress';
        }
        
        // Update timers
        this.updateTimers();
        
        // Update hints button
        const hintBtn = document.getElementById('hint-btn');
        if (hintBtn) {
            hintBtn.classList.toggle('active', this.showHints);
        }
    }

    /**
     * Update timer displays
     */
    updateTimers() {
        if (!this.gameState || !this.gameState.settings.hasTimer) return;
        
        const blueTimerEl = document.getElementById('blue-timer');
        const redTimerEl = document.getElementById('red-timer');
        
        if (blueTimerEl) {
            blueTimerEl.textContent = this.formatTime(this.gameState.blueTimeRemaining);
            blueTimerEl.parentElement.classList.toggle('warning', this.gameState.blueTimeRemaining <= GAME_CONSTANTS.TIMER_WARNING_THRESHOLD);
            blueTimerEl.parentElement.classList.toggle('danger', this.gameState.blueTimeRemaining <= 5);
        }
        
        if (redTimerEl) {
            redTimerEl.textContent = this.formatTime(this.gameState.redTimeRemaining);
            redTimerEl.parentElement.classList.toggle('warning', this.gameState.redTimeRemaining <= GAME_CONSTANTS.TIMER_WARNING_THRESHOLD);
            redTimerEl.parentElement.classList.toggle('danger', this.gameState.redTimeRemaining <= 5);
        }
    }

    /**
     * Format time as MM:SS
     */
    formatTime(seconds) {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
    }

    /**
     * Start game timer
     */
    startTimer() {
        if (!this.gameState.settings.hasTimer) return;
        
        this.timerInterval = setInterval(() => {
            this.gameState = this.gameLogic.updateTimer(this.gameState);
            this.gameState = this.gameLogic.checkTimeout(this.gameState);
            
            this.updateTimers();
            
            // Play tick sound for low time
            if (this.gameState.currentPlayer === GAME_CONSTANTS.PLAYER_BLUE && this.gameState.blueTimeRemaining <= 5) {
                audioManager.playTick();
            } else if (this.gameState.currentPlayer === GAME_CONSTANTS.PLAYER_RED && this.gameState.redTimeRemaining <= 5) {
                audioManager.playTick();
            }
            
            // Check for timeout
            if (this.gameLogic.isGameFinished(this.gameState)) {
                this.handleGameEnd();
            }
        }, 1000);
    }

    /**
     * Stop game timer
     */
    stopTimer() {
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
    }

    /**
     * Toggle pause
     */
    togglePause() {
        if (!this.isGameActive) return;
        
        this.isPaused = !this.isPaused;
        
        if (this.isPaused) {
            this.gameState = this.gameLogic.pauseGame(this.gameState);
            this.stopTimer();
        } else {
            this.gameState = this.gameLogic.resumeGame(this.gameState);
            this.startTimer();
        }
        
        this.updateUI();
    }

    /**
     * Toggle hints
     */
    toggleHints() {
        this.showHints = !this.showHints;
        
        if (this.showHints && this.gameState) {
            const validMoves = this.gameLogic.getValidMoves(this.gameState);
            this.gameBoard.highlightValidMoves(validMoves);
        } else {
            this.gameBoard.clearHighlights();
        }
        
        this.updateUI();
    }

    /**
     * Toggle theme
     */
    toggleTheme() {
        this.settings.theme = this.settings.theme === 'light' ? 'dark' : 'light';
        this.saveSettings();
        
        document.body.classList.toggle('dark-theme', this.settings.theme === 'dark');
        
        // Update scene background
        this.scene.background = new THREE.Color(this.settings.theme === 'dark' ? 0x1a1a2e : 0x87CEEB);
    }

    /**
     * Show menu
     */
    showMenu() {
        this.isGameActive = false;
        this.isPaused = false;
        this.stopTimer();
        this.gameBoard.clearHighlights();
        
        if (this.menuOverlay) {
            this.menuOverlay.style.display = 'flex';
        }
        if (this.uiOverlay) {
            this.uiOverlay.style.display = 'none';
        }
    }

    /**
     * Hide menu
     */
    hideMenu() {
        if (this.menuOverlay) {
            this.menuOverlay.style.display = 'none';
        }
        if (this.uiOverlay) {
            this.uiOverlay.style.display = 'block';
        }
    }

    /**
     * Show settings
     */
    showSettings() {
        const modal = document.getElementById('settings-modal');
        if (modal) {
            modal.classList.add('show');
        }
    }

    /**
     * Hide settings
     */
    hideSettings() {
        const modal = document.getElementById('settings-modal');
        if (modal) {
            modal.classList.remove('show');
        }
    }

    /**
     * Show tutorial
     */
    showTutorial() {
        const modal = document.getElementById('tutorial-modal');
        if (modal) {
            modal.classList.add('show');
        }
    }

    /**
     * Hide tutorial
     */
    hideTutorial() {
        const modal = document.getElementById('tutorial-modal');
        if (modal) {
            modal.classList.remove('show');
        }
    }

    /**
     * Show game over modal
     */
    showGameOver(winner) {
        const modal = document.getElementById('game-over-modal');
        const title = document.getElementById('game-over-title');
        const content = document.getElementById('game-over-content');
        
        if (modal && title && content) {
            title.textContent = winner.player === this.settings.startingPlayer ? '🎉 You Won!' : '😔 You Lost!';
            content.innerHTML = `
                <p>Game is finished!</p>
                <p>Winner: <strong>${winner.player === GAME_CONSTANTS.PLAYER_BLUE ? 'Blue' : 'Red'} Player</strong></p>
                <p>Reason: <strong>${winner.reason === GAME_CONSTANTS.WIN_NO_MOVES ? 'No more moves' : 'Time expired'}</strong></p>
            `;
            modal.classList.add('show');
        }
    }

    /**
     * Update camera position
     */
    updateCameraPosition() {
        const position = MathUtils.getCameraPosition(this.gameBoard?.boardSize || DEFAULT_SETTINGS.boardSize);
        this.camera.position.set(position.x, position.y, position.z);
        this.camera.lookAt(0, 0, 0);
        this.controls.target.set(0, 0, 0);
        this.controls.update();
    }

    /**
     * Handle window resize
     */
    onWindowResize() {
        const width = window.innerWidth;
        const height = window.innerHeight;
        
        this.camera.aspect = width / height;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(width, height);
    }

    /**
     * Start render loop
     */
    startRenderLoop() {
        const animate = () => {
            requestAnimationFrame(animate);
            
            // Update controls
            this.controls.update();
            
            // Render scene
            this.renderer.render(this.scene, this.camera);
            
            // Performance monitoring
            this.frameCount++;
            if (this.frameCount % 60 === 0) {
                PerformanceMonitor.mark(`Frame ${this.frameCount}`);
            }
        };
        
        animate();
    }

    /**
     * Show error message
     */
    showError(message) {
        console.error(message);
        // Could implement error UI here
    }
}

// Initialize game when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.squartGame = new SquartGame();
});
