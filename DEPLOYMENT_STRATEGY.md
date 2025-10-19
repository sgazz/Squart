# 🚀 Deployment Strategy - Squart Web Edition

Kompletna strategija za deployment web verzije sa multiplayer funkcionalnostima.

**Datum:** Oktobar 2025  
**Status:** 🚧 Implementation Ready

---

## 🎯 Deployment Overview

### Multi-Phase Deployment Strategy
1. **Phase 1:** MVP Web Release (PWA)
2. **Phase 2:** Multiplayer Beta
3. **Phase 3:** Production Release
4. **Phase 4:** Scaling & Monitoring

---

## 📋 Phase 1: MVP Web Release (2-3 dana)

### 1.1 Frontend Deployment (Firebase Hosting)

```bash
# Firebase Hosting Setup
npm install -g firebase-tools
firebase login
firebase init hosting

# Project Configuration
firebase use --add squart-web
firebase target:apply hosting squart-web squart-game
```

**Firebase Configuration:**
```json
// firebase.json
{
  "hosting": {
    "target": "squart-web",
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "/sw.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      },
      {
        "source": "/manifest.json",
        "headers": [
          {
            "key": "Content-Type",
            "value": "application/manifest+json"
          }
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 1.2 Build & Deploy Script

```bash
#!/bin/bash
# deploy_web.sh

echo "🚀 Deploying Squart Web MVP..."

# Clean and build
flutter clean
flutter pub get
flutter build web --release

# Copy PWA files
cp web/sw.js build/web/
cp web/manifest.json build/web/
cp -r web/icons build/web/

# Deploy to Firebase
firebase deploy --only hosting

echo "✅ Web MVP deployed successfully!"
echo "🌐 URL: https://squart-game.web.app"
```

### 1.3 Domain Configuration

```bash
# Custom domain setup
firebase hosting:channel:deploy live --project squart-game

# Add custom domain
firebase hosting:sites:create squart-game
firebase target:apply hosting squart-game squart-game
```

**Domain Setup:**
- **Primary:** `squart.game`
- **Backup:** `squart-game.web.app`
- **SSL:** Automatic (Firebase managed)

---

## 🎮 Phase 2: Multiplayer Backend (3-4 dana)

### 2.1 Backend Infrastructure

```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/squart
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - mongo
      - redis
    restart: unless-stopped

  mongo:
    image: mongo:5.0
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

  redis:
    image: redis:7.0
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  mongo_data:
  redis_data:
```

### 2.2 Heroku Deployment

```bash
# Heroku setup
heroku create squart-backend
heroku addons:create mongolab:sandbox
heroku addons:create heroku-redis:mini

# Environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-secret-key
heroku config:set FRONTEND_URL=https://squart.game

# Deploy
git push heroku main
```

**Heroku Configuration:**
```json
// package.json
{
  "name": "squart-backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest"
  },
  "engines": {
    "node": "18.x"
  },
  "dependencies": {
    "express": "^4.18.0",
    "socket.io": "^4.7.0",
    "mongoose": "^7.5.0",
    "redis": "^4.6.0",
    "jsonwebtoken": "^9.0.0",
    "cors": "^2.8.5",
    "helmet": "^7.0.0"
  }
}
```

### 2.3 Database Setup

```javascript
// backend/config/database.js
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
```

---

## 🌐 Phase 3: Production Release (2-3 dana)

### 3.1 Production Infrastructure

```yaml
# Production Architecture
Frontend (Firebase Hosting):
  - CDN: Global distribution
  - SSL: Automatic HTTPS
  - Caching: Optimized headers
  - Domain: squart.game

Backend (Heroku):
  - API: REST + WebSocket
  - Database: MongoDB Atlas
  - Cache: Redis Cloud
  - Monitoring: Heroku metrics

Database (MongoDB Atlas):
  - Cluster: M0 (Free tier)
  - Backup: Automated
  - Security: IP whitelist
  - Monitoring: Atlas metrics
```

### 3.2 CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Build web
        run: flutter build web --release

  deploy-frontend:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build web
        run: flutter build web --release
        
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: squart-game

  deploy-backend:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "squart-backend"
          heroku_email: "your-email@example.com"
```

### 3.3 Environment Configuration

```bash
# Production Environment Variables
# Frontend (Firebase)
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=squart.game
FIREBASE_PROJECT_ID=squart-game
FIREBASE_STORAGE_BUCKET=squart-game.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef

# Backend (Heroku)
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://...
REDIS_URL=redis://...
JWT_SECRET=your-production-secret
FRONTEND_URL=https://squart.game
CORS_ORIGIN=https://squart.game
```

---

## 📊 Phase 4: Monitoring & Analytics (1-2 dana)

### 4.1 Monitoring Setup

```javascript
// backend/middleware/monitoring.js
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');

// Security headers
app.use(helmet());

// Request logging
app.use(morgan('combined'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
  });
});

// Error monitoring
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});
```

### 4.2 Analytics Integration

