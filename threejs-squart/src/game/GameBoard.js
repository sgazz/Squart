/**
 * GameBoard class - Three.js 3D board rendering and interaction
 */

import * as THREE from 'three';
import { GAME_CONSTANTS } from '../utils/Constants.js';
import { MathUtils, generateId } from '../utils/Helpers.js';
import { Cell } from './Cell.js';
import { Token } from './Token.js';

export class GameBoard {
    constructor(scene, boardSize = GAME_CONSTANTS.DEFAULT_BOARD_SIZE) {
        this.scene = scene;
        this.boardSize = boardSize;
        this.board = null;
        this.cells = [];
        this.tokens = [];
        this.raycaster = new THREE.Raycaster();
        this.mouse = new THREE.Vector2();
        
        // Materials
        this.cellMaterial = new THREE.MeshStandardMaterial({
            color: GAME_CONSTANTS.COLORS.WHITE,
            transparent: true,
            opacity: 0.7,
            roughness: 0.3,
            metalness: 0.1
        });
        
        this.blackCellMaterial = new THREE.MeshStandardMaterial({
            color: GAME_CONSTANTS.COLORS.BLACK,
            transparent: true,
            opacity: 0.3,
            roughness: 0.5,
            metalness: 0.0
        });
        
        this.highlightMaterial = new THREE.MeshStandardMaterial({
            color: GAME_CONSTANTS.COLORS.YELLOW,
            transparent: true,
            opacity: 0.6,
            emissive: GAME_CONSTANTS.COLORS.YELLOW,
            emissiveIntensity: 0.2
        });
        
        this.blueTokenMaterial = new THREE.MeshStandardMaterial({
            color: GAME_CONSTANTS.COLORS.BLUE,
            transparent: true,
            opacity: 0.9,
            roughness: 0.2,
            metalness: 0.8,
            emissive: GAME_CONSTANTS.COLORS.BLUE,
            emissiveIntensity: 0.1
        });
        
        this.redTokenMaterial = new THREE.MeshStandardMaterial({
            color: GAME_CONSTANTS.COLORS.RED,
            transparent: true,
            opacity: 0.9,
            roughness: 0.2,
            metalness: 0.8,
            emissive: GAME_CONSTANTS.COLORS.RED,
            emissiveIntensity: 0.1
        });
        
        this.setupBoard();
    }

    /**
     * Setup the 3D board
     */
    setupBoard() {
        // Create board group
        this.board = new THREE.Group();
        this.board.name = 'gameBoard';
        this.scene.add(this.board);

        // Create cells
        this.createCells();
        
        // Add lighting
        this.setupLighting();
        
        // Position camera
        this.setupCamera();
    }

    /**
     * Create individual cells
     */
    createCells() {
        const cellSize = GAME_CONSTANTS.UI.CELL_SIZE;
        const cellGap = GAME_CONSTANTS.UI.CELL_GAP;
        const boardHeight = GAME_CONSTANTS.UI.BOARD_HEIGHT;
        
        // Clear existing cells
        this.cells = [];
        
        for (let row = 0; row < this.boardSize; row++) {
            this.cells[row] = [];
            for (let col = 0; col < this.boardSize; col++) {
                const cell = new Cell(row, col);
                
                // Create cell geometry
                const cellGeometry = new THREE.BoxGeometry(
                    cellSize - cellGap,
                    boardHeight,
                    cellSize - cellGap
                );
                
                // Create cell mesh
                const cellMesh = new THREE.Mesh(cellGeometry, this.cellMaterial.clone());
                cellMesh.name = `cell_${row}_${col}`;
                cellMesh.userData = { cell: cell, row: row, col: col };
                
                // Position cell
                const worldPos = MathUtils.boardToWorld(row, col, this.boardSize, cellSize);
                cellMesh.position.set(worldPos.x, boardHeight / 2, worldPos.z);
                
                // Add to scene
                this.board.add(cellMesh);
                cell.setMesh(cellMesh);
                
                // Create highlight mesh
                const highlightGeometry = new THREE.BoxGeometry(
                    cellSize - cellGap + 0.1,
                    boardHeight + 0.1,
                    cellSize - cellGap + 0.1
                );
                const highlightMesh = new THREE.Mesh(highlightGeometry, this.highlightMaterial);
                highlightMesh.position.copy(cellMesh.position);
                highlightMesh.position.y += 0.05;
                highlightMesh.visible = false;
                highlightMesh.name = `highlight_${row}_${col}`;
                
                this.board.add(highlightMesh);
                cell.highlightMesh = highlightMesh;
                
                this.cells[row][col] = cell;
            }
        }
    }

    /**
     * Setup lighting for the board
     */
    setupLighting() {
        // Ambient light
        const ambientLight = new THREE.AmbientLight(0xffffff, GAME_CONSTANTS.UI.AMBIENT_LIGHT_INTENSITY);
        this.scene.add(ambientLight);
        
        // Directional light
        const directionalLight = new THREE.DirectionalLight(0xffffff, GAME_CONSTANTS.UI.LIGHT_INTENSITY);
        directionalLight.position.set(5, 10, 5);
        directionalLight.castShadow = true;
        directionalLight.shadow.mapSize.width = 2048;
        directionalLight.shadow.mapSize.height = 2048;
        directionalLight.shadow.camera.near = 0.5;
        directionalLight.shadow.camera.far = 50;
        directionalLight.shadow.camera.left = -10;
        directionalLight.shadow.camera.right = 10;
        directionalLight.shadow.camera.top = 10;
        directionalLight.shadow.camera.bottom = -10;
        this.scene.add(directionalLight);
        
        // Point light for dramatic effect
        const pointLight = new THREE.PointLight(0xffffff, 0.5, 20);
        pointLight.position.set(0, 8, 0);
        this.scene.add(pointLight);
    }

