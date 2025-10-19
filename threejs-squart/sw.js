/**
 * Service Worker for Squart PWA
 * Provides offline functionality and caching
 */

const CACHE_NAME = 'squart-v1.0.0';
const STATIC_CACHE = 'squart-static-v1';
const DYNAMIC_CACHE = 'squart-dynamic-v1';

// Files to cache for offline functionality
const STATIC_FILES = [
    '/',
    '/index.html',
    '/styles/main.css',
    '/src/main.js',
    '/src/utils/Constants.js',
    '/src/utils/Helpers.js',
    '/src/game/Cell.js',
    '/src/game/Token.js',
    '/src/game/GameLogic.js',
    '/src/game/GameBoard.js',
    '/src/audio/AudioManager.js',
    '/manifest.json',
    '/assets/icons/icon-192x192.png',
    '/assets/icons/icon-512x512.png',
    '/assets/sounds/token_place.wav',
    '/assets/sounds/win.wav',
    '/assets/sounds/lose.wav',
    '/assets/sounds/invalid.wav',
    '/assets/sounds/tick.wav'
];

// External resources to cache
const EXTERNAL_RESOURCES = [
    'https://cdnjs.cloudflare.com/ajax/libs/three.js/r158/three.min.js',
    'https://cdn.jsdelivr.net/npm/three@0.158.0/examples/js/controls/OrbitControls.js',
    'https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'
];

// Install event - cache static files
self.addEventListener('install', (event) => {
    console.log('🔧 Service Worker installing...');
    
    event.waitUntil(
        Promise.all([
            // Cache static files
            caches.open(STATIC_CACHE).then((cache) => {
                console.log('📦 Caching static files...');
                return cache.addAll(STATIC_FILES);
            }),
            
            // Cache external resources
            caches.open(DYNAMIC_CACHE).then((cache) => {
                console.log('🌐 Caching external resources...');
                return cache.addAll(EXTERNAL_RESOURCES);
            })
        ]).then(() => {
            console.log('✅ Service Worker installed successfully');
            return self.skipWaiting();
        }).catch((error) => {
            console.error('❌ Service Worker installation failed:', error);
        })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
    console.log('🚀 Service Worker activating...');
    
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
                        console.log('🗑️ Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        }).then(() => {
            console.log('✅ Service Worker activated');
            return self.clients.claim();
        })
    );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', (event) => {
    const request = event.request;
    const url = new URL(request.url);
    
    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }
    
    // Skip chrome-extension requests
    if (url.protocol === 'chrome-extension:') {
        return;
    }
    
    event.respondWith(
        caches.match(request).then((cachedResponse) => {
            // Return cached version if available
            if (cachedResponse) {
                console.log('📦 Serving from cache:', request.url);
                return cachedResponse;
            }
            
            // Otherwise, fetch from network
            return fetch(request).then((networkResponse) => {
                // Don't cache if not a valid response
                if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic') {
                    return networkResponse;
                }
                
                // Clone the response for caching
                const responseToCache = networkResponse.clone();
                
                // Cache dynamic resources
                caches.open(DYNAMIC_CACHE).then((cache) => {
                    cache.put(request, responseToCache);
                });
                
                return networkResponse;
            }).catch(() => {
                // Return offline page for navigation requests
                if (request.destination === 'document') {
                    return caches.match('/index.html');
                }
                
                // Return placeholder for other failed requests
                return new Response('Offline content not available', {
                    status: 503,
                    statusText: 'Service Unavailable',
                    headers: new Headers({
                        'Content-Type': 'text/plain'
                    })
                });
            });
        })
    );
});

// Background sync for game state
self.addEventListener('sync', (event) => {
    console.log('🔄 Background sync:', event.tag);
    
    if (event.tag === 'save-game-state') {
        event.waitUntil(saveGameState());
    }
});

// Push notifications
self.addEventListener('push', (event) => {
    console.log('📱 Push notification received');
    
    const options = {
        body: event.data ? event.data.text() : 'Nova notifikacija od Squart-a',
        icon: '/assets/icons/icon-192x192.png',
        badge: '/assets/icons/icon-72x72.png',
        vibrate: [200, 100, 200],
        data: {
            dateOfArrival: Date.now(),
            primaryKey: 1
        },
        actions: [
            {
                action: 'explore',
                title: 'Otvori igru',
                icon: '/assets/icons/action-explore.png'
            },
            {
                action: 'close',
                title: 'Zatvori',
                icon: '/assets/icons/action-close.png'
            }
        ]
    };
    
    event.waitUntil(
        self.registration.showNotification('Squart', options)
    );
});

// Notification click
self.addEventListener('notificationclick', (event) => {
    console.log('👆 Notification clicked:', event.action);
    
    event.notification.close();
    
    if (event.action === 'explore') {
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});

// Message handling
self.addEventListener('message', (event) => {
    console.log('💬 Message received:', event.data);
    
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
    
    if (event.data && event.data.type === 'SAVE_GAME_STATE') {
        saveGameStateToIndexedDB(event.data.gameState);
    }
    
    if (event.data && event.data.type === 'LOAD_GAME_STATE') {
        loadGameStateFromIndexedDB().then((gameState) => {
            event.ports[0].postMessage({ type: 'GAME_STATE_LOADED', gameState });
        });
    }
});

// Save game state function
async function saveGameState() {
    try {
        console.log('💾 Saving game state...');
        
        // Get game state from IndexedDB
        const gameState = await loadGameStateFromIndexedDB();
        
        if (gameState) {
            // Here you could sync with a server
            console.log('✅ Game state saved');
        }
    } catch (error) {
        console.error('❌ Failed to save game state:', error);
    }
}

// IndexedDB operations
function openDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open('SquartDB', 1);
        
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result);
        
        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            
            if (!db.objectStoreNames.contains('gameStates')) {
                const store = db.createObjectStore('gameStates', { keyPath: 'id' });
                store.createIndex('timestamp', 'timestamp', { unique: false });
            }
            
            if (!db.objectStoreNames.contains('settings')) {
                db.createObjectStore('settings', { keyPath: 'key' });
            }
        };
    });
}

function saveGameStateToIndexedDB(gameState) {
    return openDB().then((db) => {
        const transaction = db.transaction(['gameStates'], 'readwrite');
        const store = transaction.objectStore('gameStates');
        
        return store.put({
            id: 'current',
            gameState: gameState,
            timestamp: Date.now()
        });
    });
}

function loadGameStateFromIndexedDB() {
    return openDB().then((db) => {
        const transaction = db.transaction(['gameStates'], 'readonly');
        const store = transaction.objectStore('gameStates');
        
        return new Promise((resolve, reject) => {
            const request = store.get('current');
            request.onsuccess = () => resolve(request.result?.gameState);
            request.onerror = () => reject(request.error);
        });
    });
}

// Performance monitoring
self.addEventListener('fetch', (event) => {
    const startTime = performance.now();
    
    event.respondWith(
        (async () => {
            try {
                const response = await fetch(event.request);
                const endTime = performance.now();
                
                console.log(`⏱️ Fetch time: ${(endTime - startTime).toFixed(2)}ms for ${event.request.url}`);
                
                return response;
            } catch (error) {
                console.error('❌ Fetch failed:', error);
                throw error;
            }
        })()
    );
});

// Error handling
self.addEventListener('error', (event) => {
    console.error('❌ Service Worker error:', event.error);
});

self.addEventListener('unhandledrejection', (event) => {
    console.error('❌ Service Worker unhandled rejection:', event.reason);
});

console.log('🎮 Squart Service Worker loaded');
