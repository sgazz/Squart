/**
 * Cell class - represents a single cell on the game board
 * Ported from Flutter version with Three.js integration
 */

import { GAME_CONSTANTS } from '../utils/Constants.js';

export class Cell {
    constructor(row, col, isBlack = false, occupiedBy = null, tokenId = null) {
        this.row = row;
        this.col = col;
        this.isBlack = isBlack;
        this.occupiedBy = occupiedBy; // 'BLUE' or 'RED' or null
        this.tokenId = tokenId;
        
        // Three.js mesh for rendering
        this.mesh = null;
        this.highlightMesh = null;
        this.isHighlighted = false;
    }

    /**
     * Check if cell is available for placing a token
     */
    get isAvailable() {
        return !this.isBlack && this.occupiedBy === null;
    }

    /**
     * Check if cell is occupied by a specific player
     */
    isOccupiedBy(player) {
        return this.occupiedBy === player;
    }

    /**
     * Create a copy of this cell with modified properties
     */
    copyWith({ row, col, isBlack, occupiedBy, tokenId }) {
        return new Cell(
            row !== undefined ? row : this.row,
            col !== undefined ? col : this.col,
            isBlack !== undefined ? isBlack : this.isBlack,
            occupiedBy !== undefined ? occupiedBy : this.occupiedBy,
            tokenId !== undefined ? tokenId : this.tokenId
        );
    }

    /**
     * Convert cell to JSON for storage
     */
    toJSON() {
        return {
            row: this.row,
            col: this.col,
            isBlack: this.isBlack,
            occupiedBy: this.occupiedBy,
            tokenId: this.tokenId
        };
    }

    /**
     * Create cell from JSON
     */
    static fromJSON(json) {
        return new Cell(
            json.row,
            json.col,
            json.isBlack || false,
            json.occupiedBy || null,
            json.tokenId || null
        );
    }

    /**
     * Get cell color based on state
     */
    getColor() {
        if (this.isBlack) {
            return GAME_CONSTANTS.COLORS.BLACK;
        }
        
        if (this.occupiedBy === GAME_CONSTANTS.PLAYER_BLUE) {
            return GAME_CONSTANTS.COLORS.BLUE;
        }
        
        if (this.occupiedBy === GAME_CONSTANTS.PLAYER_RED) {
            return GAME_CONSTANTS.COLORS.RED;
        }
        
        return GAME_CONSTANTS.COLORS.WHITE;
    }

    /**
     * Get cell opacity based on state
     */
    getOpacity() {
        if (this.isBlack) {
            return 0.3;
        }
        
        if (this.occupiedBy) {
            return 0.9;
        }
        
        return 0.7;
    }

    /**
     * Get cell material properties for Three.js
     */
    getMaterialProperties() {
        const color = this.getColor();
        const opacity = this.getOpacity();
        
        return {
            color: color,
            opacity: opacity,
            transparent: opacity < 1.0,
            roughness: 0.3,
            metalness: 0.1
        };
    }

    /**
     * Set Three.js mesh for this cell
     */
    setMesh(mesh) {
        this.mesh = mesh;
        this.updateMeshAppearance();
    }

    /**
     * Update mesh appearance based on cell state
     */
    updateMeshAppearance() {
        if (!this.mesh) return;

        const material = this.mesh.material;
        const properties = this.getMaterialProperties();
        
        material.color.setHex(properties.color.replace('#', '0x'));
        material.opacity = properties.opacity;
        material.transparent = properties.transparent;
        material.roughness = properties.roughness;
        material.metalness = properties.metalness;
        
        // Update highlight if present
        if (this.highlightMesh) {
            this.highlightMesh.visible = this.isHighlighted;
        }
    }

    /**
     * Set highlight state
     */
    setHighlight(highlighted) {
        this.isHighlighted = highlighted;
        this.updateMeshAppearance();
    }

    /**
     * Get world position for this cell
     */
    getWorldPosition(boardSize, cellSize = GAME_CONSTANTS.UI.CELL_SIZE) {
        const centerX = (boardSize - 1) / 2;
        const centerZ = (boardSize - 1) / 2;
        
        return {
            x: (this.col - centerX) * cellSize,
            y: 0,
            z: (this.row - centerZ) * cellSize
        };
    }

    /**
     * Check if this cell is adjacent to another cell
     */
    isAdjacent(other) {
        const rowDiff = Math.abs(this.row - other.row);
        const colDiff = Math.abs(this.col - other.col);
        
        return (rowDiff === 1 && colDiff === 0) || (rowDiff === 0 && colDiff === 1);
    }

    /**
     * Get all adjacent cells (within board bounds)
     */
    getAdjacentCells(boardSize) {
        const adjacent = [];
        
        // Check all 4 directions
        const directions = [
            [-1, 0], [1, 0], [0, -1], [0, 1]
        ];
        
        for (const [rowOffset, colOffset] of directions) {
            const newRow = this.row + rowOffset;
            const newCol = this.col + colOffset;
            
            if (newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize) {
                adjacent.push({ row: newRow, col: newCol });
            }
        }
        
        return adjacent;
    }

    /**
     * Check if this cell is on the edge of the board
     */
    isOnEdge(boardSize) {
        return this.row === 0 || this.row === boardSize - 1 ||
               this.col === 0 || this.col === boardSize - 1;
    }

    /**
     * Check if this cell is in the center of the board
     */
    isInCenter(boardSize) {
        const center = Math.floor(boardSize / 2);
        const rowDistance = Math.abs(this.row - center);
        const colDistance = Math.abs(this.col - center);
        
        return rowDistance <= 1 && colDistance <= 1;
    }

    /**
     * Get strategic value of this cell position
     */
    getStrategicValue(boardSize) {
        let value = 0;
        
        // Center cells are more valuable
        if (this.isInCenter(boardSize)) {
            value += 3;
        }
        
        // Edge cells are less valuable
        if (this.isOnEdge(boardSize)) {
            value -= 1;
        }
        
        // Corners are very valuable
        if ((this.row === 0 || this.row === boardSize - 1) &&
            (this.col === 0 || this.col === boardSize - 1)) {
            value += 2;
        }
        
        return value;
    }

    /**
     * String representation
     */
    toString() {
        const status = this.isBlack ? 'BLACK' : 
                      this.occupiedBy ? `OCCUPIED(${this.occupiedBy})` : 'EMPTY';
        return `Cell(${this.row},${this.col})[${status}]`;
    }

    /**
     * Equality check
     */
    equals(other) {
        return this.row === other.row &&
               this.col === other.col &&
               this.isBlack === other.isBlack &&
               this.occupiedBy === other.occupiedBy &&
               this.tokenId === other.tokenId;
    }
}