    /**
     * Setup camera positioning
     */
    setupCamera() {
        // Camera position will be set by the main game class
        // This is just a placeholder for future camera controls
    }

    /**
     * Update board with new game state
     */
    updateBoard(gameState) {
        // Update cell states
        for (let row = 0; row < this.boardSize; row++) {
            for (let col = 0; col < this.boardSize; col++) {
                const cell = this.cells[row][col];
                const gameCell = gameState.board[row][col];
                
                // Update cell properties
                cell.isBlack = gameCell.isBlack;
                cell.occupiedBy = gameCell.occupiedBy;
                cell.tokenId = gameCell.tokenId;
                
                // Update mesh appearance
                cell.updateMeshAppearance();
            }
        }
        
        // Update tokens
        this.updateTokens(gameState.tokens);
    }

    /**
     * Update tokens on the board
     */
    updateTokens(gameTokens) {
        // Remove old tokens
        this.tokens.forEach(token => {
            if (token.mesh && token.mesh.parent) {
                token.mesh.parent.remove(token.mesh);
            }
        });
        this.tokens = [];
        
        // Add new tokens
        gameTokens.forEach(gameToken => {
            const token = new Token(
                gameToken.id,
                gameToken.player,
                gameToken.orientation,
                gameToken.row,
                gameToken.col
            );
            
            this.createTokenMesh(token);
            this.tokens.push(token);
        });
    }

    /**
     * Create 3D mesh for a token
     */
    createTokenMesh(token) {
        const dimensions = token.getDimensions();
        const geometry = new THREE.BoxGeometry(dimensions.width, dimensions.height, dimensions.depth);
        
        const material = token.player === GAME_CONSTANTS.PLAYER_BLUE 
            ? this.blueTokenMaterial.clone()
            : this.redTokenMaterial.clone();
        
        const mesh = new THREE.Mesh(geometry, material);
        mesh.name = `token_${token.id}`;
        mesh.userData = { token: token };
        mesh.castShadow = true;
        mesh.receiveShadow = true;
        
        // Position token
        const worldPos = token.getWorldPosition(this.boardSize);
        mesh.position.set(worldPos.x, worldPos.y, worldPos.z);
        
        // Add to scene
        this.board.add(mesh);
        token.setMesh(mesh);
        
        // Animate placement
        token.animatePlacement();
    }

    /**
     * Handle mouse click on board
     */
    handleClick(event, camera) {
        this.updateMousePosition(event);
        this.raycaster.setFromCamera(this.mouse, camera);
        
        const intersects = this.raycaster.intersectObjects(
            this.board.children.filter(child => child.name.startsWith('cell_'))
        );
        
        if (intersects.length > 0) {
            const cellMesh = intersects[0].object;
            const cell = cellMesh.userData.cell;
            
            return {
                row: cell.row,
                col: cell.col,
                cell: cell
            };
        }
        
        return null;
    }

    /**
     * Update mouse position from event
     */
    updateMousePosition(event) {
        const rect = event.target.getBoundingClientRect();
        this.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
        this.mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
    }

    /**
     * Highlight valid moves
     */
    highlightValidMoves(validMoves) {
        // Clear all highlights
        this.clearHighlights();
        
        // Highlight valid moves
        validMoves.forEach(([row, col]) => {
            if (row >= 0 && row < this.boardSize && col >= 0 && col < this.boardSize) {
                const cell = this.cells[row][col];
                cell.setHighlight(true);
            }
        });
    }

    /**
     * Clear all highlights
     */
    clearHighlights() {
        for (let row = 0; row < this.boardSize; row++) {
            for (let col = 0; col < this.boardSize; col++) {
                this.cells[row][col].setHighlight(false);
            }
        }
    }

    /**
     * Set board size and recreate
     */
    setBoardSize(size) {
        this.boardSize = size;
        
        // Remove old board
        if (this.board) {
            this.scene.remove(this.board);
        }
        
        // Create new board
        this.setupBoard();
    }

    /**
     * Get board statistics
     */
    getBoardStats() {
        let totalCells = 0;
        let blackCells = 0;
        let occupiedCells = 0;
        
        for (let row = 0; row < this.boardSize; row++) {
            for (let col = 0; col < this.boardSize; col++) {
                const cell = this.cells[row][col];
                totalCells++;
                
                if (cell.isBlack) blackCells++;
                if (cell.occupiedBy) occupiedCells++;
            }
        }
        
        return {
            totalCells,
            blackCells,
            occupiedCells,
            availableCells: totalCells - blackCells - occupiedCells,
            blackPercentage: (blackCells / totalCells * 100).toFixed(1)
        };
    }

    /**
     * Dispose of board resources
     */
    dispose() {
        // Remove all meshes
        if (this.board) {
            this.scene.remove(this.board);
        }
        
        // Clear arrays
        this.cells = [];
        this.tokens = [];
        
        // Dispose materials
        this.cellMaterial.dispose();
        this.blackCellMaterial.dispose();
        this.highlightMaterial.dispose();
        this.blueTokenMaterial.dispose();
        this.redTokenMaterial.dispose();
    }
}