```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static void initialize() {
    if (kIsWeb) {
      // Google Analytics 4
      _initializeGA4();
      
      // Firebase Analytics
      _initializeFirebaseAnalytics();
    }
  }
  
  static void _initializeGA4() {
    // GA4 configuration
    js.context.callMethod('gtag', ['config', 'GA_MEASUREMENT_ID']);
  }
  
  static void trackEvent(String eventName, Map<String, dynamic> parameters) {
    if (kIsWeb) {
      js.context.callMethod('gtag', ['event', eventName, parameters]);
    }
  }
  
  static void trackPageView(String pageName) {
    trackEvent('page_view', {'page_title': pageName});
  }
  
  static void trackGameStart() {
    trackEvent('game_start', {
      'game_type': 'single_player',
      'board_size': '7x7',
    });
  }
  
  static void trackMultiplayerGame() {
    trackEvent('multiplayer_game_start', {
      'game_type': 'multiplayer',
      'room_id': 'generated_room_id',
    });
  }
}
```

### 4.3 Performance Monitoring

```javascript
// backend/middleware/performance.js
const performanceMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
    
    // Send to monitoring service
    if (duration > 1000) {
      console.warn(`Slow request: ${req.url} took ${duration}ms`);
    }
  });
  
  next();
};

module.exports = performanceMiddleware;
```

---

## 🔧 Development Tools

### 5.1 Local Development

```bash
#!/bin/bash
# start_dev.sh

echo "🚀 Starting Squart development environment..."

# Start backend
cd backend
npm install
npm run dev &
BACKEND_PID=$!

# Start frontend
cd ../frontend
flutter pub get
flutter run -d web-server --web-port 8080 &
FRONTEND_PID=$!

echo "✅ Development environment started!"
echo "🌐 Frontend: http://localhost:8080"
echo "🔧 Backend: http://localhost:3000"

# Wait for user input to stop
read -p "Press Enter to stop development environment..."

# Kill processes
kill $BACKEND_PID $FRONTEND_PID
echo "🛑 Development environment stopped"
```

### 5.2 Testing Scripts

```bash
#!/bin/bash
# test_all.sh

echo "🧪 Running all tests..."

# Frontend tests
echo "Testing Flutter app..."
flutter test

# Backend tests
echo "Testing Node.js backend..."
cd backend
npm test
cd ..

# Integration tests
echo "Running integration tests..."
npm run test:integration

echo "✅ All tests completed!"
```

### 5.3 Build Scripts

```bash
#!/bin/bash
# build_all.sh

echo "🔨 Building all platforms..."

# Web build
echo "Building web version..."
flutter build web --release

# Copy PWA files
cp web/sw.js build/web/
cp web/manifest.json build/web/
cp -r web/icons build/web/

# Backend build
echo "Building backend..."
cd backend
npm run build
cd ..

echo "✅ All builds completed!"
```

---

## 📈 Scaling Strategy

### 6.1 Horizontal Scaling

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=${MONGODB_URI}
      - REDIS_URL=${REDIS_URL}
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
    restart: unless-stopped
```

### 6.2 Load Balancing

```nginx
# nginx.conf
upstream backend {
    server backend:3000;
    server backend:3000;
    server backend:3000;
}

server {
    listen 80;
    server_name squart.game;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /socket.io/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🛡️ Security & Compliance

### 7.1 Security Headers

```javascript
// backend/middleware/security.js
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://squart.game"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

### 7.2 Rate Limiting

```javascript
// backend/middleware/rateLimit.js
const rateLimit = require('express-rate-limit');

const gameLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts, please try again later.',
});

app.use('/api/games', gameLimiter);
app.use('/api/auth', authLimiter);
```

---

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] ✅ All tests passing
- [ ] ✅ Build successful
- [ ] ✅ Environment variables configured
- [ ] ✅ Database migrations applied
- [ ] ✅ SSL certificates valid
- [ ] ✅ Domain DNS configured

### Post-Deployment
- [ ] ✅ Health checks passing
- [ ] ✅ Monitoring alerts configured
- [ ] ✅ Analytics tracking working
- [ ] ✅ Performance metrics within limits
- [ ] ✅ Error rates acceptable
- [ ] ✅ User feedback positive

### Rollback Plan
- [ ] ✅ Previous version tagged
- [ ] ✅ Database backup available
- [ ] ✅ Rollback script tested
- [ ] ✅ Monitoring for issues
- [ ] ✅ Communication plan ready

---

## 🎯 Success Metrics

### Technical Metrics
- **Uptime:** 99.9%
- **Response Time:** < 200ms
- **Error Rate:** < 0.1%
- **Lighthouse Score:** 90+
- **Core Web Vitals:** All green

### Business Metrics
- **User Engagement:** 5+ minutes average
- **Install Rate:** 20%+ (PWA)
- **Multiplayer Usage:** 40%+ of games
- **Retention:** 30%+ return users
- **Performance:** < 3s load time

---

**Napravljeno:** Deployment Strategy Plan  
**Datum:** Oktobar 2025  
**Status:** Ready for Implementation 🚀
