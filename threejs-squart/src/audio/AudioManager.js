/**
 * Audio Manager - Web Audio API integration for game sounds
 */

import { GAME_CONSTANTS } from '../utils/Constants.js';
import { AudioContextManager } from '../utils/Helpers.js';

export class AudioManager {
    constructor() {
        this.sounds = new Map();
        this.isEnabled = true;
        this.volume = 0.7;
        this.context = null;
        this.isInitialized = false;
        
        // Audio files to load
        this.soundFiles = {
            [GAME_CONSTANTS.SOUND_FILES.TOKEN_PLACE]: 'assets/sounds/token_place.wav',
            [GAME_CONSTANTS.SOUND_FILES.WIN]: 'assets/sounds/win.wav',
            [GAME_CONSTANTS.SOUND_FILES.LOSE]: 'assets/sounds/lose.wav',
            [GAME_CONSTANTS.SOUND_FILES.INVALID]: 'assets/sounds/invalid.wav',
            [GAME_CONSTANTS.SOUND_FILES.TICK]: 'assets/sounds/tick.wav'
        };
    }

    /**
     * Initialize audio manager
     */
    async init() {
        try {
            this.context = AudioContextManager.getContext();
            await this.loadSounds();
            this.isInitialized = true;
            console.log('🔊 Audio Manager initialized');
        } catch (error) {
            console.warn('⚠️ Audio initialization failed:', error);
            this.isInitialized = false;
        }
    }

    /**
     * Load all sound files
     */
    async loadSounds() {
        const loadPromises = Object.entries(this.soundFiles).map(([key, url]) => 
            this.loadSound(key, url)
        );
        
        await Promise.all(loadPromises);
    }

    /**
     * Load individual sound file
     */
    async loadSound(key, url) {
        try {
            const response = await fetch(url);
            const arrayBuffer = await response.arrayBuffer();
            const audioBuffer = await this.context.decodeAudioData(arrayBuffer);
            
            this.sounds.set(key, audioBuffer);
            console.log(`🔊 Loaded sound: ${key}`);
        } catch (error) {
            console.warn(`⚠️ Failed to load sound ${key}:`, error);
        }
    }

    /**
     * Play a sound
     */
    playSound(soundKey, volume = 1.0, pitch = 1.0) {
        if (!this.isEnabled || !this.isInitialized) return;
        
        const audioBuffer = this.sounds.get(soundKey);
        if (!audioBuffer) {
            console.warn(`⚠️ Sound not found: ${soundKey}`);
            return;
        }

        try {
            // Resume audio context if suspended
            if (this.context.state === 'suspended') {
                AudioContextManager.resume();
            }

            const source = this.context.createBufferSource();
            const gainNode = this.context.createGain();
            
            source.buffer = audioBuffer;
            source.playbackRate.value = pitch;
            
            gainNode.gain.value = this.volume * volume;
            
            source.connect(gainNode);
            gainNode.connect(this.context.destination);
            
            source.start();
            
            console.log(`🔊 Playing sound: ${soundKey}`);
        } catch (error) {
            console.warn(`⚠️ Failed to play sound ${soundKey}:`, error);
        }
    }

    /**
     * Play token placement sound
     */
    playTokenPlace() {
        this.playSound(GAME_CONSTANTS.SOUND_FILES.TOKEN_PLACE, 0.8);
    }

    /**
     * Play win sound
     */
    playWin() {
        this.playSound(GAME_CONSTANTS.SOUND_FILES.WIN, 1.0);
    }

    /**
     * Play lose sound
     */
    playLose() {
        this.playSound(GAME_CONSTANTS.SOUND_FILES.LOSE, 1.0);
    }

    /**
     * Play invalid move sound
     */
    playInvalid() {
        this.playSound(GAME_CONSTANTS.SOUND_FILES.INVALID, 0.6);
    }

    /**
     * Play timer tick sound
     */
    playTick() {
        this.playSound(GAME_CONSTANTS.SOUND_FILES.TICK, 0.4);
    }

    /**
     * Set volume (0.0 to 1.0)
     */
    setVolume(volume) {
        this.volume = Math.max(0, Math.min(1, volume));
    }

    /**
     * Get current volume
     */
    getVolume() {
        return this.volume;
    }

    /**
     * Enable/disable audio
     */
    setEnabled(enabled) {
        this.isEnabled = enabled;
    }

    /**
     * Check if audio is enabled
     */
    isAudioEnabled() {
        return this.isEnabled;
    }

    /**
     * Play random pitch variation of a sound
     */
    playSoundWithVariation(soundKey, baseVolume = 1.0) {
        const pitch = 0.8 + Math.random() * 0.4; // Random pitch between 0.8 and 1.2
        this.playSound(soundKey, baseVolume, pitch);
    }

    /**
     * Create audio context warning handler
     */
    setupAudioContextWarning() {
        const warningElement = document.getElementById('audio-warning');
        if (!warningElement) return;

        // Show warning initially
        warningElement.classList.remove('hidden');

        // Hide warning on first user interaction
        const hideWarning = () => {
            warningElement.classList.add('hidden');
            AudioContextManager.resume();
            document.removeEventListener('click', hideWarning);
            document.removeEventListener('touchstart', hideWarning);
            document.removeEventListener('keydown', hideWarning);
        };

        document.addEventListener('click', hideWarning);
        document.addEventListener('touchstart', hideWarning);
        document.addEventListener('keydown', hideWarning);
    }

    /**
     * Dispose of audio resources
     */
    dispose() {
        this.sounds.clear();
        this.isInitialized = false;
        
        if (this.context && this.context.state !== 'closed') {
            this.context.close();
        }
    }
}

// Create global instance
export const audioManager = new AudioManager();
