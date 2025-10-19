/**
 * Token class - represents a game token placed by a player
 * Ported from Flutter version with Three.js integration
 */

import { GAME_CONSTANTS } from '../utils/Constants.js';

export class Token {
    constructor(id, player, orientation, row, col, mesh = null) {
        this.id = id;
        this.player = player; // 'BLUE' or 'RED'
        this.orientation = orientation; // 'HORIZONTAL' or 'VERTICAL'
        this.row = row; // Top-left or top cell position
        this.col = col; // Top-left or left cell position
        
        // Three.js mesh for rendering
        this.mesh = mesh;
        this.animationTween = null;
    }

    /**
     * Get all cells occupied by this token
     */
    getOccupiedCells() {
        const cells = [{ row: this.row, col: this.col }];
        
        if (this.orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL) {
            // Horizontal token occupies 2 cells side by side
            cells.push({ row: this.row, col: this.col + 1 });
        } else {
            // Vertical token occupies 2 cells one below the other
            cells.push({ row: this.row + 1, col: this.col });
        }
        
        return cells;
    }

    /**
     * Check if token occupies a specific cell
     */
    occupiesCell(row, col) {
        const occupiedCells = this.getOccupiedCells();
        return occupiedCells.some(cell => cell.row === row && cell.col === col);
    }

    /**
     * Check if token overlaps with another token
     */
    overlapsWith(other) {
        const thisCells = this.getOccupiedCells();
        const otherCells = other.getOccupiedCells();
        
        return thisCells.some(thisCell =>
            otherCells.some(otherCell =>
                thisCell.row === otherCell.row && thisCell.col === otherCell.col
            )
        );
    }

    /**
     * Get token color
     */
    getColor() {
        return this.player === GAME_CONSTANTS.PLAYER_BLUE ? 
               GAME_CONSTANTS.COLORS.BLUE : 
               GAME_CONSTANTS.COLORS.RED;
    }

    /**
     * Get token material properties for Three.js
     */
    getMaterialProperties() {
        const color = this.getColor();
        
        return {
            color: color,
            opacity: 0.9,
            transparent: true,
            roughness: 0.2,
            metalness: 0.8,
            emissive: color,
            emissiveIntensity: 0.1
        };
    }

    /**
     * Set Three.js mesh for this token
     */
    setMesh(mesh) {
        this.mesh = mesh;
        this.updateMeshAppearance();
    }

    /**
     * Update mesh appearance based on token properties
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
        material.emissive.setHex(properties.emissive.replace('#', '0x'));
        material.emissiveIntensity = properties.emissiveIntensity;
    }

    /**
     * Get world position for this token
     */
    getWorldPosition(boardSize, cellSize = GAME_CONSTANTS.UI.CELL_SIZE) {
        const centerX = (boardSize - 1) / 2;
        const centerZ = (boardSize - 1) / 2;
        
        let x, z;
        
        if (this.orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL) {
            // Center horizontally between the two cells
            x = (this.col + 0.5 - centerX) * cellSize;
            z = (this.row - centerZ) * cellSize;
        } else {
            // Center vertically between the two cells
            x = (this.col - centerX) * cellSize;
            z = (this.row + 0.5 - centerZ) * cellSize;
        }
        
        return {
            x: x,
            y: GAME_CONSTANTS.UI.TOKEN_HEIGHT / 2,
            z: z
        };
    }

    /**
     * Get token dimensions
     */
    getDimensions(cellSize = GAME_CONSTANTS.UI.CELL_SIZE) {
        if (this.orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL) {
            return {
                width: cellSize * 2 - GAME_CONSTANTS.UI.CELL_GAP,
                height: GAME_CONSTANTS.UI.TOKEN_HEIGHT,
                depth: cellSize - GAME_CONSTANTS.UI.CELL_GAP
            };
        } else {
            return {
                width: cellSize - GAME_CONSTANTS.UI.CELL_GAP,
                height: GAME_CONSTANTS.UI.TOKEN_HEIGHT,
                depth: cellSize * 2 - GAME_CONSTANTS.UI.CELL_GAP
            };
        }
    }

    /**
     * Animate token placement
     */
    animatePlacement(duration = GAME_CONSTANTS.UI.ANIMATION_DURATION) {
        if (!this.mesh) return;

        // Start from above the board
        const startY = this.mesh.position.y + 2;
        const endY = this.mesh.position.y;
        
        this.mesh.position.y = startY;
        this.mesh.rotation.x = Math.PI;
        this.mesh.scale.set(0.1, 0.1, 0.1);

        // Animate to final position
        if (this.animationTween) {
            this.animationTween.kill();
        }

        this.animationTween = gsap.to(this.mesh, {
            position: { y: endY },
            rotation: { x: 0 },
            scale: { x: 1, y: 1, z: 1 },
            duration: duration,
            ease: "back.out(1.7)",
            onComplete: () => {
                this.animationTween = null;
            }
        });
    }

    /**
     * Animate token removal
     */
    animateRemoval(duration = GAME_CONSTANTS.UI.ANIMATION_DURATION) {
        if (!this.mesh) return;

        if (this.animationTween) {
            this.animationTween.kill();
        }

        this.animationTween = gsap.to(this.mesh, {
            position: { y: this.mesh.position.y + 2 },
            rotation: { x: Math.PI },
            scale: { x: 0.1, y: 0.1, z: 0.1 },
            opacity: 0,
            duration: duration,
            ease: "back.in(1.7)",
            onComplete: () => {
                this.animationTween = null;
                if (this.mesh && this.mesh.parent) {
                    this.mesh.parent.remove(this.mesh);
                }
            }
        });
    }

    /**
     * Create a copy of this token
     */
    copy() {
        return new Token(
            this.id,
            this.player,
            this.orientation,
            this.row,
            this.col,
            this.mesh
        );
    }

    /**
     * Convert token to JSON for storage
     */
    toJSON() {
        return {
            id: this.id,
            player: this.player,
            orientation: this.orientation,
            row: this.row,
            col: this.col
        };
    }

    /**
     * Create token from JSON
     */
    static fromJSON(json) {
        return new Token(
            json.id,
            json.player,
            json.orientation,
            json.row,
            json.col
        );
    }

    /**
     * Get token type string
     */
    getTypeString() {
        return `${this.player}_${this.orientation}`;
    }

    /**
     * Check if token is valid
     */
    isValid() {
        return this.player && 
               this.orientation && 
               typeof this.row === 'number' && 
               typeof this.col === 'number' &&
               (this.player === GAME_CONSTANTS.PLAYER_BLUE || this.player === GAME_CONSTANTS.PLAYER_RED) &&
               (this.orientation === GAME_CONSTANTS.ORIENTATION_HORIZONTAL || 
                this.orientation === GAME_CONSTANTS.ORIENTATION_VERTICAL);
    }

    /**
     * String representation
     */
    toString() {
        return `Token(${this.player}, ${this.orientation}, ${this.row},${this.col})`;
    }

    /**
     * Equality check
     */
    equals(other) {
        return this.id === other.id &&
               this.player === other.player &&
               this.orientation === other.orientation &&
               this.row === other.row &&
               this.col === other.col;
    }
}
