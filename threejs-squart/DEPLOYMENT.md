# 🚀 Squart Three.js - Deployment Guide

Ovaj dokument objašnjava kako da deploy-ujete Squart Three.js igru na različite platforme.

## 📋 Pre-deployment Checklist

- [ ] Sve fajlove su u `threejs-squart/` direktorijumu
- [ ] Audio fajlovi su u `assets/sounds/` direktorijumu
- [ ] PWA ikone su u `assets/icons/` direktorijumu
- [ ] Service Worker je konfigurisan
- [ ] Manifest.json je validan
- [ ] Testirano na različitim browserima

## 🌐 GitHub Pages

### Korak 1: Push kod na GitHub
```bash
cd threejs-squart
git init
git add .
git commit -m "Initial commit: Squart Three.js game"
git remote add origin https://github.com/YOUR_USERNAME/squart-threejs.git
git push -u origin main
```

### Korak 2: Enable GitHub Pages
1. Idite na GitHub repository
2. Settings → Pages
3. Source: Deploy from a branch
4. Branch: main
5. Folder: / (root)
6. Save

### Korak 3: Access your game
Vaša igra će biti dostupna na: `https://YOUR_USERNAME.github.io/squart-threejs`

## ☁️ Vercel

### Korak 1: Install Vercel CLI
```bash
npm install -g vercel
```

### Korak 2: Deploy
```bash
cd threejs-squart
vercel --prod
```

### Korak 3: Custom Domain (opciono)
1. Idite na Vercel dashboard
2. Settings → Domains
3. Add custom domain

## 🔥 Netlify

### Korak 1: Install Netlify CLI
```bash
npm install -g netlify-cli
```

### Korak 2: Deploy
```bash
cd threejs-squart
netlify deploy --prod --dir .
```

### Korak 3: Drag & Drop Alternative
1. Idite na [netlify.com](https://netlify.com)
2. Drag & drop `threejs-squart` folder
3. Vaša igra će biti dostupna na random URL

## 🐳 Docker (opciono)

### Dockerfile
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Build & Run
```bash
cd threejs-squart
docker build -t squart-game .
docker run -p 8080:80 squart-game
```

## 🔧 Performance Optimization

### 1. Compress Assets
```bash
# Install compression tools
npm install -g gzip-cli

# Compress files
gzip -k assets/sounds/*.wav
gzip -k assets/icons/*.png
```

### 2. CDN Setup
Koristite CDN za external resources:
- Three.js: `https://cdnjs.cloudflare.com/ajax/libs/three.js/r158/three.min.js`
- GSAP: `https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js`

### 3. Service Worker Optimization
```javascript
// Cache strategy
const CACHE_STRATEGY = {
    STATIC: 'cache-first',
    DYNAMIC: 'network-first',
    AUDIO: 'cache-first'
};
```

## 📱 PWA Testing

### 1. Lighthouse Audit
```bash
# Install Lighthouse
npm install -g lighthouse

# Run audit
lighthouse https://your-game-url.com --view
```

### 2. PWA Checklist
- [ ] Manifest validan
- [ ] Service Worker radi
- [ ] Offline funkcionalnost
- [ ] Ikonice se prikazuju
- [ ] Install prompt radi
- [ ] Splash screen

## 🔍 Monitoring

### 1. Analytics
Dodajte Google Analytics:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### 2. Error Tracking
```javascript
// Sentry integration
import * as Sentry from "@sentry/browser";

Sentry.init({
  dsn: "YOUR_SENTRY_DSN",
  environment: "production"
});
```

## 🚨 Troubleshooting

### Common Issues

#### 1. CORS Errors
```javascript
// Add CORS headers
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});
```

#### 2. Service Worker Not Updating
```javascript
// Force update
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

#### 3. Audio Not Playing
```javascript
// Audio context activation
document.addEventListener('click', () => {
  if (audioContext.state === 'suspended') {
    audioContext.resume();
  }
});
```

## 📊 Performance Metrics

### Target Metrics
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **First Input Delay**: < 100ms
- **Cumulative Layout Shift**: < 0.1

### Monitoring Tools
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [WebPageTest](https://www.webpagetest.org/)
- [GTmetrix](https://gtmetrix.com/)

## 🔐 Security

### 1. Content Security Policy
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com;
               style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com;">
```

### 2. HTTPS Only
```javascript
// Force HTTPS
if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
  location.replace('https:' + window.location.href.substring(window.location.protocol.length));
}
```

## 📈 Scaling

### 1. CDN Setup
- CloudFlare
- AWS CloudFront
- Azure CDN

### 2. Load Balancing
- Multiple server instances
- Health checks
- Auto-scaling

## 🎯 Success Metrics

### Key Performance Indicators
- **Page Load Time**: < 3s
- **Bounce Rate**: < 40%
- **User Engagement**: > 5 minutes
- **PWA Install Rate**: > 20%
- **Mobile Performance**: 90+ Lighthouse score

---

**Deployment Status**: ✅ Ready for Production  
**Last Updated**: December 2024  
**Maintained by**: Stanko Gazza

🚀 **Happy Deploying!**
